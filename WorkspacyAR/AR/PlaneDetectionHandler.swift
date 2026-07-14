import ARKit

// Handles ARPlaneAnchor lifecycle events (add/update/remove).
// Responsibility: receive raw plane anchors from ARSessionManager and
// forward valid ones (passing minPlaneExtentToTrack threshold) to
// PlaneGridExtrapolator for conversion into internal grid cells.

final class PlaneDetectionHandler {

    // TODO: let extrapolator: PlaneGridExtrapolator

    // TODO: func didAdd(planeAnchor: ARPlaneAnchor)
    // TODO: func didUpdate(planeAnchor: ARPlaneAnchor)
    // TODO: func didRemove(planeAnchor: ARPlaneAnchor)
}
