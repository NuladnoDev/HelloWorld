import SwiftUI

@available(iOS 16.0, *)
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
        
        // Получаем размеры вью и картинки
        let viewWidth = containerSize.width > 0 ? containerSize.width : UIScreen.main.bounds.width
        let viewHeight = containerSize.height > 0 ? containerSize.height : UIScreen.main.bounds.height
        let imageSize = uiImage.size
        
        // Расчет размеров как в .scaledToFill()
        let horizontalScale = viewWidth / imageSize.width
        let verticalScale = viewHeight / imageSize.height
        let baseScale = max(horizontalScale, verticalScale)
        
        // Итоговый масштаб отображения (базовый * пользовательский)
        let totalScale = baseScale * scale
        
        // Размеры отображаемой картинки
        let displayedWidth = imageSize.width * totalScale
        let displayedHeight = imageSize.height * totalScale
        
        // Центр маски в координатах вью
        let maskCenterInView = CGPoint(x: viewWidth / 2, y: viewHeight / 2)
        
        // Центр картинки в координатах вью с учетом смещения
        let imageCenterInView = CGPoint(
            x: viewWidth / 2 + offset.width,
            y: viewHeight / 2 + offset.height
        )
        
        // Положение верхнего левого угла маски относительно верхнего левого угла картинки
        // В координатах вью:
        let maskTopLeftInView = CGPoint(
            x: maskCenterInView.x - maskSize / 2,
            y: maskCenterInView.y - maskSize / 2
        )
        
        let imageTopLeftInView = CGPoint(
            x: imageCenterInView.x - displayedWidth / 2,
            y: imageCenterInView.y - displayedHeight / 2
        )
        
        // Смещение маски относительно картинки в пикселях вью
        let xOffsetInView = maskTopLeftInView.x - imageTopLeftInView.x
        let yOffsetInView = maskTopLeftInView.y - imageTopLeftInView.y
        
        // Переводим в координаты оригинальной картинки
        let cropRect = CGRect(
            x: xOffsetInView / totalScale,
            y: yOffsetInView / totalScale,
            width: maskSize / totalScale,
            height: maskSize / totalScale
        )
        
        // Выполняем кроп
        if let cgImage = uiImage.cgImage?.cropping(to: cropRect) {
            let croppedUIImage = UIImage(cgImage: cgImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
            
            // Масштабируем до целевого размера для сохранения (например, 600x600 для четкости)
            let finalSize = CGSize(width: 600, height: 600)
            UIGraphicsBeginImageContextWithOptions(finalSize, false, 0)
            croppedUIImage.draw(in: CGRect(origin: .zero, size: finalSize))
            let finalImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            image = finalImage
        }
    }
}
