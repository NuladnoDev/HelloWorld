import SwiftUI

@available(iOS 15.0, *)
@main
struct HelloWorldApp: App {
    @State private var isAuthenticated = false
    @State private var hasSeenWelcome = false
    @State private var coreStatus = "Initializing Core..."

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ChatListView()
            } else if hasSeenWelcome {
                LoginView(isAuthenticated: $isAuthenticated)
                    .transition(.move(edge: .trailing))
            } else {
                WelcomeView(showLogin: $hasSeenWelcome)
                    .transition(.opacity)
            }
        }
    }

    private func testCore() {
        print("DEBUG: Starting C++ Core test...")
        coreStatus = "Testing connection (ping)..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let pong = cpp_ping()
            print("DEBUG: Ping result: \(pong)")
            
            if pong == 100 {
                coreStatus = "C++ connection OK! Calling generateKeyPair..."
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if let keys = CoreWrapper.shared.generateKeyPair() {
                        print("DEBUG: Success! Public Key: \(keys.publicKey)")
                        
                        // Тест шифрования
                        let chatID = "test_chat_123"
                        let senderID = "user_me"
                        let secret = "shared_secret_123"
                        let text = "Hello from C++!"
                        
                        if let encrypted = CoreWrapper.shared.encryptMessage(sharedSecret: secret, chatId: chatID, senderId: senderID, text: text) {
                            print("DEBUG: Encrypted: \(encrypted)")
                            if let decrypted = CoreWrapper.shared.decryptMessage(sharedSecret: secret, chatId: chatID, senderId: senderID, encryptedText: encrypted) {
                                print("DEBUG: Decrypted: \(decrypted)")
                                
                                DispatchQueue.main.async {
                                    coreStatus = "C++ Core Full Success!\nPK: \(keys.publicKey)\nDecrypted: \(decrypted)"
                                }
                                return
                            }
                        }
                        
                        DispatchQueue.main.async {
                            coreStatus = "C++ Core Success!\nPK: \(keys.publicKey)\n(Crypto test failed)"
                        }
                    } else {
                        DispatchQueue.main.async {
                            coreStatus = "Ping OK, but KeyPair failed."
                        }
                    }
                }
            } else {
                coreStatus = "Ping failed: wrong value \(pong)"
            }
        }
    }
}
