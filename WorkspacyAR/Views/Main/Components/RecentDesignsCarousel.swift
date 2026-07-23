/*
import SwiftUI

struct RecentDesignsCarousel: View {
    let designs: [WorkspaceDesign]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Workspaces")
                .font(.system(.subheadline, design: .serif))
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(designs) { design in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.45, green: 0.38, blue: 0.28).opacity(0.06))
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: design.iconName)
                                        .font(.caption)
                                        .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.28))
                                }
                                Spacer()
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 8))
                                        .foregroundColor(Color(red: 0.42, green: 0.55, blue: 0.44))
                                    
                                    Text("\(design.ergonomicsScore)%")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(Color(red: 0.42, green: 0.55, blue: 0.44))
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.42, green: 0.55, blue: 0.44).opacity(0.08))
                                .cornerRadius(4)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                text(design.name)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Text("\(design.itemCount) item layouts")
                                    .font(.system(size: 9))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .frame(width: 150, height: 120)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.015), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 2)
            }
        }
    }
}

#Preview {
    RecentDesignsCarousel(designs: [
        WorkspaceDesign(name: "Ultimate Coding Desk", itemCount: 7, ergonomicsScore: 84, iconName: "desktopcomputer")
    ])
    .padding()
    .background(Color(.systemGroupedBackground))
}
*/
