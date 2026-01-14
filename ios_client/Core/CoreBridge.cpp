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

}
