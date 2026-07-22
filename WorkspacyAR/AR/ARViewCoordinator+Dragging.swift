//
//  ARViewCoordinator+Dragging.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import ARKit
import Combine
import Foundation
import RealityKit

extension ARViewCoordinator {
    /// Tracks the drag/translation gesture state of the selected object, validates if it remains
    /// on top of the desk mesh, and animates a bounce-back to the last valid position if dropped outside.
    func trackDraggedObjectAndBounce() {
        guard let arView = arView,
            let selected = selectedPlacedObject,
            stateManager.interactionMode == .move
        else { return }

        let entity = selected.entity

        var isDragging = false
        if let gestureRecognizers = arView.gestureRecognizers {
            for gesture in gestureRecognizers {
                if let translationGesture = gesture
                    as? EntityTranslationGestureRecognizer
                {
                    if translationGesture.state == .began
                        || translationGesture.state == .changed
                    {
                        isDragging = true
                    }
                }
            }
        }

        let origin = SIMD3<Float>(
            entity.position(relativeTo: nil).x,
            entity.position(relativeTo: nil).y + 0.05,
            entity.position(relativeTo: nil).z
        )
        let destination = SIMD3<Float>(
            entity.position(relativeTo: nil).x,
            entity.position(relativeTo: nil).y - 0.05,
            entity.position(relativeTo: nil).z
        )
        let hits = arView.scene.raycast(from: origin, to: destination)
        let isOnDesk = hits.contains { $0.entity.name == "desk_model" }

        if isOnDesk {
            self.lastValidPosition = entity.position(relativeTo: entity.parent)
        }

        let whiteMaterial = UnlitMaterial(
            color: UIColor.white.withAlphaComponent(0.35)
        )
        updateHighlightMaterial(on: entity, to: whiteMaterial)

        if isDragging {
            self.wasDragging = true
        } else if self.wasDragging {
            self.wasDragging = false

            if !isOnDesk {
                if let lastValid = self.lastValidPosition {
                    var targetTransform = entity.transform
                    targetTransform.translation = lastValid

                    entity.move(
                        to: targetTransform,
                        relativeTo: entity.parent,
                        duration: 0.35,
                        timingFunction: .easeOut
                    )
                    notifyObjectUpdate(selected)
                }
            }
        }
    }

    private func updateHighlightMaterial(
        on entity: Entity,
        to material: RealityKit.Material
    ) {
        if entity.name == "highlight_overlay",
            let modelEntity = entity as? ModelEntity
        {
            modelEntity.model?.materials = [material]
        }
        for child in entity.children {
            updateHighlightMaterial(on: child, to: material)
        }
    }
}
