import SwiftUI

struct GuideObjectView: View {
    let onDismiss: (() -> Void)
    
    var body: some View {
        ZStack {
            // Dark glassmorphic background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("How to Control Objects")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                VStack(spacing: 18) {
                    GestureGuideRow(imageName: "1finger", title: "Move Item", description: "Drag 1 finger to move the object on the desk surface.")
                    
                    GestureGuideRow(imageName: "2finger", title: "Rotate Item", description: "Twist 2 fingers to rotate the object on its axis.")
                    
                    GestureGuideRow(imageName: "3finger", title: "Adjust Height", description: "Drag 3 fingers up/down to set height or altitude offset.")
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Text("Understood")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 50)
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.bottom, 70)
            }
            .foregroundStyle(Color.white)
        }
    }
}

struct GestureGuideRow: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 60, height: 80)
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
    }
}

#Preview {
    GuideObjectView(onDismiss: {})
}
