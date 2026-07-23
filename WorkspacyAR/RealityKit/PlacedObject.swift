import RealityKit
import Foundation

public final class PlacedObject: Identifiable {
    public let id: UUID
    public let entity: ModelEntity
    public let type: PlaceableObjectType
    public let placedAt: Date
    
    public init(id: UUID = UUID(), entity: ModelEntity, type: PlaceableObjectType, placedAt: Date = Date()) {
        self.id = id
        self.entity = entity
        self.type = type
        self.placedAt = placedAt
    }
}
