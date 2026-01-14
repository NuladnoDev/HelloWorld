use std::time::{SystemTime, UNIX_EPOCH};

use base64::{engine::general_purpose::STANDARD as BASE64, Engine};
use chacha20poly1305::aead::{Aead, KeyInit, Payload};
use chacha20poly1305::{ChaCha20Poly1305, Key, Nonce};
use getrandom::getrandom;
use hkdf::Hkdf;
use sha2::Sha256;
use thiserror::Error;
use x25519_dalek::{PublicKey, StaticSecret};

use crate::models::{ChatId, UserId};

use super::key_manager::IdentityKeyPair;

// Симметричный ключ конкретного чата (получен из общего секрета + chat_id).
#[derive(Debug, Clone)]
pub struct ChatKey(pub [u8; 32]);

#[derive(Debug, Error)]
pub enum CryptoError {
    #[error("base64 error: {0}")]
    Base64(#[from] base64::DecodeError),
    #[error("aead error")]
    Aead,
}

// Основной сервис шифрования/дешифрования сообщений.
pub struct CryptoService;

impl CryptoService {
    // Считаем общий секрет в стиле Diffie-Hellman:
    // наш приватный ключ + публичный ключ собеседника -> 32 байта секрета.
    pub fn derive_shared_secret(
        my_private: &StaticSecret,
        peer_public: &PublicKey,
    ) -> [u8; 32] {
        my_private.diffie_hellman(peer_public).to_bytes()
    }

    // Удобный helper: та же операция, но берёт приватный ключ из IdentityKeyPair.
    pub fn derive_shared_secret_from_identities(
        me: &IdentityKeyPair,
        peer_public: &PublicKey,
    ) -> [u8; 32] {
        Self::derive_shared_secret(&me.private, peer_public)
    }

    // На основе общего секрета и chat_id получаем отдельный ключ для чата через HKDF.
    pub fn derive_chat_key(shared_secret: &[u8; 32], chat_id: &ChatId) -> ChatKey {
        let hk = Hkdf::<Sha256>::new(Some(chat_id.as_bytes()), shared_secret);
        let mut okm = [0u8; 32];
        hk.expand(b"chat-key", &mut okm)
            .expect("hkdf expand should not fail");
        ChatKey(okm)
    }

    // Шифруем текст сообщения для конкретного чата и отправителя.
    // Результат: base64(nonce + ciphertext+tag).
    pub fn encrypt_message(
        chat_key: &ChatKey,
        plaintext: &str,
        chat_id: &ChatId,
        sender_id: &UserId,
    ) -> Result<String, CryptoError> {
        let key = Key::from_slice(&chat_key.0);
        let cipher = ChaCha20Poly1305::new(key);

        // Случайный nonce — обеспечивает уникальность шифрования.
        let mut nonce_bytes = [0u8; 12];
        getrandom(&mut nonce_bytes).expect("random nonce");
        let nonce = Nonce::from_slice(&nonce_bytes);

        // AAD (additional authenticated data): метки чата и отправителя.
        // Они не шифруются, но защищены от подмены.
        let aad_string = format!("{chat_id}|{sender_id}");
        let payload = Payload {
            msg: plaintext.as_bytes(),
            aad: aad_string.as_bytes(),
        };

        let ciphertext = cipher
            .encrypt(nonce, payload)
            .map_err(|_| CryptoError::Aead)?;

        // Склеиваем nonce и сам зашифрованный текст в один буфер и кодируем в base64.
        let mut combined = Vec::with_capacity(12 + ciphertext.len());
        combined.extend_from_slice(&nonce_bytes);
        combined.extend_from_slice(&ciphertext);
        Ok(BASE64.encode(combined))
    }

    // Обратная операция: читаем base64, отделяем nonce и ciphertext, проверяем подпись и расшифровываем.
    pub fn decrypt_message(
        chat_key: &ChatKey,
        encrypted_payload_base64: &str,
        chat_id: &ChatId,
        sender_id: &UserId,
    ) -> Result<String, CryptoError> {
        let raw = BASE64.decode(encrypted_payload_base64)?;
        if raw.len() < 12 {
            return Err(CryptoError::Aead);
        }

        let (nonce_bytes, ciphertext) = raw.split_at(12);
        let nonce = Nonce::from_slice(nonce_bytes);

        let key = Key::from_slice(&chat_key.0);
        let cipher = ChaCha20Poly1305::new(key);

        let aad_string = format!("{chat_id}|{sender_id}");
        let payload = Payload {
            msg: ciphertext,
            aad: aad_string.as_bytes(),
        };

        let clear = cipher
            .decrypt(nonce, payload)
            .map_err(|_| CryptoError::Aead)?;
        let text = String::from_utf8_lossy(&clear).into_owned();
        Ok(text)
    }

    // Текущее время в миллисекундах — удобно для created_at_ms в сообщениях.
    pub fn now_ms() -> i64 {
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("time went backwards");
        now.as_millis() as i64
    }
}
