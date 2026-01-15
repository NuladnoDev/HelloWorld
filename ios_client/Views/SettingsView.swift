import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "saved_username") ?? "problem"
    @State private var phoneNumber: String = "+7 (999) 123-45-67"
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Хедер со сплошной заливкой и мягким свечением
                    ZStack(alignment: .top) {
                        // Сплошной темно-серый цвет фона
                        Color(red: 0.05, green: 0.07, blue: 0.12)
                            .frame(height: 320)
                            .edgesIgnoringSafeArea(.top)
                        
                        // Мягкое растушеванное белое свечение вокруг аватарки
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.06),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 160
                        )
                        .frame(width: 400, height: 400)
                        .offset(y: -50) // Центрируем свечение по аватарке
                        
                        VStack(spacing: 0) {
                            // Верхняя панель кнопок
                            HStack {
                                Button(action: {}) {
                                    Image(systemName: "square.grid.2x2.fill")
                                        .font(.system(size: 20))
                                }
                                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 12))
                                
                                Spacer()
                                
                                Button(action: {
                                    UserDefaults.standard.set(false, forKey: "is_authenticated")
                                }) {
                                    Text("Изм.")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 20, paddingVertical: 10))
                            }
                            .padding(.horizontal)
                            .padding(.top, 15) // Опустил кнопки на ~1мм (было 10)
                            
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
                                .padding(.top, -15) // Поднял аватарку еще выше (было -5)
                                
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
                            .padding(.top, 5)
                        }
                    }
                    .padding(.bottom, -20) // Уменьшил отступ после профиля до кнопок
                    
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
                        
                        // Группа выхода
                        SettingsGroup {
                            Button(action: {
                                UserDefaults.standard.set(false, forKey: "is_authenticated")
                                // Перезапускаем приложение или меняем состояние через NotificationCenter
                                NotificationCenter.default.post(name: NSNotification.Name("LogOut"), object: nil)
                            }) {
                                SettingsRow(icon: "rectangle.portrait.and.arrow.right", iconColor: .red, title: "Выйти", textColor: .red, showArrow: false)
                            }
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
