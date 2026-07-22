import RealityKit
import SwiftUI

// Simple local model for tracking placed objects
struct PlacedObjectSim: Identifiable, Equatable {
    let id: UUID
    let type: PlaceableObjectType
    var rotation: Float = 0.0  // in degrees
    var heightOffset: Float = 0.0  // in cm
    var posX: Float = 0.0  // in meters
    var posZ: Float = 0.0  // in meters
}

enum OnboardingStep {
    case scanningGuide
    case completed
}

struct ARPlannerView: View {
    @StateObject private var sessionManager = ARSessionManager()
    @State private var stateManager = StateManager()
    @State private var coordinator: ARViewCoordinator? = nil

    @State private var placedObjects: [PlacedObjectSim] = []
    @State private var selectedObject: PlacedObjectSim? = nil
<<<<<<< HEAD
    @State private var selectedObjectType: PlaceableObjectType?
    @State private var selectedCategory: ItemCategory?
=======
    @State private var selectedObjectType: PlaceableObjectType = .macbookAir13new
    @State private var selectedCategory: ItemCategory = .laptop
>>>>>>> d01692b (F/30 object anchor handling (#31))
    @State private var showSidebar = false
    @State private var showSuccessScreen = false
    @State private var showClearConfirmation = false
    
    enum PanelState {
        case collapsed
        case expanded
    }
    @State private var panelState: PanelState = .expanded
    @State private var searchText = ""
    @GestureState private var dragOffset: CGFloat = 0
    private let collapsedHeight: CGFloat = 160
    
    enum OnboardingStep {
        case scanningGuide
        case completed
    }
    @State private var onboardingStep: OnboardingStep = .scanningGuide

    var body: some View {
        ZStack(alignment: .leading) {
            // Canvas as the background
            // Background Canvas (AR)
            ZStack {
                if let coordinator = coordinator {
                    ARContainerView(
                        sessionManager: sessionManager,
                        coordinator: coordinator,
                        stateManager: stateManager,
                        isOnboardingFinished: onboardingStep == .completed
                    )
                    .ignoresSafeArea()

                    if stateManager.popoverPosition != .zero {
                        ARFloatingPopover(
                            coordinator: coordinator,
                            stateManager: stateManager
                        )
                        .position(stateManager.popoverPosition)
                    }
                } else {
                    Color.black.ignoresSafeArea()
                    ProgressView("Initializing AR Studio...")
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                sessionManager.startSession()
            }
            .onDisappear {
                sessionManager.pauseSession()
            }

            // Overlays & UI Controllers
            VStack {
                if onboardingStep != .scanningGuide {
                    // Top Toolbar
                    PlannerToolbar(
                        sessionState: stateManager.isDeskLocked
                            ? "Meja Terkunci - Tap untuk menaruh objek"
                            : "Buat Area Meja",
                        showSidebar: $showSidebar,
                        onClear: {
                            showClearConfirmation = true
                        },
                        onFinish: {
                            showSuccessScreen = true
                        }
                    )
                }

                Spacer()

                // Bottom control panel
                if stateManager.isDeskLocked {
                    if selectedObject == nil {
                        VStack(spacing: 8) {
<<<<<<< HEAD
                            Text("Pilih letak untuk \(selectedObjectType?.displayName ?? "item")")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                                .padding(.bottom, 16)
=======
                            Text(
                                "Pilih letak untuk \(selectedObjectType.displayName)"
                            )
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                            .padding(.bottom, 16)
>>>>>>> d01692b (F/30 object anchor handling (#31))
                        }
                        .transition(.opacity)
                    }
                    //                    else {
                    //                        if let object = selectedObject {
                    //                            AdjustItemPopover(
                    //                                objectType: object.type,
                    //                                onRotate: { degrees in
                    //                                    updateSelected(rotation: degrees)
                    //                                },
                    //                                onAdjustHeight: { height in
                    //                                    updateSelected(height: height)
                    //                                },
                    //                                onNudge: { _ in
                    //                                    // Nudge not supported in free-form
                    //                                },
                    //                                onDelete: {
                    //                                    deleteSelected()
                    //                                },
                    //                                onDismiss: {
                    //                                    withAnimation { selectedObject = nil }
                    //                                    coordinator?.deselectCurrentObject()
                    //                                }
                    //                            )
                    //                            .transition(.move(edge: .bottom))
                    //                        }
                    //                    }
                }
            }

            // Sliding Sidebar Drawer
            if showSidebar {
                CatalogSidebarView(
                    selectedObjectType: Binding(
                        get: { selectedObjectType ?? .macbook16},
                        set: { selectedObjectType = $0 }
                    ),
                    selectedCategory: Binding(
                        get: { selectedCategory ?? .laptop },
                        set: { selectedCategory = $0 }
                    ),
                    onPlaceItem: { item in
                        selectedObjectType = item.objectType
                        selectedCategory = selectedObjectType?.category
                        withAnimation { showSidebar = false }
                    },
                    onClose: {
                        withAnimation { showSidebar = false }
                    }
                )
                .transition(.move(edge: .leading))
                .zIndex(10)
            }

            // Onboarding Guide Overlay
            if onboardingStep == .scanningGuide {
                ZStack(alignment: .center) {
                    HStack {
                        GuideObjectView(
                            onDismiss: {
                                withAnimation { onboardingStep = .completed }
                            },
                            steps: [
                                GuideStep(
                                    imageURL:
                                        "https://picsum.photos/seed/picsum/480/300",
                                    title: "scan",
                                    description: "scan description"
                                ),
                                GuideStep(
                                    imageURL:
                                        "https://picsum.photos/seed/picsum/300/300",
                                    title: "place",
                                    description: "place description"
                                ),
                            ]
                        )
                    }
                    .frame(maxWidth: .infinity)
                }

                //                GuideScanningView(onDismiss: {
                //                    withAnimation { onboardingStep = .completed }
                //                })
                //                .transition(.opacity)
                //                .zIndex(20)
            }

            // Custom Confirmation Alert Overlay
            if showClearConfirmation {
                ZStack {
                    Color.black.opacity(0.4)
                        .onTapGesture {
                            withAnimation { showClearConfirmation = false }
                        }

                    VStack(spacing: 20) {
                        Text("Hapus Semua?")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("Area meja dan objek akan dihapus. Lanjutkan?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        HStack(spacing: 16) {
                            Button("Batal") {
                                withAnimation { showClearConfirmation = false }
                            }
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Color(.secondarySystemGroupedBackground)
                            )
                            .cornerRadius(10)

                            Button("Hapus") {
                                withAnimation { showClearConfirmation = false }
                                clearWorkspace()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 30)
                    .frame(maxWidth: 340)
                }
                .ignoresSafeArea()
                .zIndex(100)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            onboardingStep = .scanningGuide
            initializeCoordinator()
        }
        .fullScreenCover(isPresented: $showSuccessScreen) {
            LayoutSuccessView(
                placedObjects: placedObjects,
                onSaveAndExit: {
                    showSuccessScreen = false
                    NotificationCenter.default.post(
                        name: NSNotification.Name("SwitchToDashboard"),
                        object: nil
                    )
                }
            )
        }
<<<<<<< HEAD
        .onChange(of: selectedObjectType) { _, newValue in
            coordinator?.activePlacingType = newValue
=======
        .onChange(of: selectedObject) { _, newObj in
            if let newObj = newObj {
                if coordinator?.selectedPlacedObject?.id != newObj.id {
                    if let obj = coordinator?.anchorManager.placedObjects.first(
                        where: { $0.id == newObj.id })
                    {
                        coordinator?.selectObject(obj)
                    }
                }
            } else {
                if coordinator?.selectedPlacedObject != nil {
                    coordinator?.deselectCurrentObject()
                }
            }
<<<<<<< HEAD
>>>>>>> d01692b (F/30 object anchor handling (#31))
=======
            .toolbarBackground(.hidden, for: .navigationBar)
>>>>>>> bcbcf33 (F/8 UI screen development   main screen (#32))
        }
    }
    
    private func currentPanelHeight(expandedHeight: CGFloat) -> CGFloat {
        let baseHeight = (panelState == .expanded) ? expandedHeight : collapsedHeight
        let calculated = baseHeight - dragOffset
        return min(max(calculated, collapsedHeight), expandedHeight)
    }
    
    private func initializeCoordinator() {
        if coordinator == nil {
            let coord = ARViewCoordinator(stateManager: stateManager)
            coord.activePlacingType = selectedObjectType

            coord.onSelectedObjectChanged = { placedObj in
                if let obj = placedObj {
                    withAnimation {
                        if let index = placedObjects.firstIndex(where: {
                            $0.id == obj.id
                        }) {
                            selectedObject = placedObjects[index]
                        } else {
                            let worldPos = obj.entity.position(relativeTo: nil)
                            let newSim = PlacedObjectSim(
                                id: obj.id,
                                type: obj.type,
                                posX: worldPos.x,
                                posZ: worldPos.z
                            )
                            placedObjects.append(newSim)
                            selectedObject = newSim
                        }
                    }
                } else {
                    withAnimation { selectedObject = nil }
                }
            }

            coord.onPlacedObjectUpdated = { updatedObj in
                if let index = placedObjects.firstIndex(where: {
                    $0.id == updatedObj.id
                }) {
                    let worldPos = updatedObj.entity.position(relativeTo: nil)
                    let heightCm = worldPos.y * 100.0

                    let forward = updatedObj.entity.transform.rotation.act(
                        SIMD3<Float>(0, 0, 1)
                    )
                    let yawAngle = atan2(forward.x, forward.z)
                    var yawDegrees = yawAngle * 180.0 / .pi
                    if yawDegrees < 0 {
                        yawDegrees += 360.0
                    }

                    withAnimation {
                        placedObjects[index].rotation = yawDegrees
                        placedObjects[index].heightOffset = heightCm
                        placedObjects[index].posX = worldPos.x
                        placedObjects[index].posZ = worldPos.z

                        if selectedObject?.id == updatedObj.id {
                            selectedObject = placedObjects[index]
                        }
                    }
                }
            }

            coordinator = coord
        } else {
            coordinator?.activePlacingType = selectedObjectType
        }
    }

    private func clearWorkspace() {
        placedObjects.removeAll()
        selectedObject = nil
        coordinator?.anchorManager.removeAll(
            in: coordinator?.arView ?? RealityKit.ARView()
        )
        coordinator?.resetCalibration()
    }

    private func updateSelected(rotation: Float) {
        guard
            let index = placedObjects.firstIndex(where: {
                $0.id == selectedObject?.id
            })
        else { return }
        placedObjects[index].rotation = rotation
        selectedObject = placedObjects[index]
        coordinator?.updateRotation(
            forID: placedObjects[index].id,
            angleDegrees: rotation
        )
    }

    private func updateSelected(height: Float) {
        guard
            let index = placedObjects.firstIndex(where: {
                $0.id == selectedObject?.id
            })
        else { return }
        placedObjects[index].heightOffset = height
        selectedObject = placedObjects[index]
        coordinator?.updateHeight(
            forID: placedObjects[index].id,
            heightCm: height
        )
    }

    private func deleteSelected() {
        guard let obj = selectedObject else { return }
        placedObjects.removeAll(where: { $0.id == obj.id })
        coordinator?.removeObject(withID: obj.id)
        selectedObject = nil
    }
<<<<<<< HEAD
=======

    private func mapDeskItemToObjectType(_ item: DeskItem)
        -> PlaceableObjectType
    {
        let name = item.name.lowercased()
        if name.contains("monitor") {
            return .monitor32
        } else if name.contains("imac") {
            return .iMac24
        } else if name.contains("macbook") || name.contains("laptop") {
            return .macbook16
        } else if name.contains("keyboard") {
            return .magicKeyboard
        } else if name.contains("mouse") {
            return .appleMouse
        }
        return .macbook16
    }
>>>>>>> d01692b (F/30 object anchor handling (#31))
}

extension View {
    @ViewBuilder
    func applyGlassEffect<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
// Sub-component: Planner toolbar header
struct PlannerToolbar: View {
    let sessionState: String
    @Binding var showSidebar: Bool
    var onClear: () -> Void
    var onFinish: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                Text("AR CAMERA")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

                Text("•")
                    .foregroundColor(.secondary)

                Text(sessionState)
                    .font(.caption2)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemBackground).opacity(0.85))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.05), radius: 5)

            Spacer()

            HStack(spacing: 8) {
                Button(action: {
                    withAnimation { showSidebar.toggle() }
                }) {
                    Image(systemName: "sidebar.left")
                        .font(.title3)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.85))
                        .foregroundColor(
                            showSidebar
                                ? Color(red: 0.45, green: 0.38, blue: 0.28)
                                : .primary
                        )
                        .clipShape(Circle())
                }

                Button(action: onClear) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.85))
                        .foregroundColor(.red)
                        .clipShape(Circle())
                }

                Button(action: onFinish) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.85))
                        .foregroundColor(
                            Color(red: 0.42, green: 0.55, blue: 0.44)
                        )
                        .clipShape(Circle())
                }
            }
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
    }
}

#Preview {
    ARPlannerView()
}
