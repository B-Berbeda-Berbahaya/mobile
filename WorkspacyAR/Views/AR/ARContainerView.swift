import SwiftUI
import RealityKit
import ARKit

public struct ARViewRepresentable: UIViewRepresentable {
    @ObservedObject var sessionManager: ARSessionManager
    public let coordinator: ARViewCoordinator
    
    public init(sessionManager: ARSessionManager, coordinator: ARViewCoordinator) {
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
        
        if context.coordinator.stateManager.shouldAddPointTrigger {
            context.coordinator.stateManager.shouldAddPointTrigger = false
            context.coordinator.addPointAtFocus()
        }
        if context.coordinator.stateManager.shouldUndoPointTrigger {
            context.coordinator.stateManager.shouldUndoPointTrigger = false
            context.coordinator.removeLastPoint()
        }
        if context.coordinator.stateManager.shouldResetTrigger {
            context.coordinator.stateManager.shouldResetTrigger = false
            context.coordinator.resetCalibration()
        }
        
        context.coordinator.updateHandlesVisibility(isLocked: context.coordinator.stateManager.isDeskLocked)
    }
}

public struct ARContainerView: View {
    @ObservedObject var sessionManager: ARSessionManager
    public let coordinator: ARViewCoordinator
    @ObservedObject var stateManager: StateManager
    
    public init(sessionManager: ARSessionManager, coordinator: ARViewCoordinator, stateManager: StateManager) {
        self.sessionManager = sessionManager
        self.coordinator = coordinator
        self.stateManager = stateManager
    }
    
    public var body: some View {
        ZStack {
            ARViewRepresentable(sessionManager: sessionManager, coordinator: coordinator)
                .edgesIgnoringSafeArea(.all)
            
            // 1. CENTER CROSSHAIR (Hanya muncul saat kalibrasi / meja belum dikunci)
            if !stateManager.isDeskLocked {
                VStack {
                    ZStack {
                        if !stateManager.isFocusOnTable {
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 32, height: 32)
                                .shadow(color: .black.opacity(0.5), radius: 1)
                        }
                        
                        Circle()
                            .fill(stateManager.isFocusOnTable ? Color.green : Color.white)
                            .frame(width: 4, height: 4)
                            .shadow(color: .black.opacity(0.50), radius: 1)
                        
                        VStack {
                            Spacer()
                                .frame(height: 50)
                            if !stateManager.detectedPlaneType.isEmpty && stateManager.detectedPlaneType != "Scanning area..." {
                                Text(stateManager.detectedPlaneType)
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(stateManager.isFocusOnTable ? Color.green.opacity(0.85) : Color.black.opacity(0.6))
                                    .cornerRadius(6)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .allowsHitTesting(false)
            }
            
            // 2. TOP INSTRUCTION GUIDE
            if !stateManager.isDeskLocked {
                VStack {
                    if stateManager.calibrationPoints.isEmpty {
                        Text("Gerakkan perangkat dan tambah titik\nuntuk membuat area meja.")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                            .shadow(radius: 8)
                            .padding(.top, 60)
                    } else if stateManager.calibrationPoints.count < 3 {
                        Text("Tambah setidaknya 3 titik\nuntuk membuat area meja.")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
                            .shadow(radius: 8)
                            .padding(.top, 60)
                    }
                    Spacer()
                }
            } else {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation { stateManager.isDeskLocked = false }
                        }) {
                            Image(systemName: "lock.open.fill")
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.top, 60)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }
            
            // 3. TRAILING CONTROLS (Kalibrasi)
            if !stateManager.isDeskLocked {
                HStack {
                    Spacer()
                    VStack(spacing: 24) {
                        Button(action: {
                            stateManager.shouldResetTrigger = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(stateManager.calibrationPoints.isEmpty ? .gray : .white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .disabled(stateManager.calibrationPoints.isEmpty)
                        
                        Button(action: {
                            stateManager.shouldAddPointTrigger = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(stateManager.focus3DPosition != nil ? Color.white : Color.white.opacity(0.6))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .disabled(stateManager.focus3DPosition == nil)
                        
                        Button(action: {
                            stateManager.shouldUndoPointTrigger = true
                        }) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(stateManager.calibrationPoints.isEmpty ? .gray : .white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .disabled(stateManager.calibrationPoints.isEmpty)
                    }
                    .padding(.trailing, 24)
                }
                
                VStack {
                    Spacer()
                    if stateManager.calibrationPoints.count >= 3 {
                        Button(action: {
                            withAnimation { stateManager.isDeskLocked = true }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                Text("Selesai")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(25)
                            .shadow(radius: 5)
                            .transition(.scale.combined(with: .opacity))
                        }
                        .padding(.bottom, 120) // Supaya tidak tertutup toolbar bawah Planner
                    }
                }
            }
        }
    }
}
