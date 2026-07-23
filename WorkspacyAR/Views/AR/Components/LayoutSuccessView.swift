import SwiftUI

struct LayoutSuccessView: View {
    let placedObjects: [PlacedObjectSim]
    var onSaveAndExit: () -> Void
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject private var viewModel = LayoutSuccessViewModel()
    
    let themeBrown = Color(red: 0.45, green: 0.38, blue: 0.28)
    let sageGreen = Color(red: 0.42, green: 0.55, blue: 0.44)
    
    var body: some View {
        ZStack {
            // Warm off-white/linen catalog background
            Color(red: 0.97, green: 0.96, blue: 0.94)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Success Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 54))
                            .foregroundColor(sageGreen)
                            .padding(.top, 30)
                        
                        Text("Workspace Configured")
                            .font(.system(.title, design: .serif))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.22, green: 0.20, blue: 0.18))
                            .multilineTextAlignment(.center)
                        
                        Text("Your layout passes all safety standards.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Live Tabletop Layout Map
                    VStack(alignment: .leading, spacing: 10) {
                        Text("LAYOUT BLUEPRINT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(2)
                            .padding(.horizontal, 4)
                        
                        LayoutSchematicPreview(placedObjects: placedObjects)
                    }
                    
                    // Ergonomic Alignment Diagnostic Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("ERGONOMIC METRICS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.secondary)
                                .tracking(2)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "shield.fill")
                                    .font(.caption2)
                                    .foregroundColor(sageGreen)
                                Text("\(viewModel.score)/100")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(sageGreen)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(sageGreen.opacity(0.08))
                            .cornerRadius(6)
                        }
                        
                        VStack(spacing: 12) {
                            let itemsCount = viewModel.diagnostics.count
                            ForEach(0..<itemsCount, id: \.self) { idx in
                                let item = viewModel.diagnostics[idx]
                                DiagnosticRow(title: item.title, rating: item.rating, description: item.description, isOptimal: item.isOptimal)
                                
                                if idx < itemsCount - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.02), radius: 8, y: 4)
                    
                    // Actions Panel
                    VStack(spacing: 12) {
                        Button(action: {
                            let activityVC = UIActivityViewController(activityItems: ["Check out my ergonomic workspace setup on Workspacy!"], applicationActivities: nil)
                            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                activityVC.popoverPresentationController?.sourceView = rootVC.view
                                rootVC.present(activityVC, animated: true, completion: nil)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Setup")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundColor(themeBrown)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeBrown.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        Button(action: onSaveAndExit) {
                            Text("Save & Return to Studio")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(themeBrown)
                                .cornerRadius(12)
                                .shadow(color: themeBrown.opacity(0.2), radius: 8, y: 4)
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct LayoutSchematicPreview: View {
    let placedObjects: [PlacedObjectSim]
    let themeBrown = Color(red: 0.45, green: 0.38, blue: 0.28)
    
    var body: some View {
        ZStack {
            // Desk surface representation
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.93, green: 0.90, blue: 0.85))
                .frame(height: 180)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeBrown.opacity(0.12), lineWidth: 1)
                )
            
            // Grid lines overlay
            Path { path in
                let step = 30.0
                var x = 30.0
                while x < 300 {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: 180))
                    x += step
                }
            }
            .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
            
            if placedObjects.isEmpty {
                Text("No items configured")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(placedObjects, id: \.id) { obj in
                    // Map real world coordinates (-1 to 1 meters roughly) to the schematic (-150 to 150 points roughly)
                    let xOffset = CGFloat(obj.posX) * 150.0
                    let zOffset = CGFloat(obj.posZ) * 150.0
                    
                    VStack(spacing: 4) {
                        Image(systemName: obj.type.sfSymbol)
                            .font(.system(size: 14))
                            .foregroundColor(themeBrown)
                        Text(obj.type.displayName)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(themeBrown.opacity(0.9))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.04), radius: 3)
                    .offset(x: xOffset, y: zOffset)
                }
            }
        }
        .frame(height: 180)
        .cornerRadius(16)
        .clipped()
    }
}

struct DiagnosticRow: View {
    let title: String
    let rating: String
    let description: String
    let isOptimal: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: isOptimal ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .foregroundColor(isOptimal ? Color(red: 0.42, green: 0.55, blue: 0.44) : .orange)
                .font(.subheadline)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    Spacer()
                    Text(rating)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(isOptimal ? Color(red: 0.42, green: 0.55, blue: 0.44) : .orange)
                }
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

#Preview {
    LayoutSuccessView(
        placedObjects: [
            PlacedObjectSim(id: UUID(), type: .monitor32, rotation: 0, posX: 0.0, posZ: -0.2),
            PlacedObjectSim(id: UUID(), type: .magicKeyboard, rotation: 0, posX: 0.0, posZ: 0.2)
        ],
        onSaveAndExit: {}
    )
}
