import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @Binding var isAuthenticated: Bool
    @State private var username: String = UserDefaults.standard.string(forKey: "saved_username") ?? "problem"
    @State private var firstName: String = UserDefaults.standard.string(forKey: "saved_firstName") ?? ""
    @State private var lastName: String = UserDefaults.standard.string(forKey: "saved_lastName") ?? ""
    @State private var tag: String = UserDefaults.standard.string(forKey: "saved_tag") ?? ""
    @State private var phoneNumber: String = UserDefaults.standard.string(forKey: "saved_phone") ?? "+7 (999) 123-45-67"
    @State private var avatarImage: UIImage? = nil
    @State private var isEditingProfile = false
    
    // Состояние для расширяемой аватарки
    @State private var scrollOffset: CGFloat = 0
    private let collapsedAvatarSize: CGFloat = 110
    private let expandedAvatarHeight: CGFloat = 400
    
    var fullName: String {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? username : name
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Расширенная аватарка с градиентом (фон)
            if let image = avatarImage {
                GeometryReader { geo in
                    let offset = scrollOffset
                    let height = expandedAvatarHeight + (offset > 0 ? offset : 0)
                    
                    ZStack(alignment: .bottom) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: height)
                            .clipped()
                        
                        // Градиент для плавного перехода к контенту
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.8), .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 150)
                    }
                    .offset(y: offset > 0 ? 0 : offset * 0.5) // Параллакс эффект
                    .opacity(avatarOpacity)
                }
                .edgesIgnoringSafeArea(.top)
                .frame(height: expandedAvatarHeight)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Прозрачный спейсер для скролла над большой аватаркой
                    Color.clear
                        .frame(height: expandedAvatarHeight - 100)
                    
                    VStack(spacing: 0) {
                        // Контент профиля (Имя, телефон/тег)
                        VStack(spacing: 12) {
                            // Маленькая круглая аватарка (появляется при скролле вниз)
                            ZStack {
                                if let image = avatarImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: collapsedAvatarSize, height: collapsedAvatarSize)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [Color(red: 0.3, green: 0.7, blue: 1.0), .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: collapsedAvatarSize, height: collapsedAvatarSize)
                                        .overlay(
                                            ZStack {
                                                Color.black.opacity(0.3)
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.white)
                                            }
                                            .clipShape(Circle())
                                        )
                                }
                            }
                            .scaleEffect(collapsedAvatarScale)
                            .opacity(collapsedAvatarOpacity)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    // Можно добавить скролл к самому верху
                                }
                            }
                            
                            VStack(spacing: 2) {
                                Text(fullName)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(radius: scrollOffset > -100 ? 5 : 0)
                                
                                HStack(spacing: 2) {
                                    Image(systemName: tag.isEmpty ? "info.circle" : "at")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.5))
                                    Text(tag.isEmpty ? phoneNumber : tag)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                        }
                        .padding(.top, 5)
                        .padding(.bottom, 30)
                        
                        // Группы настроек
                        VStack(spacing: 20) {
                            SettingsGroup {
                                SettingsRow(icon: "face.smiling", iconColor: .blue, title: "Сменить эмодзи-статус", textColor: .blue, noIconBackground: true)
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "wand.and.stars", iconColor: .blue, title: "Изменить цвет профиля", textColor: .blue, noIconBackground: true)
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "camera", iconColor: .blue, title: "Выбрать фотографию", textColor: .blue, noIconBackground: true) {
                                    isEditingProfile = true
                                }
                                
                                if tag.isEmpty {
                                    Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                    SettingsRow(icon: "at", iconColor: .blue, title: "Выбрать имя пользователя", textColor: .blue, noIconBackground: true) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isEditingProfile = true
                                        }
                                    }
                                }
                            }
                            .padding(.top, 15)
                            
                            SettingsGroup {
                                SettingsRow(icon: "person.circle.fill", iconColor: .green, title: username, showArrow: false)
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "plus", iconColor: .blue, title: "Добавить аккаунт", textColor: .blue, showArrow: false)
                            }
                            
                            SettingsGroup {
                                SettingsRow(icon: "person.crop.circle.badge.exclamationmark", iconColor: .red, title: "Мой профиль")
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "gift.fill", iconColor: .blue, title: "Мальчонка Edition")
                            }
                            
                            SettingsGroup {
                                SettingsRow(icon: "bell.fill", iconColor: .red, title: "Уведомления и звуки")
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "lock.fill", iconColor: .gray, title: "Конфиденциальность")
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "folder.fill", iconColor: .yellow, title: "Папки с чатами")
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "iphone", iconColor: .green, title: "Устройства")
                            }
                            
                            SettingsGroup {
                                SettingsRow(icon: "questionmark.circle.fill", iconColor: .orange, title: "Помощь")
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "bubble.left.and.bubble.right.fill", iconColor: .cyan, title: "Вопросы о HelloWorld")
                                Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                                SettingsRow(icon: "lightbulb.fill", iconColor: .yellow, title: "Возможности HelloWorld")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                        .background(Color.black)
                    }
                    .background(Color.black)
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                    }
                )
            }
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffset = value
            }
            
            // Верхние кнопки поверх всего
            VStack(spacing: 0) {
                HStack {
                    Button(action: {}) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 8))
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditingProfile = true
                        }
                    }) {
                        Text("Изм.")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 16, paddingVertical: 8))
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
            
            if isEditingProfile {
                EditProfileView(isPresented: $isEditingProfile, isAuthenticated: $isAuthenticated)
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            refreshData()
        }
        .onChange(of: isEditingProfile) { newValue in
            if !newValue {
                refreshData()
            }
        }
    }
    
    // Логика прозрачности и масштаба для анимаций
    private var avatarOpacity: Double {
        if scrollOffset >= 0 { return 1.0 }
        let progress = -scrollOffset / (expandedAvatarHeight - 150)
        return Double(max(0, 1 - progress))
    }
    
    private var collapsedAvatarOpacity: Double {
        if scrollOffset >= 0 { return 0.0 }
        let progress = -scrollOffset / (expandedAvatarHeight - 200)
        return Double(min(1, progress))
    }
    
    private var collapsedAvatarScale: CGFloat {
        if scrollOffset >= 0 { return 0.5 }
        let progress = -scrollOffset / (expandedAvatarHeight - 200)
        return 0.5 + (min(1, progress) * 0.5)
    }
    
    private func refreshData() {
        username = UserDefaults.standard.string(forKey: "saved_username") ?? "problem"
        firstName = UserDefaults.standard.string(forKey: "saved_firstName") ?? ""
        lastName = UserDefaults.standard.string(forKey: "saved_lastName") ?? ""
        tag = UserDefaults.standard.string(forKey: "saved_tag") ?? ""
        phoneNumber = UserDefaults.standard.string(forKey: "saved_phone") ?? "+7 (999) 123-45-67"
        
        if let base64 = UserDefaults.standard.string(forKey: "saved_avatar"),
           let data = Data(base64Encoded: base64),
           let image = UIImage(data: data) {
            avatarImage = image
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// Повторное объявление вспомогательных структур (если они не вынесены в отдельные файлы)
// В реальном проекте их лучше держать в Common или Styles
