import SwiftUI

@available(iOS 15.0, *)
struct EditProfileView: View {
    @Binding var isPresented: Bool
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var bio: String = ""
    @State private var username: String = UserDefaults.standard.string(forKey: "saved_username") ?? ""
    @State private var phoneNumber: String = "+7 (999) 123-45-67"
    @State private var birthDate: String = "1 апр 1988"
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Хедер с кнопками Отмена и Готово
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        }) {
                            Text("Отмена")
                                .font(.system(size: 17))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 20, paddingVertical: 10))
                        
                        Spacer()
                        
                        Button(action: {
                            // Сохранение и выход
                            UserDefaults.standard.set(username, forKey: "saved_username")
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        }) {
                            Text("Готово")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 20, paddingVertical: 10))
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    
                    // Аватарка с кнопкой камеры
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.15))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {}) {
                            Text("Выбрать фотографию")
                                .font(.system(size: 17))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Поля Имя и Фамилия
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsGroup {
                            TextField("", text: $firstName, prompt: Text("Имя").foregroundColor(.white.opacity(0.3)))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.leading, 16)
                            
                            TextField("", text: $lastName, prompt: Text("Фамилия").foregroundColor(.white.opacity(0.3)))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                        }
                        
                        Text("Укажите имя и, если хотите, добавьте фотографию для Вашего профиля.")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 16)
                    }
                    
                    // Поле BIO
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsGroup {
                            TextField("", text: $bio, prompt: Text("bio").foregroundColor(.white.opacity(0.3)))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .foregroundColor(.white)
                        }
                        
                        Text("Вы можете добавить несколько строк о себе. В настроиках можно выбрать, кому они будут видны.")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 16)
                    }
                    
                    // День рождения
                    VStack(alignment: .leading, spacing: 8) {
                        SettingsGroup {
                            HStack {
                                Text("День рождения")
                                    .foregroundColor(.white)
                                Spacer()
                                Text(birthDate)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        
                        Text("Ваш день рождения могут видеть только контакты. Изменить >")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 16)
                    }
                    
                    // Остальные пункты
                    SettingsGroup {
                        SettingsRow(icon: "phone.fill", iconColor: .green, title: "Сменить номер", showArrow: true)
                            .overlay(
                                Text(phoneNumber)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.trailing, 40)
                            , alignment: .trailing)
                        
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                        
                        SettingsRow(icon: "at", iconColor: .blue, title: "Имя пользователя", showArrow: true)
                        
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                        
                        SettingsRow(icon: "paintpalette.fill", iconColor: .cyan, title: "Персональные цвета", showArrow: true)
                        
                        Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                        
                        SettingsRow(icon: " tv.fill", iconColor: .blue, title: "Канал", showArrow: true)
                            .overlay(
                                Text("Добавить")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.trailing, 40)
                            , alignment: .trailing)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
    }
}

@available(iOS 15.0, *)
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}
