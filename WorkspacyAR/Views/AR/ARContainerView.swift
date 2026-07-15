import SwiftUI
import RealityKit
import ARKit

public struct ARContainerView: UIViewRepresentable {
    @ObservedObject var sessionManager: ARSessionManager
    public let coordinator: ARViewCoordinator
    
    public init(sessionManager: ARSessionManager, coordinator: ARViewCoordinator) {
        self.sessionManager = sessionManager
        self.coordinator = coordinator
    }
    
    public func makeCoordinator() -> ARViewCoordinator {
        return coordinator
    }
    
    public func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        sessionManager.startSession()
        arView.session = sessionManager.session
        
        context.coordinator.setupGesture(in: arView)
        
        let extrapolator = PlaneGridExtrapolator(gridSystem: context.coordinator.gridSystem, mapper: context.coordinator.mapper)
        let planeHandler = PlaneDetectionHandler(extrapolator: extrapolator)
        
        sessionManager.onPlaneAdded = { planeAnchor in
            planeHandler.didAdd(planeAnchor: planeAnchor)
        }
        sessionManager.onPlaneUpdated = { planeAnchor in
            planeHandler.didUpdate(planeAnchor: planeAnchor)
        }
        sessionManager.onPlaneRemoved = { planeAnchor in
            planeHandler.didRemove(planeAnchor: planeAnchor)
        }
        
        return arView
    }
    
    public func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.activePlacingType = coordinator.activePlacingType
    }
}
