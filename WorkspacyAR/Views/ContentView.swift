import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainDashboardView(onOpenARScanner: {
                withAnimation { selectedTab = 1 }
            })
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)
            
            ARPlannerView()
                .tabItem {
                    Label("AR Studio", systemImage: "arkit")
                }
                .tag(1)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
}
