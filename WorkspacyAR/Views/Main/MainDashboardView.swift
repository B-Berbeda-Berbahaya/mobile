import SwiftUI

struct MainDashboardView: View {
    // Callback to open AR Designer tab
    var onOpenARScanner: (() -> Void)? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Profile Section
                DashboardHeaderView()
                
                // Ergonomics Circular Ring Score Card
                ErgonomicsScoreCard()
                    .padding(.horizontal)
                
                // Launch AR Action Card (Highlighted Card)
                LaunchARCard(onAction: {
                    onOpenARScanner?()
                })
                .padding(.horizontal)
                
                // Recent Designs horizontal carousel
                RecentDesignsCarousel()
                
                // Ergonomic Quick Tip Card
                QuickTipWidget()
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Small Sub-component: Dashboard Header
struct DashboardHeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("WORKSPACE MONITOR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .tracking(1.5)
                
                Text("Hi, Ady")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
            }
            
            Spacer()
            
            // Profile Circular Icon
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 46, height: 46)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// Small Sub-component: Quick tip summary box
struct QuickTipWidget: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                    .font(.subheadline)
                Text("Ergonomics Tip")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
            }
            
            Text("Keep your mouse and keyboard close to each other. Your wrists should stay parallel to the floor, and you should avoid resting them on the hard edges of your desk while typing.")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
    }
}

#Preview {
    MainDashboardView()
}
