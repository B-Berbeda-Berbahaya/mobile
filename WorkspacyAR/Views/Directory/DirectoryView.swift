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
    
    var body: some View {
        GeometryReader { geo in
            NavigationSplitView {
                List {
                    ForEach(viewModel.filteredSections) { section in
                        Section(section.title) {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90, maximum: 120))], spacing: 12) {
                                ForEach(section.items) { item in
                                    DeskItemCard(item: item)
                                        .onTapGesture { viewModel.select(item) }
                                }
                            }
                        }
                    }
                }
                .searchable(text: $viewModel.searchText)
                .navigationTitle("Directory")
//                .navigationSplitViewColumnWidth(geo.size.width * 0.50)
            } detail: {
                PreviewPanel(item: viewModel.selectedItem)
            }
            .navigationSplitViewStyle(.balanced)
        }
    }
}

struct DeskItemCard: View {
    let item: DeskItem

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: item.systemImage)
                .font(.system(size: 28, weight: .thin))
                .frame(width: 56, height: 56)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(item.name)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: 90, minHeight: 90)
        .padding(8)
        .contentShape(Rectangle())
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
                    Button {
                        // TODO: AR placement logic
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

//
//import SwiftUI
//import Foundation
//import Combine
//
//struct DirectoryView: View {
//
//    @State private var viewModel = DirectoryViewModel()
//
//    var body: some View {
//        GeometryReader { geo in
//
//            let directoryWidth = geo.size.width * 0.67
//            let previewWidth = geo.size.width * 0.33
//
//            HStack(spacing: 0) {
//
//                DirectoryPanel(
//                    viewModel: $viewModel,
//                    width: directoryWidth
//                )
//                .frame(width: directoryWidth)
//
//                Divider()
//
//                PreviewPanel(item: viewModel.selectedItem)
//                    .frame(width: previewWidth)
//            }
//        }
//    }
//}
//
//struct DirectoryPanel: View {
//
//    @Binding var viewModel: DirectoryViewModel
//
//    let width: CGFloat
//
//    private let spacing: CGFloat = 16
//
//    private var columnCount: Int {
//        max(Int(width / 180), 2)
//    }
//
//    private var columns: [GridItem] {
//        Array(
//            repeating: GridItem(.flexible(), spacing: spacing),
//            count: columnCount
//        )
//    }
//
//    private var cardWidth: CGFloat {
//        (width - CGFloat(columnCount + 1) * spacing) / CGFloat(columnCount)
//    }
//
//    var body: some View {
//
//        VStack(spacing: 0) {
//
//            Text("Directory")
//                .font(.largeTitle.bold())
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//                .padding(.top)
//
//            TextField("Search...", text: $viewModel.searchText)
//                .textFieldStyle(.roundedBorder)
//                .padding()
//
//            ScrollView {
//
//                LazyVStack(alignment: .leading, spacing: 28) {
//
//                    ForEach(viewModel.filteredSections) { section in
//
//                        VStack(alignment: .leading, spacing: 16) {
//
//                            Text(section.title)
//                                .font(.title3.bold())
//
//                            LazyVGrid(
//                                columns: columns,
//                                alignment: .leading,
//                                spacing: spacing
//                            ) {
//
//                                ForEach(section.items) { item in
//
//                                    DeskItemCard(
//                                        item: item,
//                                        width: cardWidth
//                                    )
//                                    .onTapGesture {
//                                        viewModel.select(item)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding()
//            }
//        }
//    }
//}
//
//struct DeskItemCard: View {
//
//    let item: DeskItem
//    let width: CGFloat
//
//    var body: some View {
//
//        VStack(spacing: 12) {
//
//            Image(systemName: item.systemImage)
//                .font(.system(size: width * 0.22))
//                .frame(
//                    width: width * 0.45,
//                    height: width * 0.45
//                )
//                .background(Color(.tertiarySystemBackground))
//                .clipShape(RoundedRectangle(cornerRadius: 14))
//
//            Text(item.name)
//                .font(.headline)
//                .multilineTextAlignment(.center)
//                .lineLimit(2)
//        }
//        .frame(width: width, height: width * 0.85)
//        .background(Color(.secondarySystemBackground))
//        .clipShape(RoundedRectangle(cornerRadius: 18))
//        .overlay {
//            RoundedRectangle(cornerRadius: 18)
//                .stroke(.gray.opacity(0.2))
//        }
//        .contentShape(Rectangle())
//    }
//}
//
//struct PreviewPanel: View {
//
//    let item: DeskItem?
//
//    var body: some View {
//
//        ZStack {
//
//            Color(.secondarySystemBackground)
//
//            VStack(spacing: 20) {
//
//                Spacer()
//
//                Image(systemName: "arkit")
//                    .font(.system(size: 70))
//                    .foregroundStyle(.secondary)
//
//                Text(item?.name ?? "Select an item")
//                    .font(.title2)
//
//                Spacer()
//
//                Button("Place") {
//
//                }
//                .buttonStyle(.borderedProminent)
//                .disabled(item == nil)
//                .padding(.bottom, 24)
//            }
//        }
//    }
//}
//
//#Preview {
//    DirectoryView()
//}
