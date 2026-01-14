import SwiftUI

// Кастомный стиль для кнопок с эффектом масштабирования и Liquid Glass
struct LiquidGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .blue : .white) // Белый по умолчанию, синий при нажатии
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.2), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 1.15 : 1.0)
            .offset(y: configuration.isPressed ? 2 : 0) // Немного перемещается при нажатии
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

@available(iOS 15.0, *)
struct ChatListView: View {
    @State private var searchText = ""
    @State private var selectedTab: Tab = .chats
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
         appearance.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0) // Сделал чуть светлее для контраста
         appearance.shadowColor = UIColor.white.withAlphaComponent(0.15) // Четкая обводка сверху
         
         // Настройка цвета иконок
        appearance.stackedLayoutAppearance.normal.iconColor = .gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    enum Tab: String, CaseIterable {
        case posts = "посты"
        case chats = "Чаты"
        case settings = "Настройки"
        
        var icon: String {
            switch self {
            case .posts: return "rectangle.grid.1x2.fill"
            case .chats: return "message.fill"
            case .settings: return "gear"
            }
        }
    }

    let chats = [
        Chat(name: "HelloWorld", lastMessage: "привет мальчонке", time: "12:00", unreadCount: 1, isVerified: true)
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

            // Таб Чаты
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Кастомный заголовок (как в ТГ)
                    HStack {
                        Button(action: {}) {
                            Text("Изм.")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .buttonStyle(LiquidGlassButtonStyle())
                        
                        Spacer()
                        
                        Text("Чаты")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 18))
                                .padding(2) // Небольшой отступ для иконки внутри кнопки
                        }
                        .buttonStyle(LiquidGlassButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .padding(.bottom, 8)

                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Поиск
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(.regularMaterial)
                                    .frame(height: 52) // Увеличил с 48 до 52 (вниз)
                                
                                if searchText.isEmpty {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                        Text("Поиск")
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                }
                                
                                HStack {
                                    if !searchText.isEmpty {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 12)
                                    }
                                    
                                    TextField("", text: $searchText)
                                        .foregroundColor(.white)
                                        .padding(.leading, searchText.isEmpty ? 40 : 5)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.top, 5)
                            .padding(.bottom, 12) // Увеличил отступ снизу

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
        HStack(spacing: 16) { // Увеличил расстояние до 16
            // Аватар
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60) // Увеличил аватарку с 54 до 60
                
                Text(String(chat.name.prefix(1)))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) { // Увеличил расстояние между строками
                HStack {
                    Text(chat.name).bold()
                        .font(.system(size: 17)) // Чуть больше шрифт заголовка
                        .foregroundColor(.white)
                    
                    if chat.isVerified {
                        Image(systemName: "checkmark.seal.fill")
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
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .lineLimit(2) // Telegram часто показывает до 2 строк
                    
                    Spacer()
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12) // Увеличил высоту ячейки (отступы сверху и снизу)
        .contentShape(Rectangle())
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
