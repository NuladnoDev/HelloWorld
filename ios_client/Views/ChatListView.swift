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

struct ChatListView: View {
    @Binding var isAuthenticated: Bool
    @State private var searchText = ""
    @State private var isSearchActive = false
    @State private var selectedTab: Tab = .chats
    @State private var searchCategory: String = "Чаты"
    
    // Состояния для анимации правой группы кнопок
    @State private var isPlusPressed = false
    @State private var isPencilPressed = false
    
    init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0)
        
        // Цвет обводки сверху таббара
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.15)
        
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
                        if !isSearchActive {
                            // Кастомный заголовок (как в ТГ)
                            ZStack {
                                // Центрированный заголовок
                                Text("Чаты")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                HStack {
                                    Button(action: {}) {
                                        Text("Изм.")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 16, paddingVertical: 8))
                                    
                                    Spacer()
                                    
                                    // Правая группа кнопок в одном овале
                                    HStack(spacing: 15) {
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
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
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
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 8)
                            .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .top).combined(with: .opacity)))
                        }

                        // Поиск (вынесен из ScrollView для фиксированной шапки)
                        HStack(spacing: 10) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.black.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(.ultraThinMaterial)
                                    )
                                    .frame(height: 44)
                                
                                if searchText.isEmpty {
                                    HStack {
                                        if !isSearchActive { Spacer() }
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                            .padding(.leading, isSearchActive ? 12 : 0)
                                        Text("Поиск")
                                            .foregroundColor(.gray)
                                        if !isSearchActive { Spacer() }
                                    }
                                }
                                
                                HStack {
                                    if !searchText.isEmpty || isSearchActive {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 12)
                                            .opacity(searchText.isEmpty && isSearchActive ? 0 : 1)
                                    }
                                    
                                    TextField("", text: $searchText, onEditingChanged: { editing in
                                        if editing {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                isSearchActive = true
                                            }
                                        }
                                    })
                                    .foregroundColor(.white)
                                    .padding(.leading, (searchText.isEmpty && !isSearchActive) ? 40 : 5)
                                }
                            }
                            
                            if isSearchActive {
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isSearchActive = false
                                        searchText = ""
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 12))
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                        .padding(.top, isSearchActive ? 10 : 0)
                    }
                    .background(Color(red: 12/255, green: 12/255, blue: 13/255).edgesIgnoringSafeArea(.top))
                    
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            if isSearchActive {
                                // Контент режима поиска
                                VStack(alignment: .leading, spacing: 20) {
                                    // Секция недавних контактов
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Недавние")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 16)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 20) {
                                                RecentContactItem(name: "HelloWorld", color: .blue)
                                                RecentContactItem(name: "zoguratiss", color: .purple)
                                                RecentContactItem(name: "ت", image: "person.crop.circle.fill")
                                                RecentContactItem(name: "hikka", image: "person.crop.circle.fill")
                                                RecentContactItem(name: "ancor", color: .blue)
                                                RecentContactItem(name: "Вован", color: .orange)
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                    .padding(.top, 10)
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black)
                            } else {
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
                        
                        if isSearchActive {
                            // Категории внизу (как в ТГ на скрине) - Одно меню навигации
                            SearchNavigationBar(selectedCategory: $searchCategory)
                                .padding(.bottom, 10)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity.animation(.none) // Мгновенное исчезновение без анимации
                                ))
                        }
                    }
                }
            }
            .tabItem {
                Label("Чаты", systemImage: "message.fill")
            }
            .tag(Tab.chats)

            // Вкладка Настройки
            SettingsView(isAuthenticated: $isAuthenticated)
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
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
struct RecentContactItem: View {
    let name: String
    var image: String? = nil
    var color: Color = .gray
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let image = image {
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                } else {
                    Circle()
                        .fill(LinearGradient(colors: [color.opacity(0.8), color], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 60, height: 60)
                    
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}

@available(iOS 15.0, *)
struct SearchNavigationBar: View {
    @Binding var selectedCategory: String
    let categories = ["Чаты", "Каналы", "Приложения", "Медиа"]
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(categories, id: \.self) { category in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selectedCategory = category
                    }
                }) {
                    Text(category)
                        .font(.system(size: 14, weight: selectedCategory == category ? .bold : .medium))
                        .foregroundColor(selectedCategory == category ? .white : .gray)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selectedCategory == category {
                                    Capsule()
                                        .fill(Color.white.opacity(0.12))
                                        .matchedGeometryEffect(id: "activeTab", in: animation)
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                        )
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            ZStack {
                Capsule()
                    .fill(Color.black.opacity(0.6))
                Capsule()
                    .fill(.ultraThinMaterial)
            }
        )
        .padding(.horizontal, 16)
    }
}

@available(iOS 15.0, *)
struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(isAuthenticated: .constant(true))
            .preferredColorScheme(.dark)
    }
}
