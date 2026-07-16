import ARKit
import simd

public struct PlaneGridExtrapolator {
    public let gridSystem: GridSystem
    public let mapper: WorldToGridMapper
    
    public init(gridSystem: GridSystem, mapper: WorldToGridMapper) {
        self.gridSystem = gridSystem
        self.mapper = mapper
    }
    
    public func extrapolate(planeAnchor: ARPlaneAnchor) {
        let anchorTransform = planeAnchor.transform
        let anchorWorldPos = SIMD3<Float>(anchorTransform.columns.3.x, anchorTransform.columns.3.y, anchorTransform.columns.3.z)
        
        gridSystem.setOriginIfNeeded(anchorWorldPos)
        
        let extent = planeAnchor.extent
        let center = planeAnchor.center
        
        let step = gridSystem.cellSize
        let halfWidth = extent.x / 2.0
        let halfDepth = extent.z / 2.0
        
        var xOffset = -halfWidth
        while xOffset <= halfWidth {
            var zOffset = -halfDepth
            while zOffset <= halfDepth {
                let localPos = SIMD4<Float>(center.x + xOffset, center.y, center.z + zOffset, 1.0)
                let worldPos4 = anchorTransform * localPos
                let worldPos = SIMD3<Float>(worldPos4.x, worldPos4.y, worldPos4.z)
                
                let coordinate = mapper.gridCoordinate(for: worldPos)
                gridSystem.markAvailable(coordinate)
                
                zOffset += step
            }
            xOffset += step
        }
    }
}
