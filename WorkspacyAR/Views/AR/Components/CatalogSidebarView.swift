import SwiftUI

struct CatalogSidebarView: View {
    @Binding var selectedObjectType: PlaceableObjectType
    @Binding var selectedCategory: ItemCategory
    var onPlaceItem: (DeskItem) -> Void
    var onClose: () -> Void
    
    @State private var viewModel = DirectoryViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let themeBrown = Color(red: 0.45, green: 0.38, blue: 0.28)
    
    var body: some View {
        GeometryReader { geo in
            let sidebarWidth = geo.size.width * 0.70
            let isRegular = horizontalSizeClass == .regular
            
            HStack(spacing: 0) {
                // Main Sidebar Content Container
                Group {
                    if isRegular {
                        // iPad / Widescreen: Split-Column Layout
                        HStack(spacing: 0) {
                            // Left Column: Item Selector Grid List (60% of sidebar)
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Studio Catalog")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                
                                // Custom search bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    TextField("Search items...", text: $viewModel.searchText)
                                        .textFieldStyle(PlainTextFieldStyle())
                                }
                                .padding(10)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(12)
                                
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 20) {
                                        ForEach(viewModel.filteredSections) { section in
                                            VStack(alignment: .leading, spacing: 10) {
                                                Text(section.title)
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.secondary)
                                                    .textCase(.uppercase)
                                                    .tracking(1)
                                                
                                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                                                    ForEach(section.items) { item in
                                                        Button(action: {
                                                            viewModel.select(item)
                                                        }) {
                                                            VStack(spacing: 8) {
                                                                ZStack {
                                                                    RoundedRectangle(cornerRadius: 12)
                                                                        .fill(viewModel.selectedItem?.id == item.id ? themeBrown.opacity(0.15) : Color.white.opacity(0.05))
                                                                        .frame(height: 64)
                                                                    
                                                                    Image(systemName: item.systemImage)
                                                                        .font(.title2)
                                                                        .foregroundColor(viewModel.selectedItem?.id == item.id ? themeBrown : .primary)
                                                                }
                                                                
                                                                Text(item.name)
                                                                    .font(.system(size: 10, weight: .medium))
                                                                    .foregroundColor(.primary)
                                                                    .lineLimit(1)
                                                                    .multilineTextAlignment(.center)
                                                            }
                                                            .padding(6)
                                                            .background(viewModel.selectedItem?.id == item.id ? Color.white.opacity(0.05) : Color.clear)
                                                            .cornerRadius(14)
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                            .padding(.bottom, 24)
                            .frame(width: sidebarWidth * 0.60)
                            
                            // Vertical Separator
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 1)
                                .ignoresSafeArea(.all, edges: .vertical)
                            
                            // Right Column: Preview Panel Details (40% of sidebar)
                            VStack(spacing: 20) {
                                HStack {
                                    Spacer()
                                    Button(action: onClose) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white.opacity(0.05))
                                            .frame(width: 100, height: 100)
                                        
                                        Image(systemName: viewModel.selectedItem?.systemImage ?? "arkit")
                                            .font(.system(size: 48, weight: .ultraLight))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    VStack(spacing: 6) {
                                        Text(viewModel.selectedItem?.name ?? "Select an Item")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .multilineTextAlignment(.center)
                                        
                                        Text(viewModel.selectedItem != nil ? "Place this virtual prototype on your workspace surface to inspect the dimensions and ergonomics." : "Browse the catalog categories on the left list and pick a target to inspect.")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing(2)
                                            .padding(.horizontal, 10)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if let item = viewModel.selectedItem {
                                        onPlaceItem(item)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "cube.fill")
                                        Text("Place in Studio")
                                            .fontWeight(.bold)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(viewModel.selectedItem == nil ? Color.gray.opacity(0.3) : themeBrown)
                                    .cornerRadius(14)
                                    .shadow(color: viewModel.selectedItem == nil ? Color.clear : themeBrown.opacity(0.3), radius: 8, y: 4)
                                }
                                .disabled(viewModel.selectedItem == nil)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 40)
                            .padding(.bottom, 36)
                            .frame(width: sidebarWidth * 0.40)
                            .background(Color.white.opacity(0.02))
                        }
                    } else {
                        // iPhone / Portrait: Single Column vertical flow
                        VStack(alignment: .leading, spacing: 14) {
                            // Header
                            HStack {
                                Text("Studio Catalog")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: onClose) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 44)
                            
                            // Custom search bar input
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search items...", text: $viewModel.searchText)
                                    .font(.footnote)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(10)
                            .padding(.horizontal)
                            
                            // Scroll list
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    ForEach(viewModel.filteredSections) { section in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(section.title)
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.secondary)
                                                .textCase(.uppercase)
                                                .tracking(1)
                                            
                                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 8)], spacing: 8) {
                                                ForEach(section.items) { item in
                                                    Button(action: {
                                                        viewModel.select(item)
                                                    }) {
                                                        VStack(spacing: 4) {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 10)
                                                                    .fill(viewModel.selectedItem?.id == item.id ? themeBrown.opacity(0.2) : Color.white.opacity(0.05))
                                                                    .frame(height: 50)
                                                                
                                                                Image(systemName: item.systemImage)
                                                                    .font(.body)
                                                                    .foregroundColor(viewModel.selectedItem?.id == item.id ? themeBrown : .primary)
                                                            }
                                                            
                                                            Text(item.name)
                                                                .font(.system(size: 8, weight: .medium))
                                                                .foregroundColor(.primary)
                                                                .lineLimit(1)
                                                        }
                                                        .padding(4)
                                                        .background(viewModel.selectedItem?.id == item.id ? Color.white.opacity(0.05) : Color.clear)
                                                        .cornerRadius(10)
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // Bottom Selected Item Info HUD & Place Button
                            VStack(spacing: 8) {
                                if let selected = viewModel.selectedItem {
                                    HStack(spacing: 8) {
                                        Image(systemName: selected.systemImage)
                                            .foregroundColor(themeBrown)
                                            .font(.footnote)
                                        Text(selected.name)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.04))
                                    .cornerRadius(8)
                                    .transition(.opacity)
                                }
                                
                                Button(action: {
                                    if let item = viewModel.selectedItem {
                                        onPlaceItem(item)
                                    }
                                }) {
                                    Text(viewModel.selectedItem == nil ? "Select an Item" : "Place in Studio")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(viewModel.selectedItem == nil ? Color.gray.opacity(0.3) : themeBrown)
                                        .cornerRadius(10)
                                }
                                .disabled(viewModel.selectedItem == nil)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .frame(width: sidebarWidth)
                .background(.ultraThinMaterial)
                
                // Clear tap-to-dismiss zone
                Color.black.opacity(0.3)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onClose()
                    }
            }
            .frame(width: geo.size.width)
            .ignoresSafeArea(.all, edges: .vertical)
        }
    }
}

#Preview {
    ZStack(alignment: .leading) {
        Color.black.ignoresSafeArea()
        CatalogSidebarView(
            selectedObjectType: .constant(.macbook16),
            selectedCategory: .constant(.laptop),
            onPlaceItem: { _ in },
            onClose: {}
        )
    }
}
