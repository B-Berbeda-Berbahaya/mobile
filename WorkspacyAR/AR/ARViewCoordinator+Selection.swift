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

        self.initialPositionBeforeMove = object.entity.position(
            relativeTo: object.entity.parent
        )
        self.lastValidPosition = object.entity.position(
            relativeTo: object.entity.parent
        )
        self.wasDragging = false

        let entity = object.entity
        updatePopoverPosition()
        updateGesturesState()
    }

    public func deselectCurrentObject() {
        if let object = selectedPlacedObject {
            removeHighlightOverlay(from: object.entity)
        }
        selectedPlacedObject = nil
        stateManager.setInteractionMode(.none)
        self.initialPositionBeforeMove = nil
        self.lastValidPosition = nil
        self.wasDragging = false
        onSelectedObjectChanged?(nil)
        stateManager.popoverPosition = .zero
        updateGesturesState()
    }

    private func removeHighlightOverlay(from entity: Entity) {
        if let highlight = entity.findEntity(named: "highlight_overlay") {
            highlight.removeFromParent()
        }
        for child in entity.children {
            removeHighlightOverlay(from: child)
        }
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
