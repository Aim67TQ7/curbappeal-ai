import UIKit
import Foundation

class AIService: ObservableObject {
    static let shared = AIService()
    
    private init() {}
    
    func analyzeImage(_ image: UIImage) async throws -> QuickAnalysis {
        // Convert image to data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIServiceError.imageProcessingFailed
        }
        
        // For now, use mock analysis - replace with actual API call
        return try await mockAnalyzeImage(imageData)
    }
    
    private func mockAnalyzeImage(_ imageData: Data) async throws -> QuickAnalysis {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Generate mock criteria scores
        let criteria = (1...10).map { id in
            let score = Int.random(in: 2...5) // Realistic scoring range
            let definition = CriteriaDefinitions.definitions[id]!
            
            return CurbAppealCriteria(
                id: id,
                name: definition.name,
                description: definition.description,
                score: score,
                feedback: generateMockFeedback(for: definition.name, score: score),
                recommendations: generateMockRecommendations(for: definition.name, score: score),
                costEstimate: generateMockCostEstimate(for: definition.name, score: score)
            )
        }
        
        let overallScore = criteria.reduce(0) { $0 + $1.score }
        let percentage = Int((Double(overallScore) / 50.0) * 100)
        
        return QuickAnalysis(
            id: "analysis_\(Int(Date().timeIntervalSince1970))",
            imageUrl: "", // Would be uploaded image URL
            overallScore: overallScore,
            percentage: percentage,
            criteria: criteria,
            summary: generateOverallSummary(percentage: percentage),
            createdAt: ISO8601DateFormatter().string(from: Date()),
            userId: SupabaseManager.shared.currentUser?.id
        )
    }
    
    private func generateMockFeedback(for category: String, score: Int) -> String {
        let feedbackTemplates: [String: [Int: String]] = [
            "Landscaping & Gardens": [
                5: "Exceptional landscaping with lush, well-maintained gardens and pristine lawn care.",
                4: "Very attractive landscaping with good plant variety and lawn maintenance.", 
                3: "Decent landscaping but could benefit from more color and better edging.",
                2: "Basic landscaping with some maintenance issues and sparse plantings.",
                1: "Significant landscaping problems requiring major improvements."
            ],
            "Roofing Condition": [
                5: "Roof appears to be in excellent condition with clean gutters and proper maintenance.",
                4: "Good roof condition with minor maintenance needs.",
                3: "Acceptable roof condition but some cleaning or minor repairs may be needed.",
                2: "Visible wear on roofing materials or gutters requiring attention.", 
                1: "Significant roofing issues that need immediate professional attention."
            ]
        ]
        
        if let categoryFeedback = feedbackTemplates[category],
           let feedback = categoryFeedback[score] {
            return feedback
        }
        
        switch score {
        case 5: return "\(category) is in excellent condition."
        case 4: return "\(category) is in good condition with minor room for improvement."
        case 3: return "\(category) is acceptable but could benefit from some attention."
        case 2: return "\(category) needs improvement and maintenance."
        default: return "\(category) requires significant attention and improvements."
        }
    }
    
    private func generateMockRecommendations(for category: String, score: Int) -> [String] {
        let recommendations: [String: [String]] = [
            "Landscaping & Gardens": [
                "Add seasonal flowering plants for year-round color",
                "Install proper edging around garden beds", 
                "Improve lawn health with fertilization and overseeding",
                "Add mulch to garden beds",
                "Trim and shape existing shrubs"
            ],
            "Roofing Condition": [
                "Clean gutters and inspect for proper drainage",
                "Power wash roof to remove stains and debris",
                "Replace any missing or damaged shingles", 
                "Check and seal around chimneys and vents",
                "Consider roof coating for extended life"
            ],
            "Exterior Paint & Siding": [
                "Pressure wash exterior surfaces",
                "Touch up paint on trim and accent areas",
                "Consider a fresh coat of paint in updated colors",
                "Repair or replace damaged siding sections",
                "Caulk around windows and doors"
            ]
        ]
        
        let categoryRecs = recommendations[category] ?? [
            "Improve \(category.lowercased()) condition",
            "Consider professional consultation", 
            "Regular maintenance schedule"
        ]
        
        let numRecs = score >= 4 ? 2 : score >= 3 ? 3 : 4
        return Array(categoryRecs.prefix(numRecs))
    }
    
    private func generateMockCostEstimate(for category: String, score: Int) -> CostEstimate {
        let baseCosts: [String: (low: Int, high: Int)] = [
            "Landscaping & Gardens": (500, 5000),
            "Roofing Condition": (300, 3000),
            "Exterior Paint & Siding": (800, 8000),
            "Front Porch/Entry": (200, 2000),
            "Windows & Shutters": (300, 1500),
            "Driveway & Walkways": (400, 4000),
            "Lighting & Fixtures": (150, 1000),
            "Garage & Storage": (200, 2000),
            "Fencing & Boundaries": (300, 3000),
            "Overall Symmetry & Design": (100, 1000)
        ]
        
        let base = baseCosts[category] ?? (200, 2000)
        let multiplier = score >= 4 ? 0.3 : score >= 3 ? 0.6 : 1.0
        
        let low = Int(Double(base.low) * multiplier)
        let high = Int(Double(base.high) * multiplier)
        let medium = (low + high) / 2
        
        return CostEstimate(low: low, medium: medium, high: high)
    }
    
    private func generateOverallSummary(percentage: Int) -> String {
        switch percentage {
        case 85...:
            return "Outstanding curb appeal! Your home presents beautifully and should attract buyers immediately. Focus on maintaining this excellent condition."
        case 70..<85:
            return "Great curb appeal with strong market presence. A few targeted improvements could make your home truly exceptional and maximize its value."
        case 55..<70:
            return "Good foundation with solid potential. Several key improvements would significantly boost your home's market appeal and help it stand out."
        case 40..<55:
            return "Your home has potential but needs focused attention. Strategic improvements in key areas will dramatically transform its curb appeal."
        default:
            return "Significant opportunity to transform your home's curb appeal. With the right improvements, you can dramatically increase both appeal and value."
        }
    }
}

enum AIServiceError: Error, LocalizedError {
    case imageProcessingFailed
    case networkError
    case analysisError(String)
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .networkError:
            return "Network connection error"
        case .analysisError(let message):
            return message
        }
    }
}