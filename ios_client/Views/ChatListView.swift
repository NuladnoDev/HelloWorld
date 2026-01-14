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
                // Header with Liquid Glass Buttons
                HStack {
                    // Edit Button (Liquid Glass)
                    Button(action: {}) {
                        Text("Изм.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 36)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    }
                    
                    Spacer()
                    
                    Text("Чаты")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Right Pill (Liquid Glass)
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 18))
                        }
                        Button(action: {}) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 18))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                }
                .padding(.horizontal, 16)
                .padding(.top, 50)
                .padding(.bottom, 15)
                
                // Native-styled Search Bar with Liquid Glass
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Поиск", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 0.5))
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
                
                // Categories (from reference)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryPill(title: "Все", isSelected: true)
                        CategoryPill(title: "channel", count: 4)
                        CategoryPill(title: "колледж")
                        CategoryPill(title: "геймдев")
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 15)
                
                // Chat List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(chats) { chat in
                            ChatRow(chat: chat)
                        }
                    }
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
                            .background(.ultraThinMaterial, in: Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
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
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30))
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
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
                     .frame(width: 54, height: 54)
                 
                 Text(chat.name.prefix(1))
                     .font(.system(size: 20, weight: .bold))
                     .foregroundColor(.white)
             }
             
             VStack(alignment: .leading, spacing: 3) {
                 HStack {
                     Text(chat.name)
                         .font(.system(size: 16, weight: .semibold))
                         .foregroundColor(.white)
                     
                     if chat.isVerified {
                         Image(systemName: "checkmark.seal.fill")
                             .foregroundColor(.blue)
                             .font(.system(size: 13))
                     }
                     
                     Spacer()
                     
                     Text(chat.time)
                         .font(.system(size: 13))
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
                             .font(.system(size: 11, weight: .bold))
                             .foregroundColor(.white)
                             .padding(.horizontal, 6)
                             .padding(.vertical, 3)
                             .background(Color.blue)
                             .clipShape(Capsule())
                     }
                 }
             }
         }
         .padding(.horizontal, 16)
         .padding(.vertical, 8)
         .contentShape(Rectangle())
         .overlay(
             VStack {
                 Spacer()
                 Divider()
                     .background(Color.white.opacity(0.1))
                     .padding(.leading, 85) // Offset divider to align with text
             }
         )
     }
 }
 
struct CategoryPill: View {
    let title: String
    var isSelected: Bool = false
    var count: Int? = nil
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
            
            if let count = count {
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
        .foregroundColor(isSelected ? .white : .gray)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? Color.white.opacity(0.15) : Color.clear)
        .cornerRadius(15)
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView()
    }
}
