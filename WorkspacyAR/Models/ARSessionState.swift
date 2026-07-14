import ARKit

// Simplified, UI-facing representation of ARSession tracking state.
// Responsibility: translate ARCamera.TrackingState into a state the
// SwiftUI layer can switch on directly, without importing ARKit types
// into the Views layer.

// TODO: enum ARSessionState {
//     case initializing
//     case tracking
//     case limited(reason: ARCamera.TrackingState.Reason)
//     case notAvailable
// }
