import SwiftUI

extension View {
    /// Applies a responsive maximum width constraint and centers the view if running in a wide horizontal layout (like iPad).
    @ViewBuilder
    func adaptiveWidth(isRegular: Bool, maxWidth: CGFloat = 500) -> some View {
        if isRegular {
            self
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            self
        }
    }
    
    /// Converts a full-screen instruction or view into a beautiful, centered floating card modal on iPad.
    @ViewBuilder
    func adaptiveCardModal(isRegular: Bool, width: CGFloat = 500, height: CGFloat = 600) -> some View {
        if isRegular {
            self
                .frame(width: width, height: height)
                .background(Color(red: 0.13, green: 0.12, blue: 0.11)) // Premium warm dark wood background
                .cornerRadius(28)
                .shadow(color: Color.black.opacity(0.35), radius: 30, x: 0, y: 15)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            self
        }
    }
}
