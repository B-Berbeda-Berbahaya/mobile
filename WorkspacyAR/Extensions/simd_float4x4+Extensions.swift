import simd

extension simd_float4x4 {
    public var translation: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
    
    public var rotation: simd_quatf {
        return simd_quatf(self)
    }
}
