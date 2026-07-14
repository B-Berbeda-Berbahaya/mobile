import Foundation

// State of a single cell inside GridSystem.
// Responsibility: describe whether a cell corresponds to real-world
// surface detected by PlaneGridExtrapolator, and whether it currently
// holds a placed object.

// TODO: enum GridCell {
//     case unavailable                 // not (yet) confirmed as real-world surface
//     case empty                       // confirmed available, nothing placed
//     case occupied(objectID: UUID)    // confirmed available, object placed
// }
