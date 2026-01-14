import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let name: some View { Text(username) } // Simplified for preview
    let username: String
    let lastMessage: String
    let time: String
    let unreadCount: Int
}

struct ChatListView: View {
    @State private var searchText = ""
    
    let chats = [
        ChatMessage(username: "Pavel Durov", lastMessage: "Welcome to the new client!", time: "12:45", unreadCount: 2),
        ChatMessage(username: "Satoshi", lastMessage: "Did you check the keys?", time: "10:20", unreadCount: 0),
        ChatMessage(username: "System", lastMessage: "Your session is active", time: "Вчера", unreadCount: 0)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Поиск", text: $searchText)
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color(white: 0.15))
                    .cornerRadius(10)
                    .padding()
                    
                    List {
                        ForEach(chats) { chat in
                            ChatRow(chat: chat)
                                .listRowBackground(Color.black)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Чаты")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Изм.") { }
                        .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct ChatRow: View {
    let chat: ChatMessage
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            Circle()
                .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 55, height: 55)
                .overlay(
                    Text(chat.username.prefix(1))
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                )
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(chat.username)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(chat.time)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    Spacer()
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
