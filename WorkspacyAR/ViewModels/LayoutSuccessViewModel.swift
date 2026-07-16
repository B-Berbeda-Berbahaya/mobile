import SwiftUI
import Combine

public struct DiagnosticItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let rating: String
    public let description: String
    public let isOptimal: Bool
    
    public init(title: String, rating: String, description: String, isOptimal: Bool) {
        self.title = title
        self.rating = rating
        self.description = description
        self.isOptimal = isOptimal
    }
}

public class LayoutSuccessViewModel: ObservableObject {
    @Published var score: Int = 84
    @Published var diagnostics: [DiagnosticItem] = [
        DiagnosticItem(title: "Eye Gaze Level", rating: "Optimal", description: "Display is level with your seated eye height.", isOptimal: true),
        DiagnosticItem(title: "Wrist Extension", rating: "Comfortable", description: "Keyboard offset supports a flat wrist angle.", isOptimal: true),
        DiagnosticItem(title: "Seating Clearance", rating: "Pass", description: "Distance permits 90° leg flexion clearance.", isOptimal: true)
    ]
    
    public init() {}
}
