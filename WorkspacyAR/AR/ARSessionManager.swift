import ARKit
import Combine

public final class ARSessionManager: NSObject, ObservableObject {
    public let session = ARSession()
    
    @Published public var trackingState: ARCamera.TrackingState = .notAvailable
    
    public var onPlaneAdded: ((ARPlaneAnchor) -> Void)?
    public var onPlaneUpdated: ((ARPlaneAnchor) -> Void)?
    public var onPlaneRemoved: ((ARPlaneAnchor) -> Void)?
    
    public override init() {
        super.init()
        session.delegate = self
    }
    
    public func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        session.run(configuration)
    }
    
    public func pauseSession() {
        session.pause()
    }
    
    public func resetSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}

extension ARSessionManager: ARSessionDelegate {
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                onPlaneAdded?(planeAnchor)
            }
        }
    }
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                onPlaneUpdated?(planeAnchor)
            }
        }
    }
    
    public func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                onPlaneRemoved?(planeAnchor)
            }
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        print("ARSession failed: \(error)")
    }
}
