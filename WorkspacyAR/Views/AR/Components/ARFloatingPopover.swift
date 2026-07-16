import SwiftUI

struct ARFloatingPopover: View {
    let coordinator: ARViewCoordinator
    @Binding var interactionMode: ARInteractionMode
    
    var body: some View {
        HStack(spacing: 12) {
            // Button Move
            adjustButton(
                img: "arrow.up.and.down.and.arrow.left.and.right",
                color: interactionMode == .move ? .green : .gray
            ) {
                if interactionMode == .move {
                    interactionMode = .none
                } else {
                    interactionMode = .move
                }
            }
            
            // Button Rotate
            adjustButton(
                img: "arrow.trianglehead.clockwise.rotate.90",
                color: interactionMode == .rotate ? .blue : .gray
            ) {
                if interactionMode == .rotate {
                    interactionMode = .none
                } else {
                    interactionMode = .rotate
                }
            }
            
            // Button Delete
            adjustButton(img: "trash", color: .red) {
                if let object = coordinator.selectedPlacedObject {
                    coordinator.removeObject(withID: object.id)
                }
            }
        }
        .padding(6)
        .background(Color(.systemBackground).opacity(0.85))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.15), radius: 5)
    }
}

private struct adjustButton: View {
    var img: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: img)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(8)
                .background(color)
                .clipShape(Circle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
