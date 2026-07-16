import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var placingObjectType: PlaceableObjectType = .ergonomicChair
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainDashboardView(onOpenARScanner: {
                withAnimation { selectedTab = 2 }
            })
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)
            
            DirectoryView(onPlaceItem: { item in
                placingObjectType = mapDeskItemToObjectType(item)
                withAnimation { selectedTab = 2 }
            })
            .tabItem {
                Label("Directory", systemImage: "folder.fill")
            }
            .tag(1)
            
            ARPlannerView(selectedObjectType: $placingObjectType)
                .tabItem {
                    Label("AR Studio", systemImage: "arkit")
                }
                .tag(2)
        }
        .accentColor(.blue)
    }
    
    private func mapDeskItemToObjectType(_ item: DeskItem) -> PlaceableObjectType {
        let name = item.name.lowercased()
        if name.contains("monitor") {
            return .monitor34
        } else if name.contains("vase") || name.contains("pot") || name.contains("plant") {
            return .plant
        } else if name.contains("organizer") || name.contains("case") || name.contains("pouch") {
            return .keyboard
        }
        return .ergonomicChair
    }
}

#Preview {
    ContentView()
}
