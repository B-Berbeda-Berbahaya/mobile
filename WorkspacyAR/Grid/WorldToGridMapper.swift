import Foundation
import simd

public struct WorldToGridMapper {
    public let gridSystem: GridSystem
    
    public init(gridSystem: GridSystem) {
        self.gridSystem = gridSystem
    }
    
    public func gridCoordinate(for worldPosition: SIMD3<Float>) -> GridCoordinate {
        guard let origin = gridSystem.origin else {
            return GridCoordinate(x: 0, z: 0)
        }
        
        let relativeX = worldPosition.x - origin.x
        let relativeZ = worldPosition.z - origin.z
        
        let gridX = Int(round(relativeX / gridSystem.cellSize))
        let gridZ = Int(round(relativeZ / gridSystem.cellSize))
        
        return GridCoordinate(x: gridX, z: gridZ)
    }
    
    public func worldPosition(for coordinate: GridCoordinate) -> SIMD3<Float> {
        guard let origin = gridSystem.origin else {
            return SIMD3<Float>(0, 0, 0)
        }
        
        let posX = origin.x + Float(coordinate.x) * gridSystem.cellSize
        let posZ = origin.z + Float(coordinate.z) * gridSystem.cellSize
        
        return SIMD3<Float>(posX, origin.y, posZ)
    }
}
