import SwiftUI

@available(iOS 16.0, *)
struct ChatListView: View {
    @Binding var isAuthenticated: Bool
    @State private var searchText = ""
    @State private var isSearchActive = false
    @State private var selectedTab: Tab = .chats
    @State private var searchCategory: String = "Чаты"
    
    // Состояние для вкладки Звонки
    @State private var isCallsVisible = true
    @State private var showHideCallsMenu = false
    
    // Состояния для анимации правой группы кнопок
    @State private var isPlusPressed = false
    @State private var isPencilPressed = false
    
    init(isAuthenticated: Binding<Bool>) {
        self._isAuthenticated = isAuthenticated
        // Настройка внешнего вида системного таббара согласно гайду (Liquid Glass)
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        // Используем темный блюр как основу
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        // Цвет обводки сверху таббара
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.12)
        
        // Применяем ко всем состояниям
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    enum Tab: String, CaseIterable {
        case posts = "Лента"
        case chats = "Чаты"
        case calls = "Звонки"
        case settings = "Настройки"
        
        var icon: String {
            switch self {
            case .posts: return "rectangle.grid.1x2.fill"
            case .chats: return "message.fill"
            case .calls: return "phone.fill"
            case .settings: return "gear"
            }
        }
    }

    let chats = [
        Chat(name: "HelloWorld", lastMessage: "Спасибо за принятие приглашения на бета-тест", time: "10:00", unreadCount: 1, isVerified: true, isMe: false),
        Chat(name: "Артем", lastMessage: "Завтра в силе?", time: "09:45", isMe: true, isRead: true),
        Chat(name: "Мария", lastMessage: "Скинула файл, глянь как будет время", time: "09:12", isMe: false),
        Chat(name: "Дизайн-чат", lastMessage: "Нужно поправить отступы в профиле", time: "Вчера", isMe: false, isPhoto: true),
        Chat(name: "Александр", lastMessage: "Понял, сделаю", time: "Вчера", isMe: true, isRead: false),
        Chat(name: "Support", lastMessage: "Ваш тикет был закрыт", time: "Пн", isVerified: true, isMe: false),
        Chat(name: "Мама", lastMessage: "Ты поел?", time: "Пн", isMe: false),
        Chat(name: "Дмитрий", lastMessage: "Отправил видео с тестами", time: "12.01", isMe: false, isVideo: true)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Вкладка Посты
                NavigationView {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        Text("Лента")
                            .foregroundColor(.white)
                    }
                    .navigationBarHidden(true)
                }
                .tabItem {
                    Label(Tab.posts.rawValue, systemImage: Tab.posts.icon)
                }
                .tag(Tab.posts)
                
                // Вкладка Чаты (Основная)
                NavigationView {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        
                        VStack(spacing: 0) {
                            // Верхняя панель (Хедер + Поиск)
                            VStack(spacing: 0) {
                                if !isSearchActive {
                                    // Кастомный заголовок (как в ТГ)
                                    ZStack {
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
                                                        .fill(.ultraThinMaterial)
                                                }
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                                                )
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 25) // Увеличил отступ сверху над "Чаты"
                                    .padding(.bottom, 8)
                                }

                                // Поиск
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 28)
                                            .fill(isSearchActive ? Color.black : Color(white: 0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 28)
                                                    .stroke(isSearchActive ? Color.white.opacity(0.1) : Color.clear, lineWidth: 1)
                                            )
                                            .frame(height: 41)
                                        
                                        HStack {
                                            Image(systemName: "magnifyingglass")
                                                .foregroundColor(.gray)
                                                .padding(.leading, 15) // Чуть больше отступ иконки при большом скруглении
                                            
                                            TextField("Поиск", text: $searchText, onEditingChanged: { editing in
                                                withAnimation(.spring()) {
                                                    isSearchActive = editing
                                                }
                                            })
                                            .foregroundColor(.white)
                                            .font(.system(size: 17))
                                        }
                                    }
                                    
                                    if isSearchActive {
                                        Button("Отмена") {
                                            withAnimation(.spring()) {
                                                isSearchActive = false
                                                searchText = ""
                                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            }
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                            }
                            .background(Color.black)
                            
                            // Список
                            ScrollView {
                                VStack(spacing: 0) {
                                    if isSearchActive {
                                        SearchNavigationBar(selectedCategory: $searchCategory)
                                            .padding(.vertical, 10)
                                        
                                        VStack(alignment: .leading, spacing: 20) {
                                            Text("Недавние")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 16)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 20) {
                                                    RecentContactItem(name: "HelloWorld", color: .blue)
                                                }
                                                .padding(.horizontal, 16)
                                            }
                                        }
                                    } else {
                                        LazyVStack(spacing: 0) {
                                            ForEach(chats) { chat in
                                                NavigationLink(destination: ChatView()) {
                                                    ChatRow(chat: chat)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                
                                                Divider()
                                                    .background(Color.white.opacity(0.1))
                                                    .padding(.leading, 76)
                                            }
                                        }
                                        .padding(.bottom, 90) // Отступ, чтобы список не перекрывался таб-баром
                                    }
                                }
                            }
                        }
                    }
                    .navigationBarHidden(true)
                }
                .tabItem {
                    Label(Tab.chats.rawValue, systemImage: Tab.chats.icon)
                }
                .tag(Tab.chats)
                .toolbar(.visible, for: .tabBar)
                
                // Вкладка Звонки
                if isCallsVisible {
                    NavigationView {
                        ZStack {
                            Color.black.edgesIgnoringSafeArea(.all)
                            VStack {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 10)
                                Text("Здесь будут ваши звонки")
                                    .foregroundColor(.gray)
                            }
                        }
                        .navigationBarHidden(true)
                    }
                    .tabItem {
                        Label(Tab.calls.rawValue, systemImage: Tab.calls.icon)
                    }
                    .tag(Tab.calls)
                    .onAppear {
                        // Для работы long press на системном таббаре в SwiftUI 
                        // обычно требуется кастомный таббар, но мы можем добавить 
                        // распознаватель на все вью, если выбрана эта вкладка
                    }
                }
                
                // Вкладка Настройки
                SettingsView(isAuthenticated: $isAuthenticated)
                    .tabItem {
                        Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                    }
                    .tag(Tab.settings)
            }
            .accentColor(.blue)
            .preferredColorScheme(.dark)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5).onEnded { _ in
                    if selectedTab == .calls {
                        withAnimation(.spring()) {
                            showHideCallsMenu = true
                        }
                    }
                }
            )
            
            // Меню скрытия вкладки (как в ТГ)
            if showHideCallsMenu {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation { showHideCallsMenu = false }
                        }
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            // Кнопка: Начать новый звонок
                            Button(action: {
                                withAnimation { showHideCallsMenu = false }
                            }) {
                                HStack {
                                    Text("Начать новый звонок")
                                        .font(.system(size: 16)) // Чуть меньше текст
                                    Spacer()
                                    Image(systemName: "person.badge.plus")
                                        .font(.system(size: 18)) // Чуть меньше иконка
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12) // Уменьшил вертикальный паддинг
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.12))
                            
                            // Кнопка: Скрыть вкладку
                            Button(action: {
                                withAnimation(.spring()) {
                                    isCallsVisible = false
                                    showHideCallsMenu = false
                                    selectedTab = .chats
                                }
                            }) {
                                HStack {
                                    Text("Скрыть вкладку «Звонки»")
                                        .font(.system(size: 16))
                                    Spacer()
                                    Image(systemName: "eye.slash")
                                        .font(.system(size: 18))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                        .frame(width: 280) // Ограничил ширину как на скриншоте
                        .background(Color(white: 0.15)) // Чуть светлее фон меню
                        .cornerRadius(14) // Вернул скругление 14 для меню (оно меньше чем группы)
                        .padding(.bottom, 110)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .edgesIgnoringSafeArea(.all)
                .zIndex(10)
            }
        }
    }
}

@available(iOS 16.0, *)
struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                
                Text(String(chat.name.prefix(1)))
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name).bold()
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                    
                    if chat.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        if chat.isMe {
                            if chat.isRead {
                                HStack(spacing: -5) {
                                    Image(systemName: "checkmark")
                                    Image(systemName: "checkmark")
                                }
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.blue)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text(chat.time)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                HStack(spacing: 0) {
                    if chat.isMe {
                        Text("Вы: ")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                    }
                    
                    if chat.isPhoto {
                        HStack(spacing: 4) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12))
                            Text("Фотография")
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.blue)
                     } else if chat.isVideo {
                        HStack(spacing: 4) {
                            Image(systemName: "video.fill")
                                .font(.system(size: 12))
                            Text("Видео")
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.blue)
                     } else {
                        Text(chat.lastMessage)
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    
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
        .padding(.vertical, 8)
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
    var isMe: Bool = false
    var isPhoto: Bool = false
    var isVideo: Bool = false
    var isRead: Bool = true
}

@available(iOS 16.0, *)
struct RecentContactItem: View {
    let name: String
    var color: Color = .gray
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [color.opacity(0.8), color], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .frame(width: 70)
    }
}

@available(iOS 16.0, *)
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
                        .font(.system(size: 12, weight: selectedCategory == category ? .bold : .medium))
                        .lineLimit(1)
                        .foregroundColor(selectedCategory == category ? .white : .gray)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selectedCategory == category {
                                    Capsule()
                                        .fill(Color(white: 0.12))
                                        .matchedGeometryEffect(id: "activeTab", in: animation)
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(Color(white: 0.05))
        .clipShape(Capsule())
        .padding(.horizontal, 16)
    }
}
