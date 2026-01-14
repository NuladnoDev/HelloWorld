#include "CoreBridge.h"
#include <string>
#include <vector>
#include <cstring>
#include <CommonCrypto/CommonCrypto.h>
#include <CommonCrypto/CommonRandom.h>
#include "monocypher/monocypher.h"

// Helper for Base64 (using Security framework or simple impl)
static std::string base64_encode(const uint8_t* data, size_t len) {
    static const char* lut = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                             "abcdefghijklmnopqrstuvwxyz"
                             "0123456789+/";
    std::string out;
    out.reserve((len + 2) / 3 * 4);
    for (size_t i = 0; i < len; i += 3) {
        int val = (data[i] << 16) + (i + 1 < len ? (data[i + 1] << 8) : 0) + (i + 2 < len ? data[i + 2] : 0);
        out.push_back(lut[(val >> 18) & 0x3F]);
        out.push_back(lut[(val >> 12) & 0x3F]);
        out.push_back(i + 1 < len ? lut[(val >> 6) & 0x3F] : '=');
        out.push_back(i + 2 < len ? lut[val & 0x3F] : '=');
    }
    return out;
}

static std::vector<uint8_t> base64_decode(const std::string& in) {
    static const std::vector<int> T = {
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
        -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
        -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
        -1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1
    };
    std::vector<uint8_t> out;
    int val = 0, valb = -8;
    for (uint8_t c : in) {
        if (c < T.size() && T[c] != -1) {
            val = (val << 6) + T[c];
            valb += 6;
            if (valb >= 0) {
                out.push_back(uint8_t((val >> valb) & 0xFF));
                valb -= 8;
            }
        }
    }
    return out;
}

extern "C" {

int cpp_ping(void) {
    return 100;
}

void cpp_generate_keypair(char** out_private_b64, char** out_public_b64) {
    uint8_t priv[32];
    uint8_t pub[32];
    
    CCRandomGenerateBytes(priv, 32);
    crypto_x25519_public_key(pub, priv);
    
    *out_private_b64 = strdup(base64_encode(priv, 32).c_str());
    *out_public_b64 = strdup(base64_encode(pub, 32).c_str());
}

int cpp_derive_shared_secret(const char* my_private_b64, const char* peer_public_b64, char** out_shared_b64) {
    auto priv = base64_decode(my_private_b64);
    auto pub = base64_decode(peer_public_b64);
    
    if (priv.size() != 32 || pub.size() != 32) return -1;
    
    uint8_t shared[32];
    crypto_x25519(shared, priv.data(), pub.data());
    
    *out_shared_b64 = strdup(base64_encode(shared, 32).c_str());
    return 0;
}

int cpp_encrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* plaintext, char** out_encrypted_b64) {
    auto key = base64_decode(shared_b64);
    if (key.size() != 32) return -1;
    
    size_t plain_len = strlen(plaintext);
    std::vector<uint8_t> cipher(plain_len + 16); // 16 bytes for MAC
    uint8_t nonce[24] = {0}; // In production, use real unique nonces
    
    crypto_chacha20_poly1305_encrypt(cipher.data(), cipher.data() + plain_len, 
                                     (const uint8_t*)plaintext, plain_len, 
                                     key.data(), nonce, NULL, 0);
    
    *out_encrypted_b64 = strdup(base64_encode(cipher.data(), cipher.size()).c_str());
    return 0;
}

int cpp_decrypt_message(const char* shared_b64, const char* chat_id, const char* sender_id, const char* encrypted_b64, char** out_plaintext) {
    auto key = base64_decode(shared_b64);
    auto cipher_with_mac = base64_decode(encrypted_b64);
    
    if (key.size() != 32 || cipher_with_mac.size() < 16) return -1;
    
    size_t plain_len = cipher_with_mac.size() - 16;
    std::vector<uint8_t> plain(plain_len + 1);
    uint8_t nonce[24] = {0};
    
    if (crypto_chacha20_poly1305_decrypt(plain.data(), 
                                         cipher_with_mac.data() + plain_len, 
                                         cipher_with_mac.data(), plain_len, 
                                         key.data(), nonce, NULL, 0) != 0) {
        return -2; // MAC mismatch
    }
    
    plain[plain_len] = '\0';
    *out_plaintext = strdup((const char*)plain.data());
    return 0;
}

void cpp_free_string(char* s) {
    if (s) free(s);
}

}
