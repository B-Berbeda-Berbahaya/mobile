import ARKit

extension ARPlaneAnchor {
    public var worldSpaceExtentCorners: [SIMD3<Float>] {
        let transform = self.transform

        if #available(iOS 16.0, *) {
            // Prefer precise boundary vertices if available
            let boundary = self.geometry.boundaryVertices
            if !boundary.isEmpty {
                // Map boundary points (x, 0, z) from local plane space to world space.
                return boundary.map { local2D in
                    // Boundary vertices are in the plane's local space (x, z). y is at the plane's y level.
                    let local = SIMD4<Float>(local2D.x, 0.0, local2D.y, 1.0)
                    let world = transform * local
                    return SIMD3<Float>(world.x, world.y, world.z)
                }
            }
            // If for some reason boundary is empty, fall back to center + estimated size using extent-like approach
            // via the plane's estimated alignment. As a final fallback, use a small square around center.
            let center = self.center
            let halfX: Float = 0.25
            let halfZ: Float = 0.25
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
        } else {
            // iOS < 16: use deprecated extent as a fallback to maintain compatibility
            let center = self.center
            let extent = self.extent
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
}
