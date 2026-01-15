import SwiftUI

@available(iOS 15.0, *)
struct ImageCropperView: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
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
                        isPresented = false
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
        
        // The cropping logic should take the original image and cut out the part that was visible in the mask.
        // For simplicity and reliability in SwiftUI, we'll render the scaled and translated image into a new context.
        
        let targetSize = CGSize(width: maskSize, height: maskSize)
        let format = UIGraphicsImageRendererFormat()
        format.scale = uiImage.scale // Keep original image scale/density
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        let cropped = renderer.image { context in
            // Fill background with black (optional, since it's a circle)
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))
            
            // Calculate how to draw the image
            // We need to match what the user saw on screen.
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            // Image's aspect ratio
            let aspectRatio = uiImage.size.width / uiImage.size.height
            
            // How the image was initially scaled to fill the screen (scaledToFill)
            var initialWidth = screenWidth
            var initialHeight = screenWidth / aspectRatio
            
            if initialHeight < screenHeight {
                initialHeight = screenHeight
                initialWidth = screenHeight * aspectRatio
            }
            
            // Apply user's scale and offset
            let finalWidth = initialWidth * scale
            let finalHeight = initialHeight * scale
            
            // Center the image relative to the mask (which is at screen center)
            let drawX = (targetSize.width / 2) - (initialWidth * scale / 2) + offset.width
            let drawY = (targetSize.height / 2) - (initialHeight * scale / 2) + offset.height
            
            uiImage.draw(in: CGRect(x: drawX, y: drawY, width: finalWidth, height: finalHeight))
        }
        
        image = cropped
    }
}
