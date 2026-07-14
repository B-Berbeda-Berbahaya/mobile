import ARKit
import RealityKit
import Combine

// Coordinator for ARContainerView (UIViewRepresentable).
// Responsibility: the meeting point of all AR/RealityKit/Grid layers —
// handles tap gesture, runs RaycastService, maps world position to a
// GridCoordinate via WorldToGridMapper, checks GridSystem availability,
// and if valid, asks AnchorManager + PlaceableEntityFactory to place
// the entity at the snapped position.

final class ARViewCoordinator: NSObject {

    // TODO: let raycastService: RaycastService
    // TODO: let gridSystem: GridSystem
    // TODO: let anchorManager: AnchorManager

    // TODO: @objc func handleTap(_ recognizer: UITapGestureRecognizer)
    // TODO: func placeObject(worldPosition: SIMD3<Float>, type: PlaceableObjectType)
}
