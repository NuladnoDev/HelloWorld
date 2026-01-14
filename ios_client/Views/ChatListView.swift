import SwiftUI

// Кастомный стиль для кнопок с эффектом масштабирования и Liquid Glass
struct LiquidGlassButtonStyle: ButtonStyle {
    var paddingHorizontal: CGFloat = 16
    var paddingVertical: CGFloat = 8
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .blue : .white)
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingVertical)
            .background(
                ZStack {
                    Capsule()
                        .fill(Color.black.opacity(0.4)) // Сделал еще темнее
                    Capsule()
                        .fill(.thinMaterial) // Используем thinMaterial вместо ultraThin
                }
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .scaleEffect(configuration.isPressed ? 1.12 : 1.0) // Увеличиваем только формочку
                .offset(y: configuration.isPressed ? 1 : 0) // Легкое смещение при нажатии
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
    }
}

// Вспомогательный стиль для отслеживания нажатия без изменения вида
struct PressDetectorStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

@available(iOS 15.0, *)
struct ChatListView: View {
    @State private var searchText = ""
    @State private var selectedTab: Tab = .chats
    
    // Состояния для анимации правой группы кнопок
    @State private var isPlusPressed = false
    @State private var isPencilPressed = false
    
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
                    // Верхняя панель (Хедер + Поиск) с темно-серой заливкой
                    VStack(spacing: 0) {
                        // Кастомный заголовок (как в ТГ)
                        HStack {
                            Button(action: {}) {
                                Text("Изм.")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 20, paddingVertical: 10))
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("Чаты")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Правая группа кнопок в одном овале
                            HStack(spacing: 25) { // Увеличил расстояние между иконками
                                Button(action: {}) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 22))
                                        .foregroundColor(isPlusPressed ? .blue : .white)
                                }
                                .buttonStyle(PressDetectorStyle(isPressed: $isPlusPressed))
                                
                                Button(action: {}) {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 22))
                                        .foregroundColor(isPencilPressed ? .blue : .white)
                                }
                                .buttonStyle(PressDetectorStyle(isPressed: $isPencilPressed))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    Capsule()
                                        .fill(Color.black.opacity(0.4))
                                    Capsule()
                                        .fill(.thinMaterial)
                                }
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 0.5
                                        )
                                )
                                .scaleEffect((isPlusPressed || isPencilPressed) ? 1.12 : 1.0)
                                .offset(y: (isPlusPressed || isPencilPressed) ? 1 : 0)
                            )
                            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: isPlusPressed || isPencilPressed)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 8)

                        // Поиск (вынесен из ScrollView для фиксированной шапки)
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.black.opacity(0.4)) // Глубокая темная подложка
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(.ultraThinMaterial)
                                )
                                .frame(height: 44)
                            
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
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                    }
                     .background(Color(red: 12/255, green: 12/255, blue: 13/255).edgesIgnoringSafeArea(.top)) // Цвет #0c0c0d
                     
                     ScrollView {
                        LazyVStack(spacing: 0) {
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

            // Вкладка Настройки
            SettingsView()
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
