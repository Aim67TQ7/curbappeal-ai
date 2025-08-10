// Shared types for CurbAppeal AI application

export interface CurbAppealCriteria {
  id: number
  name: string
  description: string
  score: number // 1-5
  feedback: string
  recommendations: string[]
  costEstimate: {
    low: number
    medium: number
    high: number
  }
}

export interface QuickAnalysis {
  id: string
  imageUrl: string
  overallScore: number // 1-50
  percentage: number // 0-100
  criteria: CurbAppealCriteria[]
  summary: string
  createdAt: string
  userId?: string
}

export interface DetailedAnalysis extends QuickAnalysis {
  additionalImages: string[]
  marketInsights: {
    averageHomeValue: number
    potentialValueIncrease: number
    timeOnMarketReduction: string
    competitiveAnalysis: string
  }
  priorityMatrix: {
    highImpact: string[]
    mediumImpact: string[]
    lowImpact: string[]
  }
  timeline: {
    immediate: string[] // 0-1 week
    shortTerm: string[] // 1-4 weeks  
    mediumTerm: string[] // 1-3 months
    longTerm: string[] // 3+ months
  }
  contractorRecommendations: ContractorRecommendation[]
}

export interface ContractorRecommendation {
  category: string
  estimatedCost: number
  timeframe: string
  description: string
  priority: 'high' | 'medium' | 'low'
}

export interface User {
  id: string
  email: string
  fullName?: string
  userType: 'homeowner' | 'realtor' | 'investor' | 'contractor'
  subscriptionTier: 'free' | 'premium' | 'professional'
  createdAt: string
}

export interface AnalysisRequest {
  userId?: string
  email?: string
  images: File[]
  propertyType: 'single_family' | 'townhouse' | 'condo' | 'apartment' | 'commercial'
  location?: {
    address?: string
    city: string
    state: string
    zipCode: string
  }
  analysisType: 'quick' | 'detailed'
}

export interface AnalysisReport {
  id: string
  userId: string
  analysisId: string
  reportType: 'quick' | 'detailed'
  pdfUrl: string
  generatedAt: string
  status: 'generating' | 'completed' | 'failed'
}

export const CRITERIA_DEFINITIONS: Record<number, { name: string; description: string; factors: string[] }> = {
  1: {
    name: 'Landscaping & Gardens',
    description: 'Lawn condition, garden beds, tree maintenance, seasonal plantings',
    factors: ['Lawn health and coverage', 'Garden bed design and maintenance', 'Tree and shrub condition', 'Seasonal color and appeal', 'Weed control and edging']
  },
  2: {
    name: 'Roofing Condition',
    description: 'Roof material, gutters, chimneys, overall structural appearance',
    factors: ['Roof material condition', 'Gutter cleanliness and alignment', 'Chimney condition', 'Missing or damaged elements', 'Overall structural integrity appearance']
  },
  3: {
    name: 'Exterior Paint & Siding',
    description: 'Paint condition, siding maintenance, color coordination',
    factors: ['Paint freshness and coverage', 'Siding condition and cleanliness', 'Color coordination and appeal', 'Trim and detail work', 'Weather damage assessment']
  },
  4: {
    name: 'Front Porch/Entry',
    description: 'Entry door, porch condition, welcome appeal, accessibility',
    factors: ['Entry door condition and style', 'Porch or entryway appeal', 'Welcome elements (mat, plantings)', 'Lighting and visibility', 'Accessibility and approach']
  },
  5: {
    name: 'Windows & Shutters',
    description: 'Window condition, shutters, trim, cleanliness',
    factors: ['Window cleanliness and condition', 'Shutter condition and style', 'Window trim and framing', 'Symmetry and proportion', 'Screen condition']
  },
  6: {
    name: 'Driveway & Walkways',
    description: 'Pavement condition, walkway appeal, accessibility',
    factors: ['Driveway surface condition', 'Walkway condition and safety', 'Edging and definition', 'Staining and cleanliness', 'Accessibility and flow']
  },
  7: {
    name: 'Lighting & Fixtures',
    description: 'Exterior lighting, fixtures, safety, ambiance',
    factors: ['Fixture style and condition', 'Lighting adequacy', 'Safety and security lighting', 'Aesthetic appeal', 'Energy efficiency appearance']
  },
  8: {
    name: 'Garage & Storage',
    description: 'Garage door, storage visibility, organization',
    factors: ['Garage door condition and style', 'Storage organization visibility', 'Integration with home design', 'Functionality appearance', 'Cleanliness and maintenance']
  },
  9: {
    name: 'Fencing & Boundaries',
    description: 'Fence condition, property boundaries, privacy elements',
    factors: ['Fence condition and style', 'Property boundary definition', 'Privacy and security elements', 'Integration with landscape', 'Maintenance and repair needs']
  },
  10: {
    name: 'Overall Symmetry & Design',
    description: 'Architectural harmony, proportions, cohesive design',
    factors: ['Architectural style consistency', 'Proportional balance', 'Color and material harmony', 'Design flow and cohesion', 'Neighborhood compatibility']
  }
}

export interface AIAnalysisPrompt {
  systemPrompt: string
  userPrompt: string
  images: string[] // base64 encoded images
  analysisType: 'quick' | 'detailed'
}

export interface APIResponse<T = any> {
  success: boolean
  data?: T
  error?: string
  message?: string
}

// Store interface using Zustand
export interface AppStore {
  // Current analysis state
  currentAnalysis: QuickAnalysis | DetailedAnalysis | null
  isAnalyzing: boolean
  analysisError: string | null
  
  // User state
  user: User | null
  isAuthenticated: boolean
  
  // UI state
  showEmailCapture: boolean
  currentStep: 'upload' | 'analyzing' | 'results' | 'email' | 'detailed'
  
  // Actions
  setCurrentAnalysis: (analysis: QuickAnalysis | DetailedAnalysis | null) => void
  setIsAnalyzing: (analyzing: boolean) => void
  setAnalysisError: (error: string | null) => void
  setUser: (user: User | null) => void
  setShowEmailCapture: (show: boolean) => void
  setCurrentStep: (step: AppStore['currentStep']) => void
  reset: () => void
}

export interface EmailCaptureData {
  email: string
  fullName?: string
  userType: User['userType']
  marketingOptIn: boolean
}

export interface CostEstimate {
  category: string
  lowEnd: number
  highEnd: number
  description: string
  priority: 'immediate' | 'short_term' | 'medium_term' | 'long_term'
}