import SwiftUI
import RealityKit

// Local structural model for layout simulation
struct PlacedObjectSim: Identifiable, Equatable {
    let id: UUID
    let type: PlaceableObjectType
    var gridX: Int // -4 to 4
    var gridZ: Int // -2 to 2
    var rotation: Float = 0.0 // in degrees
    var heightOffset: Float = 0.0 // in cm
    var distance: Float = 60.0 // in cm
}

struct ARPlannerView: View {
    @StateObject private var gridSystem = GridSystem()
    @StateObject private var sessionManager = ARSessionManager()
    @State private var coordinator: ARViewCoordinator? = nil
    
    //dummy
    @State private var placedObjects: [PlacedObjectSim] = [
        PlacedObjectSim(id: UUID(), type: .monitor32, gridX: 0, gridZ: 2, rotation: 0, heightOffset: 5, distance: 58),
        PlacedObjectSim(id: UUID(), type: .magicKeyboard, gridX: 0, gridZ: 0, rotation: 0, heightOffset: 0, distance: 40)
    ]
    
    @State private var selectedObject: PlacedObjectSim? = nil
    @State private var selectedObjectType: PlaceableObjectType = .monitor32
    @State private var selectedCategory: ItemCategory = .monitor
    @State private var showDebugGrid = true
    @State private var isARMode = true
    @State private var sessionState = "Searching for planes..."
    @State private var showSidebar = true
    @State private var showSuccessScreen = false
    
    enum OnboardingStep {
        case scanningGuide
        case objectGuide
        case completed
    }
    @State private var onboardingStep: OnboardingStep = .scanningGuide
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background Canvas (AR or Interactive Grid)
            if isARMode {
                ZStack {
                    if let coordinator = coordinator {
                        ARContainerView(sessionManager: sessionManager, coordinator: coordinator)
                            .ignoresSafeArea()
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
            } else {
                SimulatedGridCanvas(
                    placedObjects: $placedObjects,
                    selectedObject: $selectedObject,
                    showDebugGrid: showDebugGrid,
                    onCellTapped: { x, z in
                        Task { await handleCellTapped(x: x, z: z) }
                    }
                )
            }
            
            // Overlays & UI Controllers
            VStack {
                // Top Toolbar
                PlannerToolbar(
                    isARMode: $isARMode,
                    showDebugGrid: $showDebugGrid,
                    sessionState: sessionState,
                    showSidebar: $showSidebar,
                    onClear: {
                        clearWorkspace()
                    },
                    onFinish: {
                        showSuccessScreen = true
                    }
                )
                
                Spacer()
                
                // Bottom control panel (Picker or Adjuster)
                if selectedObject == nil {
                    VStack(spacing: 8) {
                        Text(isARMode ? "Tap surface to place \(selectedObjectType.displayName)" : "Tap table cell to place \(selectedObjectType.displayName)")
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
                            onNudge: { direction in
                                nudgeSelected(direction: direction)
                            },
                            onDelete: {
                                deleteSelected()
                            },
                            onDismiss: {
                                withAnimation { selectedObject = nil }
                            }
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
            }.onChange(of: selectedObjectType) { _, newValue in
                coordinator?.activePlacingType = newValue
            }
            
            // Sliding Sidebar Drawer
            //            if showSidebar {
            //                DirectoryView()
            //                .transition(.move(edge: .leading))
            //                .zIndex(10)
            //            }
            if showSidebar {
                CatalogSidebarView(
                    selectedObjectType: $selectedObjectType,
                    selectedCategory: $selectedCategory,
                    onPlaceItem: { item in
                        selectedObjectType = item.objectType
                        selectedCategory = selectedObjectType.category
                        withAnimation { showSidebar = false }
                    },
                    onClose: {
                        withAnimation { showSidebar = false }
                    }
                )
                .zIndex(10)
            }
            //                DirectoryView(
            //                    selectedObjectType: $selectedObjectType,
            //                    selectedCategory: $selectedCategory,
            //                    onPlaceItem: { item in
            //                        selectedObjectType = item.objectType
            //                        selectedCategory = selectedObjectType.category
            //                        withAnimation { showSidebar = false }
            //                    },
            //                    onClose: {
            //                        withAnimation { showSidebar = false }
            //                    }
            //                )
            //                .transition(.move(edge: .leading))
            //                .zIndex(10)
            //            }
            
            // Onboarding Guide Overlay
            if onboardingStep == .scanningGuide {
                GuideScanningView(onDismiss: {
                    withAnimation { onboardingStep = .objectGuide }
                })
                .transition(.opacity)
                .zIndex(20)
            } else if onboardingStep == .objectGuide {
                GuideObjectView(onDismiss: {
                    withAnimation { onboardingStep = .completed }
                })
                .transition(.opacity)
                .zIndex(20)
            }
        }
        .onAppear {
            onboardingStep = .scanningGuide
            initializeCoordinator()
        }
        .fullScreenCover(isPresented: $showSuccessScreen) {
            LayoutSuccessView(placedObjects: placedObjects, onSaveAndExit: {
                showSuccessScreen = false
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToDashboard"), object: nil)
            })
        }
    }
    
    // Core actions
    private func initializeCoordinator() {
        if coordinator == nil {
            let coord = ARViewCoordinator(gridSystem: gridSystem)
            coord.activePlacingType = selectedObjectType
            coord.onSelectedObjectChanged = { placedObj in
                if let obj = placedObj {
                    withAnimation {
                        if let index = placedObjects.firstIndex(where: { $0.id == obj.id }) {
                            selectedObject = placedObjects[index]
                        } else {
                            let newSim = PlacedObjectSim(
                                id: obj.id,
                                type: obj.type,
                                gridX: obj.gridCoordinate.x,
                                gridZ: obj.gridCoordinate.z
                            )
                            placedObjects.append(newSim)
                            selectedObject = newSim
                        }
                    }
                } else {
                    withAnimation { selectedObject = nil }
                }
            }
            coordinator = coord
        }
    }
    
    private func handleCellTapped(x: Int, z: Int) async {
        if !placedObjects.contains(where: { $0.gridX == x && $0.gridZ == z }) {
            let newId = UUID()
            let newObj = PlacedObjectSim(id: newId, type: selectedObjectType, gridX: x, gridZ: z)
            placedObjects.append(newObj)
            selectedObject = newObj
            sessionState = "Placed \(selectedObjectType.displayName)"
            
            // Real AR placement
            if let coordinator = coordinator {
                let coord = GridCoordinate(x: x, z: z)
                let worldPos = coordinator.mapper.worldPosition(for: coord)
                await coordinator.placeObject(worldPosition: worldPos, type: selectedObjectType, coordinate: coord)
            }
        } else {
            selectedObject = placedObjects.first(where: { $0.gridX == x && $0.gridZ == z })
        }
    }
    
    private func clearWorkspace() {
        placedObjects.removeAll()
        selectedObject = nil
        coordinator?.anchorManager.removeAll(in: coordinator?.arView ?? ARView())
        gridSystem.clear()
        sessionState = "Cleared Studio"
    }
    
    private func nudgeSelected(direction: AdjustItemPopover.GridDirection) {
        guard let index = placedObjects.firstIndex(where: { $0.id == selectedObject?.id }) else { return }
        
        switch direction {
        case .forward:
            if placedObjects[index].gridZ < 2 { placedObjects[index].gridZ += 1 }
        case .backward:
            if placedObjects[index].gridZ > -2 { placedObjects[index].gridZ -= 1 }
        case .left:
            if placedObjects[index].gridX > -4 { placedObjects[index].gridX -= 1 }
        case .right:
            if placedObjects[index].gridX < 4 { placedObjects[index].gridX += 1 }
        }
        selectedObject = placedObjects[index]
        
        if let coordinator = coordinator {
            let coord = GridCoordinate(x: placedObjects[index].gridX, z: placedObjects[index].gridZ)
            if let obj = coordinator.anchorManager.placedObjects.first(where: { $0.id == selectedObject?.id }) {
                let worldPos = coordinator.mapper.worldPosition(for: coord)
                obj.entity.transform.translation = worldPos
            }
        }
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
        sessionState = "Removed \(obj.type.displayName)"
    }
}

// Sub-component: Planner toolbar header
struct PlannerToolbar: View {
    @Binding var isARMode: Bool
    @Binding var showDebugGrid: Bool
    let sessionState: String
    @Binding var showSidebar: Bool
    var onClear: () -> Void
    var onFinish: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(isARMode ? Color.red : Color.green)
                    .frame(width: 8, height: 8)
                Text(isARMode ? "AR CAMERA" : "STUDIO MODE")
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
                    showSidebar.toggle()
                })  {
                    Image(systemName: "sidebar.left")
                        .font(.title3)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.85))
                        .foregroundColor(showSidebar ? Color(red: 0.45, green: 0.38, blue: 0.28) : .primary)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    withAnimation { showDebugGrid.toggle() }
                }) {
                    Image(systemName: showDebugGrid ? "grid.circle.fill" : "grid.circle")
                        .font(.title3)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.85))
                        .foregroundColor(.primary)
                        .clipShape(Circle())
                }
                
                Button(action: {
                    isARMode.toggle()
                }) {
                    Image(systemName: isARMode ? "cube.transparent" : "arkit")
                        .font(.title3)
                        .padding(8)
                        .background(Color(.systemBackground).opacity(0.85))
                        .foregroundColor(.primary)
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

// 3D Simulated tabletop canvas
struct SimulatedGridCanvas: View {
    @Binding var placedObjects: [PlacedObjectSim]
    @Binding var selectedObject: PlacedObjectSim?
    let showDebugGrid: Bool
    let onCellTapped: @Sendable (Int, Int) -> Void
    
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
    let onCellTapped: @Sendable (Int, Int) -> Void
    
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
    let onTap: @Sendable () -> Void
    
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

private struct DetailPlaceholderContainer: View {
    var body: some View {
        NavigationSplitView {
            List {
                Text("Sidebar")
            }
        } detail: {
            Text("Select an item")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Detail Placeholder") {
    DetailPlaceholderContainer()
}
