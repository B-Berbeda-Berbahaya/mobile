import SwiftUI

// Optional debug overlay to visualize active/occupied grid cells
// on screen. Only enabled when AppState.showDebugGrid is true.
// Responsibility: purely visual, reads grid cell data — no mutation.

struct GridDebugOverlayView: View {

    // TODO: let gridSystem: GridSystem

    var body: some View {
        // TODO: draw markers/outlines for each tracked GridCoordinate
        EmptyView()
    }
}
