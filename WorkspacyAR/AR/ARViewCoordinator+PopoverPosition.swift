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
    func updatePopoverPosition() {
        guard let arView = arView, let object = selectedPlacedObject else {
            DispatchQueue.main.async {
                self.stateManager.popoverPosition = .zero
            }
            return
        }

        let bounds = object.entity.visualBounds(relativeTo: nil)
        let topPosition = SIMD3<Float>(
            bounds.center.x,
            bounds.max.y + 0.05,
            bounds.center.z
        )

        if let screenPoint = arView.project(topPosition) {
            DispatchQueue.main.async {
                self.stateManager.popoverPosition = screenPoint
            }
        } else {
            DispatchQueue.main.async {
                self.stateManager.popoverPosition = .zero
            }
        }
    }
}
