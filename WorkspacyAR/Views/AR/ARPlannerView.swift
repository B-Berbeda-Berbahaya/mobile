import SwiftUI
import RealityKit

// Simple local model for tracking placed objects
struct PlacedObjectSim: Identifiable, Equatable {
    let id: UUID
    let type: PlaceableObjectType
    var rotation: Float = 0.0 // in degrees
    var heightOffset: Float = 0.0 // in cm
    var posX: Float = 0.0 // in meters
    var posZ: Float = 0.0 // in meters
}

struct ARPlannerView: View {
    @StateObject private var sessionManager = ARSessionManager()
    @StateObject private var stateManager = StateManager()
    @State private var coordinator: ARViewCoordinator? = nil
    
    @State private var placedObjects: [PlacedObjectSim] = []
    @State private var selectedObject: PlacedObjectSim? = nil
    @State private var selectedObjectType: PlaceableObjectType = .macbook16
    @State private var selectedCategory: ItemCategory = .laptop
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
        NavigationStack {
            ZStack(alignment: .leading) {
                // Background Canvas (AR)
                ZStack {
                    if let coordinator = coordinator {
                        ARContainerView(sessionManager: sessionManager, coordinator: coordinator, stateManager: stateManager)
                            .ignoresSafeArea()
                        
                        if stateManager.popoverPosition != .zero {
                            ARFloatingPopover(coordinator: coordinator, stateManager: stateManager)
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
                
                // Top Center Instruction Badge
                VStack {
                    if stateManager.isDeskLocked && selectedObject == nil {
                        HStack {
                            Spacer()
                            Text("Pilih letak untuk \(selectedObjectType.displayName)")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .applyGlassEffect(in: Capsule())
                                .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
                            Spacer()
                        }
                        .padding(.top, 70) // Below top toolbar
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Spacer()
                }
                
                // Bottom control panel (Commented out / Non-active)
                /*
                VStack {
                    Spacer()
                    if stateManager.isDeskLocked {
                        if let object = selectedObject {
                            AdjustItemPopover(
                                objectType: object.type,
                                onRotate: { degrees in
                                    updateSelected(rotation: degrees)
                                },
                                onAdjustHeight: { height in
                                    updateSelected(height: height)
                                },
                                onNudge: { _ in
                                    // Nudge not supported in free-form
                                },
                                onDelete: {
                                    deleteSelected()
                                },
                                onDismiss: {
                                    withAnimation { selectedObject = nil }
                                    coordinator?.deselectCurrentObject()
                                }
                            )
                            .transition(.move(edge: .bottom))
                        }
                    }
                }
                */
                
                
                
                // Floating Resizable Left Directory Panel
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        HStack {
                            if showSidebar {
                                let expandedHeight = geo.size.height - 120
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    // Drag Handle & Header
                                    HStack {
                                        Spacer()
                                        Capsule()
                                            .fill(Color.secondary.opacity(0.6))
                                            .frame(width: 40, height: 5)
                                        Spacer()
                                    }
                                    .frame(height: 20)
                                    .background(Color.white.opacity(0.001)) // Make entire header draggable
                                    .gesture(
                                        DragGesture()
                                            .updating($dragOffset) { value, state, _ in
                                                state = value.translation.height
                                            }
                                            .onEnded { value in
                                                let dragThreshold: CGFloat = 50
                                                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                                                    if value.translation.height < -dragThreshold {
                                                        panelState = .expanded
                                                    } else if value.translation.height > dragThreshold {
                                                        panelState = .collapsed
                                                    }
                                                }
                                            }
                                    )
                                    .padding(.top, 4)
                                    
                                    // Header Title
                                    Text("Directory Studio")
                                        .font(.system(.title3, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                    
                                    // Custom Glassmorphic Search Bar
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                        TextField("Search items...", text: $searchText)
                                            .font(.system(size: 13))
                                            .textFieldStyle(.plain)
                                        if !searchText.isEmpty {
                                            Button(action: { searchText = "" }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.footnote)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .applyGlassEffect(in: RoundedRectangle(cornerRadius: 12))
                                    .padding(.horizontal, 16)
                                    
                                    // Content Section
                                    if panelState == .expanded {
                                        DirectoryView(onPlaceItem: { item in
                                            selectedObjectType = mapDeskItemToObjectType(item)
                                            selectedCategory = selectedObjectType.category
                                        }, searchText: $searchText)
                                        .transition(.opacity)
                                    }
                                    
                                    Spacer(minLength: 0)
                                }
                                .padding(.bottom, 8)
                                .frame(width: 360, height: currentPanelHeight(expandedHeight: expandedHeight))
                                .applyGlassEffect(in: RoundedRectangle(cornerRadius: 24))
                                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                                .padding(.leading, 20)
                                .padding(.bottom, 20) // Floating on the left bottom
                                .transition(.move(edge: .leading).combined(with: .opacity))
                                .zIndex(10)
                            }
                            Spacer()
                        }
                    }
                }
                .allowsHitTesting(true)
                
                // Onboarding Guide Overlay (Top-Left)
                if onboardingStep == .scanningGuide {
                    VStack {
                        HStack {
                            GuideScanningView(onDismiss: {
                                withAnimation { onboardingStep = .completed }
                            })
                            .padding(.leading, 20)
                            .padding(.top, 70) // Below status bar / navigation toolbar
                            Spacer()
                        }
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(20)
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
                                .background(Color(.secondarySystemGroupedBackground))
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(stateManager.isDeskLocked ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text("AR STUDIO")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(stateManager.isDeskLocked ? "Meja Terkunci - Tap untuk menaruh objek" : "Buat Area Meja")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .applyGlassEffect(in: Capsule())
                    .shadow(color: Color.black.opacity(0.04), radius: 3)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        Button(action: {
                            showSidebar.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(8)
                        }
                        .applyGlassEffect(in: Circle())
                        
                        Button(action: {
                            showClearConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .padding(8)
                        }
                        
                        Button(action: {
                            showSuccessScreen = true
                        }) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.42, green: 0.55, blue: 0.44))
                                .padding(8)
                        }
                    }
                }
            }
            .onAppear {
                onboardingStep = .scanningGuide
                initializeCoordinator()
            }
            .fullScreenCover(isPresented: $showSuccessScreen) {
                LayoutSuccessView(placedObjects: placedObjects, onSaveAndExit: {
                    showSuccessScreen = false
                })
            }
            
            .onChange(of: stateManager.isDeskLocked) { oldValue, newValue in
                if newValue {
                    showSidebar = true
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
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
                        if let index = placedObjects.firstIndex(where: { $0.id == obj.id }) {
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
                if let index = placedObjects.firstIndex(where: { $0.id == updatedObj.id }) {
                    let worldPos = updatedObj.entity.position(relativeTo: nil)
                    let heightCm = worldPos.y * 100.0
                    
                    let forward = updatedObj.entity.transform.rotation.act(SIMD3<Float>(0, 0, 1))
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
        coordinator?.anchorManager.removeAll(in: coordinator?.arView ?? RealityKit.ARView())
        coordinator?.resetCalibration()
    }
    
    private func updateSelected(rotation: Float) {
        guard let index = placedObjects.firstIndex(where: { $0.id == selectedObject?.id }) else { return }
        placedObjects[index].rotation = rotation
        selectedObject = placedObjects[index]
        coordinator?.updateRotation(forID: placedObjects[index].id, angleDegrees: rotation)
    }
    
    private func updateSelected(height: Float) {
        guard let index = placedObjects.firstIndex(where: { $0.id == selectedObject?.id }) else { return }
        placedObjects[index].heightOffset = height
        selectedObject = placedObjects[index]
        coordinator?.updateHeight(forID: placedObjects[index].id, heightCm: height)
    }
    
    private func deleteSelected() {
        guard let obj = selectedObject else { return }
        placedObjects.removeAll(where: { $0.id == obj.id })
        coordinator?.removeObject(withID: obj.id)
        selectedObject = nil
    }
    
    private func mapDeskItemToObjectType(_ item: DeskItem) -> PlaceableObjectType {
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
}

extension View {
    @ViewBuilder
    func applyGlassEffect<S: Shape>(in shape: S) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }
}

