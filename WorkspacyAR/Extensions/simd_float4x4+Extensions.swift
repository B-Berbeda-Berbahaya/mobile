import simd

// Convenience accessors on simd_float4x4 (transform matrices returned
// by ARAnchor/ARPlaneAnchor/raycast results). Responsibility: extract
// translation/rotation components without repeating column-indexing
// logic across AR/Grid layers.

// TODO: extension simd_float4x4 {
//     var translation: SIMD3<Float> { get }
//     var rotation: simd_quatf { get }
// }
