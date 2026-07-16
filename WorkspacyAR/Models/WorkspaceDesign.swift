import Foundation

public struct WorkspaceDesign: Identifiable, Hashable {
    public let id: UUID
    public var name: String
    public let createdAt: Date
    public var itemCount: Int
    public var ergonomicsScore: Int
    public var iconName: String
    
    public init(id: UUID = UUID(), name: String, createdAt: Date = Date(), itemCount: Int, ergonomicsScore: Int, iconName: String) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.itemCount = itemCount
        self.ergonomicsScore = ergonomicsScore
        self.iconName = iconName
    }
}
