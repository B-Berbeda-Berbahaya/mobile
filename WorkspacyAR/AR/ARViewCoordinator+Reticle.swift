//
//  ARViewCoordinator+Reticle.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import ARKit
import Foundation
import RealityKit
import UIKit

extension ARViewCoordinator {
    
    /// Updates the position, orientation, and visual color of the AR reticle target ring
    /// based on continuous center-screen raycasting.
    func updateReticle() {
        guard let arView = arView else { return }
        if stateManager.isDeskLocked {
            reticleAnchor?.isEnabled = false
            return
        }

        let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        let results = arView.raycast(
            from: centerPoint,
            allowing: .existingPlaneGeometry,
            alignment: .horizontal
        )

        let hitResult: ARRaycastResult?
        if let first = results.first {
            hitResult = first
        } else {
            let estimated = arView.raycast(
                from: centerPoint,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )
            hitResult = estimated.first
        }

        if let result = hitResult {
            let anchor: AnchorEntity
            if let existing = self.reticleAnchor {
                anchor = existing
            } else {
                anchor = AnchorEntity()
                self.setReticleAnchor(anchor)
                arView.scene.addAnchor(anchor)
            }

            let entity: ModelEntity
            if let existingEntity = self.reticleEntity {
                entity = existingEntity
            } else {
                let planeMesh = MeshResource.generatePlane(
                    width: 0.05,
                    depth: 0.05
                )
                let material = UnlitMaterial(
                    color: UIColor.white.withAlphaComponent(0.8)
                )
                entity = ModelEntity(mesh: planeMesh, materials: [material])
                entity.name = "reticle_model"
                self.setReticleEntity(entity)
                anchor.addChild(entity)
            }

            anchor.transform = Transform(matrix: result.worldTransform)
            anchor.isEnabled = true

            let isPlane = result.anchor is ARPlaneAnchor
            let reticleColor = isPlane ? UIColor.green : UIColor.white
            var material = UnlitMaterial()
            material.blending = .transparent(opacity: 1.0)
            if let texture = generateReticleTexture(color: reticleColor) {
                let materialTexture = MaterialParameters.Texture(texture)
                material.color = .init(
                    tint: UIColor.white,
                    texture: materialTexture
                )
            } else {
                material.color = .init(
                    tint: reticleColor.withAlphaComponent(0.8)
                )
            }
            entity.model?.materials = [material]
        } else {
            reticleAnchor?.isEnabled = false
        }
    }

    private func generateReticleTexture(color: UIColor) -> TextureResource? {
        let size = CGSize(width: 128, height: 128)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        let image = renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.clear.cgColor)
            ctx.fill(CGRect(origin: .zero, size: size))
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(4.0)
            ctx.strokeEllipse(in: CGRect(x: 10, y: 10, width: 108, height: 108))
        }
        guard let cgImage = image.cgImage else { return nil }
        return try? TextureResource.init(
            image: cgImage,
            options: .init(semantic: .color)
        )
    }
}
