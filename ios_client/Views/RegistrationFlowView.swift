import SwiftUI

@available(iOS 15.0, *)
struct RegistrationFlowView: View {
    @Binding var isAuthenticated: Bool
    @State private var currentStep: Int = 1
    
    // Данные регистрации
    @State private var phoneNumber: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var tag: String = ""
    @State private var selectedImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                if currentStep == 1 {
                    PhoneStepView(phoneNumber: $phoneNumber, nextStep: { currentStep = 2 })
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if currentStep == 2 {
                    NameStepView(firstName: $firstName, lastName: $lastName, nextStep: { currentStep = 3 })
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if currentStep == 3 {
                    TagStepView(tag: $tag, nextStep: { currentStep = 4 }, skipStep: { currentStep = 4 })
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                } else if currentStep == 4 {
                    AvatarStepView(selectedImage: $selectedImage, finish: {
                        completeRegistration()
                    }, skipStep: {
                        completeRegistration()
                    })
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
        }
    }
    
    private func completeRegistration() {
        // Сохраняем данные
        let finalUsername = tag.isEmpty ? firstName.lowercased() : tag
        UserDefaults.standard.set(finalUsername, forKey: "saved_username")
        UserDefaults.standard.set(firstName, forKey: "saved_firstName")
        UserDefaults.standard.set(lastName, forKey: "saved_lastName")
        UserDefaults.standard.set(tag, forKey: "saved_tag")
        UserDefaults.standard.set(phoneNumber, forKey: "saved_phone")
        
        withAnimation {
            isAuthenticated = true
        }
    }
}

// MARK: - Step 1: Phone
@available(iOS 15.0, *)
struct PhoneStepView: View {
    @Binding var phoneNumber: String
    var nextStep: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer().frame(height: 40)
            
            // Большая иконка (SVG стиль)
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Ваш номер телефона")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Пожалуйста, введите свой номер телефона.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            TextField("+7 (999) 000-00-00", text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding()
                .background(Color(white: 0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: nextStep) {
                Text("Далее")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .disabled(phoneNumber.count < 5)
            .opacity(phoneNumber.count < 5 ? 0.5 : 1.0)
        }
    }
}

// MARK: - Step 2: Name
@available(iOS 15.0, *)
struct NameStepView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    var nextStep: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer().frame(height: 40)
            
            // Большая иконка (SVG стиль)
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Ваше имя")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Введите ваше имя и фамилию.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 15) {
                TextField("Имя", text: $firstName)
                    .padding()
                    .background(Color(white: 0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                TextField("Фамилия (необязательно)", text: $lastName)
                    .padding()
                    .background(Color(white: 0.1))
                    .cornerRadius(12)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: nextStep) {
                Text("Далее")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .disabled(firstName.isEmpty)
            .opacity(firstName.isEmpty ? 0.5 : 1.0)
        }
    }
}

// MARK: - Step 3: Tag
@available(iOS 15.0, *)
struct TagStepView: View {
    @Binding var tag: String
    var nextStep: () -> Void
    var skipStep: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Spacer()
                Button(action: skipStep) {
                    Text("Пропустить")
                        .foregroundColor(.blue)
                        .font(.system(size: 17))
                }
                .padding()
            }
            
            // Большая иконка (SVG стиль)
            Image(systemName: "at.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Выбор тега")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Выберите уникальное имя пользователя (@тег).")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            HStack {
                Text("@")
                    .foregroundColor(.white.opacity(0.5))
                TextField("username", text: $tag)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color(white: 0.1))
            .cornerRadius(12)
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: nextStep) {
                Text("Далее")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .disabled(tag.isEmpty)
            .opacity(tag.isEmpty ? 0.5 : 1.0)
        }
    }
}

// MARK: - Step 4: Avatar
@available(iOS 15.0, *)
struct AvatarStepView: View {
    @Binding var selectedImage: UIImage?
    var finish: () -> Void
    var skipStep: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Spacer()
                Button(action: skipStep) {
                    Text("Пропустить")
                        .foregroundColor(.blue)
                        .font(.system(size: 17))
                }
                .padding()
            }
            
            // Большая иконка (SVG стиль)
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("Фотография профиля")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Добавьте фотографию, чтобы друзья могли вас узнать.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            ZStack {
                Circle()
                    .fill(Color(white: 0.1))
                    .frame(width: 150, height: 150)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                }
            }
            .onTapGesture {
                // В реальности здесь открытие ImagePicker
            }
            
            Spacer()
            
            Button(action: finish) {
                Text("Готово")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
    }
}
