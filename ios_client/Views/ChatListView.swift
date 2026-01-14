import SwiftUI

@available(iOS 15.0, *)
struct ChatListView: View {
    @State private var searchText = ""
    @State private var selectedTab: Tab = .chats
    
    enum Tab: String, CaseIterable {
        case posts = "посты"
        case calls = "Звонки"
        case chats = "Чаты"
        case settings = "Настройки"
        
        var icon: String {
            switch self {
            case .posts: return "rectangle.grid.1x2.fill"
            case .calls: return "phone.fill"
            case .chats: return "message.fill"
            case .settings: return "gear"
            }
        }
    }

    let chats = [
        Chat(name: "HelloWorld", lastMessage: "Добро пожаловать в мессенджер будущего!", time: "12:00", unreadCount: 1, isVerified: true),
        Chat(name: "Design Team", lastMessage: "Эффект жидкого стекла готов", time: "11:45", unreadCount: 5),
        Chat(name: "Иван Иванов", lastMessage: "Привет, как дела?", time: "Вчера"),
        Chat(name: "Колледж", lastMessage: "Расписание на завтра", time: "Пн", unreadCount: 12),
        Chat(name: "Геймдев", lastMessage: "Новый билд доступен", time: "10.01.26")
    ]

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                Text("посты")
                    .foregroundColor(.white)
                    .navigationTitle("посты")
            }
            .tabItem {
                Label("посты", systemImage: "rectangle.grid.1x2.fill")
            }
            .tag(Tab.posts)

            NavigationView {
                Text("Звонки")
                    .foregroundColor(.white)
                    .navigationTitle("Звонки")
            }
            .tabItem {
                Label("Звонки", systemImage: "phone.fill")
            }
            .tag(Tab.calls)

            NavigationView {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Поиск
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Поиск", text: $searchText)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                            .padding(.horizontal, 8)
                            .padding(.top, 5)

                            // Список чатов
                            ForEach(chats) { chat in
                                ChatRow(chat: chat)
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                    .padding(.leading, 76)
                            }
                        }
                    }
                }
                .navigationTitle("Чаты")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Изм.") { }
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "square.and.pencil")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .tabItem {
                Label("Чаты", systemImage: "message.fill")
            }
            .tag(Tab.chats)

            NavigationView {
                Text("Настройки")
                    .foregroundColor(.white)
                    .navigationTitle("Настройки")
            }
            .tabItem {
                Label("Настройки", systemImage: "gear")
            }
            .tag(Tab.settings)
        }
        .accentColor(.blue)
    }
}

@available(iOS 15.0, *)
struct CategoryPill: View {
    let title: String
    let isActive: Bool
    
    var body: some View {
        Text(title).bold()
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isActive ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
            .foregroundColor(isActive ? .blue : .white)
            .clipShape(Capsule())
    }
}

@available(iOS 15.0, *)
struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 12) {
            // Аватар
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 54, height: 54)
                
                Text(String(chat.name.prefix(1)))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name).bold()
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    if chat.isVerified {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                    }
                    
                    Spacer()
                    
                    Text(chat.time)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(chat.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct Chat: Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let time: String
    var unreadCount: Int = 0
    var isVerified: Bool = false
}

@available(iOS 15.0, *)
struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
            .preferredColorScheme(.dark)
    }
}
