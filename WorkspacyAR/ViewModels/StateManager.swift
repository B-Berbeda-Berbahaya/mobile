import Combine
import RealityKit
import SwiftUI

@Observable
public final class StateManager {
    public var popoverPosition: CGPoint = .zero
    public var selectedEntity: ModelEntity? = nil

    // Interaction Mode
    public var interactionModeRequest: ((ARInteractionMode) -> Void)?
    private(set) var interactionMode: ARInteractionMode = .none
    func setInteractionMode(_ mode: ARInteractionMode) {
        self.interactionMode = mode

        interactionModeRequest?(mode)
    }

    // MARK: Desk detector and locker
    public var isDeskDetected: Bool = false
    public var onDescLocked: ((Bool) -> Void)?
    private(set) var isDeskLocked: Bool = false
    func setDeskLock(_ value: Bool) {
        isDeskLocked = value
    }

    // Manual Calibration & Table Detection
    public var calibrationPoints: [SIMD3<Float>] = []
    public var focus3DPosition: SIMD3<Float>? = nil
    public var isFocusOnTable: Bool = false
    public var detectedPlaneType: String = "Mencari bidang..."

    // Triggers
    // Add point
    public var onAddPointRequested: (() -> Void)?
    private(set) var isAddingPoint: Bool = false
    func setIsAddingPoint(_ value: Bool) {
        isAddingPoint = value
    }

    // Undo point addition
    public var onUndoPointTrigger: (() -> Void)?
    private(set) var canUndo: Bool = false {
        didSet {
            onUndoPointTrigger?()
        }
    }
    func setCanUndo(_ value: Bool) {
        canUndo = value
    }

    // Rest point addition
    public var onResetTrigger: (() -> Void)?
    private(set) var canReset: Bool = false {
        didSet {
            onResetTrigger?()
        }
    }
    func setCanReset(_ value: Bool) {
        canReset = value
    }

    // MARK: - Saved Layout Triggers & State
    public var shouldSaveLayoutTrigger: Bool = false
    public var layoutToRestore: SavedDeskLayout? = nil
    public var pendingRestoringLayout: SavedDeskLayout? = nil
    public var pendingBundleRotation: Float = 0.0
    public var shouldConfirmBundlePlacementTrigger: Bool = false
    public var shouldCancelBundlePlacementTrigger: Bool = false
    public var showSavedLayoutsSheet: Bool = false
    public var saveStatusMessage: String? = nil

    // Ergonomics Metrics
    public var realTimeDistance: Float = 0.0
    public var realTimeEyeLevelDiff: Float = 0.0
    public var distanceStatus: ErgonomicStatus = .optimal
    public var eyeLevelStatus: ErgonomicStatus = .optimal
    public var complianceScore: Int = 100

    public init() {}

}

public enum ErgonomicStatus: String, Codable {
    case optimal
    case warning
    case danger
    
    public var color: Color {
        switch self {
        case .optimal: return .green
        case .warning: return .orange
        case .danger: return .red
        }
    }
}
