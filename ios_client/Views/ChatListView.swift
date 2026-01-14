import SwiftUI

@available(iOS 15.0, *)
struct ChatListView: View {
    @State private var searchText = ""
    @State private var selectedTab: Tab = .chats
    
    enum Tab: String, CaseIterable {
        case feed = "Лента"
        case calls = "Звонки"
        case chats = "Чаты"
        case settings = "Настройки"
        
        var icon: String {
            switch self {
            case .feed: return "person.2.fill"
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
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Основной контент в зависимости от вкладки
            VStack(spacing: 0) {
                if selectedTab == .chats {
                    chatsView
                } else {
                    // Заглушка для других вкладок
                    NavigationView {
                        ZStack {
                            Color.black.edgesIgnoringSafeArea(.all)
                            Text(selectedTab.rawValue)
                                .foregroundColor(.white)
                        }
                        .navigationTitle(selectedTab.rawValue)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
            
            // Кастомная нижняя навигация
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    // Кнопка поиска слева (как в референсе)
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    // Основная панель вкладок
                    HStack(spacing: 0) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 20))
                                    Text(tab.rawValue)
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundColor(selectedTab == tab ? .blue : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                            }
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
    }

    var chatsView: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Поиск
                        ZStack {
                            // Фон поиска
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                                .brightness(-0.2) // Делаем материал темнее
                                .frame(height: 48) // Увеличили высоту
                            
                            // Контент поиска (центрированный)
                            HStack(spacing: 8) {
                                if searchText.isEmpty {
                                    Spacer()
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    Text("Поиск")
                                        .foregroundColor(.gray)
                                    Spacer()
                                } else {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                        .padding(.leading, 12)
                                    TextField("", text: $searchText)
                                        .foregroundColor(.white)
                                    if !searchText.isEmpty {
                                        Button(action: { searchText = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 10)

                        // Список чатов
                        ForEach(chats) { chat in
                            ChatRow(chat: chat)
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 76)
                        }
                        
                        // Отступ снизу для навигации
                        Color.clear.frame(height: 100)
                    }
                }
            }
            .navigationTitle("Чаты")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Изм.") { }
                        .font(.system(size: 17))
                        .foregroundColor(.white) // Белый шрифт
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.white) // Белая иконка
                    }
                }
            }
        }
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
