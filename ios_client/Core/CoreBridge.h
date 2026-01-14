#ifndef CoreBridge_h
#define CoreBridge_h

#ifdef __cplusplus
extern "C" {
#endif

int cpp_ping(void);
void cpp_generate_keypair(char** out_private, char** out_public);
void cpp_free_string(char* s);

#ifdef __cplusplus
}
#endif

#endif /* CoreBridge_h */
