import Foundation
import simd

// Converts between AR world-space positions and internal GridCoordinate,
// relative to GridSystem's origin and cell size. Pure math — no ARKit
// or RealityKit dependency.

// TODO: struct WorldToGridMapper {
//     let gridSystem: GridSystem
//
//     func gridCoordinate(for worldPosition: SIMD3<Float>) -> GridCoordinate
//     func worldPosition(for coordinate: GridCoordinate) -> SIMD3<Float>
// }
