import ARKit
import simd

// Core extrapolation logic: takes a detected ARPlaneAnchor (its
// extent + transform) and samples the covered world-space area,
// marking the corresponding GridCoordinate cells as available in
// GridSystem via WorldToGridMapper. This is what bridges "real world
// plane" to "internal grid system".

// TODO: struct PlaneGridExtrapolator {
//     let gridSystem: GridSystem
//     let mapper: WorldToGridMapper
//
//     func extrapolate(planeAnchor: ARPlaneAnchor)
//     // internally: iterate sample points across planeAnchor.planeExtent,
//     // transform each to world space via planeAnchor.transform,
//     // map to GridCoordinate, mark available in gridSystem
// }
