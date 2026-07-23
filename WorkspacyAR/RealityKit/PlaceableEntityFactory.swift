import RealityKit
import SwiftUI
import Workspacy

public enum PlaceableEntityFactory {
    
    public static func makeEntity(for type: PlaceableObjectType) async -> ModelEntity {
        do {
            let loadedEntity = try await ModelLoader.load(named: type.assetName)

            let containerEntity = ModelEntity()
            containerEntity.name = "placed_\(type.rawValue)"
            containerEntity.addChild(loadedEntity)

            var transform = containerEntity.transform
            transform.scale *= type.scaleCorrection
            // Rotasi dihapus — asset dari Blender (setelah Apply All Transforms)
            // seharusnya sudah Y-up dengan benar, tidak perlu koreksi rotasi global lagi.
            containerEntity.transform = transform

            containerEntity.generateCollisionShapes(recursive: true)
            return containerEntity
        } catch {
            return makeFallbackBox()
        }
    }
    
    private static func makeFallbackBox() -> ModelEntity {
        // Dummy box
        let size: SIMD3<Float> = SIMD3<Float>(0.3, 0.2, 0.2)
        let mesh = MeshResource.generateBox(size: size)
        let material = SimpleMaterial(
            color: SimpleMaterial.Color.init(.pink),
            isMetallic: true
        )

        // Load box as entity model
        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Generate
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
