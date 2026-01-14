import SwiftUI

@available(iOS 15.0, *)
struct ChatListView: View {
    @State private var searchText = ""
    @State private var selectedTab: Tab = .chats
    @Namespace private var animation
    
    enum Tab: String, CaseIterable {
        case feed = "Лента"
        case chats = "Чаты"
        case settings = "Настройки"
        
        var icon: String {
            switch self {
            case .feed: return "person.2.fill"
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
            // Фон
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Основной контент
            NavigationView {
                ZStack(alignment: .top) {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        // Поиск (Liquid Glass) - вынесен из ScrollView, чтобы не уезжал
                        searchBar
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .zIndex(10)

                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(chats) { chat in
                                    ChatRow(chat: chat)
                                    Divider()
                                        .background(Color.white.opacity(0.1))
                                        .padding(.leading, 76)
                                }
                                // Отступ для нижней панели
                                Color.clear.frame(height: 120)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Чаты")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Text("Изм.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            // Кастомная навигация с морфингом капли
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    // Кнопка поиска слева (Отдельная капля)
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Основная панель
                    HStack(spacing: 0) {
                        ForEach(Tab.allCases, id: \.self) { tab in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)) {
                                    selectedTab = tab
                                }
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 18))
                                    Text(tab.rawValue)
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .foregroundColor(selectedTab == tab ? .blue : .white)
                                .background(
                                    ZStack {
                                        if selectedTab == tab {
                                            // Та самая "перемещающаяся капля"
                                            Capsule()
                                                .fill(Color.white.opacity(0.12))
                                                .matchedGeometryEffect(id: "activeTab", in: animation)
                                                .padding(4)
                                        }
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12) // Опустил вниз как просил юзер
            }
        }
    }

    var searchBar: some View {
        ZStack {
            // Фон поиска (Liquid Glass) - убрал сильное затемнение
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .frame(height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
            
            HStack {
                if searchText.isEmpty {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Text("Поиск")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.leading, 12)
                    TextField("", text: $searchText)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.trailing, 12)
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
