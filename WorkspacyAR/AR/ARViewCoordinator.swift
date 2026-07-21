import ARKit
import RealityKit
import Combine
import SwiftUI

public final class ARViewCoordinator: NSObject, ARSessionDelegate {
    public let anchorManager = AnchorManager()
    public var stateManager: StateManager
    
    public var onSelectedObjectChanged: ((PlacedObject?) -> Void)?

    public var activePlacingType: PlaceableObjectType?

    public var onPlacedObjectUpdated: ((PlacedObject) -> Void)?
    public var onPopoverPositionChanged: ((CGPoint) -> Void)?
    
    public weak var arView: ARView?
    public var selectedPlacedObject: PlacedObject?
    
    private var updateSubscription: Cancellable?
    private var cancellables = Set<AnyCancellable>()
    private var initialY: Float = 0.0
    
    // Desk Customization
    private var deskAnchor: AnchorEntity? = nil
    private var lastValidPosition: SIMD3<Float>? = nil
    private var wasDragging = false
    
    // Reticle
    private var reticleAnchor: AnchorEntity? = nil
    private var reticleEntity: ModelEntity? = nil
    
    public init(stateManager: StateManager) {
        self.stateManager = stateManager
        super.init()
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        stateManager.$shouldAddPointTrigger
            .dropFirst()
            .sink { [weak self] trigger in
                if trigger {
                    self?.addPointAtFocus()
                    DispatchQueue.main.async {
                        self?.stateManager.shouldAddPointTrigger = false
                    }
                }
            }
            .store(in: &cancellables)
            
        stateManager.$shouldUndoPointTrigger
            .dropFirst()
            .sink { [weak self] trigger in
                if trigger {
                    self?.removeLastPoint()
                    DispatchQueue.main.async {
                        self?.stateManager.shouldUndoPointTrigger = false
                    }
                }
            }
            .store(in: &cancellables)
            
        stateManager.$shouldResetTrigger
            .dropFirst()
            .sink { [weak self] trigger in
                if trigger {
                    self?.resetCalibration()
                    DispatchQueue.main.async {
                        self?.stateManager.shouldResetTrigger = false
                    }
                }
            }
            .store(in: &cancellables)
            
        stateManager.$isDeskLocked
            .dropFirst()
            .sink { [weak self] isLocked in
                self?.updateHandlesVisibility(isLocked: isLocked)
            }
            .store(in: &cancellables)
            
        stateManager.$interactionMode
            .dropFirst()
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateGesturesState()
                }
            }
            .store(in: &cancellables)
    }
    
    public func setupGesture(in arView: ARView) {
        self.arView = arView
        arView.session.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Use two fingers for height adjustment like cobaAR
        let twoFingerPan = UIPanGestureRecognizer(target: self, action: #selector(handleTwoFingerPan(_:)))
        twoFingerPan.minimumNumberOfTouches = 2
        twoFingerPan.maximumNumberOfTouches = 2
        arView.addGestureRecognizer(twoFingerPan)
        
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            self?.onSceneUpdate()
        }
    }
    
    @objc public func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let location = recognizer.location(in: arView)
        
        // Check if tapping existing placed object
        if let entity = arView.entity(at: location) as? ModelEntity {
            if entity.name == "desk_model" || 
               entity.name.hasPrefix("handle_") || 
               entity.name.hasPrefix("line_") || 
               entity.name == "rubber_band" ||
               entity.name == "invalid_ghost" {
                // Do not select these
            } else {
                let targetEntity = entity.name == "highlight_overlay" ? (entity.parent as? ModelEntity ?? entity) : entity
                if let placedObject = anchorManager.placedObjects.first(where: { $0.entity == targetEntity }) {
                    selectObject(placedObject)
                    return
                }
            }
        }
        
        // If we reach here, we are trying to place something
        guard stateManager.isDeskLocked else { return } // Can only place if desk is locked
        guard let type = activePlacingType else { return } // Tidak ada tipe aktif, tidak bisa place

        let hitResults = arView.hitTest(location)
        if let deskHit = hitResults.first(where: { $0.entity.name == "desk_model" }) {
            Task { @MainActor in
                await placeObject(worldPosition: deskHit.position, type: type)
            }
        } else {
            // Failed to drop: Spawn invalid ghost
            let raycastResults = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
            let position: SIMD3<Float>
            if let firstResult = raycastResults.first {
                position = SIMD3<Float>(
                    firstResult.worldTransform.columns.3.x,
                    firstResult.worldTransform.columns.3.y,
                    firstResult.worldTransform.columns.3.z
                )
            } else {
                position = SIMD3<Float>(0, 0, -0.5) // Fallback
            }
            
            Task { @MainActor in
                await spawnInvalidGhost(type: type, at: position, in: arView)
            }
        }
    }
    
    private func placeObject(worldPosition: SIMD3<Float>, type: PlaceableObjectType) async {
        guard let arView = arView else { return }
        
        let entity = await PlaceableEntityFactory.makeEntity(for: type)
        let physics = PhysicsBodyComponent(massProperties: .init(mass: 1.0), material: .default, mode: .dynamic)
        entity.components.set(physics)
        
        let placedObj = anchorManager.placeEntity(entity, at: worldPosition, in: arView, type: type)
        
        let gestures = arView.installGestures([.translation, .rotation], for: entity)
        for gesture in gestures {
            gesture.addTarget(self, action: #selector(handleEntityGesture(_:)))
        }
        
        selectObject(placedObj)
    }
    
    private func spawnInvalidGhost(type: PlaceableObjectType, at position: SIMD3<Float>, in arView: ARView) async {
        let modelEntity = await PlaceableEntityFactory.makeEntity(for: type)
        modelEntity.name = "invalid_ghost"
        
        let redMaterial = UnlitMaterial(color: UIColor.red.withAlphaComponent(0.60))
        applyMaterialRecursively(modelEntity, material: redMaterial)
        
        let anchorEntity = AnchorEntity(world: position)
        anchorEntity.addChild(modelEntity)
        arView.scene.addAnchor(anchorEntity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak anchorEntity] in
            anchorEntity?.removeFromParent()
        }
    }

    
    private func applyMaterialRecursively(_ entity: Entity, material: RealityKit.Material) {
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
        if let translationGesture = recognizer as? EntityTranslationGestureRecognizer {
            entity = translationGesture.entity as? ModelEntity
        } else if let rotationGesture = recognizer as? EntityRotationGestureRecognizer {
            entity = rotationGesture.entity as? ModelEntity
        } else {
            return
        }
        
        guard let targetEntity = entity,
              let placedObj = anchorManager.placedObjects.first(where: { $0.entity == targetEntity }) else {
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
    
    private func trackDraggedObjectAndBounce() {
        guard let arView = arView,
              let selected = selectedPlacedObject,
              stateManager.interactionMode == .move else { return }
        
        let entity = selected.entity
        
        var isDragging = false
        if let gestureRecognizers = arView.gestureRecognizers {
            for gesture in gestureRecognizers {
                if let translationGesture = gesture as? EntityTranslationGestureRecognizer {
                    if translationGesture.state == .began || translationGesture.state == .changed {
                        isDragging = true
                    }
                }
            }
        }
        
        let origin = SIMD3<Float>(entity.position(relativeTo: nil).x, entity.position(relativeTo: nil).y + 0.05, entity.position(relativeTo: nil).z)
        let destination = SIMD3<Float>(entity.position(relativeTo: nil).x, entity.position(relativeTo: nil).y - 0.05, entity.position(relativeTo: nil).z)
        let hits = arView.scene.raycast(from: origin, to: destination)
        let isOnDesk = hits.contains { $0.entity.name == "desk_model" }
        
        if isOnDesk {
            self.lastValidPosition = entity.position(relativeTo: entity.parent)
        }
        
        let whiteMaterial = UnlitMaterial(color: UIColor.white.withAlphaComponent(0.35))
        updateHighlightMaterial(on: entity, to: whiteMaterial)
        
        if isDragging {
            self.wasDragging = true
        } else if self.wasDragging {
            self.wasDragging = false
            
            if !isOnDesk {
                if let lastValid = self.lastValidPosition {
                    var targetTransform = entity.transform
                    targetTransform.translation = lastValid
                    
                    entity.move(to: targetTransform, relativeTo: entity.parent, duration: 0.35, timingFunction: .easeOut)
                    notifyObjectUpdate(selected)
                }
            }
        }
    }
    
    @objc public func handleTwoFingerPan(_ sender: UIPanGestureRecognizer) {
        guard let arView = arView,
              let placedObj = selectedPlacedObject,
              stateManager.interactionMode == .move else { return }
        
        let entity = placedObj.entity
        let translation = sender.translation(in: arView)
        
        switch sender.state {
        case .began:
            initialY = entity.transform.translation.y
            if var physicsBody = entity.components[PhysicsBodyComponent.self] {
                physicsBody.mode = .kinematic
                entity.components.set(physicsBody)
            }
        case .changed:
            let deltaY = -Float(translation.y) * 0.0015
            entity.transform.translation.y = initialY + deltaY
            notifyObjectUpdate(placedObj)
        case .ended, .cancelled:
            if var physicsBody = entity.components[PhysicsBodyComponent.self] {
                physicsBody.mode = .dynamic
                entity.components.set(physicsBody)
            }
            notifyObjectUpdate(placedObj)
        default:
            break
        }
    }
    
    private func updateHighlightMaterial(on entity: Entity, to material: RealityKit.Material) {
        if entity.name == "highlight_overlay", let modelEntity = entity as? ModelEntity {
            modelEntity.model?.materials = [material]
        }
        for child in entity.children {
            updateHighlightMaterial(on: child, to: material)
        }
    }
    
    // MARK: - Scene Updates & Helpers
    
    private func onSceneUpdate() {
        keepObjectsUpright()
        updatePopoverPosition()
        updateFocusPosition()
        syncDraggedHandles()
        rebuildDeskElements()
        trackDraggedObjectAndBounce()
        updateReticle()
    }
    
    private func updateReticle() {
        guard let arView = arView else { return }
        if stateManager.isDeskLocked {
            reticleAnchor?.isEnabled = false
            return
        }
        
        let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        let results = arView.raycast(from: centerPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
        let hitResult: ARRaycastResult?
        if let first = results.first {
            hitResult = first
        } else {
            let estimated = arView.raycast(from: centerPoint, allowing: .estimatedPlane, alignment: .horizontal)
            hitResult = estimated.first
        }
        
        if let result = hitResult {
            let anchor: AnchorEntity
            if let existing = self.reticleAnchor {
                anchor = existing
            } else {
                anchor = AnchorEntity()
                self.reticleAnchor = anchor
                arView.scene.addAnchor(anchor)
            }
            
            let entity: ModelEntity
            if let existingEntity = self.reticleEntity {
                entity = existingEntity
            } else {
                let planeMesh = MeshResource.generatePlane(width: 0.05, depth: 0.05)
                let material = UnlitMaterial(color: UIColor.white.withAlphaComponent(0.8))
                entity = ModelEntity(mesh: planeMesh, materials: [material])
                entity.name = "reticle_model"
                self.reticleEntity = entity
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
                material.color = .init(tint: UIColor.white, texture: materialTexture)
            } else {
                material.color = .init(tint: reticleColor.withAlphaComponent(0.8))
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
        return try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
    }
    
    private func updateFocusPosition() {
        guard let arView = arView, !stateManager.isDeskLocked else {
            DispatchQueue.main.async { self.stateManager.focus3DPosition = nil }
            return
        }
        
        let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        let results = arView.raycast(from: centerPoint, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
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
            let estimatedResults = arView.raycast(from: centerPoint, allowing: .estimatedPlane, alignment: .horizontal)
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
    
    private func syncDraggedHandles() {
        guard let anchor = deskAnchor, !stateManager.isDeskLocked else { return }
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
            DispatchQueue.main.async { self.stateManager.calibrationPoints = points }
        }
    }
    
    private func rebuildDeskElements() {
        guard let arView = arView else { return }
        
        let anchor: AnchorEntity
        if let existing = self.deskAnchor {
            anchor = existing
        } else {
            anchor = AnchorEntity()
            self.deskAnchor = anchor
            arView.scene.addAnchor(anchor)
        }
        
        let points = stateManager.calibrationPoints
        anchor.children.filter { $0.name.hasPrefix("line_") || $0.name == "rubber_band" }.forEach { $0.removeFromParent() }
        
        if points.count >= 2 {
            let lineColor = UIColor.green
            for i in 0..<points.count - 1 {
                let line = createLineEntity(from: points[i], to: points[i+1], color: lineColor, radius: 0.003)
                line.name = "line_\(i)"
                anchor.addChild(line)
            }
            if stateManager.isDeskLocked {
                let closeLine = createLineEntity(from: points.last!, to: points.first!, color: .green, radius: 0.003)
                closeLine.name = "line_close"
                anchor.addChild(closeLine)
            }
        }
        
        if !stateManager.isDeskLocked, let lastPoint = points.last, let focusPos = stateManager.focus3DPosition {
            let rubberBand = createLineEntity(from: lastPoint, to: focusPos, color: UIColor.green.withAlphaComponent(0.6), radius: 0.002)
            rubberBand.name = "rubber_band"
            anchor.addChild(rubberBand)
        }
        
        rebuildDeskMesh(in: anchor)
    }
    
    private func createLineEntity(from start: SIMD3<Float>, to end: SIMD3<Float>, color: UIColor, radius: Float) -> ModelEntity {
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
            entity.orientation = simd_quatf(angle: angle, axis: simd_normalize(axis))
        } else if direction.y < 0 {
            entity.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(1, 0, 0))
        }
        
        return entity
    }
    
    private func generateGridTexture() -> TextureResource? {
        let tileSize: CGFloat = 100
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: tileSize, height: tileSize), format: format)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            ctx.setFillColor(UIColor.systemGreen.withAlphaComponent(0.15).cgColor)
            ctx.fill(CGRect(x: 0, y: 0, width: tileSize, height: tileSize))
            
            ctx.setStrokeColor(UIColor.systemGreen.withAlphaComponent(0.35).cgColor)
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
            
            ctx.setStrokeColor(UIColor.systemGreen.withAlphaComponent(0.85).cgColor)
            ctx.setLineWidth(3.0)
            ctx.stroke(CGRect(x: 0, y: 0, width: tileSize, height: tileSize))
        }
        guard let cgImage = image.cgImage else { return nil }
        return try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
    }
    
    private func rebuildDeskMesh(in anchor: AnchorEntity) {
        let points = stateManager.calibrationPoints
        guard points.count >= 3 else {
            if let oldDesk = anchor.findEntity(named: "desk_model") {
                oldDesk.removeFromParent()
            }
            return
        }
        
        let indices = Triangulator.triangulate(points: points)
        guard !indices.isEmpty else { return }
        
        var descriptor = MeshDescriptor(name: "desk_mesh")
        let alignedY = points.first?.y ?? 0.0
        let vertices = points.map { SIMD3<Float>($0.x, alignedY + 0.001, $0.z) }
        descriptor.positions = MeshBuffers.Positions(vertices)
        descriptor.primitives = .triangles(indices)
        descriptor.normals = MeshBuffers.Normals(Array(repeating: SIMD3<Float>(0, 1, 0), count: vertices.count))
        
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
        
        if let mesh = try? MeshResource.generate(from: [descriptor]) {
            var material = UnlitMaterial()
            material.blending = .transparent(opacity: 1.0)
            if let texture = generateGridTexture() {
                let materialTexture = MaterialParameters.Texture(texture)
                material.color = .init(tint: UIColor.white, texture: materialTexture)
            } else {
                material.color = .init(tint: UIColor.green.withAlphaComponent(0.30))
            }
            
            if let deskModel = anchor.findEntity(named: "desk_model") as? ModelEntity {
                deskModel.model = ModelComponent(mesh: mesh, materials: [material])
            } else {
                let deskModel = ModelEntity(mesh: mesh, materials: [material])
                deskModel.name = "desk_model"
                anchor.addChild(deskModel)
            }
        }
    }
    
    private func keepObjectsUpright() {
        guard let arView = arView else { return }
        for anchor in arView.scene.anchors {
            for child in anchor.children {
                if let modelEntity = child as? ModelEntity,
                   modelEntity.name != "highlight_overlay",
                   modelEntity.name != "desk_model",
                   !modelEntity.name.hasPrefix("handle_"),
                   !modelEntity.name.hasPrefix("line_"),
                   modelEntity.name != "rubber_band",
                   modelEntity.name != "invalid_ghost" {
                    
                    var currentTransform = modelEntity.transform
                    let forward = currentTransform.rotation.act(SIMD3<Float>(0, 0, 1))
                    let yawAngle = atan2(forward.x, forward.z)
                    currentTransform.rotation = simd_quatf(angle: yawAngle, axis: SIMD3<Float>(0, 1, 0))
                    modelEntity.transform = currentTransform
                }
            }
        }
    }
    
    private func updatePopoverPosition() {
        guard let arView = arView, let object = selectedPlacedObject else {
            DispatchQueue.main.async { self.stateManager.popoverPosition = .zero }
            return
        }
        
        let bounds = object.entity.visualBounds(relativeTo: nil)
        let topPosition = SIMD3<Float>(bounds.center.x, bounds.max.y + 0.05, bounds.center.z)
        
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
    
    // MARK: - Actions From UI
    
    public func selectObject(_ object: PlacedObject) {
        deselectCurrentObject()
        selectedPlacedObject = object
        stateManager.interactionMode = .move
        onSelectedObjectChanged?(object)
        
        self.lastValidPosition = object.entity.position(relativeTo: object.entity.parent)
        self.wasDragging = false
        
        let entity = object.entity
        if entity.findEntity(named: "highlight_overlay") == nil {
            if let mesh = entity.model?.mesh {
                let glowMaterial = UnlitMaterial(color: UIColor.white.withAlphaComponent(0.35))
                let highlightEntity = ModelEntity(mesh: mesh, materials: [glowMaterial])
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
            if let highlight = object.entity.findEntity(named: "highlight_overlay") {
                highlight.removeFromParent()
            }
        }
        selectedPlacedObject = nil
        stateManager.interactionMode = .none
        self.lastValidPosition = nil
        self.wasDragging = false
        onSelectedObjectChanged?(nil)
        stateManager.popoverPosition = .zero
        updateGesturesState()
    }
    
    public func removeObject(withID id: UUID) {
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }) {
            if selectedPlacedObject?.id == id {
                deselectCurrentObject()
            }
            if let arView = arView {
                anchorManager.removeObject(object, in: arView)
            }
        }
    }
    
    public func updateRotation(forID id: UUID, angleDegrees: Float) {
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }) {
            let radians = angleDegrees * .pi / 180.0
            object.entity.transform.rotation = simd_quatf(angle: radians, axis: SIMD3<Float>(0, 1, 0))
        }
    }
    
    public func updateHeight(forID id: UUID, heightCm: Float) {
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }) {
            let heightMeters = heightCm / 100.0
            let targetWorldPos = SIMD3<Float>(object.entity.position.x, object.entity.position.y + heightMeters, object.entity.position.z)
            object.entity.setPosition(targetWorldPos, relativeTo: nil)
        }
    }
    
    public func updateGesturesState() {
        guard let arView = arView, let gestureRecognizers = arView.gestureRecognizers else { return }
        
        for gesture in gestureRecognizers {
            if let translationGesture = gesture as? EntityTranslationGestureRecognizer {
                translationGesture.isEnabled = (stateManager.interactionMode == .move)
            } else if let rotationGesture = gesture as? EntityRotationGestureRecognizer {
                rotationGesture.isEnabled = (stateManager.interactionMode == .rotate)
            } else if let panGesture = gesture as? UIPanGestureRecognizer, panGesture.minimumNumberOfTouches == 2 {
                panGesture.isEnabled = (stateManager.interactionMode == .move)
            }
        }
    }
    
    public func addPointAtFocus() {
        guard let arView = arView, let focusPos = stateManager.focus3DPosition else { return }
        
        let anchor: AnchorEntity
        if let existing = self.deskAnchor {
            anchor = existing
        } else {
            anchor = AnchorEntity()
            self.deskAnchor = anchor
            arView.scene.addAnchor(anchor)
        }
        
        let index = stateManager.calibrationPoints.count
        let targetY = stateManager.calibrationPoints.first?.y ?? focusPos.y
        let flatPos = SIMD3<Float>(focusPos.x, targetY, focusPos.z)
        
        let handleMesh = MeshResource.generateSphere(radius: 0.015)
        let handleMaterial = SimpleMaterial(color: .green, isMetallic: false)
        let handleEntity = ModelEntity(mesh: handleMesh, materials: [handleMaterial])
        
        handleEntity.name = "handle_\(index)"
        handleEntity.position = flatPos
        
        handleEntity.generateCollisionShapes(recursive: true)
        arView.installGestures(.translation, for: handleEntity)
        
        anchor.addChild(handleEntity)
        
        DispatchQueue.main.async {
            self.stateManager.calibrationPoints.append(flatPos)
            self.stateManager.isDeskDetected = true
        }
    }
    
    public func removeLastPoint() {
        guard let anchor = deskAnchor, !stateManager.calibrationPoints.isEmpty else { return }
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
            self.deskAnchor = nil
        }
        if let rAnchor = reticleAnchor {
            rAnchor.removeFromParent()
            self.reticleAnchor = nil
            self.reticleEntity = nil
        }
        
        DispatchQueue.main.async {
            self.stateManager.calibrationPoints.removeAll()
            self.stateManager.isDeskDetected = false
            self.stateManager.isDeskLocked = false
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
        
        if let deskModel = anchor.findEntity(named: "desk_model") as? ModelEntity {
            if isLocked {
                deskModel.generateCollisionShapes(recursive: true)
                deskModel.components.set(PhysicsBodyComponent(massProperties: .init(mass: 0.0), material: .default, mode: .static))
            } else {
                deskModel.components.remove(PhysicsBodyComponent.self)
                deskModel.components.remove(CollisionComponent.self)
            }
        }
    }
    
    private func notifyObjectUpdate(_ placedObj: PlacedObject) {
        onPlacedObjectUpdated?(placedObj)
    }
}
