#include "CoreBridge.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

extern "C" {

int cpp_ping(void) {
    return 100; // Используем 100 для отличия от Rust
}

void cpp_generate_keypair(char** out_private, char** out_public) {
    const char* priv = "cpp_private_key_test_123";
    const char* pub = "cpp_public_key_test_456";
    
    *out_private = strdup(priv);
    *out_public = strdup(pub);
}

void cpp_free_string(char* s) {
    if (s) {
        free(s);
    }
}

int cpp_derive_shared_secret(const char* my_private_b64, const char* peer_public_b64, char** out_shared_b64) {
    *out_shared_b64 = strdup("cpp_shared_secret_stub");
    return 0;
}

int cpp_encrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* plaintext, char** out_encrypted_b64) {
    *out_encrypted_b64 = strdup("cpp_encrypted_stub");
    return 0;
}

int cpp_decrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* encrypted_b64, char** out_plaintext) {
    *out_plaintext = strdup("cpp_decrypted_stub");
    return 0;
}

}
