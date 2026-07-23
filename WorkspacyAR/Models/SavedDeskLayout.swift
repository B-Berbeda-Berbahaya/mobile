import Foundation
import SwiftData
import simd

public struct CodableVector3: Codable {
    public var x: Float
    public var y: Float
    public var z: Float
    
    public var simd: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
    
    public init(_ simd: SIMD3<Float>) {
        self.x = simd.x
        self.y = simd.y
        self.z = simd.z
    }
    
    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct CodableQuaternion: Codable {
    public var x: Float
    public var y: Float
    public var z: Float
    public var w: Float
    
    public init(x: Float, y: Float, z: Float, w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
}

public struct CodablePlacedObject: Codable {
    public var id: UUID
    public var assetName: String
    public var relativePosition: CodableVector3
    public var rotation: CodableQuaternion
    
    public init(id: UUID, assetName: String, relativePosition: CodableVector3, rotation: CodableQuaternion) {
        self.id = id
        self.assetName = assetName
        self.relativePosition = relativePosition
        self.rotation = rotation
    }
}

@Model
public final class SavedDeskLayout {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var createdAt: Date
    public var relativePointsData: Data
    public var placedObjectsData: Data
    
    public init(name: String, relativePoints: [SIMD3<Float>], placedObjects: [CodablePlacedObject]) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
        
        let codablePoints = relativePoints.map { CodableVector3($0) }
        self.relativePointsData = (try? JSONEncoder().encode(codablePoints)) ?? Data()
        self.placedObjectsData = (try? JSONEncoder().encode(placedObjects)) ?? Data()
    }
    
    public var relativePoints: [SIMD3<Float>] {
        guard let decoded = try? JSONDecoder().decode([CodableVector3].self, from: relativePointsData) else {
            return []
        }
        return decoded.map { $0.simd }
    }
    
    public var placedObjects: [CodablePlacedObject] {
        (try? JSONDecoder().decode([CodablePlacedObject].self, from: placedObjectsData)) ?? []
    }
}
