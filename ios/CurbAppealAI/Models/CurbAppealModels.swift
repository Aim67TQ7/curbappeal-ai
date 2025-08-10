import Foundation

// MARK: - Core Models

struct CurbAppealCriteria: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let score: Int // 1-5
    let feedback: String
    let recommendations: [String]
    let costEstimate: CostEstimate
}

struct CostEstimate: Codable {
    let low: Int
    let medium: Int
    let high: Int
}

struct QuickAnalysis: Codable, Identifiable {
    let id: String
    let imageUrl: String
    let overallScore: Int // 1-50
    let percentage: Int // 0-100
    let criteria: [CurbAppealCriteria]
    let summary: String
    let createdAt: String
    let userId: String?
}

struct DetailedAnalysis: Codable, Identifiable {
    let id: String
    let imageUrl: String
    let overallScore: Int
    let percentage: Int
    let criteria: [CurbAppealCriteria]
    let summary: String
    let createdAt: String
    let userId: String?
    let additionalImages: [String]
    let marketInsights: MarketInsights
    let priorityMatrix: PriorityMatrix
    let timeline: Timeline
    let contractorRecommendations: [ContractorRecommendation]
}

struct MarketInsights: Codable {
    let averageHomeValue: Int
    let potentialValueIncrease: Int
    let timeOnMarketReduction: String
    let competitiveAnalysis: String
}

struct PriorityMatrix: Codable {
    let highImpact: [String]
    let mediumImpact: [String]
    let lowImpact: [String]
}

struct Timeline: Codable {
    let immediate: [String] // 0-1 week
    let shortTerm: [String] // 1-4 weeks
    let mediumTerm: [String] // 1-3 months
    let longTerm: [String] // 3+ months
}

struct ContractorRecommendation: Codable, Identifiable {
    let id = UUID()
    let category: String
    let estimatedCost: Int
    let timeframe: String
    let description: String
    let priority: Priority
    
    enum Priority: String, Codable, CaseIterable {
        case high, medium, low
    }
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String?
    let userType: UserType
    let subscriptionTier: SubscriptionTier
    let createdAt: String
    
    enum UserType: String, Codable, CaseIterable {
        case homeowner, realtor, investor, contractor
    }
    
    enum SubscriptionTier: String, Codable, CaseIterable {
        case free, premium, professional
    }
}

struct AnalysisRequest: Codable {
    let userId: String?
    let email: String?
    let images: [Data]
    let propertyType: PropertyType
    let location: Location?
    let analysisType: AnalysisType
    
    enum PropertyType: String, Codable, CaseIterable {
        case singleFamily = "single_family"
        case townhouse, condo, apartment, commercial
    }
    
    enum AnalysisType: String, Codable, CaseIterable {
        case quick, detailed
    }
}

struct Location: Codable {
    let address: String?
    let city: String
    let state: String
    let zipCode: String
}

// MARK: - UI State Models

enum AnalysisState {
    case idle
    case uploading
    case analyzing
    case completed(QuickAnalysis)
    case error(String)
}

enum CameraState {
    case notAuthorized
    case configuring
    case ready
    case capturing
    case processing
}

// MARK: - Constants

struct CriteriaDefinitions {
    static let definitions: [Int: (name: String, description: String, factors: [String])] = [
        1: (
            name: "Landscaping & Gardens",
            description: "Lawn condition, garden beds, tree maintenance, seasonal plantings",
            factors: ["Lawn health and coverage", "Garden bed design and maintenance", "Tree and shrub condition", "Seasonal color and appeal", "Weed control and edging"]
        ),
        2: (
            name: "Roofing Condition", 
            description: "Roof material, gutters, chimneys, overall structural appearance",
            factors: ["Roof material condition", "Gutter cleanliness and alignment", "Chimney condition", "Missing or damaged elements", "Overall structural integrity appearance"]
        ),
        3: (
            name: "Exterior Paint & Siding",
            description: "Paint condition, siding maintenance, color coordination", 
            factors: ["Paint freshness and coverage", "Siding condition and cleanliness", "Color coordination and appeal", "Trim and detail work", "Weather damage assessment"]
        ),
        4: (
            name: "Front Porch/Entry",
            description: "Entry door, porch condition, welcome appeal, accessibility",
            factors: ["Entry door condition and style", "Porch or entryway appeal", "Welcome elements (mat, plantings)", "Lighting and visibility", "Accessibility and approach"]
        ),
        5: (
            name: "Windows & Shutters",
            description: "Window condition, shutters, trim, cleanliness",
            factors: ["Window cleanliness and condition", "Shutter condition and style", "Window trim and framing", "Symmetry and proportion", "Screen condition"]
        ),
        6: (
            name: "Driveway & Walkways",
            description: "Pavement condition, walkway appeal, accessibility",
            factors: ["Driveway surface condition", "Walkway condition and safety", "Edging and definition", "Staining and cleanliness", "Accessibility and flow"]
        ),
        7: (
            name: "Lighting & Fixtures",
            description: "Exterior lighting, fixtures, safety, ambiance",
            factors: ["Fixture style and condition", "Lighting adequacy", "Safety and security lighting", "Aesthetic appeal", "Energy efficiency appearance"]
        ),
        8: (
            name: "Garage & Storage",
            description: "Garage door, storage visibility, organization",
            factors: ["Garage door condition and style", "Storage organization visibility", "Integration with home design", "Functionality appearance", "Cleanliness and maintenance"]
        ),
        9: (
            name: "Fencing & Boundaries",
            description: "Fence condition, property boundaries, privacy elements",
            factors: ["Fence condition and style", "Property boundary definition", "Privacy and security elements", "Integration with landscape", "Maintenance and repair needs"]
        ),
        10: (
            name: "Overall Symmetry & Design",
            description: "Architectural harmony, proportions, cohesive design",
            factors: ["Architectural style consistency", "Proportional balance", "Color and material harmony", "Design flow and cohesion", "Neighborhood compatibility"]
        )
    ]
}