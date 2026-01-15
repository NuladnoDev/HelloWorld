import SwiftUI

@available(iOS 15.0, *)
struct EditTagView: View {
    @Binding var tag: String
    @Environment(\.presentationMode) var presentationMode
    @State private var tempTag: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button("Отмена") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 20, paddingVertical: 10))
                    
                    Spacer()
                    
                    Text("Имя пользователя")
                        .font(.system(size: 16, weight: .bold)) // Немного уменьшил шрифт заголовка, чтобы влезло
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button("Готово") {
                        tag = tempTag
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 20, paddingVertical: 10))
                }
                .padding(.horizontal)
                .padding(.top, 15)
                .background(Color.black)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ИМЯ ПОЛЬЗОВАТЕЛЯ")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 16)
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 28) // Увеличил скругление до 28
                                    .fill(Color(white: 0.12))
                                
                                TextField("", text: $tempTag, prompt: Text("Имя пользователя").foregroundColor(.white.opacity(0.3)))
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20) // Увеличил паддинг для большого скругления
                                    .padding(.vertical, 12)
                            }
                            .frame(height: 54) // Чуть выше для соответствия скруглению 28
                            .padding(.horizontal, 16)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Вы можете выбрать публичное имя пользователя в нашем приложении. В этом случае другие люди смогут найти Вас по такому имени и связаться, не зная Вашего телефона.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text("Можно использовать a–z, 0–9 и _. Минимальная длина — 5 символов.")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.6))
                            
                            if !tempTag.isEmpty {
                                Text("По этой ссылке откроется диалог с Вами:\nhttps://hw.me/\(tempTag)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            tempTag = tag
        }
    }
}
