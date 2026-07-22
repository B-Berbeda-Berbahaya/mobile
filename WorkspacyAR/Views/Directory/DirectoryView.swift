//
//  Directory.swift
//  WorkspacyAR
//
//  Created by Mochammad Athar Humam Ghazanfar on 14/07/26.
//

import SwiftUI
import Foundation
import Combine
import RealityKit
import Workspacy

struct DirectoryView: View {
    @State private var viewModel = DirectoryViewModel()
    var onPlaceItem: ((DeskItem) -> Void)? = nil
    @Binding var searchText: String

    var body: some View {
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
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(section.items) { item in
                                Button {
                                    viewModel.select(item)
                                    onPlaceItem?(item)
                                } label: {
                                    DirectoryItemCell(item: item, isSelected: viewModel.selectedItem?.id == item.id)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .background(Color.clear)
        .onChange(of: searchText, initial: true) { oldValue, newValue in
            viewModel.searchText = newValue
        }
    }
}

struct DirectoryItemCell: View {
    let item: DeskItem
    let isSelected: Bool

    var body: some View {
        let backgroundColor: Color = isSelected ? Color.accentColor.opacity(0.15) : .clear
        let iconTint: Color = isSelected ? .accentColor : .primary
        let containerBackground: Color = isSelected ? Color.accentColor.opacity(0.05) : .clear

        return VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    .frame(height: 64)

                Image(systemName: item.systemImage)
                    .font(.title2)
                    .foregroundStyle(iconTint)
            }

            Text(item.name)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .padding(6)
        .background(containerBackground)
        .cornerRadius(14)
    }
}

#Preview {
    DirectoryView(searchText: .constant(""))
}
