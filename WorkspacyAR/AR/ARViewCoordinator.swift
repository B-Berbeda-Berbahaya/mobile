import ARKit
import RealityKit
import Combine
import SwiftUI

public final class ARViewCoordinator: NSObject {
    public let raycastService = RaycastService()
    public let gridSystem: GridSystem
    public let anchorManager = AnchorManager()
    public let mapper: WorldToGridMapper
    
    public var onSelectedObjectChanged: ((PlacedObject?) -> Void)?
    public var activePlacingType: PlaceableObjectType = .ergonomicChair
    
    public var arView: ARView?
    
    public init(gridSystem: GridSystem) {
        self.gridSystem = gridSystem
        self.mapper = WorldToGridMapper(gridSystem: gridSystem)
        super.init()
    }
    
    public func setupGesture(in arView: ARView) {
        self.arView = arView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
    }
    
    @objc public func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let location = recognizer.location(in: arView)
        
        guard let worldPos = raycastService.raycastWorldPosition(from: location, in: arView) else {
            return
        }
        
        gridSystem.setOriginIfNeeded(worldPos)
        
        let coordinate = mapper.gridCoordinate(for: worldPos)
        
        if gridSystem.isAvailable(coordinate) {
            placeObject(worldPosition: worldPos, type: activePlacingType, coordinate: coordinate)
        } else {
            if let entity = arView.entity(at: location) as? ModelEntity {
                if let placedObject = anchorManager.placedObjects.first(where: { $0.entity == entity }) {
                    onSelectedObjectChanged?(placedObject)
                }
            }
        }
    }
    
    public func placeObject(worldPosition: SIMD3<Float>, type: PlaceableObjectType, coordinate: GridCoordinate) {
        guard let arView = arView else { return }
        
        let entity = PlaceableEntityFactory.makeEntity(for: type)
        let snappedWorldPos = mapper.worldPosition(for: coordinate)
        
        var transform = simd_float4x4(1) // Identity matrix
        transform.columns.3 = SIMD4<Float>(snappedWorldPos.x, snappedWorldPos.y, snappedWorldPos.z, 1.0)
        
        let placedObj = anchorManager.placeEntity(entity, at: transform, in: arView, type: type, coordinate: coordinate)
        gridSystem.markOccupied(coordinate, objectID: placedObj.id)
        
        onSelectedObjectChanged?(placedObj)
    }
    
    public func removeObject(withID id: UUID) {
        guard let arView = arView else { return }
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }) {
            anchorManager.removeObject(object, in: arView)
            gridSystem.markAvailableAgain(object.gridCoordinate)
        }
    }
    
    public func updateRotation(forID id: UUID, angleDegrees: Float) {
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }) {
            let radians = angleDegrees * .pi / 180.0
            object.entity.transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0, 1, 0))
        }
    }
    
    public func updateHeight(forID id: UUID, heightCm: Float) {
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }) {
            let heightMeters = heightCm / 100.0
            let snappedWorldPos = mapper.worldPosition(for: object.gridCoordinate)
            object.entity.transform.translation = SIMD3<Float>(snappedWorldPos.x, snappedWorldPos.y + heightMeters, snappedWorldPos.z)
        }
    }
}
