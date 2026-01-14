#ifndef CoreBridge_Bridging_Header_h
#define CoreBridge_Bridging_Header_h

#import <Foundation/Foundation.h>

// Function signatures from src/ffi.rs
void hw_free_string(char* s);
int hw_generate_identity_keypair(char** out_private_b64, char** out_public_b64);
int hw_derive_shared_secret(const char* my_private_b64, const char* peer_public_b64, char** out_shared_b64);
int hw_encrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* plaintext, char** out_encrypted_b64);
int hw_decrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* encrypted_b64, char** out_plaintext);

#endif /* CoreBridge_Bridging_Header_h */
