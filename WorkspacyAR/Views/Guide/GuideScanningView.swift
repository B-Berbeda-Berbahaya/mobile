import SwiftUI

struct GuideScanningView: View {
    let onDismiss: (() -> Void)
    
    var body: some View {
        ZStack {
            // Dark glassmorphic background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Ready to Scan")
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("Stand up and face your desk surface")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Responsive illustration frame
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 280, height: 220)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    
                    Image("Scanning")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 180)
                }
                
                Text("Hold your device at chest height and slowly move it side-to-side to detect the surface.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
                
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

#Preview {
    GuideScanningView(onDismiss: {})
}
