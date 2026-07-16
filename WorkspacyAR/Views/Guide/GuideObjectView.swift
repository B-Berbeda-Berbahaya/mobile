import SwiftUI

struct GuideObjectView: View {
    let onDismiss: (() -> Void)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let themeBrown = Color(red: 0.45, green: 0.38, blue: 0.28)
    
    var body: some View {
        ZStack {
            // Dark glassmorphic background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer()
                
                Text("How to Control Objects")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.top, 16)
                
                VStack(spacing: 10) {
                    GestureGuideRow(imageName: "1finger", title: "Move Item", description: "Drag 1 finger to move the object on the desk surface.")
                    
                    GestureGuideRow(imageName: "2finger", title: "Rotate Item", description: "Twist 2 fingers to rotate the object on its axis.")
                    
                    GestureGuideRow(imageName: "3finger", title: "Adjust Height", description: "Drag 3 fingers up/down to set height or altitude offset.")
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Text("Understood")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(themeBrown)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 130)
            }
            .foregroundStyle(Color.white)
            .padding(.top, horizontalSizeClass == .compact ? 60 : 20)
            .adaptiveCardModal(isRegular: horizontalSizeClass == .regular, width: 460, height: 560)
        }
    }
}

struct GestureGuideRow: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 46, height: 60)
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 44)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color.white.opacity(0.03))
        .cornerRadius(12)
    }
}

#Preview {
    GuideObjectView(onDismiss: {})
}
