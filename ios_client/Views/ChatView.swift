import SwiftUI
import PhotosUI
import AVKit

@available(iOS 16.0, *)
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
    let time: String
    let hasTail: Bool
    var image: UIImage? = nil
    var videoURL: URL? = nil
    var isVideo: Bool = false
    var isPhoto: Bool = false
    var isEmoji: Bool = false
}

@available(iOS 16.0, *)
struct MediaViewer: View {
    let message: ChatMessage
    @Binding var isPresented: Bool
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
                .opacity(Double(1.0 - (abs(offset.height) / 500)))
            
            // Основной контент (фото или видео)
            VStack {
                Spacer()
                
                if let videoURL = message.videoURL {
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(contentMode: .fit)
                } else if let image = message.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation
                                }
                                .onEnded { value in
                                    if abs(offset.height) > 150 {
                                        isPresented = false
                                    } else {
                                        withAnimation(.spring()) {
                                            offset = .zero
                                        }
                                    }
                                }
                        )
                }
                
                Spacer()
            }
            
            // Верхняя панель
            VStack {
                HStack {
                    Button(action: { isPresented = false }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Назад")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                    }
                    
                    Spacer()
                    
                    Text("1 из 1") // В реальном приложении здесь будет индекс
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Image(systemName: "text.viewfinder")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 12)
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.4), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
            }
            
            // Нижняя панель
            VStack {
                Spacer()
                
                HStack {
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    Text("вчера в \(message.time)")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "pencil.tip.crop.circle") // Заглушка для иконки редактирования/A
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 40)
                .padding(.top, 20)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .transition(.opacity)
        .edgesIgnoringSafeArea(.all)
    }
}

@available(iOS 16.0, *)
struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText: String = ""
    @State private var showMediaPicker = false
    @State private var selectedMediaItem: PhotosPickerItem? = nil
    @State private var selectedViewerMessage: ChatMessage? = nil
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Привет! Как дела?", isMe: false, time: "10:00", hasTail: true),
        ChatMessage(text: "Привет! Все отлично, работаю над новым проектом. А у тебя?", isMe: true, time: "10:01", hasTail: true),
        ChatMessage(text: "Тоже неплохо. Помнишь, я говорил про тот дизайн?", isMe: false, time: "10:02", hasTail: true),
        ChatMessage(text: "Да, конечно. Есть какие-то наработки?", isMe: true, time: "10:03", hasTail: true),
        ChatMessage(text: "Да, вот посмотри скриншот.", isMe: false, time: "10:04", hasTail: true),
        ChatMessage(text: "", isMe: false, time: "10:04", hasTail: true, image: UIImage(systemName: "photo.artframe"), isPhoto: true)
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
                                MessageBubble(message: msg) {
                                    if msg.isPhoto || msg.isVideo {
                                        selectedViewerMessage = msg
                                    }
                                }
                                .id(msg.id)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
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
            
            if let msg = selectedViewerMessage {
                MediaViewer(message: msg, isPresented: Binding(
                    get: { selectedViewerMessage != nil },
                    set: { if !$0 { selectedViewerMessage = nil } }
                ))
                .zIndex(10)
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .photosPicker(isPresented: $showMediaPicker, selection: $selectedMediaItem, matching: .any(of: [.images, .videos]))
        .onChange(of: selectedMediaItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        messages.append(ChatMessage(text: "", isMe: true, time: getCurrentTime(), hasTail: true, image: uiImage, isPhoto: true))
                    }
                } else if let movie = try? await newItem?.loadTransferable(type: VideoModel.self) {
                    await MainActor.run {
                        messages.append(ChatMessage(text: "", isMe: true, time: getCurrentTime(), hasTail: true, videoURL: movie.url, isVideo: true))
                    }
                }
                selectedMediaItem = nil
            }
        }
        .onAppear {
            UINavigationController.enableSwipeBack()
        }
    }
    
    private var inputBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                // Кнопка скрепки
                Button(action: { showMediaPicker = true }) {
                    Image(systemName: "paperclip.circle.fill")
                        .font(.system(size: 26))
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 10, paddingVertical: 8))
                
                // Поле ввода
                LiquidGlassView(cornerRadius: 28) {
                    HStack(spacing: 8) {
                        TextField("Сообщение", text: $messageText)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(.leading, 16)
                        
                        Button(action: {}) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.trailing, messageText.isEmpty ? 12 : 4)
                        
                        if !messageText.isEmpty {
                            Button(action: {
                                if !messageText.isEmpty {
                                    messages.append(ChatMessage(text: messageText, isMe: true, time: getCurrentTime(), hasTail: true))
                                    messageText = ""
                                }
                            }) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 28))
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
    
    private var chatHeader: some View {
        HStack(spacing: 8) {
            Button(action: { 
                presentationMode.wrappedValue.dismiss() 
            }) {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .bold))
            }.buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 10))
            
            Spacer()
            
            LiquidGlassView(cornerRadius: 20) {
                VStack(spacing: 2) {
                    Text("hikka")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("был(а) недавно")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button(action: {}) {
                Circle().fill(Color.gray.opacity(0.3)).frame(width: 36, height: 36)
                    .overlay(Image(systemName: "person.fill").font(.system(size: 18)).foregroundColor(.white.opacity(0.8)))
            }.buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 4, paddingVertical: 4))
        }
        .padding(.horizontal, 8)
        .padding(.top, 44) // Увеличенный отступ сверху
        .padding(.bottom, 10)
        .background(Color.black.opacity(0.3))
    }
}

@available(iOS 16.0, *)
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

// Модель для загрузки видео
@available(iOS 16.0, *)
struct VideoModel: Transferable {
    let url: URL
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = FileManager.default.temporaryDirectory.appendingPathComponent(received.file.lastPathComponent)
            if FileManager.default.fileExists(atPath: copy.path) {
                try? FileManager.default.removeItem(at: copy)
            }
            try FileManager.default.copyItem(at: received.file, to: copy)
            return VideoModel(url: copy)
        }
    }
}

@available(iOS 16.0, *)
struct MessageBubble: View {
    let message: ChatMessage
    var onMediaTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isMe { Spacer() }
            
            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 4) {
                if message.isEmoji {
                    Text(message.text).font(.system(size: 80))
                    Text(message.time).font(.system(size: 11)).foregroundColor(.white.opacity(0.5)).padding(.horizontal, 4)
                } else if message.isPhoto || message.isVideo {
                    Button(action: { onMediaTap?() }) {
                        ZStack(alignment: .bottomTrailing) {
                            if let image = message.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: 250, maxHeight: 300)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            } else {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(white: 0.15))
                                    .frame(width: 250, height: 250)
                                    .overlay(Image(systemName: message.isVideo ? "play.fill" : "photo").font(.system(size: 40)).foregroundColor(.white.opacity(0.3)))
                            }
                            
                            HStack(spacing: 4) {
                                if message.isVideo { Image(systemName: "play.fill").font(.system(size: 10)) }
                                Text(message.time).font(.system(size: 11))
                                if message.isMe { TelegramCheckmarks() }
                            }
                            .foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.black.opacity(0.4)).cornerRadius(10).padding(8)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    HStack(alignment: .bottom, spacing: 8) {
                        Text(message.text).font(.system(size: 16))
                        HStack(spacing: 2) {
                            Text(message.time).font(.system(size: 11))
                            if message.isMe { TelegramCheckmarks() }
                        }
                        .foregroundColor(message.isMe ? .white.opacity(0.7) : .white.opacity(0.5))
                    }
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(message.isMe ? Color.blue : Color(white: 0.15))
                    .cornerRadius(18)
                }
            }
            if !message.isMe { Spacer() }
        }
    }
}

@available(iOS 16.0, *)
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

// Расширение для поддержки свайпа назад при скрытом navigationBar
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
    // Статический метод для инициализации (вызывается в onAppear)
    static func enableSwipeBack() {
        // Метод пустой, так как viewDidLoad делает всю работу
    }
}
