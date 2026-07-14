import Foundation

// Discrete coordinate in the internal grid system (horizontal plane,
// x/z axis — matches ARKit's ground plane convention where y is up).
// Responsibility: pure value type, Hashable so it can key GridSystem's
// cell dictionary. No dependency on ARKit/RealityKit.

// TODO: struct GridCoordinate: Hashable {
//     let x: Int
//     let z: Int
// }
