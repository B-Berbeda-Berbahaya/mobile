//
//  ARViewCoordinator+PlacementObject.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import Foundation
import RealityKit
import UIKit
import ARKit

extension ARViewCoordinator {
    
    @objc public func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let arView = self.arView else { return }
        let location = recognizer.location(in: arView)
        
        if let entity = arView.entity(at: location) as? ModelEntity {
            if entity.name == "desk_model"
                || entity.name.hasPrefix("handle_")
                || entity.name.hasPrefix("line_")
                || entity.name == "rubber_band"
                || entity.name == "invalid_ghost"
            {
                // Ignore virtual desk
            } else {
                let targetEntity =
                entity.name == "highlight_overlay"
                ? (entity.parent as? ModelEntity ?? entity) : entity
                
                if let placedObject = anchorManager.placedObjects.first(where: {
                    $0.entity == targetEntity
                }) {
                    selectObject(placedObject)
                    return
                }
            }
        }
        
        guard stateManager.isDeskLocked else { return }
        
        // Unwrap di sini — kalau nggak ada tipe aktif, memang belum bisa place apapun
        guard let type = activePlacingType else {
            return
        }
        
        let hitResults = arView.hitTest(location)
        
        if let deskHit = hitResults.first(where: { $0.entity.name == "desk_model" }) {
            Task { @MainActor in
                await placeObject(worldPosition: deskHit.position, type: type)
            }
        } else {
            let raycastResults = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )
            
            let position: SIMD3<Float>
            if let firstResult = raycastResults.first {
                position = SIMD3<Float>(
                    firstResult.worldTransform.columns.3.x,
                    firstResult.worldTransform.columns.3.y,
                    firstResult.worldTransform.columns.3.z
                )
            } else {
                position = SIMD3<Float>(0, 0, -0.5)
            }
            
            Task { @MainActor in
                await spawnInvalidGhost(type: type, at: position, in: arView)
            }
        }
    }
    
//    private func placeObject(worldPosition: SIMD3<Float>, type: PlaceableObjectType) async {
//        guard let arView = arView else { return }
//        
//        let entity = await PlaceableEntityFactory.makeEntity(for: type)
//        
//        let physics = PhysicsBodyComponent(
//            massProperties: .init(mass: 1.0),
//            material: .default,
//            mode: .kinematic
//        )
//        entity.components.set(physics)
//        
//        // Kalau titik tap nabrak objek yang gak boleh ditimpa,
//        // otomatis geser ke posisi kosong terdekat di desk yang sama.
//        let resolvedPosition = anchorManager.findValidPosition(near: worldPosition, for: type)
//        let spawnPosition = resolvedPosition + SIMD3<Float>(0, 0.003, 0) // +3mm
//        
//        let placedObj = anchorManager.placeEntity(entity, at: spawnPosition, in: arView, type: type)
//        
//        let gestures = arView.installGestures([.translation, .rotation], for: entity)
//        for gesture in gestures {
//            gesture.addTarget(self, action: #selector(handleEntityGesture(_:)))
//        }
//        
//        selectObject(placedObj)
//    }
    
    private func placeObject(worldPosition: SIMD3<Float>, type: PlaceableObjectType) async {
        guard let arView = arView else { return }
        
        let entity = await PlaceableEntityFactory.makeEntity(for: type)
        
        let physics = PhysicsBodyComponent(
            massProperties: .init(mass: 1.0),
            material: .default,
            mode: .kinematic
        )
        entity.components.set(physics)
        
        let resolvedPosition = anchorManager.findValidPosition(near: worldPosition, for: type)
        let spawnPosition = resolvedPosition + SIMD3<Float>(0, 0.003, 0)
        
        let placedObj = anchorManager.placeEntity(entity, at: spawnPosition, in: arView, type: type)
        
        // Kalau objek yang baru ditaruh itu alas (deskmat/raiser), angkat
        // objek-objek yang sudah ada dan overlap dengannya ke atas alas ini.
        anchorManager.liftOverlappingObjects(above: placedObj)
        
        let gestures = arView.installGestures([.translation, .rotation], for: entity)
        for gesture in gestures {
            gesture.addTarget(self, action: #selector(handleEntityGesture(_:)))
        }
        
        selectObject(placedObj)
    }
    
    private func spawnInvalidGhost(
        type: PlaceableObjectType,
        at position: SIMD3<Float>,
        in arView: ARView
    ) async {
        let modelEntity = await PlaceableEntityFactory.makeEntity(for: type)
        modelEntity.name = "invalid_ghost"
        
        let redMaterial = UnlitMaterial(
            color: UIColor.red.withAlphaComponent(0.60)
        )
        applyMaterialRecursively(modelEntity, material: redMaterial)
        
        let anchorEntity = AnchorEntity(world: position)
        anchorEntity.addChild(modelEntity)
        arView.scene.addAnchor(anchorEntity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            [weak anchorEntity] in
            anchorEntity?.removeFromParent()
        }
    }
    
    private func applyMaterialRecursively(
        _ entity: Entity,
        material: RealityKit.Material
    ) {
        if let modelEntity = entity as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        for child in entity.children {
            applyMaterialRecursively(child, material: material)
        }
    }
    
    // MARK: - Dragging & Bouncing
    
    @objc private func handleEntityGesture(_ recognizer: UIGestureRecognizer) {
        let entity: ModelEntity?
        if let translationGesture = recognizer
            as? EntityTranslationGestureRecognizer
        {
            entity = translationGesture.entity as? ModelEntity
        } else if let rotationGesture = recognizer
                    as? EntityRotationGestureRecognizer
        {
            entity = rotationGesture.entity as? ModelEntity
        } else {
            return
        }
        
        guard let targetEntity = entity,
              let placedObj = anchorManager.placedObjects.first(where: {
                  $0.entity == targetEntity
              })
        else {
            return
        }
        
        switch recognizer.state {
        case .began:
            if selectedPlacedObject?.id != placedObj.id {
                selectObject(placedObj)
            }
        case .changed:
            notifyObjectUpdate(placedObj)
        case .ended, .cancelled:
            notifyObjectUpdate(placedObj)
        default:
            break
        }
    }
}
