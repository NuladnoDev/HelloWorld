import SwiftUI

@available(iOS 15.0, *)
struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Голубой круг вместо лого ТГ
                Circle()
                    .fill(Color.blue)
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 20) {
                    Text(isRegistering ? "Создать аккаунт" : "Вход")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 15) {
                    TextField("Имя пользователя", text: $username)
                        .padding()
                        .background(Color(white: 0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .autocapitalization(.none)
                    
                    SecureField("Пароль", text: $password)
                        .padding()
                        .background(Color(white: 0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 30)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    handleAuth()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(isRegistering ? "Зарегистрироваться" : "Продолжить")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .font(.headline)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)
                .disabled(isLoading)
                
                Button(action: {
                    isRegistering.toggle()
                }) {
                    Text(isRegistering ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Создать")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
        }
    }
    
    private func handleAuth() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Симуляция работы с ядром
        DispatchQueue.global(qos: .userInitiated).async {
            // В реальном приложении здесь будет вызов C++ ядра для генерации ключей или входа
            if let keys = CoreWrapper.shared.generateKeyPair() {
                print("DEBUG: Generated keys for \(username): \(keys.publicKey)")
                
                DispatchQueue.main.async {
                    isLoading = false
                    isAuthenticated = true
                }
            } else {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Ошибка при работе с ядром"
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(isAuthenticated: .constant(false))
    }
}
