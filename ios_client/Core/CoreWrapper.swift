import Foundation

class CoreWrapper {
    static let shared = CoreWrapper()
    
    private init() {}
    
    func generateKeyPair() -> (privateKey: String, publicKey: String)? {
        var privatePtr: UnsafeMutablePointer<Int8>?
        var publicPtr: UnsafeMutablePointer<Int8>?
        
        cpp_generate_keypair(&privatePtr, &publicPtr)
        
        if let priv = privatePtr, let pub = publicPtr {
            let privateKey = String(cString: priv)
            let publicKey = String(cString: pub)
            
            cpp_free_string(privatePtr)
            cpp_free_string(publicPtr)
            
            return (privateKey, publicKey)
        }
        
        return nil
    }
    
    func deriveSharedSecret(myPrivateKey: String, peerPublicKey: String) -> String? {
        var sharedPtr: UnsafeMutablePointer<Int8>?
        
        let result = cpp_derive_shared_secret(myPrivateKey, peerPublicKey, &sharedPtr)
        
        if result == 0, let shared = sharedPtr {
            let secret = String(cString: shared)
            cpp_free_string(sharedPtr)
            return secret
        }
        
        return nil
    }

    func encryptMessage(sharedSecret: String, chatId: String, senderId: String, text: String) -> String? {
        var encryptedPtr: UnsafeMutablePointer<Int8>?
        
        let result = cpp_encrypt_message(sharedSecret, chatId, senderId, text, &encryptedPtr)
        
        if result == 0, let encrypted = encryptedPtr {
            let resultStr = String(cString: encrypted)
            cpp_free_string(encryptedPtr)
            return resultStr
        }
        
        return nil
    }
    
    func decryptMessage(sharedSecret: String, chatId: String, senderId: String, encryptedText: String) -> String? {
        var decryptedPtr: UnsafeMutablePointer<Int8>?
        
        let result = cpp_decrypt_message(sharedSecret, chatId, senderId, encryptedText, &decryptedPtr)
        
        if result == 0, let decrypted = decryptedPtr {
            let resultStr = String(cString: decrypted)
            cpp_free_string(decryptedPtr)
            return resultStr
        }
        
        return nil
    }
}
