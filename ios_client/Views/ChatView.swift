import SwiftUI

@available(iOS 15.0, *)
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
    let time: String
    let hasTail: Bool
    var image: String? = nil
    var isVideo: Bool = false
    var isPhoto: Bool = false
    var isEmoji: Bool = false
}

@available(iOS 15.0, *)
struct LiquidGlassView<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 28
    
    init(cornerRadius: CGFloat = 28, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.black.opacity(0.4))
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.thinMaterial)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.15), .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
            )
    }
}

@available(iOS 15.0, *)
struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Привет! Как дела?", isMe: false, time: "10:00", hasTail: true),
        ChatMessage(text: "Привет! Все отлично, работаю над новым проектом. А у тебя?", isMe: true, time: "10:01", hasTail: true),
        ChatMessage(text: "Тоже неплохо. Помнишь, я говорил про тот дизайн?", isMe: false, time: "10:02", hasTail: true),
        ChatMessage(text: "Да, конечно. Есть какие-то наработки?", isMe: true, time: "10:03", hasTail: true),
        ChatMessage(text: "Да, вот посмотри скриншот.", isMe: false, time: "10:04", hasTail: true),
        ChatMessage(text: "", isMe: false, time: "10:04", hasTail: true, image: "avatar_placeholder", isPhoto: true),
        ChatMessage(text: "Ого, выглядит очень круто! Мне нравится цветовая схема.", isMe: true, time: "10:05", hasTail: true),
        ChatMessage(text: "Спасибо! Я еще хочу добавить пару деталей.", isMe: false, time: "10:06", hasTail: true),
        ChatMessage(text: "Давай, жду обновлений.", isMe: true, time: "10:07", hasTail: true),
        ChatMessage(text: "Кстати, ты видел новые функции в приложении?", isMe: false, time: "10:08", hasTail: true),
        ChatMessage(text: "Пока нет, сейчас гляну.", isMe: true, time: "10:09", hasTail: true),
        ChatMessage(text: "Там добавили очень удобный поиск и фильтры.", isMe: false, time: "10:10", hasTail: true),
        ChatMessage(text: "Это как раз то, чего не хватало!", isMe: true, time: "10:11", hasTail: true),
        ChatMessage(text: "Согласен, теперь пользоваться одно удовольствие.", isMe: false, time: "10:12", hasTail: true)
    ]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                chatHeader
                
                // Список сообщений
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            Spacer(minLength: 10)
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        if let lastMessage = messages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                
                inputBar
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Включаем свайп назад даже при скрытом navigation bar
            UINavigationController.enableSwipeBack()
        }
    }
    
    private var chatHeader: some View {
        HStack(spacing: 8) {
            // Кнопка назад
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
            }
            .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 10))
            
            // Инфо-панель
            LiquidGlassView(cornerRadius: 20) {
                HStack(spacing: 0) {
                    Spacer()
                    VStack(alignment: .center, spacing: 2) {
                        Text("hikka")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("был(а) недавно")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.vertical, 6)
            }
            
            // Аватарка
            Button(action: {}) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.8))
                    )
            }
            .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 4, paddingVertical: 4))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.3))
    }
    
    private var inputBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // Кнопка скрепки
                Button(action: {}) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                }
                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 10))
                
                // Поле ввода
                LiquidGlassView(cornerRadius: 28) {
                    HStack(spacing: 8) {
                        Button(action: {}) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 20))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.leading, 12)
                        
                        TextField("Сообщение", text: $messageText)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        
                        if !messageText.isEmpty {
                            Button(action: {
                                if !messageText.isEmpty {
                                    messages.append(ChatMessage(text: messageText, isMe: true, time: getCurrentTime(), hasTail: true))
                                    messageText = ""
                                }
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.blue)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .frame(height: 44)
                }
                
                // Кнопка микрофона (если текст пустой)
                if messageText.isEmpty {
                    Button(action: {}) {
                        Image(systemName: "mic")
                            .font(.system(size: 20))
                    }
                    .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 10))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.2))
        }
    }
    
    private func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

// Расширение для включения свайпа назад при скрытом навигейшн баре
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
    static func enableSwipeBack() {
        // Пустой метод для вызова, инициализация происходит в viewDidLoad
    }
}

@available(iOS 15.0, *)
struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isMe { Spacer() }
            
            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 4) {
                if message.isEmoji {
                    Text(message.text)
                        .font(.system(size: 80))
                    Text(message.time)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 4)
                } else if message.isPhoto {
                    ZStack(alignment: .bottomTrailing) {
                        Image("avatar_placeholder") // Заглушка для фото
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 250, maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        
                        HStack(spacing: 4) {
                            Text(message.time)
                                .font(.system(size: 11))
                            if message.isMe {
                                TelegramCheckmarks()
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                        .padding(8)
                    }
                } else if message.isVideo {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color(white: 0.2))
                            .frame(width: 250, height: 250)
                            .overlay(
                                Image(systemName: "play.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                        
                        HStack(spacing: 4) {
                            Text("0:28")
                                .font(.system(size: 11))
                            Image(systemName: "speaker.slash.fill")
                                .font(.system(size: 10))
                            Text(message.time)
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                        .padding(15)
                    }
                } else {
                    HStack(alignment: .bottom, spacing: 8) {
                        Text(message.text)
                            .font(.system(size: 16))
                        
                        HStack(spacing: 2) {
                            Text(message.time)
                                .font(.system(size: 11))
                            if message.isMe {
                                TelegramCheckmarks()
                            }
                        }
                        .foregroundColor(message.isMe ? .white.opacity(0.7) : .white.opacity(0.5))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isMe ? Color(red: 0.4, green: 0.3, blue: 0.8) : Color(white: 0.15))
                    .cornerRadius(18)
                }
            }
            
            if !message.isMe { Spacer() }
        }
    }
}

@available(iOS 15.0, *)
struct TelegramCheckmarks: View {
    var body: some View {
        HStack(spacing: -5) {
            Image(systemName: "checkmark")
                .font(.system(size: 7, weight: .bold))
            Image(systemName: "checkmark")
                .font(.system(size: 7, weight: .bold))
        }
    }
}
