import SwiftUI

public struct ARFloatingPopover: View {
    public let coordinator: ARViewCoordinator
    @ObservedObject public var stateManager: StateManager
    
    public init(coordinator: ARViewCoordinator, stateManager: StateManager) {
        self.coordinator = coordinator
        self.stateManager = stateManager
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Button Move
            adjustButton(
                img: "arrow.up.and.down.and.arrow.left.and.right",
                color: stateManager.interactionMode == .move ? .green : .gray
            ) {
                if stateManager.interactionMode == .move {
                    stateManager.interactionMode = .none
                } else {
                    stateManager.interactionMode = .move
                }
            }
            
            // Button Rotate
            adjustButton(
                img: "arrow.trianglehead.clockwise.rotate.90",
                color: stateManager.interactionMode == .rotate ? .blue : .gray
            ) {
                if stateManager.interactionMode == .rotate {
                    stateManager.interactionMode = .none
                } else {
                    stateManager.interactionMode = .rotate
                }
            }
            
            // Button Delete
            adjustButton(img: "trash", color: .red) {
                if let object = coordinator.selectedPlacedObject {
                    coordinator.removeObject(withID: object.id)
                    stateManager.popoverPosition = .zero
                    stateManager.interactionMode = .none
                }
            }
        }
        .padding(8)
    }
}

private struct adjustButton: View {
    var img: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: img)
                .font(.system(size: 20))
                .padding(4)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(color)
    }
}
