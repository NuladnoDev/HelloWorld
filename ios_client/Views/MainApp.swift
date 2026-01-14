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
        if let keys = CoreWrapper.shared.generateKeyPair() {
            coreStatus = "Core initialized!\nPublic Key: \(keys.publicKey.prefix(10))..."
        } else {
            coreStatus = "Failed to initialize Core."
        }
    }
}
