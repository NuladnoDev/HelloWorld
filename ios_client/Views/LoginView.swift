import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Telegram-like Logo
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .padding(25)
                    .background(Color.blue)
                    .clipShape(Circle())
                
                VStack(spacing: 20) {
                    Text(isRegistering ? "Создать аккаунт" : "Вход")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Введите данные для доступа к HelloWorld")
                        .font(.subheadline)
                        .foregroundColor(.gray)
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
                
                Button(action: {
                    // Logic will be added here
                }) {
                    Text(isRegistering ? "Зарегистрироваться" : "Продолжить")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
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
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
