import SwiftUI

struct Chat: Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let time: String
    let unreadCount: Int
    let isVerified: Bool
}

struct ChatListView: View {
    @State private var searchText = ""
    @State private var selectedTab: Tab = .chats
    
    @State private var chats = [
        Chat(name: "HelloWorld", lastMessage: "Добро пожаловать в HelloWorld! Это ваш первый чат.", time: "23:20", unreadCount: 1, isVerified: true)
    ]
    
    enum Tab: String, CaseIterable {
        case feed = "Лента"
        case chats = "Чаты"
        case settings = "Настройки"
        
        var icon: String {
            switch self {
            case .feed: return "person.2.fill"
            case .chats: return "bubble.left.and.bubble.right.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Чаты")
                        .font(.system(size: 38, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 25)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Liquid Glass Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.6))
                    TextField("Поиск", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.1))
                        .background(Blur(style: .systemThinMaterialDark).cornerRadius(18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                
                // Chat List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(chats) { chat in
                            ChatRow(chat: chat)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            
            // Floating Liquid Glass Navigation Menu
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    // Separate Search Button on the LEFT
                    Button(action: { }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .background(Blur(style: .systemThinMaterialDark).clipShape(Circle()))
                                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                            )
                    }
                    
                    // Main Nav Pill
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
                                .foregroundColor(selectedTab == tab ? .blue : .white.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(
                                    ZStack {
                                        if selectedTab == tab {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.white.opacity(0.1))
                                                .matchedGeometryEffect(id: "tab_bg", in: tabAnimation)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.white.opacity(0.1))
                            .background(Blur(style: .systemThinMaterialDark).cornerRadius(30))
                            .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @Namespace private var tabAnimation
}

struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 15) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                
                Text(chat.name.prefix(1))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name)
                        .font(.system(size: 17, weight: .semibold))
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
                        .lineLimit(2)
                    
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
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .overlay(
            VStack {
                Spacer()
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.leading, 90) // Offset divider to align with text
            }
        )
    }
}

// Blur Effect Helper
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
