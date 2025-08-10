import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedAnalysis: QuickAnalysis?
    
    var body: some View {
        NavigationView {
            Group {
                if appViewModel.recentAnalyses.isEmpty {
                    emptyStateView
                } else {
                    analysesList
                }
            }
            .navigationTitle("Your Results")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedAnalysis) { analysis in
            AnalysisDetailView(analysis: analysis)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Analyses Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Take a photo of your home to get started with your first curb appeal analysis")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            Button(action: {
                // Switch to camera tab
            }) {
                Text("Start Analysis")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    private var analysesList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(appViewModel.recentAnalyses) { analysis in
                    AnalysisRowView(analysis: analysis) {
                        selectedAnalysis = analysis
                    }
                }
            }
            .padding()
        }
    }
}

struct AnalysisRowView: View {
    let analysis: QuickAnalysis
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Score circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(analysis.percentage) / 100)
                        .stroke(scoreColor, lineWidth: 3)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(analysis.percentage)%")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("\(analysis.score)/50")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Analysis details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Curb Appeal Analysis")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(scoreLabel)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(scoreColor)
                    }
                    
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(analysis.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var scoreColor: Color {
        switch analysis.percentage {
        case 80...: return .green
        case 60..<80: return .yellow
        case 40..<60: return .orange
        default: return .red
        }
    }
    
    private var scoreLabel: String {
        switch analysis.percentage {
        case 80...: return "Excellent"
        case 60..<80: return "Good"
        case 40..<60: return "Fair"
        default: return "Needs Work"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        if let date = ISO8601DateFormatter().date(from: analysis.createdAt) {
            return formatter.string(from: date)
        }
        return "Recent"
    }
}

struct AnalysisDetailView: View {
    let analysis: QuickAnalysis
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with score
                    VStack(spacing: 16) {
                        ScoreDisplayView(
                            score: analysis.overallScore,
                            percentage: analysis.percentage,
                            size: .large
                        )
                        
                        Text(analysis.summary)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Criteria breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detailed Breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(analysis.criteria) { criterion in
                                CriterionCard(criterion: criterion)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Priority recommendations
                    let priorityCriteria = analysis.criteria.filter { $0.score <= 3 }.sorted { $0.score < $1.score }
                    
                    if !priorityCriteria.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Priority Improvements")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(priorityCriteria.prefix(3)) { criterion in
                                PriorityRecommendationCard(criterion: criterion)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            // Get detailed report
                        }) {
                            Text("Get Professional Report ($9.99)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Share analysis
                        }) {
                            Text("Share Results")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Analysis Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CriterionCard: View {
    let criterion: CurbAppealCriteria
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(criterion.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Spacer()
                
                Text("\(criterion.score)/5")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(scoreColor.opacity(0.2))
                    .cornerRadius(8)
            }
            
            HStack {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: index < criterion.score ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundColor(index < criterion.score ? .yellow : .gray)
                }
            }
            
            Text(criterion.feedback)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
    
    private var scoreColor: Color {
        switch criterion.score {
        case 4...5: return .green
        case 3: return .yellow
        case 2: return .orange
        default: return .red
        }
    }
}

struct PriorityRecommendationCard: View {
    let criterion: CurbAppealCriteria
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(criterion.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Score: \(criterion.score)/5")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(criterion.feedback)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Quick Improvements:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                ForEach(Array(criterion.recommendations.prefix(3).enumerated()), id: \.offset) { index, recommendation in
                    HStack(alignment: .top) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text(recommendation)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            
            HStack {
                Text("Est. Cost:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("$\(criterion.costEstimate.low) - $\(criterion.costEstimate.high)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
            .environmentObject(AppViewModel())
    }
}