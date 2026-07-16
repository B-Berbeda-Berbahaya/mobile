import ARKit

public final class PlaneDetectionHandler {
    public let extrapolator: PlaneGridExtrapolator
    
    public init(extrapolator: PlaneGridExtrapolator) {
        self.extrapolator = extrapolator
    }
    
    public func didAdd(planeAnchor: ARPlaneAnchor) {
        extrapolator.extrapolate(planeAnchor: planeAnchor)
    }
    
    public func didUpdate(planeAnchor: ARPlaneAnchor) {
        extrapolator.extrapolate(planeAnchor: planeAnchor)
    }
    
    public func didRemove(planeAnchor: ARPlaneAnchor) {
        // Option to clean/retract grid if necessary
    }
}
