import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Верхняя панель настроек
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
                    
                    // Секция профиля (Аватар + Тег + Имя)
                    VStack(spacing: 12) {
                        ZStack {
                            // Свечение вокруг аватарки
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .blur(radius: 20)
                            
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color(red: 0.3, green: 0.7, blue: 1.0), .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                            
                            Text("L")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 4) {
                            Text("@lario")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Laryion")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Группы настроек
                    VStack(spacing: 20) {
                        // Первая группа (синие кнопки)
                        SettingsGroup {
                            SettingsRow(icon: "face.smiling", iconColor: .blue, title: "Сменить эмодзи-статус", textColor: .blue)
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "wand.and.stars", iconColor: .blue, title: "Изменить цвет профиля", textColor: .blue)
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "camera.fill", iconColor: .blue, title: "Выбрать фотографию", textColor: .blue)
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "at", iconColor: .blue, title: "Выбрать имя пользователя", textColor: .blue)
                        }
                        
                        // Группа аккаунтов
                        SettingsGroup {
                            SettingsRow(icon: "person.circle.fill", iconColor: .green, title: "tagoff acc", showArrow: false)
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "plus", iconColor: .blue, title: "Добавить аккаунт", textColor: .blue, showArrow: false)
                        }
                        
                        // Группа профиля и кошелька
                        SettingsGroup {
                            SettingsRow(icon: "person.crop.circle.badge.exclamationmark", iconColor: .red, title: "Мой профиль")
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "creditcard.fill", iconColor: .blue, title: "Кошелёк")
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
                            SettingsRow(icon: "bubble.left.and.bubble.right.fill", iconColor: .cyan, title: "Вопросы о Telegram")
                            Divider().background(Color.white.opacity(0.05)).padding(.leading, 44)
                            SettingsRow(icon: "lightbulb.fill", iconColor: .yellow, title: "Возможности Telegram")
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
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

@available(iOS 15.0, *)
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var textColor: Color = .white
    var showArrow: Bool = true
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor)
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
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
