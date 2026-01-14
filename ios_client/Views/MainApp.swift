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
        print("DEBUG: Starting Core test...")
        coreStatus = "Testing connection (ping)..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let pong = hw_ping()
            print("DEBUG: Ping result: \(pong)")
            
            if pong == 42 {
                coreStatus = "Rust connection OK! Calling generateKeyPair..."
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if let keys = CoreWrapper.shared.generateKeyPair() {
                        print("DEBUG: Success! Public Key: \(keys.publicKey.prefix(10))")
                        DispatchQueue.main.async {
                            coreStatus = "Core Full Init Success!\nPK: \(keys.publicKey.prefix(10))..."
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
