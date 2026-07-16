import SwiftUI

struct ErgonomicsScoreCard: View {
    let score: Int
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                // Soft background ring
                Circle()
                    .stroke(Color.primary.opacity(0.04), lineWidth: 5)
                    .frame(width: 72, height: 72)
                
                // Sage green compliance ring
                Circle()
                    .trim(from: 0.0, to: CGFloat(score) / 100.0)
                    .stroke(
                        Color(red: 0.42, green: 0.55, blue: 0.44), // Sage green
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 72, height: 72)
                    .rotationEffect(Angle(degrees: -90))
                
                VStack {
                    Text("\(score)%")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                    Text("COMPLY")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Postural Compliance")
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text("Your current studio configuration scores a \(score)% alignment with healthy joint angles.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 3)
    }
}

#Preview {
    ErgonomicsScoreCard(score: 78)
        .padding()
        .background(Color(.systemGroupedBackground))
}
