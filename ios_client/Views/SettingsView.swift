import SwiftUI

// Вспомогательная структура для создания AnyShape
@available(iOS 15.0, *)
struct AnyShape: Shape {
    private let _path: (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        _path = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}

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
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Геометрия для отслеживания скролла
                    GeometryReader { geo in
                        Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .global).minY)
                    }
                    .frame(height: 0)

                    // Верхняя часть с анимированной аватаркой
                    ZStack(alignment: .bottom) {
                        // Фон (размытие для объема, когда расширена)
                        if isAvatarExpanded, let image = avatarImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: isAvatarExpanded ? expandedAvatarHeight : 320)
                                .blur(radius: 40)
                                .opacity(0.4)
                        } else {
                            LinearGradient(
                                colors: [Color(red: 0.1, green: 0.1, blue: 0.15), .black],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 320)
                        }
                        
                        // Контент профиля
                        VStack(spacing: isAvatarExpanded ? 0 : 16) {
                            // Аватарка
                            Button(action: {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                                    isAvatarExpanded.toggle()
                                }
                            }) {
                                ZStack {
                                    if let image = avatarImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(
                                                width: isAvatarExpanded ? UIScreen.main.bounds.width : collapsedAvatarSize,
                                                height: isAvatarExpanded ? expandedAvatarHeight : collapsedAvatarSize
                                            )
                                            .clipShape(isAvatarExpanded ? AnyShape(Rectangle()) : AnyShape(Circle()))
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
                                .shadow(color: .black.opacity(isAvatarExpanded ? 0 : 0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(PressDetectorStyle(isPressed: .constant(false)))
                            
                            // Информация под аватаркой (скрывается или сдвигается при расширении)
                            if !isAvatarExpanded {
                                VStack(spacing: 4) {
                                    Text(fullName)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text(tag.isEmpty ? phoneNumber : "@\(tag)")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                .padding(.bottom, 40)
                            }
                        }
                    }
                    .frame(height: isAvatarExpanded ? expandedAvatarHeight : 320)
                    .clipShape(Rectangle())
                    
                    // Группы настроек
                    VStack(spacing: 20) {
                        if isAvatarExpanded {
                            // Имя и телефон внутри списка, когда аватарка расширена (как в ТГ)
                            SettingsGroup {
                                HStack(spacing: 15) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(fullName)
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                        Text(tag.isEmpty ? phoneNumber : "@\(tag)")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

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
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                let threshold: CGFloat = -20
                if value < threshold && isAvatarExpanded {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isAvatarExpanded = false
                    }
                }
                scrollOffset = value
            }
            
            // Верхние кнопки поверх всего
            VStack(spacing: 0) {
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

@available(iOS 15.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isAuthenticated: .constant(true))
            .preferredColorScheme(.dark)
    }
}
