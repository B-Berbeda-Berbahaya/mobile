import SwiftUI

struct GuideStep {
    let imageURL: String
    let title: String
    let description: String
}

struct GuideObjectView: View {
    let onDismiss: (() -> Void)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let themeBrown = Color(red: 0.45, green: 0.38, blue: 0.28)

    @State private var currentIndex = 0
    @State private var slideEdge: Edge = .trailing

    var steps: [GuideStep] = []

    private var isCompact: Bool { horizontalSizeClass == .compact }
    private var frameWidth: CGFloat { isCompact ? 360 : 480 }
    private var frameHeight: CGFloat { isCompact ? 300 : 540 }
    private var imageWidth: CGFloat { isCompact ? frameWidth * 0.4 : frameWidth }

    var body: some View {
        if #available(iOS 26.0, *) {
            ZStack(alignment: .top) {

                Group {
                    if isCompact {
                        // Horizontal layout: image on left
                        HStack(alignment: .top) {
                            AsyncImage(url: URL(string: steps[currentIndex].imageURL)!) { image in
                                image.image?
                                    .resizable()
                                    .scaledToFit()
                            }
                            .clipShape(.rect(cornerRadius: 16))
                            .frame(width: imageWidth)
                            .frame(maxHeight: .infinity, alignment: .top)

                            VStack(alignment: .leading) {
                                Text(steps[currentIndex].title)
                                    .font(.title2)
                                    .fontWeight(.semibold)

                                Text(steps[currentIndex].description)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Button {
                                    if currentIndex == steps.count - 1 {
                                        onDismiss()
                                    } else {
                                        slideEdge = .trailing
                                        withAnimation(.easeInOut) { currentIndex += 1 }
                                    }
                                } label: {
                                    Text(currentIndex == steps.count - 1 ? "I'm understood" : "Continue")
                                        .padding(4)
                                }
                                .tint(.brown)
                                .buttonStyle(.glassProminent)
                            }
                            .foregroundStyle(Color.primary)
                            .padding(.leading, 8)
                        }
                        .padding()
                        .id(currentIndex)
                        .transition(.move(edge: slideEdge).combined(with: .opacity))

                    } else {
                        // Original vertical layout
                        VStack(alignment: .center) {
                            VStack {
                                AsyncImage(url: URL(string: steps[currentIndex].imageURL)!) { image in
                                    image.image?
                                        .resizable()
                                        .scaledToFit()
                                }
                                .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
                                .frame(width: imageWidth)
                                .frame(maxHeight: 308, alignment: .top)

                                Group {
                                    Text(steps[currentIndex].title)
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)

                                    Text(steps[currentIndex].description)
                                        .multilineTextAlignment(.center)
                                }
                                .foregroundStyle(Color.primary)

                                Spacer()
                            }
                            .id(currentIndex)
                            .transition(.move(edge: slideEdge).combined(with: .opacity))

                            Spacer()

                            Button {
                                if currentIndex == steps.count - 1 {
                                    onDismiss()
                                } else {
                                    slideEdge = .trailing
                                    withAnimation(.easeInOut) { currentIndex += 1 }
                                }
                            } label: {
                                Text(currentIndex == steps.count - 1 ? "I'm understood" : "Continue")
                                    .padding(4)
                            }
                            .tint(.brown)
                            .buttonStyle(.glassProminent)
                        }
                        .padding(.bottom, 24)
                    }
                }

                // Back button
                HStack {
                    if currentIndex > 0 {
                        Button {
                            slideEdge = .leading
                            withAnimation(.easeInOut) { currentIndex -= 1 }
                        } label: {
                            Image(systemName: "chevron.left").padding(8)
                        }
                        .buttonBorderShape(.circle)
                        .buttonStyle(.glass)
                    }
                    Spacer()
                }
                .padding(16)
            }
            .frame(width: frameWidth, height: frameHeight)
            .background(.thinMaterial, in: .rect(cornerRadius: 16))
            .clipped()

        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        AsyncImage(
            url: URL(string: "https://picsum.photos/seed/picsum/200/300")
        ) { image in
            image.image?.resizable()
        }

        GuideObjectView(onDismiss: {}, steps: [
            GuideStep(imageURL: "https://picsum.photos/seed/picsum/480/300", title: "scan", description: "scan description"),
            GuideStep(imageURL: "https://picsum.photos/seed/picsum/480/300", title: "place", description: "place description"),
        ])
    }
}
