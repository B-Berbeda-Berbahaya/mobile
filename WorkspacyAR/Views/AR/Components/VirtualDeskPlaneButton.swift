//
//  VirtualDeskPlaneButton.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import SwiftUI

struct VirtualDeskPlaneButton: View {
    let systemName: String
    var iconSize: CGFloat = 20
    var foregroundColor: Color = .white
    var backgroundColor: Color = Color.black.opacity(0.6)
    var size: CGFloat = 50
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundColor(isDisabled ? .gray : foregroundColor)
                .frame(width: size, height: size)
        }
        .glassProminentIfAvailable(color: backgroundColor)
        .buttonBorderShape(.circle)
        .disabled(isDisabled)
    }
}

#Preview {
    ZStack {
        Color.gray
        
        VirtualDeskPlaneButton(
            systemName: "plus",
            foregroundColor: .primary,
            backgroundColor: .white.opacity(0.3),
            action: {}
        )
    }

}
