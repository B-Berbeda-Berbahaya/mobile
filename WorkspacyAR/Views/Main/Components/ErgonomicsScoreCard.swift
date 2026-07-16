import SwiftUI

struct ErgonomicsScoreCard: View {
    let score: Int = 78
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.06), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(score) / 100.0)
                    .stroke(
                        LinearGradient(
                            colors: [.orange, .green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: -90))
                
                VStack {
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("SCORE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Ergonomics Level: Good")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Your current desk configuration is \(score)% compliant with medical ergonomic layouts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ErgonomicsScoreCard()
        .padding()
        .background(Color(.systemGroupedBackground))
}
