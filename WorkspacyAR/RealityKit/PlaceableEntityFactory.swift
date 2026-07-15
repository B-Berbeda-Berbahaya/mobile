import RealityKit
import UIKit

public enum PlaceableEntityFactory {
    public static func makeEntity(for type: PlaceableObjectType) -> ModelEntity {
        let size: SIMD3<Float>
        let materialColor: UIColor
        
        switch type {
        case .standardDesk:
            size = SIMD3<Float>(1.2, 0.75, 0.6)
            materialColor = .brown
        case .standingDesk:
            size = SIMD3<Float>(1.4, 0.8, 0.7)
            materialColor = .darkGray
        case .ergonomicChair:
            size = SIMD3<Float>(0.6, 1.0, 0.6)
            materialColor = .black
        case .monitor34:
            size = SIMD3<Float>(0.8, 0.45, 0.2)
            materialColor = .blue
        case .laptop:
            size = SIMD3<Float>(0.35, 0.02, 0.24)
            materialColor = .lightGray
        case .deskLamp:
            size = SIMD3<Float>(0.15, 0.4, 0.15)
            materialColor = .yellow
        case .keyboard:
            size = SIMD3<Float>(0.44, 0.03, 0.13)
            materialColor = .darkGray
        case .mouse:
            size = SIMD3<Float>(0.07, 0.05, 0.12)
            materialColor = .darkGray
        case .plant:
            size = SIMD3<Float>(0.2, 0.3, 0.2)
            materialColor = .green
        case .speakers:
            size = SIMD3<Float>(0.18, 0.28, 0.2)
            materialColor = .black
        }
        
        let mesh = MeshResource.generateBox(size: size)
        let material = SimpleMaterial(color: materialColor, isMetallic: true)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.generateCollisionShapes(recursive: true)
        
        return entity
    }
}
