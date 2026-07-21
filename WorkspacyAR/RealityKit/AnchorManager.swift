import RealityKit
import Combine
import Foundation

public final class AnchorManager {
    public private(set) var placedObjects: [PlacedObject] = []
    
    public init() {}
    
    @discardableResult
    public func placeEntity(_ entity: ModelEntity, at worldPosition: SIMD3<Float>, in arView: ARView, type: PlaceableObjectType) -> PlacedObject {
        let anchorEntity = AnchorEntity(world: worldPosition)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
        
        let placedObj = PlacedObject(entity: entity, type: type)
        placedObjects.append(placedObj)
        
        return placedObj
    }
    
    public func removeObject(_ object: PlacedObject, in arView: ARView) {
        if let anchorEntity = object.entity.anchor {
            arView.scene.removeAnchor(anchorEntity)
        }
        placedObjects.removeAll(where: { $0.id == object.id })
    }
    
    public func removeAll(in arView: ARView) {
        for obj in placedObjects {
            if let anchorEntity = obj.entity.anchor {
                arView.scene.removeAnchor(anchorEntity)
            }
        }
        placedObjects.removeAll()
    }
} 
