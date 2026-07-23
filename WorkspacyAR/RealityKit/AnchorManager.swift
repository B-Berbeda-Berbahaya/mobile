import RealityKit
import Combine
import Foundation

public final class AnchorManager {
    public private(set) var placedObjects: [PlacedObject] = []
    
    public init() {}
    
    @discardableResult
    public func placeEntity(_ entity: ModelEntity, at worldPosition: SIMD3<Float>, in arView: ARView, type: PlaceableObjectType) -> PlacedObject {
        let anchorEntity = AnchorEntity(world: worldPosition)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
        
        let placedObj = PlacedObject(entity: entity, type: type)
        placedObjects.append(placedObj)
        
        return placedObj
    }
    
    public func removeObject(_ object: PlacedObject, in arView: ARView) {
        if let anchorEntity = object.entity.anchor {
            arView.scene.removeAnchor(anchorEntity)
        }
        placedObjects.removeAll(where: { $0.id == object.id })
    }
    
    public func removeAll(in arView: ARView) {
        for obj in placedObjects {
            if let anchorEntity = obj.entity.anchor {
                arView.scene.removeAnchor(anchorEntity)
            }
        }
        placedObjects.removeAll()
    }
    
    public func canPlace(at position: SIMD3<Float>, overlapRadius: Float = 0.1) -> Bool {
        for obj in placedObjects {
            let objPos = obj.entity.position(relativeTo: nil)
            let dx = objPos.x - position.x
            let dz = objPos.z - position.z
            let horizontalDistance = sqrt(dx * dx + dz * dz)
            
            if horizontalDistance < overlapRadius && !obj.type.canBeStackedOn {
                return false
            }
        }
        return true
    }
    
    /// Ngecek apakah suatu titik nabrak objek yang udah ada DAN gak boleh ditimpa.
    private func blockingOverlap(
        at position: SIMD3<Float>,
        radius: Float,
        newItemType: PlaceableObjectType,
        excluding excludedID: UUID? = nil
    ) -> (blocked: Bool, stackBase: PlacedObject?) {
        var stackBase: PlacedObject? = nil
        
        for obj in placedObjects {
            if obj.id == excludedID { continue }
            
            let objPos = obj.entity.position(relativeTo: nil)
            let dx = objPos.x - position.x
            let dz = objPos.z - position.z
            let distance = sqrt(dx * dx + dz * dz)
            
            guard distance < (radius + obj.type.footprintRadius) else { continue }
            
            // Objek baru boleh "naik" ke atas HANYA kalau objek lama itu .base
            // dan objek baru itu .device (bukan sesama .base)
            let canStackOnThis = (obj.type.stackLayer == .base) && (newItemType.stackLayer == .device)
            
            if canStackOnThis {
                if stackBase == nil || objPos.y > stackBase!.entity.position(relativeTo: nil).y {
                    stackBase = obj
                }
            } else {
                return (blocked: true, stackBase: nil)
            }
        }
        
        return (blocked: false, stackBase: stackBase)
    }

    private func blockingOverlap(
        at position: SIMD3<Float>,
        radius: Float,
        excluding excludedID: UUID? = nil
    ) -> (blocked: Bool, stackBase: PlacedObject?) {
        var stackBase: PlacedObject? = nil
        
        for obj in placedObjects {
            if obj.id == excludedID { continue }
            
            let objPos = obj.entity.position(relativeTo: nil)
            let dx = objPos.x - position.x
            let dz = objPos.z - position.z
            let distance = sqrt(dx * dx + dz * dz)
            
            guard distance < (radius + obj.type.footprintRadius) else { continue }
            
            if obj.type.canBeStackedOn {
                // Simpan alas tertinggi kalau ada beberapa yang overlap
                if stackBase == nil || objPos.y > stackBase!.entity.position(relativeTo: nil).y {
                    stackBase = obj
                }
            } else {
                return (blocked: true, stackBase: nil)
            }
        }
        
        return (blocked: false, stackBase: stackBase)
    }

    public func findValidPosition(
        near target: SIMD3<Float>,
        for type: PlaceableObjectType,
        excluding excludedID: UUID? = nil
    ) -> SIMD3<Float> {
        let radius = type.footprintRadius
        
        let result = blockingOverlap(at: target, radius: radius, newItemType: type, excluding: excludedID)
        if !result.blocked {
            if let base = result.stackBase {
                let baseY = base.entity.position(relativeTo: nil).y
                return SIMD3<Float>(target.x, baseY + base.type.physicalHeight, target.z)
            }
            return target
        }
        
        let directionsPerRing = 12
        let maxRings = 12
        let ringStep: Float = 0.06
        
        for ring in 1...maxRings {
            let searchRadius = Float(ring) * ringStep
            for i in 0..<directionsPerRing {
                let angle = (Float(i) / Float(directionsPerRing)) * 2 * .pi
                let candidate = SIMD3<Float>(
                    target.x + cos(angle) * searchRadius,
                    target.y,
                    target.z + sin(angle) * searchRadius
                )
                let candidateResult = blockingOverlap(at: candidate, radius: radius, newItemType: type, excluding: excludedID)
                if !candidateResult.blocked {
                    if let base = candidateResult.stackBase {
                        let baseY = base.entity.position(relativeTo: nil).y
                        return SIMD3<Float>(candidate.x, baseY + base.type.physicalHeight, candidate.z)
                    }
                    return candidate
                }
            }
        }
        
        return target
    }

    public func liftOverlappingObjects(above newBase: PlacedObject) {
        guard newBase.type.stackLayer == .base else { return }
        
        let basePos = newBase.entity.position(relativeTo: nil)
        let baseRadius = newBase.type.footprintRadius
        let targetY = basePos.y + newBase.type.physicalHeight
        
        for obj in placedObjects {
            if obj.id == newBase.id { continue }
            if obj.type.stackLayer != .device { continue } // sesama .base tidak diangkat
            
            let objPos = obj.entity.position(relativeTo: nil)
            let dx = objPos.x - basePos.x
            let dz = objPos.z - basePos.z
            let distance = sqrt(dx * dx + dz * dz)
            
            guard distance < (baseRadius + obj.type.footprintRadius) else { continue }
            
            if objPos.y < targetY {
                obj.entity.setPosition(
                    SIMD3<Float>(objPos.x, targetY, objPos.z),
                    relativeTo: nil
                )
            }
        }
    }
}
