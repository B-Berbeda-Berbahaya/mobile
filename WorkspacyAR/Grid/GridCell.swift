import Foundation

public enum GridCell: Hashable, Codable {
    case unavailable
    case empty
    case occupied(objectID: UUID)
}
