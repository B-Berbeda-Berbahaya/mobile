import SwiftUI

struct RecentDesignsCarousel: View {
    let designs: [WorkspaceDesign] = [
        WorkspaceDesign(name: "Ultimate Coding Desk", itemCount: 7, ergonomicsScore: 84, iconName: "desktopcomputer"),
        WorkspaceDesign(name: "Home Office Setup", itemCount: 4, ergonomicsScore: 62, iconName: "laptopcomputer"),
        WorkspaceDesign(name: "Standing Studio", itemCount: 5, ergonomicsScore: 91, iconName: "arrow.up.and.down.square")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Designs")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(designs) { design in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.08))
                                        .frame(width: 36, height: 36)
                                    
                                    Image(systemName: design.iconName)
                                        .foregroundColor(.accentColor)
                                }
                                Spacer()
                                
                                HStack(spacing: 3) {
                                    Image(systemName: "shield.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(.green)
                                    Text("\(design.ergonomicsScore)%")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(6)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(design.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                Text("\(design.itemCount) items")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .frame(width: 150, height: 120)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 2)
            }
        }
    }
}

#Preview {
    RecentDesignsCarousel()
        .background(Color(.systemGroupedBackground))
}
