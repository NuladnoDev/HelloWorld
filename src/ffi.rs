use std::ffi::{CStr, CString};
use std::ptr;

use base64::{engine::general_purpose::STANDARD as BASE64, Engine};
use libc::c_char;
use x25519_dalek::PublicKey;

use crate::crypto::{CryptoService, KeyManager};
use crate::models::ChatId;

// ВАЖНО: все функции ниже предназначены для вызова из C++ через extern "C".
// Они работают только с C-строками и простыми типами.

fn cstr_to_string(ptr: *const c_char) -> Result<String, ()> {
    if ptr.is_null() {
        return Err(());
    }
    unsafe {
        CStr::from_ptr(ptr)
            .to_str()
            .map(|s| s.to_owned())
            .map_err(|_| ())
    }
}

fn string_to_c(ptr: String) -> *mut c_char {
    CString::new(ptr)
        .expect("CString::new failed")
        .into_raw()
}

#[no_mangle]
pub extern "C" fn hw_free_string(s: *mut c_char) {
    if s.is_null() {
        return;
    }
    unsafe {
        let _ = CString::from_raw(s);
    }
}

/// Генерация пары ключей пользователя.
///
/// out_private_b64 и out_public_b64 должны быть указателями на NULL,
/// функция запишет в них новые C-строки (нужно освобождать через hw_free_string).
#[no_mangle]
pub extern "C" fn hw_generate_identity_keypair(
    out_private_b64: *mut *mut c_char,
    out_public_b64: *mut *mut c_char,
) -> i32 {
    if out_private_b64.is_null() || out_public_b64.is_null() {
        return -1;
    }

    let pair = KeyManager::generate_identity_keypair();
    let private_b64 = KeyManager::export_private_key_base64(&pair);
    let public_b64 = KeyManager::public_key_base64(&pair);

    unsafe {
        ptr::write(out_private_b64, string_to_c(private_b64));
        ptr::write(out_public_b64, string_to_c(public_b64));
    }

    0
}

/// Восстановление публичного ключа из base64 и расчёт общего секрета.
///
/// my_private_b64: приватный ключ пользователя в base64.
/// peer_public_b64: публичный ключ собеседника в base64.
/// out_shared_b64: base64(32 байта общего секрета), освобождать через hw_free_string.
#[no_mangle]
pub extern "C" fn hw_derive_shared_secret(
    my_private_b64: *const c_char,
    peer_public_b64: *const c_char,
    out_shared_b64: *mut *mut c_char,
) -> i32 {
    if out_shared_b64.is_null() {
        return -1;
    }

    let my_priv_str = match cstr_to_string(my_private_b64) {
        Ok(s) => s,
        Err(_) => return -2,
    };
    let peer_pub_str = match cstr_to_string(peer_public_b64) {
        Ok(s) => s,
        Err(_) => return -3,
    };

    let pair = match KeyManager::import_private_key_base64(&my_priv_str) {
        Ok(p) => p,
        Err(_) => return -4,
    };

    let peer_pub = match KeyManager::public_key_from_base64(&peer_pub_str) {
        Ok(p) => p,
        Err(_) => return -5,
    };

    let shared = CryptoService::derive_shared_secret_from_identities(&pair, &peer_pub);
    let shared_b64 = BASE64.encode(shared);

    unsafe {
        ptr::write(out_shared_b64, string_to_c(shared_b64));
    }

    0
}

/// Шифрование сообщения.
///
/// shared_b64: base64(32 байта общего секрета).
/// chat_id: строковый идентификатор чата.
/// sender_id: строковый идентификатор отправителя.
/// plaintext: обычный текст сообщения.
/// out_encrypted_b64: результат base64(nonce + ciphertext+tag).
#[no_mangle]
pub extern "C" fn hw_encrypt_message(
    shared_b64: *const c_char,
    chat_id: *const c_char,
    sender_id: *const c_char,
    plaintext: *const c_char,
    out_encrypted_b64: *mut *mut c_char,
) -> i32 {
    if out_encrypted_b64.is_null() {
        return -1;
    }

    let shared_str = match cstr_to_string(shared_b64) {
        Ok(s) => s,
        Err(_) => return -2,
    };
    let chat_id_str = match cstr_to_string(chat_id) {
        Ok(s) => s,
        Err(_) => return -3,
    };
    let sender_id_str = match cstr_to_string(sender_id) {
        Ok(s) => s,
        Err(_) => return -4,
    };
    let plaintext_str = match cstr_to_string(plaintext) {
        Ok(s) => s,
        Err(_) => return -5,
    };

    let mut shared_bytes = [0u8; 32];
    let decoded = match BASE64.decode(shared_str) {
        Ok(b) => b,
        Err(_) => return -6,
    };
    if decoded.len() != 32 {
        return -7;
    }
    shared_bytes.copy_from_slice(&decoded);

    let chat_id_typed: ChatId = chat_id_str.clone();
    let chat_key = CryptoService::derive_chat_key(&shared_bytes, &chat_id_typed);

    let encrypted = match CryptoService::encrypt_message(
        &chat_key,
        &plaintext_str,
        &chat_id_typed,
        &sender_id_str,
    ) {
        Ok(e) => e,
        Err(_) => return -8,
    };

    unsafe {
        ptr::write(out_encrypted_b64, string_to_c(encrypted));
    }

    0
}

/// Расшифровка сообщения.
///
/// shared_b64, chat_id, sender_id аналогичны hw_encrypt_message.
/// encrypted_b64: base64(nonce + ciphertext+tag).
/// out_plaintext: расшифрованный текст.
#[no_mangle]
pub extern "C" fn hw_decrypt_message(
    shared_b64: *const c_char,
    chat_id: *const c_char,
    sender_id: *const c_char,
    encrypted_b64: *const c_char,
    out_plaintext: *mut *mut c_char,
) -> i32 {
    if out_plaintext.is_null() {
        return -1;
    }

    let shared_str = match cstr_to_string(shared_b64) {
        Ok(s) => s,
        Err(_) => return -2,
    };
    let chat_id_str = match cstr_to_string(chat_id) {
        Ok(s) => s,
        Err(_) => return -3,
    };
    let sender_id_str = match cstr_to_string(sender_id) {
        Ok(s) => s,
        Err(_) => return -4,
    };
    let encrypted_str = match cstr_to_string(encrypted_b64) {
        Ok(s) => s,
        Err(_) => return -5,
    };

    let mut shared_bytes = [0u8; 32];
    let decoded = match BASE64.decode(shared_str) {
        Ok(b) => b,
        Err(_) => return -6,
    };
    if decoded.len() != 32 {
        return -7;
    }
    shared_bytes.copy_from_slice(&decoded);

    let chat_id_typed: ChatId = chat_id_str.clone();
    let chat_key = CryptoService::derive_chat_key(&shared_bytes, &chat_id_typed);

    let decrypted = match CryptoService::decrypt_message(
        &chat_key,
        &encrypted_str,
        &chat_id_typed,
        &sender_id_str,
    ) {
        Ok(p) => p,
        Err(_) => return -8,
    };

    unsafe {
        ptr::write(out_plaintext, string_to_c(decrypted));
    }

    0
}

