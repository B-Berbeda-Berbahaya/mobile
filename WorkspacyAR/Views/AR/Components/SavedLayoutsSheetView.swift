import SwiftUI
import SwiftData

public struct SavedLayoutsSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \SavedDeskLayout.createdAt, order: .reverse) private var savedLayouts: [SavedDeskLayout]
    
    @State var stateManager: StateManager
    
    // Edit Name State
    @State private var layoutToRename: SavedDeskLayout? = nil
    @State private var newLayoutName: String = ""
    @State private var showRenameAlert: Bool = false
    
    public init(stateManager: StateManager) {
        self.stateManager = stateManager
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if savedLayouts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("Belum Ada Layout Tersimpan")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Kalibrasi meja, letakkan objek 3D di atasnya, lalu simpan tatanan meja untuk dimuat kembali kapan saja.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(savedLayouts, id: \.id) { layout in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 8) {
                                        Text(layout.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        // Edit Name Button
                                        Button(action: {
                                            layoutToRename = layout
                                            newLayoutName = layout.name
                                            showRenameAlert = true
                                        }) {
                                            Image(systemName: "pencil")
                                                .font(.subheadline)
                                                .foregroundColor(.accentColor)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        Label("\(layout.placedObjects.count) Objek", systemImage: "cube.fill")
                                        Label("\(layout.relativePoints.count) Titik Sudut", systemImage: "mappin.and.ellipse")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    
                                    Text(layout.createdAt, style: .date)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 10) {
                                    // Load Button
                                    Button(action: {
                                        stateManager.pendingRestoringLayout = layout
                                        stateManager.shouldConfirmBundlePlacementTrigger = true
                                        dismiss()
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.down.doc.fill")
                                            Text("Muat")
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.accentColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(.borderless)
                                    
                                    // Dedicated Delete Button
                                    Button(action: {
                                        deleteLayout(layout)
                                    }) {
                                        Image(systemName: "trash.fill")
                                            .font(.subheadline)
                                            .padding(8)
                                            .background(Color.red.opacity(0.12))
                                            .foregroundColor(.red)
                                            .clipShape(Circle())
                                    }
                                    .buttonStyle(.borderless)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .onDelete(perform: deleteLayouts)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Layout Tersimpan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
            .alert("Edit Nama Layout", isPresented: $showRenameAlert) {
                TextField("Nama Layout", text: $newLayoutName)
                Button("Simpan", action: saveRenamedLayout)
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Masukkan nama baru untuk tatanan meja ini.")
            }
        }
    }
    
    private func saveRenamedLayout() {
        guard let layout = layoutToRename, !newLayoutName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        layout.name = newLayoutName.trimmingCharacters(in: .whitespaces)
        try? modelContext.save()
        layoutToRename = nil
        newLayoutName = ""
    }
    
    private func deleteLayout(_ layout: SavedDeskLayout) {
        modelContext.delete(layout)
        try? modelContext.save()
    }
    
    private func deleteLayouts(offsets: IndexSet) {
        for index in offsets {
            let layout = savedLayouts[index]
            modelContext.delete(layout)
        }
        try? modelContext.save()
    }
}
