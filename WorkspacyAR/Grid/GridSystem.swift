import Foundation
import simd

// Core container for the internal grid: cell size, world-space origin
// reference, and the dictionary of tracked cells. This is the single
// source of truth ARViewCoordinator consults before placing an object,
// and PlaneGridExtrapolator writes into as planes are detected.
// Pure Swift/simd — no ARKit or RealityKit dependency.

// TODO: final class GridSystem {
//     let cellSize: Float
//     private(set) var origin: SIMD3<Float>?
//     private(set) var cells: [GridCoordinate: GridCell]
//
//     func setOriginIfNeeded(_ worldPosition: SIMD3<Float>)
//     func markAvailable(_ coordinate: GridCoordinate)
//     func markOccupied(_ coordinate: GridCoordinate, objectID: UUID)
//     func isAvailable(_ coordinate: GridCoordinate) -> Bool
// }
