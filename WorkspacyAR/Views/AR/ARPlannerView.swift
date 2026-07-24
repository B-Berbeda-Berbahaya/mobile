import RealityKit
import SwiftUI
import SwiftData

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
    @Environment(\.modelContext) private var modelContext
    @StateObject private var sessionManager = ARSessionManager()
    @State private var stateManager = StateManager()
    @State private var coordinator: ARViewCoordinator? = nil

    @State private var placedObjects: [PlacedObjectSim] = []
    @State private var selectedObject: PlacedObjectSim? = nil
    @State private var selectedObjectType: PlaceableObjectType?
    @State private var selectedCategory: ItemCategory = .laptop
    @State private var showSidebar = false
    @State private var showSuccessScreen = false
    @State private var showClearConfirmation = false
    
    // Save & Restore Layout States
    @State private var showSaveLayoutDialog = false
    @State private var saveLayoutNameInput = ""
    
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

                // Top Center Instruction Badge
                VStack {
                    if stateManager.isDeskLocked && stateManager.pendingRestoringLayout == nil && selectedObject == nil {
                        HStack {
                            Spacer()
                            Text("Pilih letak untuk \(selectedObjectType?.displayName ?? "item")")
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

                // Floating Resizable Left Directory Panel (Hanya muncul saat mode Placement Objek)
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        HStack {
                            let showDirectoryPanel = stateManager.isDeskLocked && stateManager.pendingRestoringLayout == nil
                            if showDirectoryPanel {
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
                                            selectedObjectType = item.objectType
                                            selectedCategory = item.objectType.category
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

                // Floating Ergonomics HUD Card (Bottom-Right, Hanya di Mode Placement)
                if stateManager.isDeskLocked && stateManager.pendingRestoringLayout == nil {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 6) {
                                    Image(systemName: "gauge.medium")
                                        .font(.caption2)
                                        .foregroundColor(stateManager.complianceScore >= 75 ? .green : (stateManager.complianceScore >= 50 ? .orange : .red))
                                    Text("WORKSPACE WELLNESS")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .tracking(1)
                                    Spacer()
                                    Text("\(stateManager.complianceScore)%")
                                        .font(.system(size: 11, weight: .bold, design: .serif))
                                        .foregroundColor(stateManager.complianceScore >= 75 ? .green : (stateManager.complianceScore >= 50 ? .orange : .red))
                                }
                                
                                Divider()
                                    .background(Color.secondary.opacity(0.15))
                                
                                HStack(spacing: 16) {
                                    // Distance Info
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("DISTANCE")
                                            .font(.system(size: 7, weight: .semibold))
                                            .foregroundColor(.secondary)
                                        
                                        if stateManager.realTimeDistance > 0 {
                                            Text(String(format: "%.0f cm", stateManager.realTimeDistance * 100))
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(stateManager.distanceStatus.color)
                                        } else {
                                            Text("No Monitor")
                                                .font(.system(size: 11, weight: .semibold))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer(minLength: 8)
                                    
                                    // Eye Level Info
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("EYE LEVEL")
                                            .font(.system(size: 7, weight: .semibold))
                                            .foregroundColor(.secondary)
                                        
                                        if stateManager.realTimeDistance > 0 {
                                            Text(String(format: "%+.0f cm", stateManager.realTimeEyeLevelDiff * 100))
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(stateManager.eyeLevelStatus.color)
                                        } else {
                                            Text("--")
                                                .font(.system(.subheadline, design: .rounded))
                                                .fontWeight(.bold)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                if stateManager.realTimeDistance > 0 {
                                    Divider()
                                        .background(Color.secondary.opacity(0.15))
                                    Text("*Posisi mata diestimasi berdasarkan posisi genggam perangkat (jarak genggam ~30cm, tinggi mata ~15cm).")
                                        .font(.system(size: 6))
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding(14)
                            .frame(width: 190)
                            .applyGlassEffect(in: RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                        }
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .zIndex(10)
                }

                // 1. Onboarding Tutorial Dialog (Centered Popup)
                if onboardingStep == .scanningGuide {
                    ZStack {
                        Color.black.opacity(0.45)
                            .ignoresSafeArea()
                        
                        GuideObjectView(
                            onDismiss: {
                                withAnimation { onboardingStep = .completed }
                            },
                            steps: [
                                GuideStep(
                                    imageURL: "https://picsum.photos/seed/picsum/480/300",
                                    title: "Scan Area Meja",
                                    description: "Gerakkan perangkat Anda secara perlahan untuk mendeteksi permukaan meja kerja Anda."
                                ),
                                GuideStep(
                                    imageURL: "https://picsum.photos/seed/picsum/300/300",
                                    title: "Tempatkan Produk",
                                    description: "Pilih produk dari katalog studio di bawah dan tempatkan pada area meja yang terdeteksi."
                                )
                            ]
                        )
                    }
                    .transition(.opacity)
                    .zIndex(30)
                }

                // 2. Compact Floating Scanning Guide (Top-Left)
                if onboardingStep == .completed && !stateManager.isDeskLocked {
                    VStack {
                        HStack {
                            GuideScanningView(onDismiss: {
                                withAnimation { stateManager.setDeskLock(true) }
                            })
                            .padding(.leading, 10)
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
                            Text("Hapus Semua Objek?")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Text("Semua objek 3D di atas meja akan dihapus. Lanjutkan?")
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

                // BUNDLE ROTATION & CONFIRMATION CONTROLS (Live Preview Bundle Mode)
                if stateManager.pendingRestoringLayout != nil {
                    VStack {
                        Spacer()
                        VStack(spacing: 14) {
                            HStack(spacing: 12) {
                                // Rotate Left -15° Button
                                Button(action: {
                                    withAnimation {
                                        stateManager.pendingBundleRotation -= .pi / 12
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "rotate.left.fill")
                                        Text("-15°")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color.black.opacity(0.75))
                                    .clipShape(Capsule())
                                }
                                
                                // Confirm Button: Pasang Di Sini
                                Button(action: {
                                    if let pendingLayout = stateManager.pendingRestoringLayout {
                                        let targetPos = stateManager.focus3DPosition ?? SIMD3<Float>(0, 0, -0.5)
                                        let rotation = stateManager.pendingBundleRotation
                                        
                                        coordinator?.removePreviewBundle()
                                        stateManager.pendingRestoringLayout = nil
                                        stateManager.pendingBundleRotation = 0.0
                                        coordinator?.restoreSavedLayout(layout: pendingLayout, at: targetPos, rotationAngle: rotation)
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3)
                                        Text("Pasang Di Sini")
                                            .font(.headline)
                                            .bold()
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(Color.accentColor)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.accentColor.opacity(0.4), radius: 8)
                                }
                                
                                // Rotate Right +15° Button
                                Button(action: {
                                    withAnimation {
                                        stateManager.pendingBundleRotation += .pi / 12
                                    }
                                }) {
                                    HStack(spacing: 4) {
                                        Text("+15°")
                                        Image(systemName: "rotate.right.fill")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(Color.black.opacity(0.75))
                                    .clipShape(Capsule())
                                }
                            }
                            
                            // Cancel Button
                            Button(action: {
                                coordinator?.removePreviewBundle()
                                stateManager.pendingRestoringLayout = nil
                                stateManager.pendingBundleRotation = 0.0
                            }) {
                                Text("Batal Penempatan")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.red.opacity(0.85))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.bottom, 36)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(150)
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
            }
            .onChange(of: selectedObjectType) { _, newType in
                coordinator?.activePlacingType = newType
            }
            .onChange(of: stateManager.isDeskLocked) { _, isLocked in
                if isLocked {
                    panelState = .expanded
                }
            }
            .sheet(isPresented: $stateManager.showSavedLayoutsSheet) {
                SavedLayoutsSheetView(stateManager: stateManager)
            }
            .alert("Simpan Layout Meja", isPresented: $showSaveLayoutDialog) {
                TextField("Nama Layout", text: $saveLayoutNameInput)
                Button("Simpan & Selesai") {
                    coordinator?.saveCurrentLayout(modelContext: modelContext, name: saveLayoutNameInput)
                    showSuccessScreen = true
                }
                Button("Selesai Tanpa Menyimpan") {
                    showSuccessScreen = true
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Masukkan nama tatanan meja AR ini untuk disimpan sebelum menyelesaikan.")
            }
            .toolbar {
                if stateManager.pendingRestoringLayout == nil {
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
                            // Button View Saved Layouts Sheet (Tampil di mode buat meja & placement mode)
                            Button(action: {
                                stateManager.showSavedLayoutsSheet = true
                            }) {
                                Image(systemName: "folder.fill")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .padding(8)
                            }
                            .applyGlassEffect(in: Circle())

                            if stateManager.isDeskLocked {
                                // Button Unlock / Edit Desk Area
                                Button(action: {
                                    withAnimation {
                                        stateManager.setDeskLock(false)
                                    }
                                }) {
                                    Image(systemName: "lock.open.fill")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                        .padding(8)
                                }
                                .applyGlassEffect(in: Circle())

                                // Button Clear All 3D Objects
                                Button(action: {
                                    showClearConfirmation = true
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                        .padding(8)
                                }
                                .applyGlassEffect(in: Circle())
                                
                                // Button Finish & Save (Merged Checkmark)
                                Button(action: {
                                    saveLayoutNameInput = "Layout \(Date().formatted(date: .abbreviated, time: .shortened))"
                                    showSaveLayoutDialog = true
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 0.42, green: 0.55, blue: 0.44))
                                        .padding(8)
                                }
                                .applyGlassEffect(in: Circle())
                            }
                        }
                    }
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
        if let placedObjectsInAR = coordinator?.anchorManager.placedObjects {
            let copyList = Array(placedObjectsInAR)
            for object in copyList {
                coordinator?.removeObject(withID: object.id)
            }
        }
        coordinator?.deselectCurrentObject()
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

    private func mapDeskItemToObjectType(_ item: DeskItem) -> PlaceableObjectType? {
        let name = item.name.lowercased()
        if name.contains("monitor") {
            return .monitor32
        } else if name.contains("imac") {
            return .iMac24
        } else if name.contains("macbook") || name.contains("laptop") {
            return .macbookPro16
        } else if name.contains("keyboard") {
            return .magicKeyboard
        } else if name.contains("mouse") {
            return .appleMouse
        } else if name.contains("accessoris") {
            return .monitorRaiser
        } else if name.contains("deskmat") {
            return .deskmat
        } else {
            return nil
        }
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

#Preview {
    ARPlannerView()
}
