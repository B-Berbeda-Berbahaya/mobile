import RealityKit
import Foundation

public final class PlacedObject: Identifiable {
    public let id: UUID
    public let entity: ModelEntity
    public let type: PlaceableObjectType
    public var gridCoordinate: GridCoordinate
    public let placedAt: Date
    
    public init(id: UUID = UUID(), entity: ModelEntity, type: PlaceableObjectType, gridCoordinate: GridCoordinate, placedAt: Date = Date()) {
        self.id = id
        self.entity = entity
        self.type = type
        self.gridCoordinate = gridCoordinate
        self.placedAt = placedAt
    }
}
