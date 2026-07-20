import ARKit
import RealityKit
import Combine
import SwiftUI

public enum ARInteractionMode {
    case none
    case move
    case rotate
}

public final class ARViewCoordinator: NSObject {
    public let raycastService = RaycastService()
    public let gridSystem: GridSystem
    public let anchorManager = AnchorManager()
    public let mapper: WorldToGridMapper
    
    public var onSelectedObjectChanged: ((PlacedObject?) -> Void)?
    public var onPlacedObjectUpdated: ((PlacedObject) -> Void)?
    public var onPopoverPositionChanged: ((CGPoint) -> Void)?
    public var activePlacingType: PlaceableObjectType = .ergonomicChair
    
    public var arView: ARView?
    public var selectedPlacedObject: PlacedObject?
    public var interactionMode: ARInteractionMode = .none {
        didSet {
            updateGesturesState()
        }
    }
    
    private var updateSubscription: Cancellable?
    private var initialY: Float = 0.0
    
    public init(gridSystem: GridSystem) {
        self.gridSystem = gridSystem
        self.mapper = WorldToGridMapper(gridSystem: gridSystem)
        super.init()
    }
    
    public func setupGesture(in arView: ARView) {
        self.arView = arView
        
        // Tap gesture to select or place
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        // Height gesture (Three-finger pan)
        let threeFingerPan = UIPanGestureRecognizer(target: self, action: #selector(handleThreeFingerPan(_:)))
        threeFingerPan.minimumNumberOfTouches = 3
        threeFingerPan.maximumNumberOfTouches = 3
        arView.addGestureRecognizer(threeFingerPan)
        
        // Scene update subscription (keep objects upright, etc.)
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self] _ in
            self?.onSceneUpdate()
        }
    }
    
    @objc public func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let location = recognizer.location(in: arView)
        
        // 1. Check if we tapped an existing entity (or its highlight overlay)
        if let entity = arView.entity(at: location) as? ModelEntity {
            let targetEntity = entity.name == "highlight_overlay" ? (entity.parent as? ModelEntity ?? entity) : entity
            if let placedObject = anchorManager.placedObjects.first(where: { $0.entity == targetEntity }) {
                selectObject(placedObject)
                return
            }
        }
        
        // 2. If not tapping an entity, try to place an object at the raycast hit position
        guard let worldPos = raycastService.raycastWorldPosition(from: location, in: arView) else {
            deselectCurrentObject()
            return
        }
        
        gridSystem.setOriginIfNeeded(worldPos)
        let coordinate = mapper.gridCoordinate(for: worldPos)
        
        if gridSystem.isAvailable(coordinate) {
            guard let type = activePlacingType else { return }
            Task {
                await placeObject(worldPosition: worldPos, type: type, coordinate: coordinate)
            }
        }
        
        else {
            if let entity = arView.entity(at: location) as? ModelEntity {
                if let placedObject = anchorManager.placedObjects.first(where: { $0.entity == entity }) {
                    onSelectedObjectChanged?(placedObject)
                }
            }
        }
    }
    public func placeObject(worldPosition: SIMD3<Float>, type: PlaceableObjectType, coordinate: GridCoordinate) async {
        guard let arView = arView else { return }
        
        let entity = await PlaceableEntityFactory.makeEntity(for: type)
        let snappedWorldPos = mapper.worldPosition(for: coordinate)
        
        var transform = simd_float4x4(1) // Identity matrix
        transform.columns.3 = SIMD4<Float>(snappedWorldPos.x, snappedWorldPos.y, snappedWorldPos.z, 1.0)
        
        let placedObj = anchorManager.placeEntity(entity, at: transform, in: arView, type: type, coordinate: coordinate)
        gridSystem.markOccupied(coordinate, objectID: placedObj.id)
        
        // Install RealityKit drag & rotate gestures
        let gestures = arView.installGestures([.translation, .rotation], for: entity)
        for gesture in gestures {
            gesture.addTarget(self, action: #selector(handleEntityGesture(_:)))
        }
        
        selectObject(placedObj)
    }
    
    public func removeObject(withID id: UUID) {
        guard let arView = arView else { return }
        if let object = anchorManager.placedObjects.first(where: { $0.id == id }) {
            if selectedPlacedObject?.id == id {
                deselectCurrentObject()
            }
            anchorManager.removeObject(object, in: arView)
            gridSystem.markAvailableAgain(object.gridCoordinate)
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
            let snappedWorldPos = mapper.worldPosition(for: object.gridCoordinate)
            let targetWorldPos = SIMD3<Float>(snappedWorldPos.x, snappedWorldPos.y + heightMeters, snappedWorldPos.z)
            object.entity.setPosition(targetWorldPos, relativeTo: nil)
        }
    }
    
    // MARK: - Gestures & Snapping
    
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
            if recognizer is EntityTranslationGestureRecognizer {
                snapToGrid(placedObj)
            } else {
                notifyObjectUpdate(placedObj)
            }
        default:
            break
        }
    }
    
    private func snapToGrid(_ placedObj: PlacedObject) {
        let entity = placedObj.entity
        let currentWorldPos = entity.position(relativeTo: nil)
        let newCoordinate = mapper.gridCoordinate(for: currentWorldPos)
        let oldCoordinate = placedObj.gridCoordinate
        
        let isCellAvailable = (newCoordinate == oldCoordinate || gridSystem.isAvailable(newCoordinate))
        
        if isCellAvailable {
            let snappedWorldPos = mapper.worldPosition(for: newCoordinate)
            let heightOffset = currentWorldPos.y - snappedWorldPos.y
            let targetWorldPos = SIMD3<Float>(snappedWorldPos.x, snappedWorldPos.y + heightOffset, snappedWorldPos.z)
            
            // Simpan posisi lama sebelum tes tabrakan
            let originalWorldPos = entity.position(relativeTo: nil)
            entity.setPosition(targetWorldPos, relativeTo: nil)
            
            if !checkOverlaps() {
                // Konfirmasi pemindahan jika tidak tabrakan
                gridSystem.markAvailableAgain(oldCoordinate)
                gridSystem.markOccupied(newCoordinate, objectID: placedObj.id)
                placedObj.gridCoordinate = newCoordinate
            } else {
                // Jika tabrakan fisik dengan objek lain, batalkan & snap ke koordinat lama
                entity.setPosition(originalWorldPos, relativeTo: nil)
                
                let oldSnappedWorldPos = mapper.worldPosition(for: oldCoordinate)
                let oldHeightOffset = originalWorldPos.y - oldSnappedWorldPos.y
                let oldTargetPos = SIMD3<Float>(oldSnappedWorldPos.x, oldSnappedWorldPos.y + oldHeightOffset, oldSnappedWorldPos.z)
                entity.setPosition(oldTargetPos, relativeTo: nil)
            }
        } else {
            // Revert back ke koordinat lama jika sel grid tujuan penuh
            let snappedWorldPos = mapper.worldPosition(for: oldCoordinate)
            let heightOffset = currentWorldPos.y - snappedWorldPos.y
            
            let targetWorldPos = SIMD3<Float>(snappedWorldPos.x, snappedWorldPos.y + heightOffset, snappedWorldPos.z)
            entity.setPosition(targetWorldPos, relativeTo: nil)
        }
        
        notifyObjectUpdate(placedObj)
    }
    
    @objc public func handleThreeFingerPan(_ sender: UIPanGestureRecognizer) {
        guard let arView = arView,
              let placedObj = selectedPlacedObject else { return }
        
        let entity = placedObj.entity
        let translation = sender.translation(in: arView)
        
        switch sender.state {
        case .began:
            initialY = entity.transform.translation.y
        case .changed:
            let deltaY = -Float(translation.y) * 0.0015
            entity.transform.translation.y = initialY + deltaY
            notifyObjectUpdate(placedObj)
        case .ended, .cancelled:
            notifyObjectUpdate(placedObj)
        default:
            break
        }
    }
    
    private func notifyObjectUpdate(_ placedObj: PlacedObject) {
        onPlacedObjectUpdated?(placedObj)
    }
    
    // MARK: - Scene Update & Stabilization
    
    private func onSceneUpdate() {
        keepObjectsUpright()
        updatePopoverPosition()
        
        let isOverlapping = checkOverlaps()
        updateHighlightColor(isOverlapping: isOverlapping)
    }
    
    private func keepObjectsUpright() {
        guard let arView = arView else { return }
        for anchor in arView.scene.anchors {
            for child in anchor.children {
                if let modelEntity = child as? ModelEntity, modelEntity.name != "highlight_overlay" {
                    var currentTransform = modelEntity.transform
                    let forward = currentTransform.rotation.act(SIMD3<Float>(0, 0, 1))
                    let yawAngle = atan2(forward.x, forward.z)
                    currentTransform.rotation = simd_quatf(angle: yawAngle, axis: SIMD3<Float>(0, 1, 0))
                    modelEntity.transform = currentTransform
                }
            }
        }
    }
    
    // MARK: - Selection & Highlight
    
    public func selectObject(_ object: PlacedObject) {
        deselectCurrentObject()
        selectedPlacedObject = object
        interactionMode = .move
        onSelectedObjectChanged?(object)
        
        let entity = object.entity
        if entity.findEntity(named: "highlight_overlay") == nil {
            if let mesh = entity.model?.mesh {
                let glowMaterial = UnlitMaterial(color: UIColor.white.withAlphaComponent(0.12))
                let highlightEntity = ModelEntity(mesh: mesh, materials: [glowMaterial])
                highlightEntity.name = "highlight_overlay"
                highlightEntity.scale = [1.03, 1.03, 1.03]
                entity.addChild(highlightEntity)
            }
        }
        updatePopoverPosition()
    }
    
    public func deselectCurrentObject() {
        if let object = selectedPlacedObject {
            if let highlight = object.entity.findEntity(named: "highlight_overlay") {
                highlight.removeFromParent()
            }
        }
        selectedPlacedObject = nil
        interactionMode = .none
        onSelectedObjectChanged?(nil)
        onPopoverPositionChanged?(.zero)
    }
    
    public func updateGesturesState() {
        guard let arView = arView, let gestureRecognizers = arView.gestureRecognizers else { return }
        
        for gesture in gestureRecognizers {
            if let translationGesture = gesture as? EntityTranslationGestureRecognizer {
                translationGesture.isEnabled = (interactionMode == .move)
            } else if let rotationGesture = gesture as? EntityRotationGestureRecognizer {
                rotationGesture.isEnabled = (interactionMode == .rotate)
            } else if let panGesture = gesture as? UIPanGestureRecognizer, panGesture.minimumNumberOfTouches == 3 {
                panGesture.isEnabled = (interactionMode == .move)
            }
        }
    }
    
    private func updatePopoverPosition() {
        guard let arView = arView, let object = selectedPlacedObject else {
            onPopoverPositionChanged?(.zero)
            return
        }
        
        let bounds = object.entity.visualBounds(relativeTo: nil)
        // Posisikan tepat di tengah-tengah X-Z objek, dan 5cm di atas bagian teratas objek (bounds.max.y)
        let topPosition = SIMD3<Float>(bounds.center.x, bounds.max.y + 0.05, bounds.center.z)
        
        if let screenPoint = arView.project(topPosition) {
            DispatchQueue.main.async {
                self.onPopoverPositionChanged?(screenPoint)
            }
        } else {
            DispatchQueue.main.async {
                self.onPopoverPositionChanged?(.zero)
            }
        }
    }
    
    // MARK: - Overlap & Bounding Box Helpers
    
    private func checkOverlaps() -> Bool {
        guard let selected = selectedPlacedObject else { return false }
        let selectedEntity = selected.entity
        let selectedBounds = selectedEntity.visualBounds(relativeTo: nil)
        
        for object in anchorManager.placedObjects {
            if object.id == selected.id { continue } // Lewati diri sendiri
            
            let otherEntity = object.entity
            let otherBounds = otherEntity.visualBounds(relativeTo: nil)
            
            if selectedBounds.intersects(otherBounds) {
                return true
            }
        }
        return false
    }
    
    private func updateHighlightColor(isOverlapping: Bool) {
        guard let selected = selectedPlacedObject,
              let highlight = selected.entity.findEntity(named: "highlight_overlay") as? ModelEntity else {
            return
        }
        
        let color = isOverlapping ? UIColor.red.withAlphaComponent(0.25) : UIColor.white.withAlphaComponent(0.12)
        let glowMaterial = UnlitMaterial(color: color)
        highlight.model?.materials = [glowMaterial]
    }
}
