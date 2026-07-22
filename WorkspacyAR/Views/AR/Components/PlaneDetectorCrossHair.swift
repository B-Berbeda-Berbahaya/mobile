//
//  PlaneDetectorCrossHair.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 21/07/26.
//

import SwiftUI

struct PlaneDetectorCrossHair: View {
    var strokeColor: Color = .white
    var centerColor: Color = .white

    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(strokeColor, lineWidth: 2)
                .frame(width: 32, height: 32)
                .shadow(color: .black.opacity(0.5), radius: 1)

            // Inner dot
            Circle()
                .fill(centerColor)
                .frame(width: 4, height: 4)
                .shadow(color: .black.opacity(0.50), radius: 1)
        }
    }
}

#Preview {
    PlaneDetectorCrossHair()
}
