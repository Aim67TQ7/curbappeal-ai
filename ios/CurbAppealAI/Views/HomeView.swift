import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Quick Start Section
                    quickStartSection
                    
                    // Recent Analyses
                    if !appViewModel.recentAnalyses.isEmpty {
                        recentAnalysesSection
                    }
                    
                    // Features Section
                    featuresSection
                    
                    // Testimonials
                    testimonialsSection
                }
                .padding()
            }
            .navigationTitle("CurbAppeal AI")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Icon
            Image(systemName: "house.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding()
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                )
            
            VStack(spacing: 8) {
                Text("Maximize Your Home's")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Curb Appeal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Text("Get instant AI-powered analysis of your home's exterior with professional recommendations to increase market value.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private var quickStartSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "camera.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready to Start?")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Take a photo and get instant analysis")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                Button(action: {
                    // Switch to camera tab
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    private var recentAnalysesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Analyses")
                    .font(.headline)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to all analyses
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(appViewModel.recentAnalyses.prefix(5))) { analysis in
                        RecentAnalysisCard(analysis: analysis)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Features")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                FeatureCard(
                    icon: "timer",
                    title: "30-Second Analysis",
                    description: "Get instant professional assessment"
                )
                
                FeatureCard(
                    icon: "chart.bar.fill",
                    title: "10-Point Scoring",
                    description: "Comprehensive evaluation criteria"
                )
                
                FeatureCard(
                    icon: "doc.text.fill",
                    title: "Detailed Reports",
                    description: "Professional recommendations"
                )
                
                FeatureCard(
                    icon: "dollarsign.circle.fill",
                    title: "Cost Estimates",
                    description: "Budget-friendly improvements"
                )
            }
        }
    }
    
    private var testimonialsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What Users Say")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    TestimonialCard(
                        name: "Sarah J.",
                        role: "Homeowner",
                        text: "Helped me sell 3 weeks faster!",
                        rating: 5
                    )
                    
                    TestimonialCard(
                        name: "Mike R.",
                        role: "Realtor",
                        text: "Essential tool for my clients.",
                        rating: 5
                    )
                    
                    TestimonialCard(
                        name: "Jennifer C.",
                        role: "Investor",
                        text: "Accurate cost estimates.",
                        rating: 5
                    )
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct RecentAnalysisCard: View {
    let analysis: QuickAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Score Circle
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(analysis.percentage) / 100)
                        .stroke(scoreColor, lineWidth: 3)
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(analysis.percentage)%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            
            Text("Analysis")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 100)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    private var scoreColor: Color {
        if analysis.percentage >= 80 { return .green }
        if analysis.percentage >= 60 { return .yellow }
        if analysis.percentage >= 40 { return .orange }
        return .red
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let date = ISO8601DateFormatter().date(from: analysis.createdAt) {
            return formatter.string(from: date)
        }
        return "Recent"
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct TestimonialCard: View {
    let name: String
    let role: String
    let text: String
    let rating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ForEach(0..<rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
            
            Text("\"" + text + "\"")
                .font(.subheadline)
                .italic()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(role)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 180)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppViewModel())
    }
}