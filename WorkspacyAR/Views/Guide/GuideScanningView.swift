import SwiftUI

struct GuideScanningView: View {
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
                
                VStack(spacing: 6) {
                    Text("Ready to Scan")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                    
                    Text("Stand up and face your desk surface")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Responsive illustration frame (scaled down for iPhone Portrait)
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 220, height: 160)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    
                    Image("Scanning")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 130)
                }
                
                Text("Hold your device at chest height and slowly move it side-to-side to detect the surface.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .lineSpacing(3)
                
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

#Preview {
    GuideScanningView(onDismiss: {})
}
