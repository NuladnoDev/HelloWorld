import SwiftUI

@available(iOS 15.0, *)
struct EditBioView: View {
    @Binding var bio: String
    @Environment(\.presentationMode) var presentationMode
    @State private var tempBio: String = ""
    
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
                    
                    Text("О себе")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Готово") {
                        bio = tempBio
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
                            Text("О СЕБЕ")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 16)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(white: 0.12))
                                
                                bioEditorView
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(minHeight: 120)
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Text("Вы можете добавить несколько строк о себе. В настройках можно выбрать, кому они будут видны.")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 16)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            tempBio = bio
            // TextEditor background workaround for iOS 15
            UITextView.appearance().backgroundColor = .clear
        }
    }
    
    @ViewBuilder
    private var bioEditorView: some View {
        if #available(iOS 16.0, *) {
            TextEditor(text: $tempBio)
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
        } else {
            TextEditor(text: $tempBio)
                .foregroundColor(.white)
        }
    }
}
