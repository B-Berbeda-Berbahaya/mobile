//
//  ARViewCoordinator+Transform.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import Foundation
import RealityKit

extension ARViewCoordinator {
    
    func keepObjectsUpright() {   // hapus "private"
            guard let arView = arView else { return }
            for anchor in arView.scene.anchors {
                for child in anchor.children {
                    guard let modelEntity = child as? ModelEntity,
                          modelEntity.name.hasPrefix("placed_"),
                          modelEntity != selectedPlacedObject?.entity || stateManager.interactionMode != .rotate
                    else { continue }
                    
                    var currentTransform = modelEntity.transform
                    let forward = currentTransform.rotation.act(SIMD3<Float>(0, 0, 1))
                    let yawAngle = atan2(forward.x, forward.z)
                    currentTransform.rotation = simd_quatf(angle: yawAngle, axis: SIMD3<Float>(0, 1, 0))
                    modelEntity.transform = currentTransform
                }
            }
        }
    
    public func updateRotation(forID id: UUID, angleDegrees: Float) {
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }
        ) {
            let radians = angleDegrees * .pi / 180.0
            object.entity.transform.rotation = simd_quatf(
                angle: radians,
                axis: SIMD3<Float>(0, 1, 0)
            )
        }
    }

    public func updateHeight(forID id: UUID, heightCm: Float) {
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }
        ) {
            let heightMeters = heightCm / 100.0
            let targetWorldPos = SIMD3<Float>(
                object.entity.position.x,
                object.entity.position.y + heightMeters,
                object.entity.position.z
            )
            object.entity.setPosition(targetWorldPos, relativeTo: nil)
        }
    }
}
