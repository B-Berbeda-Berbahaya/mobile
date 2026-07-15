import Foundation

public struct GridCoordinate: Hashable, Codable {
    public let x: Int
    public let z: Int
    
    public init(x: Int, z: Int) {
        self.x = x
        self.z = z
    }
}
