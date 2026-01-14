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
        coreStatus = "Calling Rust..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            print("DEBUG: Calling generateKeyPair from background thread")
            if let keys = CoreWrapper.shared.generateKeyPair() {
                print("DEBUG: Success! Public Key: \(keys.publicKey.prefix(10))")
                DispatchQueue.main.async {
                    coreStatus = "Core initialized!\nPublic Key: \(keys.publicKey.prefix(10))..."
                }
            } else {
                print("DEBUG: Core returned nil")
                DispatchQueue.main.async {
                    coreStatus = "Failed to initialize Core (returned nil)."
                }
            }
        }
    }
}
