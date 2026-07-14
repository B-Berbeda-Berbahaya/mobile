import SwiftUI
import RealityKit
import ARKit

// UIViewRepresentable wrapper around RealityKit's ARView.
// Responsibility: bridge SwiftUI <-> ARView, wire up ARSessionManager
// for configuration/session lifecycle, and attach ARViewCoordinator
// for handling tap gestures (object placement).

struct ARContainerView: UIViewRepresentable {

    // TODO: func makeCoordinator() -> ARViewCoordinator

    func makeUIView(context: Context) -> ARView {
        // TODO: create ARView, assign session config via ARSessionManager,
        // TODO: register tap gesture recognizer targeting context.coordinator
        fatalError("Not implemented")
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // TODO: handle state updates from SwiftUI side if needed
    }
}
