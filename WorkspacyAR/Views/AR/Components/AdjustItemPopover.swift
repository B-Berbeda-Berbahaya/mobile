import SwiftUI

struct AdjustItemPopover: View {
    let objectType: PlaceableObjectType
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Sliders & settings states
    @State private var rotationAngle: Float = 0.0 // in degrees
    @State private var relativeHeight: Float = 0.0 // in cm offsets
    @State private var distanceToUser: Float = 60.0 // in cm
    @State private var showErgoFeedback: Bool = true
    
    // Callbacks
    var onRotate: ((Float) -> Void)? = nil
    var onAdjustHeight: ((Float) -> Void)? = nil
    var onNudge: ((GridDirection) -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    
    enum GridDirection {
        case forward, backward, left, right
    }
    
    // Calculate simulated ergonomic compliance
    var ergoStatus: (isGood: Bool, title: String, description: String) {
        switch objectType {
        case .iMac24, .monitor32:
            if distanceToUser < 50 {
                return (false, "Monitor Too Close", "Move monitor further away. Recommended eye-to-screen distance is 50-70 cm (currently \(Int(distanceToUser)) cm).")
            } else if distanceToUser > 80 {
                return (false, "Monitor Too Far", "Move monitor closer. Recommended distance is 50-70 cm to prevent squinting and forward head posture.")
            } else {
                return (true, "Optimal Placement", "Monitor is at the ideal ergonomic distance (\(Int(distanceToUser)) cm). Make sure the top matches your eye level.")
            }
        case .macbookPro16:
            return (false, "Neck Flexion Risk", "Laptops cause neck strain when used flat. We recommend a laptop stand and external keyboard.")
        default:
            return (true, "Ready to use", "This accessory is placed correctly in your active reach zone.")
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Bar / Grabber
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Item Header
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(categoryColor.opacity(0.12))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: objectType.sfSymbol)
                        .font(.title2)
                        .foregroundColor(categoryColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(objectType.displayName)
                        .font(.headline)
                    Text(objectType.category.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(categoryColor)
                }
                
                Spacer()
                
                // Close button
                Button(action: {
                    onDismiss?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Fine-Tune Controls
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Fine-Tune Placement")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        // Rotation Slider
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label("Rotation", systemImage: "rotate.right")
                                Spacer()
                                Text("\(Int(rotationAngle))°")
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                            
                            Slider(value: $rotationAngle, in: -180...180, step: 5) { _ in
                                onRotate?(rotationAngle)
                            }
                        }
                        
                        // Height Slider (Vertical Offset)
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label("Height Offset", systemImage: "arrow.up.and.down")
                                Spacer()
                                Text("\(Int(relativeHeight)) cm")
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                            
                            Slider(value: $relativeHeight, in: -15...15, step: 1) { _ in
                                onAdjustHeight?(relativeHeight)
                            }
                        }
                        
                        // Specific Ergonomics Controls (e.g., monitor distance to user)
                        if objectType == .iMac24 || objectType == .monitor32 {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Label("Screen-to-Eye Distance", systemImage: "eye")
                                    Spacer()
                                    Text("\(Int(distanceToUser)) cm")
                                        .fontWeight(.semibold)
                                }
                                .font(.caption)
                                
                                Slider(value: $distanceToUser, in: 30...100, step: 2)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // Directional Nudge Pad (Grid Positioning)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Grid Nudge Controller")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 8) {
                                // Up
                                Button(action: { onNudge?(.forward) }) {
                                    Image(systemName: "chevron.up.square.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.accentColor)
                                }
                                
                                HStack(spacing: 24) {
                                    // Left
                                    Button(action: { onNudge?(.left) }) {
                                        Image(systemName: "chevron.left.square.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.accentColor)
                                    }
                                    
                                    // Center dot indicator
                                    Circle()
                                        .fill(Color.secondary.opacity(0.4))
                                        .frame(width: 12, height: 12)
                                    
                                    // Right
                                    Button(action: { onNudge?(.right) }) {
                                        Image(systemName: "chevron.right.square.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                
                                // Down
                                Button(action: { onNudge?(.backward) }) {
                                    Image(systemName: "chevron.down.square.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.accentColor)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.vertical)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    // Ergonomics Compliance Status Box
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Ergonomics Compliance Check")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Image(systemName: ergoStatus.isGood ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(ergoStatus.isGood ? .green : .orange)
                        }
                        
                        Text(ergoStatus.title)
                            .font(.headline)
                            .foregroundColor(ergoStatus.isGood ? .green : .orange)
                        
                        Text(ergoStatus.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ergoStatus.isGood ? Color.green.opacity(0.08) : Color.orange.opacity(0.08))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(ergoStatus.isGood ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Action Buttons (Delete Object)
                    Button(action: {
                        onDelete?()
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Remove from Workspace")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 20)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -4)
        .adaptiveWidth(isRegular: horizontalSizeClass == .regular, maxWidth: 500)
    }
    
    private var categoryColor: Color {
        switch objectType.category {
        case .monitor: return .blue
        case .laptop: return .purple
        case .keyboard: return .orange
        case .mouse: return .orange
        case .deskmat, .accessories: return .gray
        }
    }
}

#Preview {
    AdjustItemPopover(objectType: .monitor32)
}
