//
//  GlassProminentButtonExtension.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func glassProminentIfAvailable(color: Color = .blue) -> some View {
        if #available(iOS 26.4, *) {
            self.buttonStyle(.glassProminent).tint(color)
        } else {
            self.tint(color)
        }
    }
}
