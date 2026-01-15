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
    var isEmoji: Bool = false
}

@available(iOS 15.0, *)
struct ChatView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "🐷", isMe: false, time: "19:40", hasTail: true, isEmoji: true),
        ChatMessage(text: "мама свин и папк свин", isMe: true, time: "19:41", hasTail: true),
        ChatMessage(text: "", isMe: false, time: "19:41", hasTail: true, image: "avatar_placeholder", isVideo: true),
        ChatMessage(text: "🐷", isMe: false, time: "19:41", hasTail: true, isEmoji: true),
        ChatMessage(text: "🐷", isMe: false, time: "19:41", hasTail: true, isEmoji: true)
    ]
    
    var body: some View {
        ZStack {
            // Фон (пока просто черный)
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Хедер
                chatHeader
                
                // Список сообщений
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 12) {
                            Spacer()
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 20)
                    }
                }
                
                // Поле ввода
                inputBar
            }
        }
        .navigationBarHidden(true)
    }
    
    private var chatHeader: some View {
        HStack(spacing: 12) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("hikka")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                Text("был(а) недавно")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(Color(white: 0.15))
            .cornerRadius(20)
            
            Spacer()
            
            Circle()
                .fill(Color.gray)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.white.opacity(0.5))
                )
                .padding(.trailing, 8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.8))
    }
    
    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.1))
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
                
                ZStack(alignment: .trailing) {
                    TextField("Сообщение", text: $messageText)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 9)
                        .background(Color(white: 0.15))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                    
                    Button(action: {}) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                    }
                }
                
                Button(action: {
                    if !messageText.isEmpty {
                        messages.append(ChatMessage(text: messageText, isMe: true, time: "19:42", hasTail: true))
                        messageText = ""
                    }
                }) {
                    Image(systemName: messageText.isEmpty ? "mic" : "arrow.up.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(messageText.isEmpty ? .gray : .blue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black)
        }
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
                } else if let _ = message.image {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color(white: 0.2))
                            .frame(width: 250, height: 250)
                            .overlay(
                                Image(systemName: message.isVideo ? "play.fill" : "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.3))
                            )
                        
                        HStack(spacing: 4) {
                            if message.isVideo {
                                Text("0:28")
                                    .font(.system(size: 11))
                                Image(systemName: "speaker.slash.fill")
                                    .font(.system(size: 10))
                            }
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
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8))
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8))
                                    .offset(x: -4)
                            }
                        }
                        .foregroundColor(message.isMe ? .white.opacity(0.7) : .gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isMe ? Color.purple.opacity(0.8) : Color(white: 0.15))
                    .cornerRadius(18)
                }
            }
            
            if !message.isMe { Spacer() }
        }
    }
}
