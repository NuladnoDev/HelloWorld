use base64::{engine::general_purpose::STANDARD as BASE64, Engine};
use rand_core::OsRng;
use x25519_dalek::{PublicKey, StaticSecret};

// Пара долгоживущих ключей пользователя (аналог identity key в секретных чатах).
pub struct IdentityKeyPair {
    pub private: StaticSecret,
    pub public: PublicKey,
}

pub struct KeyManager;

impl KeyManager {
    // Генерация новой пары ключей.
    // Приватный ключ остаётся только на устройстве, публичный можно отправить на сервер.
    pub fn generate_identity_keypair() -> IdentityKeyPair {
        let private = StaticSecret::new(OsRng);
        let public = PublicKey::from(&private);
        IdentityKeyPair { private, public }
    }

    // Экспорт приватного ключа в base64, чтобы сохранить бэкап (например, в зашифрованном хранилище).
    pub fn export_private_key_base64(pair: &IdentityKeyPair) -> String {
        let bytes = pair.private.to_bytes();
        BASE64.encode(bytes)
    }

    // Восстановление пары ключей из сохранённой base64-строки.
    pub fn import_private_key_base64(encoded: &str) -> Result<IdentityKeyPair, base64::DecodeError> {
        let bytes = BASE64.decode(encoded)?;
        let mut arr = [0u8; 32];
        arr.copy_from_slice(&bytes);
        let private = StaticSecret::from(arr);
        let public = PublicKey::from(&private);
        Ok(IdentityKeyPair { private, public })
    }

    // Публичный ключ в base64 — отправляем его в Supabase для обмена ключами между пользователями.
    pub fn public_key_base64(pair: &IdentityKeyPair) -> String {
        BASE64.encode(pair.public.as_bytes())
    }

    // Обратное преобразование: читаем публичный ключ другого пользователя из base64.
    pub fn public_key_from_base64(encoded: &str) -> Result<PublicKey, base64::DecodeError> {
        let bytes = BASE64.decode(encoded)?;
        let mut arr = [0u8; 32];
        arr.copy_from_slice(&bytes);
        Ok(PublicKey::from(arr))
    }
}
