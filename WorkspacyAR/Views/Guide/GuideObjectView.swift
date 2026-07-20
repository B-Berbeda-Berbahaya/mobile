import SwiftUI

struct GuideStep {
    let imageURL: String
    let title: String
    let description: String
}

struct GuideObjectView: View {
    let onDismiss: (() -> Void)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let themeBrown = Color(red: 0.45, green: 0.38, blue: 0.28)

    @State private var currentIndex = 0
    @State private var slideEdge: Edge = .trailing

    var steps: [GuideStep] = []

    var body: some View {
        if #available(iOS 26.0, *) {
            ZStack(alignment: .top) {

                VStack(alignment: .center) {
                    VStack {
                        AsyncImage(
                            url: URL(
                                string: steps[currentIndex].imageURL
                            )!
                        ) { image in
                            image
                                .image?
                                .resizable()
                                .scaledToFit()
                        }
                        .clipShape(
                            .rect(topLeadingRadius: 16, topTrailingRadius: 16)
                        )
                        .frame(width: 480)
                        .frame(maxHeight: 308, alignment: .top)

                        Group {
                            Text(steps[currentIndex].title)
                                .font(Font.largeTitle)
                                .fontWeight(.semibold)

                            Text(
                                """
                                \(steps[currentIndex].description)
                                """
                            )
                            .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(Color.primary)

                        Spacer()
                    }
                    .id(currentIndex)
                    .transition(.move(edge: slideEdge).combined(with: .opacity))

                    Spacer()

                    // Continue button
                    Button {
                        if currentIndex == steps.count - 1 {
                            onDismiss()
                        } else {
                            slideEdge = .trailing
                            withAnimation(.easeInOut) {
                                currentIndex += 1
                            }
                        }

                    } label: {
                        Text(currentIndex == steps.count - 1 ? "I'm understood" : "Continue")
                                .padding(4)
                    }
                    .tint(.brown)
                    .buttonStyle(.glassProminent)
                }
                .padding(.bottom, 24)

                // Bcak button
                HStack {
                    if currentIndex > 0 {
                        Button {
                            slideEdge = .leading
                            withAnimation(.easeInOut) {
                                currentIndex -= 1
                            }
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
            .frame(width: 480, height: 540)
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

        GuideObjectView(onDismiss: {}, steps: [GuideStep(imageURL: "https://picsum.photos/seed/picsum/480/300", title: "scan", description: "scan description")])
    }
}
