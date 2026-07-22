//
//  ARViewCoordinator+Transform.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import Foundation
import RealityKit
import UIKit

extension ARViewCoordinator {
    // MARK: - Actions From UI

    public func selectObject(_ object: PlacedObject) {
        deselectCurrentObject()
        selectedPlacedObject = object
        stateManager.setInteractionMode(.move)
        onSelectedObjectChanged?(object)

        self.lastValidPosition = object.entity.position(
            relativeTo: object.entity.parent
        )
        self.wasDragging = false

        let entity = object.entity
        if entity.findEntity(named: "highlight_overlay") == nil {
            if let mesh = entity.model?.mesh {
                let glowMaterial = UnlitMaterial(
                    color: UIColor.white.withAlphaComponent(0.35)
                )
                let highlightEntity = ModelEntity(
                    mesh: mesh,
                    materials: [glowMaterial]
                )
                highlightEntity.name = "highlight_overlay"
                highlightEntity.scale = [1.05, 1.05, 1.05]
                entity.addChild(highlightEntity)
            }
        }
        updatePopoverPosition()
        updateGesturesState()
    }

    public func deselectCurrentObject() {
        if let object = selectedPlacedObject {
            if let highlight = object.entity.findEntity(
                named: "highlight_overlay"
            ) {
                highlight.removeFromParent()
            }
        }
        selectedPlacedObject = nil
        stateManager.setInteractionMode(.none)
        self.lastValidPosition = nil
        self.wasDragging = false
        onSelectedObjectChanged?(nil)
        stateManager.popoverPosition = .zero
        updateGesturesState()
    }

    public func removeObject(withID id: UUID) {
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }
        ) {
            if selectedPlacedObject?.id == id {
                deselectCurrentObject()
            }
            if let arView = arView {
                anchorManager.removeObject(object, in: arView)
            }
        }
    }
}
