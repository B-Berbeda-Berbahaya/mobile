//
//  ARViewCoordinator+Transform.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import Foundation
import RealityKit
import UIKit
import ARKit

extension ARViewCoordinator {
    func updateFocusPosition() {
        guard let arView = arView, !stateManager.isDeskLocked else {
            DispatchQueue.main.async { self.stateManager.focus3DPosition = nil }
            return
        }

        let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        let results = arView.raycast(
            from: centerPoint,
            allowing: .existingPlaneGeometry,
            alignment: .horizontal
        )

        if let firstResult = results.first {
            let position = SIMD3<Float>(
                firstResult.worldTransform.columns.3.x,
                firstResult.worldTransform.columns.3.y,
                firstResult.worldTransform.columns.3.z
            )

            var isTable = false
            var planeName = "Floor/Flat Surface"
            if let planeAnchor = firstResult.anchor as? ARPlaneAnchor {
                switch planeAnchor.classification {
                case .table:
                    isTable = true
                    planeName = "Desk"
                case .floor:
                    planeName = "Floor"
                default:
                    planeName = "Flat Surface"
                }
            }

            DispatchQueue.main.async {
                self.stateManager.focus3DPosition = position
                self.stateManager.isFocusOnTable = isTable
                self.stateManager.detectedPlaneType = planeName
            }
        } else {
            let estimatedResults = arView.raycast(
                from: centerPoint,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )
            if let firstEstimated = estimatedResults.first {
                let position = SIMD3<Float>(
                    firstEstimated.worldTransform.columns.3.x,
                    firstEstimated.worldTransform.columns.3.y,
                    firstEstimated.worldTransform.columns.3.z
                )
                DispatchQueue.main.async {
                    self.stateManager.focus3DPosition = position
                    self.stateManager.isFocusOnTable = false
                    self.stateManager.detectedPlaneType = "Estimasi Bidang"
                }
            } else {
                DispatchQueue.main.async {
                    self.stateManager.focus3DPosition = nil
                    self.stateManager.isFocusOnTable = false
                    self.stateManager.detectedPlaneType = "Scanning area..."
                }
            }
        }
    }
}
