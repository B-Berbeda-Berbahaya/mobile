import SwiftUI

struct GuideScanningView: View {
    let onDismiss: (() -> Void)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "hand.raised.fill")
                        .font(.footnote)
                        .foregroundColor(.orange)
                    Text("Ready to Scan")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(6)
                }
                .applyGlassEffect(in: Circle())
            }
            
            Text("Hold your device at chest height and slowly move it side-to-side to detect the surface.")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(width: 320)
        .applyGlassEffect(in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    GuideScanningView(onDismiss: {})
        .background(Color.gray)
}
