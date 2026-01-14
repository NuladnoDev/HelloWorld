import SwiftUI

@main
struct HelloWorldApp: App {
    @State private var coreStatus = "Initializing Core..."

    var body: some Scene {
        WindowGroup {
            VStack {
                Text(coreStatus)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .onAppear {
                testCore()
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
                        DispatchQueue.main.async {
                            coreStatus = "C++ Core Success!\nPK: \(keys.publicKey)"
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
