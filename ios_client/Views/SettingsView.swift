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
    
    var fullName: String {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? username : name
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Хедер с контентом и растягивающимся фоном
                    VStack(spacing: 0) {
                        // Верхняя панель кнопок
                        HStack {
                            Button(action: {}) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.system(size: 20))
                            }
                            .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 12))
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isEditingProfile = true
                                }
                            }) {
                                Text("Изм.")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 20, paddingVertical: 10))
                        }
                        .padding(.horizontal)
                        .padding(.top, 15)
                        
                        // Секция профиля (Аватар + Тег + Номер + Имя)
                        VStack(spacing: 12) { // Увеличил отступ между аватаром и текстом (был 4)
                            ZStack {
                                if let image = avatarImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [Color(red: 0.3, green: 0.7, blue: 1.0), .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 110, height: 110)
                                }
                            }
                            .padding(.top, -35) // Опустил аватарку ниже (было -100)
                            
                            VStack(spacing: 2) {
                                Text(fullName)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                                
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
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        GeometryReader { geo in
                            let minY = geo.frame(in: .global).minY
                            Color(white: 0.1)
                                .offset(y: minY > 0 ? -minY : 0)
                                .frame(height: minY > 0 ? 215 + minY : 215) // Уменьшил высоту заливки (было 250)
                        }
                    )
                    
                    // Группы настроек
                    VStack(spacing: 20) {
                        // Первая группа (без фона иконок)
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
                        .padding(.top, 15) // Добавил отступ сверху вместо отрицательного, чтобы не наезжало на тег
                        
                        // Группа аккаунтов
                        SettingsGroup {
                            SettingsRow(icon: "person.circle.fill", iconColor: .green, title: username, showArrow: false)
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "plus", iconColor: .blue, title: "Добавить аккаунт", textColor: .blue, showArrow: false)
                        }
                        
                        // Группа профиля и подарков
                        SettingsGroup {
                            SettingsRow(icon: "person.crop.circle.badge.exclamationmark", iconColor: .red, title: "Мой профиль")
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "gift.fill", iconColor: .blue, title: "Мальчонка Edition")
                        }
                        
                        // Дополнительные тестовые кнопки
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
            
            if isEditingProfile {
                EditProfileView(isPresented: $isEditingProfile, isAuthenticated: $isAuthenticated)
                    .transition(.opacity)
                    .zIndex(1)
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
        .clipShape(RoundedRectangle(cornerRadius: 22)) // Еще больше увеличил скругление (было 18)
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
