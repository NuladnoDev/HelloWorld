import SwiftUI

@main
struct HelloWorldApp: App {
    @State private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ChatListView()
            } else {
                LoginView()
            }
        }
    }
}
