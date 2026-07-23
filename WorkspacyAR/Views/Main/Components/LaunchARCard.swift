/*
import SwiftUI

struct LaunchARCard: View {
    var onAction: () -> Void
    
    var body: some View {
        Button(action: onAction) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: "sofa.fill")
                        .foregroundColor(Color(red: 0.55, green: 0.48, blue: 0.38))
                        .font(.caption2)
                    Text("Deskscape")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(red: 0.55, green: 0.48, blue: 0.38))
                        .tracking(2)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Interactive AR Studio")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundColor(Color(red: 0.22, green: 0.20, blue: 0.18))
                    
                    Text("Calibrate your desk dimensions and arrange ergonomic seating, displays, and storage to fit your body.")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.40, green: 0.37, blue: 0.34))
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack(spacing: 6) {
                    Text("Configure Space")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.up.and.down.and.sparkles")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color(red: 0.45, green: 0.38, blue: 0.28))
                .cornerRadius(8)
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(
                            colors: [Color(red: 0.95, green: 0.93, blue: 0.90), Color(red: 0.88, green: 0.84, blue: 0.78)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    // Decorative minimalist wood rings
                    Circle()
                        .stroke(Color(red: 0.65, green: 0.58, blue: 0.48).opacity(0.1), lineWidth: 1)
                        .frame(width: 220, height: 220)
                        .offset(x: 130, y: -10)
                }
            )
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LaunchARCard(onAction: {})
        .padding()
        .background(Color.white)
}
*/
