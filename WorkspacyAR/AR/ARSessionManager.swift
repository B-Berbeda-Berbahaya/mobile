import ARKit
import Combine

// Owns the ARSession lifecycle and configuration.
// Responsibility: start/pause/reset session with
// ARWorldTrackingConfiguration (plane detection enabled), and act as
// ARSessionDelegate, forwarding anchor/frame updates to
// PlaneDetectionHandler. Knows nothing about RealityKit entities or grid logic.

final class ARSessionManager: NSObject {

    // TODO: let session: ARSession
    // TODO: func startSession()
    // TODO: func pauseSession()
    // TODO: func resetSession()
}

// MARK: - ARSessionDelegate
extension ARSessionManager: ARSessionDelegate {
    // TODO: func session(_ session: ARSession, didUpdate frame: ARFrame)
    // TODO: func session(_ session: ARSession, didFailWithError error: Error)
    // TODO: func sessionWasInterrupted(_ session: ARSession)
    // TODO: func sessionInterruptionEnded(_ session: ARSession)
}
