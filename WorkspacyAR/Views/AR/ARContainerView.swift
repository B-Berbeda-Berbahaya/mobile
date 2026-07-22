import ARKit
import RealityKit
import SwiftUI

public struct ARViewRepresentable: UIViewRepresentable {
    @ObservedObject var sessionManager: ARSessionManager
    public let coordinator: ARViewCoordinator

    public init(
        sessionManager: ARSessionManager,
        coordinator: ARViewCoordinator
    ) {
        self.sessionManager = sessionManager
        self.coordinator = coordinator
    }

    public func makeCoordinator() -> ARViewCoordinator {
        return coordinator
    }

    public func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        sessionManager.startSession()
        arView.session = sessionManager.session

        context.coordinator.setupGesture(in: arView)

        return arView
    }

    public func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.activePlacingType = coordinator.activePlacingType

        if context.coordinator.stateManager.isAddingPoint {
            context.coordinator.stateManager.setIsAddingPoint(false)
            context.coordinator.addPointAtFocus()
        }
        if context.coordinator.stateManager.canUndo {
            context.coordinator.stateManager.setCanUndo(false)
            context.coordinator.removeLastPoint()
        }
        if context.coordinator.stateManager.canReset {
            context.coordinator.stateManager.setCanReset(false)
            context.coordinator.resetCalibration()
        }

        context.coordinator.updateHandlesVisibility(
            isLocked: context.coordinator.stateManager.isDeskLocked
        )
    }
}

public struct ARContainerView: View {
    @ObservedObject var sessionManager: ARSessionManager
    public let coordinator: ARViewCoordinator
    @State var stateManager: StateManager
    
    var isOnboardingFinished: Bool = false

//    public init(
//        sessionManager: ARSessionManager,
//        coordinator: ARViewCoordinator,
//        stateManager: StateManager
//    ) {
//        self.sessionManager = sessionManager
//        self.coordinator = coordinator
//        self.stateManager = stateManager
//    }

    public var body: some View {
        ZStack {
            // BASE AR VIEW
            // Fullscreen
            ARViewRepresentable(
                sessionManager: sessionManager,
                coordinator: coordinator
            )
            .edgesIgnoringSafeArea(.all)

            // CONDITIONAL OVERLAYS
            if stateManager.isDeskLocked {
                lockedOverlay
            } else {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation { stateManager.setDeskLock(false) }
                        }) {
                            Image(systemName: "lock.open.fill")
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(12)
                        }
                        .applyGlassEffect(in: Circle())
                        .shadow(radius: 4)
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 20)
                    Spacer()
                }
            } else {
                unlockedCalibrationOverlay
            }
        }
    }

    @ViewBuilder
    private var unlockedCalibrationOverlay: some View {
        // Mode Kalibrasi: Crosshair, Petunjuk Teks, dan Control Buttons
        ZStack {
            // Crosshair + Label
            centerCrosshairView
                .allowsHitTesting(false)

            // Instruction Guide di atas
            instructionGuideView

            // Trailing Control Buttons (Trash, Plus, Undo)
            trailingControlsView

            // Tombol Selesai di bawah
            finishButtonView
        }
    }

    private var centerCrosshairView: some View {
        VStack {
            ZStack {
                PlaneDetectorCrossHair(
                    strokeColor: .white,
                    centerColor: stateManager.isFocusOnTable ? .green : .white
                )

                VStack {
                    Spacer().frame(height: 50)

                    if !stateManager.detectedPlaneType.isEmpty
                        && stateManager.detectedPlaneType != "Scanning area..."
                    {
                        Text(stateManager.detectedPlaneType)
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                stateManager.isFocusOnTable
                                    ? Color.green.opacity(0.85)
                                    : Color.black.opacity(0.6)
                            )
                            .cornerRadius(6)
                            .shadow(radius: 2)
                    }
                }
            }
        }
    }

    private var instructionGuideView: some View {
        VStack {
            if stateManager.calibrationPoints.isEmpty {
                GuideTextOverlay(
                    caption:
                        "Gerakkan perangkat dan tambah titik untuk membuat area meja."
                )
                .padding(.top, 60)
            } else if stateManager.calibrationPoints.count < 3 {
                GuideTextOverlay(
                    caption:
                        "Tambah setidaknya 3 titik untuk membuat area meja."
                )
                .padding(.top, 60)
            }
            Spacer()
        }
    }

    private var trailingControlsView: some View {
        HStack {
            Spacer()
            VStack(spacing: 24) {
                // Trash Button
                VirtualDeskPlaneButton(
                    systemName: "trash",
                    isDisabled: stateManager.calibrationPoints.isEmpty
                ) {
                    stateManager.setCanReset(true)
                }

                // Plus Button
                VirtualDeskPlaneButton(
                    systemName: "plus",
                    iconSize: 24,
                    foregroundColor: .primary,
                    backgroundColor: stateManager.focus3DPosition != nil ? .white : .clear,
                    size: 60,
                    isDisabled: stateManager.focus3DPosition == nil
                ) {
                    stateManager.setIsAddingPoint(true)
                }

                // Undo Button
                VirtualDeskPlaneButton(
                    systemName: "arrow.uturn.backward",
                    isDisabled: stateManager.calibrationPoints.isEmpty
                ) {
                    stateManager.setCanUndo(true)
                }
            }
            .padding(.trailing, 24)
        }
    }

    private var finishButtonView: some View {
        VStack {
            Spacer()
            if stateManager.calibrationPoints.count >= 3 {
                Button(action: {
                    withAnimation { stateManager.setDeskLock(true) }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.headline)
                        Text("Finish")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .transition(.scale.combined(with: .opacity))
                }
                .padding(8)
                .tint(.blue)
                .glassProminentIfAvailable(color: .blue)
                .padding(.bottom, 120)
            }
        }
    }
}
