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
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0.1
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
                .opacity(Double(1.0 - (abs(offset.height) / 500)))
            
            // Основной контент (фото или видео)
            Group {
                if message.isVideo, let videoURL = message.videoURL {
                    VideoPlayerView(url: videoURL, isPlaying: $isPlaying, currentTime: $currentTime, duration: $duration)
                        .edgesIgnoringSafeArea(.all)
                } else if let image = message.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                }
            }
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
                    
                    Text("137 из 137")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "gearshape")
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
                        colors: [.black.opacity(0.6), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
            }
            
            // Нижняя панель
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    if message.isVideo {
                        // Слайдер времени
                        VStack(spacing: 8) {
                            Slider(value: $currentTime, in: 0...duration)
                                .accentColor(.white)
                                .padding(.horizontal, 10)
                            
                            HStack {
                                Text(formatTime(currentTime))
                                Spacer()
                                Text(formatTime(duration))
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                        }
                        .padding(.bottom, 10)
                    }
                    
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "arrowshape.turn.up.right")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        if message.isVideo {
                            Button(action: { isPlaying.toggle() }) {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        } else {
                            Text("вчера в \(message.time)")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "trash")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.bottom, 40)
                    .padding(.top, message.isVideo ? 10 : 20)
                }
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .transition(.opacity)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

@available(iOS 16.0, *)
struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    @Binding var duration: Double
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        
        // Отслеживание времени
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
            currentTime = time.seconds
            if let durationTime = player.currentItem?.duration.seconds, !durationTime.isNaN {
                duration = durationTime
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if isPlaying {
            uiViewController.player?.play()
        } else {
            uiViewController.player?.pause()
        }
    }
}

@available(iOS 16.0, *)
struct CustomKeyboard: View {
    @Binding var text: String
    @Binding var isPresented: Bool
    @State private var selectedTab: Int = 2 // 0: GIF, 1: Стикеры, 2: Эмодзи
    
    let emojis = [
        "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "😊", "😇",
        "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗", "😙", "😚",
        "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓", "😎", "🤩",
        "🥳", "😏", "😒", "😞", "😔", "😟", "😕", "🙁", "☹️", "😣",
        "😖", "😫", "😩", "🥺", "😢", "😭", "😤", "😠", "😡", "🤬"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Верхняя панель категорий (как на скрине)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    Image(systemName: "plus")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                    Image(systemName: "bookmark")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                    Image(systemName: "clock")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.6))
                    
                    // Заглушки для стикеров
                    ForEach(0..<8) { _ in
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.black.opacity(0.4))
            
            // Сетка контента
            if selectedTab == 2 {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button(action: { text += emoji }) {
                                Text(emoji)
                                    .font(.system(size: 32))
                            }
                        }
                    }
                    .padding(16)
                }
                .frame(maxHeight: .infinity)
            } else {
                VStack {
                    Spacer()
                    Text(selectedTab == 0 ? "GIF не реализованы" : "Стикеры не реализованы")
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            }
            
            // Нижняя панель переключения
            HStack(spacing: 0) {
                HStack(spacing: 10) {
                    Button(action: { selectedTab = 0 }) {
                        Text("GIF")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTab == 0 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(15)
                    }
                    Button(action: { selectedTab = 1 }) {
                        Text("Стикеры")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTab == 1 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(15)
                    }
                    Button(action: { selectedTab = 2 }) {
                        Text("Эмодзи")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedTab == 2 ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(15)
                    }
                }
                .padding(4)
                .background(Color.black.opacity(0.5))
                .cornerRadius(20)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.4))
        }
        .frame(height: 300)
        .background(Color(white: 0.1))
        .transition(.move(edge: .bottom))
    }
}

@available(iOS 16.0, *)
struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText: String = ""
    @State private var showMediaPicker = false
    @State private var selectedMediaItem: PhotosPickerItem? = nil
    @State private var selectedViewerMessage: ChatMessage? = nil
    @State private var showCustomKeyboard = false
    @FocusState private var isTextFieldFocused: Bool
    
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
                
                if showCustomKeyboard {
                    CustomKeyboard(text: $messageText, isPresented: $showCustomKeyboard)
                }
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
            UITabBar.setTabBarVisible(false, animated: true)
        }
        .onDisappear {
            UITabBar.setTabBarVisible(true, animated: true)
        }
    }
    
    private var inputBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                // Левая кнопка (скрепка)
                Button(action: { showMediaPicker = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: 10))
                
                // Поле ввода
                LiquidGlassView(cornerRadius: 28) {
                    HStack(spacing: 8) {
                        TextField("Сообщение", text: $messageText)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .padding(.leading, 16)
                            .focused($isTextFieldFocused)
                            .onTapGesture {
                                withAnimation {
                                    showCustomKeyboard = false
                                }
                            }
                        
                        // Смайлик в конце поля ввода
                        Button(action: {
                            withAnimation {
                                if showCustomKeyboard {
                                    isTextFieldFocused = true
                                    showCustomKeyboard = false
                                } else {
                                    isTextFieldFocused = false
                                    showCustomKeyboard = true
                                }
                            }
                        }) {
                            Image(systemName: showCustomKeyboard ? "keyboard" : "face.smiling.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.trailing, 12)
                    }
                    .frame(height: 44)
                }
                
                // Правая кнопка (микрофон или отправить)
                Button(action: {
                    if !messageText.isEmpty {
                        messages.append(ChatMessage(text: messageText, isMe: true, time: getCurrentTime(), hasTail: true))
                        messageText = ""
                    }
                }) {
                    Image(systemName: messageText.isEmpty ? "mic" : "arrow.up.circle.fill")
                        .font(.system(size: messageText.isEmpty ? 22 : 28))
                        .foregroundColor(messageText.isEmpty ? .white : .blue)
                }
                .buttonStyle(LiquidGlassButtonStyle(paddingHorizontal: 12, paddingVertical: messageText.isEmpty ? 10 : 6))
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(Color.black.opacity(0.3))
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
            .padding(.top, 22) // Уменьшено в 2 раза (было 44)
            .padding(.bottom, 10)
            .background(Color.black.opacity(0.3))
    }
}

// Расширение для управления видимостью TabBar
extension UITabBar {
    static func setTabBarVisible(_ visible: Bool, animated: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        guard let tabBarController = window?.rootViewController?.findTabBarController() else { return }
        
        let frame = tabBarController.tabBar.frame
        let height = frame.size.height
        let offsetY = (visible ? 0 : height)
        
        let duration = (animated ? 0.3 : 0.0)
        
        UIView.animate(withDuration: duration) {
            tabBarController.tabBar.frame.origin.y = UIScreen.main.bounds.height - (visible ? height : 0)
            tabBarController.tabBar.alpha = visible ? 1 : 0
        }
    }
}

extension UIViewController {
    func findTabBarController() -> UITabBarController? {
        if let tabBarController = self as? UITabBarController {
            return tabBarController
        }
        for child in children {
            if let tabBarController = child.findTabBarController() {
                return tabBarController
            }
        }
        return nil
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
