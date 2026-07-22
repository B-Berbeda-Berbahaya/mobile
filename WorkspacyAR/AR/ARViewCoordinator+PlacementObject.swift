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
    
    /// Tap Gesture handling for ARView delegation
    @objc public func handleTap(_ recognizer: UITapGestureRecognizer) {
        // Check for arView instance within class
        guard let arView = self.arView else { return }

        // Get tap location
        let location = recognizer.location(in: arView)

        // Check if tapping existing placed object
        // Check for tapping existing object
        if let entity = arView.entity(at: location) as? ModelEntity {
            if entity.name == "desk_model"
                || entity.name.hasPrefix("handle_")
                || entity.name.hasPrefix("line_")
                || entity.name == "rubber_band"
                || entity.name == "invalid_ghost"
            {
                // Ignore virtual desk
            } else {
                // Select the parent object of highlighted object
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

        // MARK: Place new object

        // If we reach here, we are trying to place something
        guard stateManager.isDeskLocked else { return }  // Can only place if desk is locked

        // Hit test for virtual desk
        let hitResults = arView.hitTest(location)

        // Check if the hitted object is a desk
        if let deskHit = hitResults.first(where: {
            $0.entity.name == "desk_model"
        }) {
            Task { @MainActor in
                await placeObject(
                    worldPosition: deskHit.position,
                    type: activePlacingType
                )
            }
        } else {
            // Failed to drop: Spawn invalid ghost
            // Detect horizontal plane
            let raycastResults = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )

            // Get positoin on the plane
            let position: SIMD3<Float>
            if let firstResult = raycastResults.first {
                position = SIMD3<Float>(
                    firstResult.worldTransform.columns.3.x,
                    firstResult.worldTransform.columns.3.y,
                    firstResult.worldTransform.columns.3.z
                )
            } else {
                // Default position is 50cm above camera
                position = SIMD3<Float>(0, 0, -0.5)  // Fallback
            }

            // Spawn ghost
            Task { @MainActor in
                await spawnInvalidGhost(
                    type: activePlacingType,
                    at: position,
                    in: arView
                )
            }
        }
    }

    private func placeObject(
        worldPosition: SIMD3<Float>,
        type: PlaceableObjectType
    ) async {
        guard let arView = arView else { return }

        let entity = await PlaceableEntityFactory.makeEntity(for: type)
        
        // Place object to world
        let placedObj = anchorManager.placeEntity(
            entity,
            at: worldPosition,
            in: arView,
            type: type
        )

        // Attach physics
        let physics = PhysicsBodyComponent(
            massProperties: .init(mass: 1.0),
            material: .default,
            mode: .dynamic
        )
        entity.components.set(physics)


        // Install gestures
        let gestures = arView.installGestures(
            [.translation, .rotation],
            for: entity
        )
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
