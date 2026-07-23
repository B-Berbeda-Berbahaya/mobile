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
    /// on top of the desk mesh or inside the custom desk polygon, and animates a bounce-back to the initial position before move if dropped outside.
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

        // Get WORLD position of the object in 3D space
        let worldPos = entity.position(relativeTo: nil)

        // Check if 2D (X, Z) world position is inside polygon of calibrated desk corners
        let points2D = stateManager.calibrationPoints.map { SIMD2<Float>($0.x, $0.z) }
        let point2D = SIMD2<Float>(worldPos.x, worldPos.z)

        var isOnDesk = false
        if points2D.count >= 3 {
            isOnDesk = isPointInPolygon(point: point2D, polygon: points2D)
        } else {
            let origin = worldPos + SIMD3<Float>(0, 0.10, 0)
            let destination = worldPos - SIMD3<Float>(0, 0.10, 0)
            let hits = arView.scene.raycast(from: origin, to: destination)
            isOnDesk = hits.contains { $0.entity.name == "desk_model" } || stateManager.calibrationPoints.isEmpty
        }

        if isDragging {
            self.wasDragging = true
        } else if self.wasDragging {
            self.wasDragging = false

            // Hentikan sisa inersia/kecepatan fisik agar objek tidak meluncur/bergeser sendiri setelah dilepas
            entity.components.set(PhysicsMotionComponent(linearVelocity: .zero, angularVelocity: .zero))

            if !isOnDesk {
                if let startingPos = self.initialPositionBeforeMove {
                    entity.position = startingPos
                    entity.components.set(PhysicsMotionComponent(linearVelocity: .zero, angularVelocity: .zero))
                    notifyObjectUpdate(selected)
                    print("🔄 Objek dilepas di luar meja! Mengembalikan langsung ke posisi awal sebelum dimove.")
                }
            } else {
                // Jika dilepas di posisi valid di dalam meja, perbarui posisi awal ke posisi baru ini
                self.initialPositionBeforeMove = entity.position
                self.lastValidPosition = entity.position
                notifyObjectUpdate(selected)
            }
        }
    }

    func isPointInPolygon(point: SIMD2<Float>, polygon: [SIMD2<Float>]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var inside = false
        var j = polygon.count - 1
        for i in 0..<polygon.count {
            let pi = polygon[i]
            let pj = polygon[j]
            if ((pi.y > point.y) != (pj.y > point.y)) &&
                (point.x < (pj.x - pi.x) * (point.y - pi.y) / (pj.y - pi.y) + pi.x) {
                inside.toggle()
            }
            j = i
        }
        return inside
    }
}
