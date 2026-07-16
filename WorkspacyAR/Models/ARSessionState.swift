import ARKit

public enum ARSessionState {
    case initializing
    case tracking
    case limited(reason: ARCamera.TrackingState.Reason)
    case notAvailable
    
    public init(from arTrackingState: ARCamera.TrackingState) {
        switch arTrackingState {
        case .notAvailable:
            self = .notAvailable
        case .limited(let reason):
            self = .limited(reason: reason)
        case .normal:
            self = .tracking
        }
    }
}
