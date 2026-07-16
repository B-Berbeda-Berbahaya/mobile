import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    let themeBrown = Color(red: 0.45, green: 0.38, blue: 0.28)
    
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
        .accentColor(themeBrown)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToDashboard"))) { _ in
            withAnimation {
                selectedTab = 0
            }
        }
    }
}

#Preview {
    ContentView()
}
