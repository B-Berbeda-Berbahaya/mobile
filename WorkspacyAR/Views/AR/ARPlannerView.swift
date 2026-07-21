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
    
    enum OnboardingStep {
        case scanningGuide
        case completed
    }
    @State private var onboardingStep: OnboardingStep = .scanningGuide
    
    var body: some View {
<<<<<<< HEAD
        NavigationStack {
            ZStack(alignment: .leading) {
            // Background Canvas (AR or Interactive Grid)
            if isARMode {
                ZStack {
                    if let coordinator = coordinator {
                        ARContainerView(sessionManager: sessionManager, coordinator: coordinator)
                            .ignoresSafeArea()
                        
                        if popoverPosition != .zero {
                            ARFloatingPopover(coordinator: coordinator, interactionMode: $interactionMode)
                                .position(popoverPosition)
                        }
                    } else {
                        Color.black.ignoresSafeArea()
                        ProgressView("Initializing AR Studio...")
                            .foregroundColor(.white)
=======
        ZStack(alignment: .leading) {
            // Background Canvas (AR)
            ZStack {
                if let coordinator = coordinator {
                    ARContainerView(sessionManager: sessionManager, coordinator: coordinator, stateManager: stateManager)
                        .ignoresSafeArea()
                    
                    if stateManager.popoverPosition != .zero {
                        ARFloatingPopover(coordinator: coordinator, stateManager: stateManager)
                            .position(stateManager.popoverPosition)
>>>>>>> main
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
                // Top Toolbar
                PlannerToolbar(
                    sessionState: stateManager.isDeskLocked ? "Meja Terkunci - Tap untuk menaruh objek" : "Buat Area Meja",
                    showSidebar: $showSidebar,
                    onClear: {
                        showClearConfirmation = true
                    },
                    onFinish: {
                        showSuccessScreen = true
                    }
                )
                
                Spacer()
                
                // Bottom control panel
                if stateManager.isDeskLocked {
                    if selectedObject == nil {
                        VStack(spacing: 8) {
                            Text("Pilih letak untuk \(selectedObjectType.displayName)")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(10)
                                .padding(.bottom, 16)
                        }
                        .transition(.opacity)
                    } else {
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
            }
            
            // Sliding Sidebar Drawer
            if showSidebar {
                GeometryReader { geo in
                    let sidebarWidth = geo.size.width * 0.70
                    HStack(spacing: 0) {
                        DirectoryView(onPlaceItem: { item in
                            selectedObjectType = mapDeskItemToObjectType(item)
                            selectedCategory = selectedObjectType.category
                            withAnimation { showSidebar = false }
                        })
                        .frame(width: sidebarWidth)
                        
                        Color.black.opacity(0.35)
                            .frame(width: geo.size.width - sidebarWidth)
                            .onTapGesture {
                                withAnimation { showSidebar = false }
                            }
                    }
                    .ignoresSafeArea(.all, edges: .vertical)
                }
                .transition(.move(edge: .leading))
                .zIndex(10)
            }
            
            // Onboarding Guide Overlay
            if onboardingStep == .scanningGuide {
                GuideScanningView(onDismiss: {
                    withAnimation { onboardingStep = .completed }
                })
                .transition(.opacity)
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
        .onAppear {
            onboardingStep = .scanningGuide
            initializeCoordinator()
        }
        .fullScreenCover(isPresented: $showSuccessScreen) {
            LayoutSuccessView(placedObjects: placedObjects, onSaveAndExit: {
                showSuccessScreen = false
            })
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(isARMode ? Color.red : Color.green)
                        .frame(width: 8, height: 8)
                    Text(isARMode ? "AR CAMERA" : "STUDIO MODE")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(sessionState)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.primary)
                }
            } else {
                if coordinator?.selectedPlacedObject != nil {
                    coordinator?.deselectCurrentObject()
                }
            }
        }
<<<<<<< HEAD
        .toolbarBackground(.hidden, for: .navigationBar)
        }
=======
>>>>>>> main
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

/*
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
                        .foregroundColor(showSidebar ? Color(red: 0.45, green: 0.38, blue: 0.28) : .primary)
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
                        .foregroundColor(Color(red: 0.42, green: 0.55, blue: 0.44))
                        .clipShape(Circle())
                }
            }
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}
<<<<<<< HEAD
*/

// 3D Simulated tabletop canvas
struct SimulatedGridCanvas: View {
    @Binding var placedObjects: [PlacedObjectSim]
    @Binding var selectedObject: PlacedObjectSim?
    let showDebugGrid: Bool
    let onCellTapped: (Int, Int) -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.16, green: 0.18, blue: 0.22), Color(red: 0.11, green: 0.12, blue: 0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    let scale: CGFloat = geo.size.width < 400 ? (geo.size.width / 400.0) : 0.95
                    
                    VStack(spacing: 2) {
                        ForEach(Array(stride(from: 2, through: -2, by: -1)), id: \.self) { z in
                            HStack(spacing: 2) {
                                ForumCellBuilder(z: z, placedObjects: $placedObjects, selectedObject: $selectedObject, showDebugGrid: showDebugGrid, onCellTapped: onCellTapped)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .rotation3DEffect(
                        .degrees(35),
                        axis: (x: 1.0, y: 0.0, z: 0.0),
                        anchor: .center,
                        perspective: 0.5
                    )
                    .scaleEffect(scale)
                    .offset(y: -40)
                    
                    Spacer()
                }
            }
        }
    }
}

struct ForumCellBuilder: View {
    let z: Int
    @Binding var placedObjects: [PlacedObjectSim]
    @Binding var selectedObject: PlacedObjectSim?
    let showDebugGrid: Bool
    let onCellTapped: (Int, Int) -> Void
    
    var body: some View {
        ForEach(-4...4, id: \.self) { x in
            CellButton(
                x: x,
                z: z,
                placedObject: placedObjects.first(where: { $0.gridX == x && $0.gridZ == z }),
                isSelected: selectedObject?.gridX == x && selectedObject?.gridZ == z,
                showDebug: showDebugGrid,
                onTap: {
                    onCellTapped(x, z)
                }
            )
        }
    }
}

// Single Cell on the Simulated Grid
struct CellButton: View {
    let x: Int
    let z: Int
    let placedObject: PlacedObjectSim?
    let isSelected: Bool
    let showDebug: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected ? Color(red: 0.45, green: 0.38, blue: 0.28).opacity(0.3) :
                        (placedObject != nil ? Color.white.opacity(0.08) : Color.white.opacity(0.02))
                    )
                    .frame(width: 38, height: 38)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color(red: 0.45, green: 0.38, blue: 0.28) : Color.white.opacity(0.1), lineWidth: 1)
                    )
                
                if showDebug && placedObject == nil {
                    Text("\(x),\(z)")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.2))
                }
                
                if let obj = placedObject {
                    VStack {
                        Image(systemName: obj.type.sfSymbol)
                            .font(.system(size: 16))
                            .foregroundColor(isSelected ? Color(red: 0.45, green: 0.38, blue: 0.28) : .white)
                            .rotationEffect(.degrees(Double(obj.rotation)))
                            .scaleEffect(isSelected ? 1.2 : 1.0)
                            .animation(.spring(), value: isSelected)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
=======
>>>>>>> main
