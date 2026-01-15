import SwiftUI

@available(iOS 15.0, *)
struct EditProfileView: View {
    @Binding var isPresented: Bool
    @Binding var isAuthenticated: Bool
    @State private var firstName: String = UserDefaults.standard.string(forKey: "saved_firstName") ?? ""
    @State private var lastName: String = UserDefaults.standard.string(forKey: "saved_lastName") ?? ""
    @State private var tag: String = UserDefaults.standard.string(forKey: "saved_tag") ?? ""
    @State private var bio: String = ""
    @State private var username: String = UserDefaults.standard.string(forKey: "saved_username") ?? ""
    @State private var phoneNumber: String = UserDefaults.standard.string(forKey: "saved_phone") ?? "+7 (999) 123-45-67"
    @State private var birthDate = Date()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Хедер с кнопками Отмена и Готово
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
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
                                UserDefaults.standard.set(firstName, forKey: "saved_firstName")
                                UserDefaults.standard.set(lastName, forKey: "saved_lastName")
                                UserDefaults.standard.set(tag, forKey: "saved_tag")
                                UserDefaults.standard.set(username, forKey: "saved_username")
                                withAnimation(.easeInOut(duration: 0.3)) {
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
                        
                        // Аватарка (синхронизирована с SettingsView)
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(red: 0.3, green: 0.7, blue: 1.0), .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 110, height: 110)
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
                            .padding(.top, -35) // Точное совпадение с SettingsView
                            
                            Button(action: {}) {
                                Text("Выбрать фотографию")
                                    .font(.system(size: 17))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 5) // Совпадает с Profile VStack padding в SettingsView
                        .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        Color.black // Убрал серую заливку, оставил черный фон
                            .edgesIgnoringSafeArea(.top)
                    )
                    
                    VStack(spacing: 24) {
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
                                    DatePicker("", selection: $birthDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
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
                                .overlay(
                                    TextField("", text: $tag, prompt: Text("Установить тег").foregroundColor(.white.opacity(0.3)))
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(.trailing, 40)
                                , alignment: .trailing)
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                            
                            SettingsRow(icon: "paintpalette.fill", iconColor: .cyan, title: "Персональные цвета", showArrow: true)
                            
                            Divider().background(Color.white.opacity(0.1)).padding(.leading, 50)
                            
                            SettingsRow(icon: "tv.fill", iconColor: .blue, title: "Канал", showArrow: true)
                                .overlay(
                                    Text("Добавить")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.5))
                                        .padding(.trailing, 40)
                                , alignment: .trailing)
                        }
                        
                        // Кнопка Выйти
                        SettingsGroup {
                            Button(action: {
                                withAnimation {
                                    isAuthenticated = false
                                    isPresented = false
                                }
                                UserDefaults.standard.set(false, forKey: "is_authenticated")
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.red)
                                        .frame(width: 28, height: 28)
                                    
                                    Text("Выйти")
                                        .font(.system(size: 17))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

@available(iOS 15.0, *)
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(isPresented: .constant(true), isAuthenticated: .constant(true))
            .preferredColorScheme(.dark)
    }
}
