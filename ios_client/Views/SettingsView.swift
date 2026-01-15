import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @State private var username: String = "jsoaai"
    @State private var phoneNumber: String = "+7 (999) 123-45-67"
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Хедер с градиентом
                    ZStack(alignment: .top) {
                        // Темная заливка как на скрине (темнее цвета аватарки)
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.15, blue: 0.25).opacity(0.8),
                                Color(red: 0.05, green: 0.07, blue: 0.12),
                                .black
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 380)
                        .edgesIgnoringSafeArea(.top)
                        
                        VStack(spacing: 0) {
                            // Верхняя панель кнопок
                            HStack {
                                Button(action: {}) {
                                    Image(systemName: "square.grid.2x2.fill")
                                        .font(.system(size: 20))
                                }
                                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 12))
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    Text("Изм.")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 20, paddingVertical: 10))
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Секция профиля (Аватар + Тег + Номер + Имя)
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(
                                            colors: [Color(red: 0.3, green: 0.7, blue: 1.0), .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .frame(width: 110, height: 110)
                                    
                                    Text(String(username.prefix(1)).uppercased())
                                        .font(.system(size: 44, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .padding(.top, -5) // Еще выше
                                
                                VStack(spacing: 4) {
                                    Text("@\(username)")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    HStack(spacing: 6) {
                                        Image(systemName: "info.circle")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.5))
                                        Text(phoneNumber)
                                            .font(.system(size: 15))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    
                    // Группы настроек
                    VStack(spacing: 20) {
                        // Первая группа (без фона иконок)
                        SettingsGroup {
                            SettingsRow(icon: "face.smiling", iconColor: .blue, title: "Сменить эмодзи-статус", textColor: .blue, noIconBackground: true)
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "wand.and.stars", iconColor: .blue, title: "Изменить цвет профиля", textColor: .blue, noIconBackground: true)
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "camera.fill", iconColor: .blue, title: "Выбрать фотографию", textColor: .blue, noIconBackground: true)
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "at", iconColor: .blue, title: "Выбрать имя пользователя", textColor: .blue, noIconBackground: true)
                        }
                        
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
                            SettingsRow(icon: "gift.fill", iconColor: .blue, title: "Gifts for the boy")
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
        .clipShape(RoundedRectangle(cornerRadius: 18)) // Увеличил скругление
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
    
    var body: some View {
        Button(action: {}) {
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
        }
    }
}

@available(iOS 15.0, *)
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
