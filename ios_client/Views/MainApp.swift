import SwiftUI

@available(iOS 16.0, *)
@main
struct HelloWorldApp: App {
    @State private var isAuthenticated = UserDefaults.standard.bool(forKey: "is_authenticated")
    @State private var hasSeenWelcome = UserDefaults.standard.bool(forKey: "has_seen_welcome")
    @State private var coreStatus = "Initializing Core..."

    var body: some Scene {
        WindowGroup {
            Group {
                if isAuthenticated {
                    ChatListView(isAuthenticated: $isAuthenticated)
                } else if hasSeenWelcome {
                    LoginView(isAuthenticated: $isAuthenticated)
                        .transition(.move(edge: .trailing))
                } else {
                    WelcomeView(showLogin: $hasSeenWelcome)
                        .transition(.opacity)
                        .onChange(of: hasSeenWelcome) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "has_seen_welcome")
                        }
                }
            }
            .onChange(of: isAuthenticated) { newValue in
                UserDefaults.standard.set(newValue, forKey: "is_authenticated")
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LogOut"))) { _ in
                isAuthenticated = false
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
