import SwiftUI
import Combine

public struct GestureGuideItem: Identifiable {
    public let id = UUID()
    public let imageName: String
    public let title: String
    public let description: String
    
    public init(imageName: String, title: String, description: String) {
        self.imageName = imageName
        self.title = title
        self.description = description
    }
}

public class GuideViewModel: ObservableObject {
    @Published var gestureItems: [GestureGuideItem] = [
        GestureGuideItem(imageName: "1finger", title: "Move Item", description: "Drag 1 finger to move the object on the desk surface."),
        GestureGuideItem(imageName: "2finger", title: "Rotate Item", description: "Twist 2 fingers to rotate the object on its axis."),
        GestureGuideItem(imageName: "3finger", title: "Adjust Height", description: "Drag 3 fingers up/down to set height or altitude offset.")
    ]
    
    public init() {}
}
