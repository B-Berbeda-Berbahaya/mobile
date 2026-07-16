import SwiftUI

struct LaunchARCard: View {
    var onAction: () -> Void
    
    var body: some View {
        Button(action: onAction) {
            ZStack(alignment: .bottomLeading) {
                // Background Gradient with subtle glow
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(
                        colors: [Color(red: 0.25, green: 0.35, blue: 0.95), Color(red: 0.55, green: 0.2, blue: 0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 190)
                    .shadow(color: Color(red: 0.25, green: 0.35, blue: 0.95).opacity(0.35), radius: 15, x: 0, y: 8)
                
                // Abstract background shapes
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "arkit")
                            .font(.system(size: 130))
                            .foregroundColor(.white.opacity(0.1))
                            .rotationEffect(.degrees(-10))
                            .offset(x: 15, y: -10)
                    }
                    Spacer()
                }
                .frame(height: 190)
                .clipped()
                
                // Content
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("WORKSPACE DESIGNER")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .tracking(2)
                    }
                    
                    Text("Launch AR Studio")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Scan your physical desk surface in 3D to place virtual monitors, chairs, and customize ergonomics.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .lineSpacing(2)
                        .padding(.trailing, 40)
                    
                    Spacer()
                    
                    HStack {
                        Text("Start Scanning")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.subheadline)
                    }
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.25, green: 0.35, blue: 0.95))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(14)
                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                }
                .padding(24)
            }
            .frame(height: 190)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LaunchARCard(onAction: {})
        .padding()
}
