import RealityKit
import UIKit
import Workspacy

public enum PlaceableEntityFactory {
    public static func makeEntity(for type: PlaceableObjectType) async -> ModelEntity {
        do {
            let entity = try await ModelLoader.load(named: type.assetName)
            
            if let modelEntity = entity as? ModelEntity {
                modelEntity.generateCollisionShapes(recursive: true)
                return modelEntity
            }
            
            if let firstModelChild = entity.findFirstModelEntity() {
                firstModelChild.scale = type.scaleCorrection
                firstModelChild.generateCollisionShapes(recursive: true)
                return firstModelChild
            }
            return makeFallbackBox(for: type)
        } catch {
            return makeFallbackBox(for: type)
        }
    }
    
    private static func makeFallbackBox(for type: PlaceableObjectType) -> ModelEntity {
        let size: SIMD3<Float> = SIMD3<Float>(0.3, 0.2, 0.2)
        let mesh = MeshResource.generateBox(size: size)
        let material = SimpleMaterial(color: .systemPink, isMetallic: true)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.generateCollisionShapes(recursive: true)
        return entity
    }
}

extension Entity {
    func findFirstModelEntity() -> ModelEntity? {
        if let model = self as? ModelEntity {
            return model
        }
        for child in children {
            if let found = child.findFirstModelEntity() {
                return found
            }
        }
        return nil
    }
}
