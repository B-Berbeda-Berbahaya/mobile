import SwiftUI
import RealityKit
import Combine

public enum ARInteractionMode {
    case none
    case move
    case rotate
}

public class StateManager: ObservableObject {
    @Published public var popoverPosition: CGPoint = .zero
    @Published public var selectedEntity: ModelEntity? = nil
    @Published public var interactionMode: ARInteractionMode = .none
    
    @Published public var isDeskDetected: Bool = false
    @Published public var isDeskLocked: Bool = false
    
    // Manual Calibration & Table Detection
    @Published public var calibrationPoints: [SIMD3<Float>] = []
    @Published public var focus3DPosition: SIMD3<Float>? = nil
    @Published public var isFocusOnTable: Bool = false
    @Published public var detectedPlaneType: String = "Mencari bidang..."
    
    // Triggers
    @Published public var shouldAddPointTrigger: Bool = false
    @Published public var shouldUndoPointTrigger: Bool = false
    @Published public var shouldResetTrigger: Bool = false
    
    public init() {}
}
