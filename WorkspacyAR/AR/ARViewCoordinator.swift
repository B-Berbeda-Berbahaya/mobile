import ARKit
import Combine
import RealityKit
import SwiftUI

public final class ARViewCoordinator: NSObject, ARSessionDelegate {
    public let anchorManager = AnchorManager()
    public var stateManager: StateManager

    public var onSelectedObjectChanged: ((PlacedObject?) -> Void)?

    public var activePlacingType: PlaceableObjectType?

    public var onPlacedObjectUpdated: ((PlacedObject) -> Void)?
    public var onPopoverPositionChanged: ((CGPoint) -> Void)?
<<<<<<< HEAD
    
=======

    public var activePlacingType: PlaceableObjectType = .macbook16

    /// Shared ARView class  instance
>>>>>>> d01692b (F/30 object anchor handling (#31))
    public weak var arView: ARView?

    public var selectedPlacedObject: PlacedObject?

    private var updateSubscription: Cancellable?
    private var cancellables = Set<AnyCancellable>()
    private var initialY: Float = 0.0

    // Desk Customization
    /// Desk anchor
    private(set) var deskAnchor: AnchorEntity? = nil
    func setDeskAnchor(_ anchor: AnchorEntity?) {
        self.deskAnchor = anchor
    }
    
    var lastValidPosition: SIMD3<Float>? = nil
    var wasDragging = false

    // Reticle
    private(set) var reticleAnchor: AnchorEntity? = nil
    func setReticleAnchor(_ anchor: AnchorEntity?) {
        self.reticleAnchor = anchor
    }
    private(set) var reticleEntity: ModelEntity? = nil
    func setReticleEntity(_ entity: ModelEntity?) {
        self.reticleEntity = entity
    }

    public init(stateManager: StateManager) {
        self.stateManager = stateManager
        super.init()

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        stateManager.onAddPointRequested = { [weak self] in
            self?.addPointAtFocus()

        }

        stateManager.onUndoPointTrigger = { [weak self] in
            self?.removeLastPoint()
        }
<<<<<<< HEAD
        
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
=======

        stateManager.onResetTrigger = { [weak self] in
            self?.resetCalibration()
>>>>>>> d01692b (F/30 object anchor handling (#31))
        }

        stateManager.onDescLocked = { [weak self] isLocked in
            self?.updateHandlesVisibility(isLocked: isLocked)
        }

        stateManager.interactionModeRequest = { [weak self] newMode in
            self?.updateGesturesState(newMode)
        }
    }

    public func setupGesture(in arView: ARView) {
        // Set AR View di class instance
        // Delegate arView ke coordinator ini
        self.arView = arView
        arView.session.delegate = self

        // Setup tap gestture ke arview
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)

        // Setup two finger motions
        // Use two fingers for height adjustment like cobaAR
        let twoFingerPan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleTwoFingerPan(_:))
        )
        twoFingerPan.minimumNumberOfTouches = 2
        twoFingerPan.maximumNumberOfTouches = 2
        arView.addGestureRecognizer(twoFingerPan)

        // Subscribe to SceneEvent update for perframe
        updateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self)
        { [weak self] _ in
            self?.onSceneUpdate()
        }
    }


    @objc public func handleTwoFingerPan(_ sender: UIPanGestureRecognizer) {
        guard let arView = arView,
            let placedObj = selectedPlacedObject,
            stateManager.interactionMode == .move
        else { return }

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

    func notifyObjectUpdate(_ placedObj: PlacedObject) {
        onPlacedObjectUpdated?(placedObj)
    }
}
