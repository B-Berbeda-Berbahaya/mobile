//
//  ARViewCoordinator+DeskBuilder.swift
//  WorkspacyAR
//
//  Created by Bomanarakasura on 22/07/26.
//

import ARKit
import Combine
import Foundation
import RealityKit
import SwiftUI

extension ARViewCoordinator {
    func rebuildDeskElements() {
        guard let arView = arView else { return }

        let anchor: AnchorEntity
        if let existing = self.deskAnchor {
            anchor = existing
        } else {
            anchor = AnchorEntity()
            self.setDeskAnchor(anchor)
            arView.scene.addAnchor(anchor)
        }

        let points = stateManager.calibrationPoints
        anchor.children.filter {
            $0.name.hasPrefix("line_") || $0.name == "rubber_band"
        }.forEach { $0.removeFromParent() }

        if points.count >= 2 {
            let lineColor = UIColor.green
            for i in 0..<points.count - 1 {
                let line = createLineEntity(
                    from: points[i],
                    to: points[i + 1],
                    color: lineColor,
                    radius: 0.003
                )
                line.name = "line_\(i)"
                anchor.addChild(line)
            }
            if stateManager.isDeskLocked {
                let closeLine = createLineEntity(
                    from: points.last!,
                    to: points.first!,
                    color: .green,
                    radius: 0.003
                )
                closeLine.name = "line_close"
                anchor.addChild(closeLine)
            }
        }

        if !stateManager.isDeskLocked, let lastPoint = points.last,
            let focusPos = stateManager.focus3DPosition
        {
            let rubberBand = createLineEntity(
                from: lastPoint,
                to: focusPos,
                color: UIColor.green.withAlphaComponent(0.6),
                radius: 0.002
            )
            rubberBand.name = "rubber_band"
            anchor.addChild(rubberBand)
        }

        rebuildDeskMesh(in: anchor)
    }

    private func createLineEntity(
        from start: SIMD3<Float>,
        to end: SIMD3<Float>,
        color: UIColor,
        radius: Float
    ) -> ModelEntity {
        let distance = simd_distance(start, end)
        let height = max(distance, 0.001)
        let mesh = MeshResource.generateCylinder(height: height, radius: radius)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])

        entity.position = (start + end) / 2
        let direction = simd_normalize(end - start)
        let up = SIMD3<Float>(0, 1, 0)
        let dotVal = simd_dot(up, direction)
        let clampedDot = min(max(dotVal, -1.0), 1.0)
        let angle = acos(clampedDot)
        let axis = simd_cross(up, direction)

        if simd_length(axis) > 0.0001 {
            entity.orientation = simd_quatf(
                angle: angle,
                axis: simd_normalize(axis)
            )
        } else if direction.y < 0 {
            entity.orientation = simd_quatf(
                angle: .pi,
                axis: SIMD3<Float>(1, 0, 0)
            )
        }

        return entity
    }

    /// Rebuilds or updates the 3D procedural mesh surface representing the calibrated desk area.
    ///
    /// This method validates that at least 3 points exist, performs polygon triangulation,
    /// generates vertex positions with a slight Y-offset, calculates texture UV coordinates,
    /// and applies a grid material to visually render the desk area in the AR scene.
    ///
    /// - Parameter anchor: The parent `AnchorEntity` where the desk mesh model is attached.
    private func rebuildDeskMesh(in anchor: AnchorEntity) {
        let points = stateManager.calibrationPoints

        // Ensure at least 3 points are available to construct a 2D polygon mesh; otherwise, clean up existing mesh
        guard points.count >= 3 else {
            if let oldDesk = anchor.findEntity(named: "desk_model") {
                oldDesk.removeFromParent()
            }
            return
        }

        // Convert polygon points into a series of triangle vertex indices using triangulation
        //        let indices = Triangulator.triangulate(points: points)
        //        guard !indices.isEmpty else { return }

        let frontIndices = Triangulator.triangulate(points: points)
        guard !frontIndices.isEmpty else { return }

        // Sertakan indeks dua sisi (double-sided) agar tidak ter-cull dari sudut pandang manapun
        var backIndices: [UInt32] = []
        for i in stride(from: 0, to: frontIndices.count, by: 3) {
            backIndices.append(frontIndices[i])
            backIndices.append(frontIndices[i + 2])
            backIndices.append(frontIndices[i + 1])
        }
        let doubleSidedIndices = frontIndices + backIndices

        // Initialize the custom mesh descriptor and elevate Y position slightly (1mm) to prevent z-fighting
        var descriptor = MeshDescriptor(name: "desk_mesh")
        let alignedY = points.first?.y ?? 0.0
        let vertices = points.map { SIMD3<Float>($0.x, alignedY + 0.001, $0.z) }

        descriptor.positions = MeshBuffers.Positions(vertices)
        descriptor.primitives = .triangles(doubleSidedIndices)
        descriptor.normals = MeshBuffers.Normals(
            Array(repeating: SIMD3<Float>(0, 1, 0), count: vertices.count)
        )

        // Calculate UV texture coordinates based on the bounding box to tile the grid pattern evenly
        if !vertices.isEmpty {
            let xs = vertices.map { $0.x }
            let zs = vertices.map { $0.z }
            let minX = xs.min() ?? 0
            let maxX = xs.max() ?? 1
            let minZ = zs.min() ?? 0
            let maxZ = zs.max() ?? 1
            let rangeX = max(maxX - minX, 0.01)
            let rangeZ = max(maxZ - minZ, 0.01)

            let uvs = vertices.map { vertex -> SIMD2<Float> in
                let u = (vertex.x - minX) / rangeX
                let v = (vertex.z - minZ) / rangeZ
                return SIMD2<Float>(u * (rangeX / 0.1), v * (rangeZ / 0.1))
            }
            descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
        }

        // Generate the 3D Mesh Resource and apply material with grid texture or translucent color fallback
        if let mesh = try? MeshResource.generate(from: [descriptor]) {
            var material = UnlitMaterial()
            material.blending = .transparent(opacity: 1.0)

            material.faceCulling = .none

            if let texture = generateGridTexture() {
                let materialTexture = MaterialParameters.Texture(texture)
                material.color = .init(
                    tint: UIColor.white,
                    texture: materialTexture
                )
            } else {
                material.color = .init(
                    tint: UIColor.green.withAlphaComponent(0.30)
                )
            }

            // Desk Model mesh creation
            // Reuse existing desk model entity if present; otherwise, create and add a new model entity to the anchor
            if let deskModel = anchor.findEntity(named: "desk_model")
                as? ModelEntity
            {
                deskModel.model = ModelComponent(
                    mesh: mesh,
                    materials: [material]
                )
            } else {
                let deskModel = ModelEntity(mesh: mesh, materials: [material])
                deskModel.name = "desk_model"

                deskModel.components.set(
                    GroundingShadowComponent(
                        castsShadow: false,
                        receivesShadow: false
                    )
                )

                anchor.addChild(deskModel)
            }
        }
    }

    private func generateGridTexture() -> TextureResource? {
        let tileSize: CGFloat = 100
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: tileSize, height: tileSize),
            format: format
        )

        let image = renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(
                UIColor.systemGreen.withAlphaComponent(0.15).cgColor
            )
            ctx.fill(CGRect(x: 0, y: 0, width: tileSize, height: tileSize))

            ctx.setStrokeColor(
                UIColor.systemGreen.withAlphaComponent(0.35).cgColor
            )
            ctx.setLineWidth(1.0)
            for x in stride(from: 20, to: Int(tileSize), by: 20) {
                ctx.move(to: CGPoint(x: CGFloat(x), y: 0))
                ctx.addLine(to: CGPoint(x: CGFloat(x), y: tileSize))
            }
            for y in stride(from: 20, to: Int(tileSize), by: 20) {
                ctx.move(to: CGPoint(x: 0, y: CGFloat(y)))
                ctx.addLine(to: CGPoint(x: tileSize, y: CGFloat(y)))
            }
            ctx.strokePath()

            ctx.setStrokeColor(
                UIColor.systemGreen.withAlphaComponent(0.85).cgColor
            )
            ctx.setLineWidth(3.0)
            ctx.stroke(CGRect(x: 0, y: 0, width: tileSize, height: tileSize))
        }
        guard let cgImage = image.cgImage else { return nil }
        return try? TextureResource.init(
            image: cgImage,
            options: .init(semantic: .color)
        )
    }
}
