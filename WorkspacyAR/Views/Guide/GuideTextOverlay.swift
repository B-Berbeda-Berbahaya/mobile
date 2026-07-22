//
//  GuideTextOverlay.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 20/07/26.
//

import SwiftUI

struct GuideTextOverlay: View {
    
    let caption: String
    
    var body: some View {
        Text(caption)
            .font(.caption)
            .foregroundColor(.primary.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.regularMaterial)
            .cornerRadius(10)
            .padding(.bottom, 16)
    }
}

#Preview {
    ZStack {
        Color.gray
        
        GuideTextOverlay(caption: "Tap object surface to adjust the position")
    }
}
