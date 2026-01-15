import SwiftUI

@available(iOS 15.0, *)
struct ImageCropperView: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var containerSize: CGSize = .zero // Добавил для точного расчета
    
    private let maskSize: CGFloat = 300
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            if let uiImage = image {
                GeometryReader { geometry in
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(scale)
                        .offset(offset)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .onAppear {
                            containerSize = geometry.size
                        }
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale *= delta
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                }
            }
            
            // Mask
            ZStack {
                Color.black.opacity(0.5)
                Circle()
                    .frame(width: maskSize, height: maskSize)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            .allowsHitTesting(false)
            
            // UI Controls
            VStack {
                HStack {
                    Button("Отмена") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                    
                    Button("Готово") {
                        cropImage()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isPresented = false
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .bold))
                    .padding()
                }
                Spacer()
                
                Text("Перетащите и измените масштаб")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 14))
                    .padding(.bottom, 30)
            }
        }
    }
    
    private func cropImage() {
        guard let uiImage = image else { return }
        
        let targetSize = CGSize(width: maskSize, height: maskSize)
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale // Используем масштаб экрана для высокого качества
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let cropped = renderer.image { context in
            // Черный фон
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            
            // Размер контейнера (где отображалось фото)
            let viewWidth = containerSize.width > 0 ? containerSize.width : UIScreen.main.bounds.width
            let viewHeight = containerSize.height > 0 ? containerSize.height : UIScreen.main.bounds.height
            
            let aspectRatio = uiImage.size.width / uiImage.size.height
            
            // Начальные размеры как в scaledToFill
            var drawWidth = viewWidth
            var drawHeight = viewWidth / aspectRatio
            
            if drawHeight < viewHeight {
                drawHeight = viewHeight
                drawWidth = viewHeight * aspectRatio
            }
            
            // Применяем масштаб пользователя
            let finalWidth = drawWidth * scale
            let finalHeight = drawHeight * scale
            
            // Центрируем и применяем смещение
            // Маска находится в центре вью
            let drawX = (targetSize.width / 2) - (drawWidth * scale / 2) + offset.width
            let drawY = (targetSize.height / 2) - (drawHeight * scale / 2) + offset.height
            
            uiImage.draw(in: CGRect(x: drawX, y: drawY, width: finalWidth, height: finalHeight))
        }
        
        image = cropped
    }
}
