import ARKit

extension ARPlaneAnchor {
    public var worldSpaceExtentCorners: [SIMD3<Float>] {
        let center = self.center
        let extent = self.extent
        let transform = self.transform
        
        let halfX = extent.x / 2.0
        let halfZ = extent.z / 2.0
        
        let localCorners = [
            SIMD4<Float>(center.x - halfX, center.y, center.z - halfZ, 1.0),
            SIMD4<Float>(center.x + halfX, center.y, center.z - halfZ, 1.0),
            SIMD4<Float>(center.x + halfX, center.y, center.z + halfZ, 1.0),
            SIMD4<Float>(center.x - halfX, center.y, center.z + halfZ, 1.0)
        ]
        
        return localCorners.map { local in
            let world = transform * local
            return SIMD3<Float>(world.x, world.y, world.z)
        }
    }
}
