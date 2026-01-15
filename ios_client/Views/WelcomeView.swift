import SwiftUI

@available(iOS 16.0, *)
struct WelcomeView: View {
    @Binding var showLogin: Bool
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Голубой круг вместо лого
                Circle()
                    .fill(Color.blue)
                    .frame(width: 140, height: 140)
                    .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                
                VStack(spacing: 10) {
                    Text("HelloWorld")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Быстро. Безопасно. Удобно.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Кнопка "Продолжить" в стиле Liquid Glass
                Button(action: {
                    withAnimation(.spring()) {
                        showLogin = true
                    }
                }) {
                    Text("Продолжить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.8))
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            }
                        )
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
    }
}

@available(iOS 15.0, *)
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(showLogin: .constant(false))
    }
}
