import SwiftUI

struct MainDashboardView: View {
    // Callback to open AR Designer tab
    var onOpenARScanner: (() -> Void)? = nil
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Header Profile Section
                DashboardHeaderView(username: viewModel.username)
                    .frame(maxWidth: 1000)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer(minLength: 12)
                
                if horizontalSizeClass == .regular {
                    // iPad / Widescreen: 2-Column Balanced layout with spacers
                    HStack(alignment: .top, spacing: 32) {
                        // Left Column (Interactive Studio Launch & Ergonomic Tip)
                        VStack(alignment: .leading, spacing: 16) {
                            LaunchARCard(onAction: {
                                onOpenARScanner?()
                            })
                            
                            Spacer(minLength: 16)
                            
                            QuickTipWidget(tipText: viewModel.currentTip)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right Column (Compliance score and Saved Designs)
                        VStack(alignment: .leading, spacing: 16) {
                            ErgonomicsScoreCard(score: viewModel.complianceScore)
                            
                            Spacer(minLength: 16)
                            
                            RecentDesignsCarousel(designs: viewModel.recentDesigns)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: 1000)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                } else {
                    // iPhone / Compact: Standard vertical stacking with spacers
                    VStack(alignment: .leading, spacing: 16) {
                        ErgonomicsScoreCard(score: viewModel.complianceScore)
                            .padding(.horizontal)
                        
                        Spacer(minLength: 12)
                        
                        // Launch AR Action Card
                        LaunchARCard(onAction: {
                            onOpenARScanner?()
                        })
                        .padding(.horizontal)
                        
                        Spacer(minLength: 12)
                        
                        // Recent Designs horizontal carousel
                        RecentDesignsCarousel(designs: viewModel.recentDesigns)
                        
                        Spacer(minLength: 12)
                        
                        // Ergonomic Quick Tip Card
                        QuickTipWidget(tipText: viewModel.currentTip)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Small Sub-component: Dashboard Header
struct DashboardHeaderView: View {
    let username: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("WORKSPACE WELLNESS")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(Color(red: 0.55, green: 0.48, blue: 0.38))
                    .tracking(2)
                
                Text("Hi, \(username)")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Profile Circular Icon with subtle frame
            ZStack {
                Circle()
                    .fill(Color(red: 0.45, green: 0.38, blue: 0.28).opacity(0.08))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.28))
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}

// Small Sub-component: Quick tip summary box styled like a catalog advice box
struct QuickTipWidget: View {
    let tipText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.28))
                    .font(.subheadline)
                
                Text("ERGONOMIC ADVICE")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(Color(red: 0.45, green: 0.38, blue: 0.28))
                    .tracking(1)
                
                Spacer()
            }
            
            Text(tipText)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.015), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    MainDashboardView()
}
