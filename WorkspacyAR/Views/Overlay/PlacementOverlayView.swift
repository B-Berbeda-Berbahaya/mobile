import SwiftUI

// Overlay UI drawn on top of the AR camera feed.
// Responsibility: reticle/crosshair indicator, object type picker,
// place button, and session status indicator. Purely presentational —
// reads/writes through PlacementOverlayViewModel.

struct PlacementOverlayView: View {

    // TODO: @StateObject private var viewModel = PlacementOverlayViewModel()

    var body: some View {
        // TODO: VStack {
        //     Spacer()
        //     objectPicker
        //     placeButton
        // }
        EmptyView()
    }
}
