import ARKit
import Combine
import RealityKit
import SwiftUI

public final class ARViewCoordinator: NSObject, ARSessionDelegate {
    public let anchorManager = AnchorManager()
    public var stateManager: StateManager

    public var onSelectedObjectChanged: ((PlacedObject?) -> Void)?
    public var onPlacedObjectUpdated: ((PlacedObject) -> Void)?
    public var onPopoverPositionChanged: ((CGPoint) -> Void)?

    public var activePlacingType: PlaceableObjectType?

    /// Shared ARView class  instance
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

        stateManager.onResetTrigger = { [weak self] in
            self?.resetCalibration()
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
