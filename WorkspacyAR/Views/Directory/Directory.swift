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
    @State private var searchText = ""
    @State private var selectedItem: DeskItem?
    @State

    let sections: [DeskItemSection] = DeskItemSection.mockData // TODO: replace with real catalog

    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    // TODO: search bar goes in .searchable(), not inline
                }
                ForEach(sections) { section in
                    Section(section.title) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                            ForEach(section.items) { item in
                                DeskItemCard(item: item)
                                    .onTapGesture { selectedItem = item }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Directory")
        } detail: {
            PreviewPanel(item: selectedItem) // TODO: swap for RealityView once assets exist
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct PreviewPanel: View {
    let item: DeskItem?

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
                    Button("Place") {
                        // TODO: AR placement logic
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
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
