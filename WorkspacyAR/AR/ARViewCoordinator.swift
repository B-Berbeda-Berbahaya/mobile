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
        trackErgonomics()
    }

    func notifyObjectUpdate(_ placedObj: PlacedObject) {
        onPlacedObjectUpdated?(placedObj)
    }
}

// MARK: - Real-Time Ergonomic Tracking Calculations
extension ARViewCoordinator {
    
    private func trackErgonomics() {
        guard let arView = arView, stateManager.isDeskLocked else {
            // Reset metrics when not locked
            DispatchQueue.main.async {
                self.stateManager.realTimeDistance = 0
                self.stateManager.realTimeEyeLevelDiff = 0
                self.stateManager.complianceScore = 100
                self.stateManager.distanceStatus = .optimal
                self.stateManager.eyeLevelStatus = .optimal
            }
            return
        }
        
        // 1. Get Camera translation and rotation matrix
        let cameraTransform = arView.cameraTransform
        let cameraPos = cameraTransform.translation
        let matrix = cameraTransform.matrix
        
        // Z-axis (columns.2) points backward towards the user's face in right-handed coordinates
        let zAxis = SIMD3<Float>(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z)
        let cameraBackward = normalize(zAxis)
        
        // Estimate actual eye position:
        // - Shift 30cm backward along camera Z-axis (holding distance)
        // - Shift 15cm upward vertically (chest-to-eye height offset)
        let estimatedEyePos = cameraPos + (cameraBackward * 0.30) + SIMD3<Float>(0, 0.15, 0)
        
        // 2. Find nearest monitor / laptop object
        let displays = anchorManager.placedObjects.filter {
            $0.type.category == .monitor || $0.type.category == .laptop
        }
        
        guard let nearestDisplay = findNearestDisplay(displays, to: cameraPos) else {
            // No display placed yet, reset metrics
            DispatchQueue.main.async {
                self.stateManager.realTimeDistance = 0
                self.stateManager.realTimeEyeLevelDiff = 0
                self.stateManager.complianceScore = 100
                self.stateManager.distanceStatus = .optimal
                self.stateManager.eyeLevelStatus = .optimal
            }
            return
        }
        
        // 3. Calculate distance and eye level diff
        let displayPos = nearestDisplay.entity.position(relativeTo: nil)
        
        let dx = estimatedEyePos.x - displayPos.x
        let dz = estimatedEyePos.z - displayPos.z
        let distance = sqrt(dx*dx + dz*dz)
        
        let displayHeight = getPhysicalHeight(for: nearestDisplay.type)
        let eyeLevelDiff = estimatedEyePos.y - (displayPos.y + displayHeight)
        
        // 4. Determine Ergonomic Statuses
        let distStatus = evaluateDistance(distance)
        let eyeStatus = evaluateEyeLevel(eyeLevelDiff)
        
        // 5. Calculate Compliance Score
        let score = calculateComplianceScore(distStatus: distStatus, eyeStatus: eyeStatus)
        
        // 6. Update StateManager on main queue
        DispatchQueue.main.async {
            self.stateManager.realTimeDistance = distance
            self.stateManager.realTimeEyeLevelDiff = eyeLevelDiff
            self.stateManager.distanceStatus = distStatus
            self.stateManager.eyeLevelStatus = eyeStatus
            self.stateManager.complianceScore = score
        }
    }
    
    private func findNearestDisplay(_ displays: [PlacedObject], to cameraPos: SIMD3<Float>) -> PlacedObject? {
        var nearest: PlacedObject? = nil
        var minDistance: Float = Float.infinity
        
        for display in displays {
            let displayPos = display.entity.position(relativeTo: nil)
            let dx = cameraPos.x - displayPos.x
            let dz = cameraPos.z - displayPos.z
            let dist = sqrt(dx*dx + dz*dz)
            
            if dist < minDistance {
                minDistance = dist
                nearest = display
            }
        }
        
        return nearest
    }
    
    private func getPhysicalHeight(for type: PlaceableObjectType) -> Float {
        switch type {
        case .macbookAir13:
            return 0.20 // 20 cm
        case .macbookPro14:
            return 0.22 // 22 cm
        case .macbookAir15:
            return 0.23 // 23 cm
//        case .macbook16, .macbook16CenterNew:
//            return 0.25 // 25 cm
        case .iMac24:
            return 0.46 // 46 cm
        case .studioDisplay27:
            return 0.48 // 48 cm
        case .monitor32:
            return 0.52 // 52 cm
        default:
            return 0.20
        }
    }
    
    private func evaluateDistance(_ distance: Float) -> ErgonomicStatus {
        if distance < 0.50 {
            return .danger // Too close!
        } else if distance <= 0.75 {
            return .optimal // Ideal range: 50-75cm
        } else if distance <= 1.00 {
            return .warning // A bit far: 75-100cm
        } else {
            return .danger // Too far!
        }
    }
    
    private func evaluateEyeLevel(_ diff: Float) -> ErgonomicStatus {
        // Ideal
        if diff < -0.05 {
            return .danger // Monitor is too high (eye is below top by > 5cm)
        } else if diff >= -0.05 && diff < 0.0 {
            return .warning // Slightly high
        } else if diff >= 0.0 && diff <= 0.15 {
            return .optimal // Perfect alignment
        } else if diff > 0.15 && diff <= 0.25 {
            return .warning // Slightly low (user looking down slightly)
        } else {
            return .danger // Monitor is too low (diff > 25cm, eye is far above top edge)
        }
    }
    
    private func calculateComplianceScore(distStatus: ErgonomicStatus, eyeStatus: ErgonomicStatus) -> Int {
        var score = 100
        
        switch distStatus {
        case .optimal: break
        case .warning: score -= 25
        case .danger: score -= 50
        }
        
        switch eyeStatus {
        case .optimal: break
        case .warning: score -= 25
        case .danger: score -= 50
        }
        
        return max(score, 0)
    }
}
