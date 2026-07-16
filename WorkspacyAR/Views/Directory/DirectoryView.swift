//
//  Directory.swift
//  WorkspacyAR
//
//  Created by Mochammad Athar Humam Ghazanfar on 14/07/26.
//

import SwiftUI
import Foundation
import Combine

struct DirectoryView: View {
    @State private var viewModel = DirectoryViewModel()
    var onPlaceItem: ((DeskItem) -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            NavigationSplitView {
                List {
                    ForEach(viewModel.filteredSections) { section in
                        Section(section.title) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 12) {
                                ForEach(section.items) { item in
                                    Button {
                                        viewModel.select(item)
                                    } label: {
                                        DeskItemCard(item: item)
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(RoundedRectangle(cornerRadius: 20))
//                                    DeskItemCard(item: item)
//                                        .onTapGesture { viewModel.select(item) }
                                }
                            }
                        }
                    }
                }
                .searchable(text: $viewModel.searchText)
                .navigationTitle("Directory")
                .navigationSplitViewColumnWidth(geo.size.width * 0.50)
            } detail: {
                PreviewPanel(item: viewModel.selectedItem, onPlace: {
                    if let item = viewModel.selectedItem {
                        onPlaceItem?(item)
                    }
                })
            }
            .navigationSplitViewStyle(.balanced)
        }
    }
}

struct DeskItemCard: View {
    let item: DeskItem
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack{
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                Image(systemName: item.systemImage)
                    .font(.system(size: 48, weight: .ultraLight))
                    .scaledToFit()
                    .frame(width: 56, height: 56)
            }
            .aspectRatio(1.3, contentMode: .fit)
            
            Text(item.name)
                .font(.headline)
                .fontWeight(.regular)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
                .padding(12)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct PreviewPanel: View {
    let item: DeskItem?
    var onPlace: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)

            VStack(spacing: 12) {
                Image(systemName: "arkit")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundStyle(.secondary)
                Text(item?.name ?? "Select an item to preview")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        onPlace?()
                    } label: {
                        Text("Place")
                            .frame(width: 150, height: 44)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(item == nil)
                    .padding(24)

                }
            }
        }
        .navigationTitle("Preview")
    }
}

#Preview {
    DirectoryView()
}
