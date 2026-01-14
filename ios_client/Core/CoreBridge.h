#ifndef CoreBridge_h
#define CoreBridge_h

#ifdef __cplusplus
extern "C" {
#endif

int cpp_ping(void);
void cpp_generate_keypair(char** out_private, char** out_public);
void cpp_free_string(char* s);

// Заглушки для компиляции, пока не переписали логику
int cpp_derive_shared_secret(const char* my_private_b64, const char* peer_public_b64, char** out_shared_b64);
int cpp_encrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* plaintext, char** out_encrypted_b64);
int cpp_decrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* encrypted_b64, char** out_plaintext);

#ifdef __cplusplus
}
#endif

#endif /* CoreBridge_h */
