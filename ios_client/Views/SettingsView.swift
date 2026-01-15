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
    @State private var isAvatarExpanded = false
    private let collapsedAvatarSize: CGFloat = 110
    private let expandedAvatarHeight: CGFloat = 450
    
    var fullName: String {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? username : name
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Расширенная аватарка (FullScreen overlay при клике)
            if isAvatarExpanded, let image = avatarImage {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isAvatarExpanded = false
                            }
                        }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(20)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Верхняя часть с градиентным фоном и информацией
                    ZStack(alignment: .bottom) {
                        // Фоновый градиент или размытое фото как в Telegram
                        if let image = avatarImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 320)
                                .blur(radius: 50)
                                .opacity(0.3)
                        } else {
                            LinearGradient(
                                colors: [Color(red: 0.1, green: 0.1, blue: 0.15), .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 320)
                        }
                        
                        // Контент профиля (Имя, телефон/тег)
                        VStack(spacing: 16) {
                            // Аватарка
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isAvatarExpanded = true
                                }
                            }) {
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
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(PressDetectorStyle(isPressed: .constant(false))) // Используем стиль для нажатия без анимации
                            
                            VStack(spacing: 4) {
                                Text(fullName)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(tag.isEmpty ? phoneNumber : "@\(tag)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(.bottom, 40)
                    }
                    .frame(height: 320)
                    .clipShape(Rectangle())
                    
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
                        .padding(.top, 10)
                            
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
                    }
                }
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
                    .buttonStyle(SettingsButtonStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditingProfile = true
                        }
                    }) {
                        Text("Изм.")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(SettingsButtonStyle())
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

// Компоненты для настроек
@available(iOS 15.0, *)
struct SettingsGroup<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(white: 0.12))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

@available(iOS 15.0, *)
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var textColor: Color = .white
    var showArrow: Bool = true
    var noIconBackground: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 16) {
                ZStack {
                    if !noIconBackground {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(iconColor)
                            .frame(width: 28, height: 28)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(noIconBackground ? iconColor : .white)
                }
                .frame(width: 28, height: 28)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(textColor)
                
                Spacer()
                
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.2))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(SettingsButtonStyle())
    }
}

@available(iOS 15.0, *)
struct SettingsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.1) : Color.clear)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

@available(iOS 15.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isAuthenticated: .constant(true))
            .preferredColorScheme(.dark)
    }
}
