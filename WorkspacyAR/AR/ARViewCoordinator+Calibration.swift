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
    func syncDraggedHandles() {
        guard let anchor = deskAnchor, !stateManager.isDeskLocked else {
            return
        }
        var points = stateManager.calibrationPoints
        guard !points.isEmpty else { return }

        var didChange = false
        for i in 0..<points.count {
            if let handle = anchor.findEntity(named: "handle_\(i)") {
                let pos = handle.position
                let targetY = points.first?.y ?? pos.y
                let flatPos = SIMD3<Float>(pos.x, targetY, pos.z)

                if simd_distance(points[i], flatPos) > 0.001 {
                    points[i] = flatPos
                    handle.position = flatPos
                    didChange = true
                }
            }
        }
        if didChange {
            DispatchQueue.main.async {
                self.stateManager.calibrationPoints = points
            }
        }
    }

    /// Adds a new calibration point marker in the 3D space at the current focus position.
    ///
    /// This method creates or reuses a root desk anchor in the AR scene, flattens the Y-axis
    /// of the target position to match the initial calibration plane, constructs a spherical 3D handle entity
    /// with translation gesture support, and appends the point to the state manager.
    public func addPointAtFocus() {
        // Ensure the AR view instance and current 3D focus position are valid
        guard let arView = arView, let focusPos = stateManager.focus3DPosition
        else { return }

        // Retrieve the existing root desk anchor or initialize and attach a new one to the scene
        let anchor: AnchorEntity
        if let existing = self.deskAnchor {
            anchor = existing
        } else {
            anchor = AnchorEntity()
            self.setDeskAnchor(anchor)
            arView.scene.addAnchor(anchor)
        }

        // Determine point index and flatten Y-coordinate to align with the first calibration point's height
        let index = stateManager.calibrationPoints.count
        let targetY = stateManager.calibrationPoints.first?.y ?? focusPos.y
        let flatPos = SIMD3<Float>(focusPos.x, targetY, focusPos.z)

        // Create a spherical 3D visual handle for the calibration point
        let handleMesh = MeshResource.generateSphere(radius: 0.010)
        let handleMaterial = SimpleMaterial(color: .orange, isMetallic: false)
        let handleEntity = ModelEntity(
            mesh: handleMesh,
            materials: [handleMaterial]
        )

        // Configure entity properties and position in 3D space
        handleEntity.name = "handle_\(index)"
        handleEntity.position = flatPos

        // Enable collision shapes and attach drag/translation gestures for user interaction
        handleEntity.generateCollisionShapes(recursive: true)
        arView.installGestures(.translation, for: handleEntity)

        // Attach the handle entity to the scene anchor
        anchor.addChild(handleEntity)

        // Update state manager properties on the main thread
        DispatchQueue.main.async {
            self.stateManager.calibrationPoints.append(flatPos)
            self.stateManager.isDeskDetected = true
        }
    }

    public func removeLastPoint() {
        guard let anchor = deskAnchor, !stateManager.calibrationPoints.isEmpty
        else { return }
        let indexToRemove = stateManager.calibrationPoints.count - 1

        if let handle = anchor.findEntity(named: "handle_\(indexToRemove)") {
            handle.removeFromParent()
        }

        DispatchQueue.main.async {
            self.stateManager.calibrationPoints.removeLast()
            if self.stateManager.calibrationPoints.isEmpty {
                self.stateManager.isDeskDetected = false
            }
        }
    }

    public func resetCalibration() {
        if let anchor = deskAnchor {
            anchor.removeFromParent()
            self.setDeskAnchor(nil)
        }
        if let rAnchor = reticleAnchor {
            rAnchor.removeFromParent()
            self.setReticleAnchor(nil)
            self.setReticleEntity(nil)
        }

        DispatchQueue.main.async {
            self.stateManager.calibrationPoints.removeAll()
            self.stateManager.isDeskDetected = false
            self.stateManager.setDeskLock(false)
        }
    }

    public func updateHandlesVisibility(isLocked: Bool) {
        guard let anchor = deskAnchor else { return }
        let pointsCount = stateManager.calibrationPoints.count

        for i in 0..<pointsCount {
            if let handle = anchor.findEntity(named: "handle_\(i)") {
                handle.isEnabled = !isLocked
            }
        }

        if let deskModel = anchor.findEntity(named: "desk_model")
            as? ModelEntity
        {
            if isLocked {
                deskModel.generateCollisionShapes(recursive: true)
                deskModel.components.set(
                    PhysicsBodyComponent(
                        massProperties: .init(mass: 0.0),
                        material: .default,
                        mode: .static
                    )
                )
            } else {
                deskModel.components.remove(PhysicsBodyComponent.self)
                deskModel.components.remove(CollisionComponent.self)
            }
        }
    }
}
