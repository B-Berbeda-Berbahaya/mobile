//
//  TipsObjectInteraction.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 20/07/26.
//

import SwiftUI
import TipKit

struct ObjectInteractionTipView: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "move.3d")
                .font(.title3)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Edit an Object")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)

                Text(
                    "Select an object by tapping it, then choose Move, Rotate, or Delete."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 280, alignment: .leading)
        .background(.thinMaterial, in: .rect(cornerRadius: 12))
    }
}

struct TipsObjectInteractionPreview: View {
    @State private var showTip = false

    var body: some View {
        VStack {
            Image(systemName: "star")
                .imageScale(.large)

            Button {
                showTip = true
            } label: {
                Text("Action")
            }

            if showTip {
                ObjectInteractionTipView {
                    showTip = false
                }
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
            }

            Spacer()
        }
    }
}

#Preview {
    ZStack {
        Color.gray
        TipsObjectInteractionPreview()
    }
}
