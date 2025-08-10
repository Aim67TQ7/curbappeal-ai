import type { QuickAnalysis, CurbAppealCriteria, DetailedAnalysis } from '../../../shared/types'
import { CRITERIA_DEFINITIONS } from '../../../shared/types'

// Convert file to base64
const fileToBase64 = (file: File): Promise<string> => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.readAsDataURL(file)
    reader.onload = () => {
      const base64 = reader.result as string
      // Remove data URL prefix to get just the base64 string
      resolve(base64.split(',')[1])
    }
    reader.onerror = error => reject(error)
  })
}

// Mock AI analysis for development
const mockAnalyzeImage = async (file: File): Promise<QuickAnalysis> => {
  // Simulate processing delay
  await new Promise(resolve => setTimeout(resolve, 3000))

  const base64Image = await fileToBase64(file)
  const imageUrl = URL.createObjectURL(file)

  // Generate mock scores (in production, this would be AI-generated)
  const criteria: CurbAppealCriteria[] = Object.keys(CRITERIA_DEFINITIONS).map(id => {
    const criteriaId = parseInt(id)
    const score = Math.floor(Math.random() * 3) + 2 // 2-4 for realistic variation
    const definition = CRITERIA_DEFINITIONS[criteriaId]
    
    return {
      id: criteriaId,
      name: definition.name,
      description: definition.description,
      score,
      feedback: generateMockFeedback(definition.name, score),
      recommendations: generateMockRecommendations(definition.name, score),
      costEstimate: generateMockCostEstimate(definition.name, score)
    }
  })

  const overallScore = criteria.reduce((sum, c) => sum + c.score, 0)
  const percentage = Math.round((overallScore / 50) * 100)

  const analysis: QuickAnalysis = {
    id: `analysis_${Date.now()}`,
    imageUrl,
    overallScore,
    percentage,
    criteria,
    summary: generateOverallSummary(percentage),
    createdAt: new Date().toISOString()
  }

  return analysis
}

const generateMockFeedback = (category: string, score: number): string => {
  const feedbacks = {
    'Landscaping & Gardens': {
      5: 'Exceptional landscaping with lush, well-maintained gardens and pristine lawn care.',
      4: 'Very attractive landscaping with good plant variety and lawn maintenance.',
      3: 'Decent landscaping but could benefit from more color and better edging.',
      2: 'Basic landscaping with some maintenance issues and sparse plantings.',
      1: 'Significant landscaping problems requiring major improvements.'
    },
    'Roofing Condition': {
      5: 'Roof appears to be in excellent condition with clean gutters and proper maintenance.',
      4: 'Good roof condition with minor maintenance needs.',
      3: 'Acceptable roof condition but some cleaning or minor repairs may be needed.',
      2: 'Visible wear on roofing materials or gutters requiring attention.',
      1: 'Significant roofing issues that need immediate professional attention.'
    },
    'Exterior Paint & Siding': {
      5: 'Fresh, high-quality paint and siding in excellent condition throughout.',
      4: 'Good paint condition with attractive color choices and well-maintained siding.',
      3: 'Paint and siding are acceptable but showing some age and minor wear.',
      2: 'Paint is fading or chipping in places, siding needs attention.',
      1: 'Significant paint and siding issues requiring major renovation.'
    }
    // Add more categories as needed
  }

  const categoryFeedback = feedbacks[category as keyof typeof feedbacks]
  if (categoryFeedback) {
    return categoryFeedback[score as keyof typeof categoryFeedback] || 
           `${category} scored ${score}/5 and could benefit from improvements.`
  }
  
  return `${category} scored ${score}/5. ${score >= 4 ? 'Excellent condition' : score >= 3 ? 'Good condition but room for improvement' : 'Needs attention and improvements'}.`
}

const generateMockRecommendations = (category: string, score: number): string[] => {
  const recommendations = {
    'Landscaping & Gardens': [
      'Add seasonal flowering plants for year-round color',
      'Install proper edging around garden beds',
      'Improve lawn health with fertilization and overseeding',
      'Add mulch to garden beds',
      'Trim and shape existing shrubs'
    ],
    'Roofing Condition': [
      'Clean gutters and inspect for proper drainage',
      'Power wash roof to remove stains and debris',
      'Replace any missing or damaged shingles',
      'Check and seal around chimneys and vents',
      'Consider roof coating for extended life'
    ],
    'Exterior Paint & Siding': [
      'Pressure wash exterior surfaces',
      'Touch up paint on trim and accent areas',
      'Consider a fresh coat of paint in updated colors',
      'Repair or replace damaged siding sections',
      'Caulk around windows and doors'
    ]
  }

  const categoryRecs = recommendations[category as keyof typeof recommendations] || [
    `Improve ${category.toLowerCase()} condition`,
    'Consider professional consultation',
    'Regular maintenance schedule'
  ]

  // Return fewer recommendations for higher scores
  const numRecs = score >= 4 ? 2 : score >= 3 ? 3 : 4
  return categoryRecs.slice(0, numRecs)
}

const generateMockCostEstimate = (category: string, score: number) => {
  // Higher scores = lower cost improvements needed
  const multiplier = score >= 4 ? 0.3 : score >= 3 ? 0.6 : 1.0
  
  const baseCosts = {
    'Landscaping & Gardens': { low: 500, high: 5000 },
    'Roofing Condition': { low: 300, high: 3000 },
    'Exterior Paint & Siding': { low: 800, high: 8000 },
    'Front Porch/Entry': { low: 200, high: 2000 },
    'Windows & Shutters': { low: 300, high: 1500 },
    'Driveway & Walkways': { low: 400, high: 4000 },
    'Lighting & Fixtures': { low: 150, high: 1000 },
    'Garage & Storage': { low: 200, high: 2000 },
    'Fencing & Boundaries': { low: 300, high: 3000 },
    'Overall Symmetry & Design': { low: 100, high: 1000 }
  }

  const base = baseCosts[category as keyof typeof baseCosts] || { low: 200, high: 2000 }
  
  return {
    low: Math.round(base.low * multiplier),
    medium: Math.round((base.low + base.high) / 2 * multiplier),
    high: Math.round(base.high * multiplier)
  }
}

const generateOverallSummary = (percentage: number): string => {
  if (percentage >= 85) {
    return "Outstanding curb appeal! Your home presents beautifully and should attract buyers immediately. Focus on maintaining this excellent condition."
  } else if (percentage >= 70) {
    return "Great curb appeal with strong market presence. A few targeted improvements could make your home truly exceptional and maximize its value."
  } else if (percentage >= 55) {
    return "Good foundation with solid potential. Several key improvements would significantly boost your home's market appeal and help it stand out."
  } else if (percentage >= 40) {
    return "Your home has potential but needs focused attention. Strategic improvements in key areas will dramatically transform its curb appeal."
  } else {
    return "Significant opportunity to transform your home's curb appeal. With the right improvements, you can dramatically increase both appeal and value."
  }
}

// Production AI analysis using OpenAI
const productionAnalyzeImage = async (file: File): Promise<QuickAnalysis> => {
  const base64Image = await fileToBase64(file)
  
  const systemPrompt = `You are a professional curb appeal analyst and real estate expert. Analyze home exterior photos and provide detailed assessments across 10 key criteria. Rate each criteria on a 1-5 scale where:
  1 = Poor condition, major improvements needed
  2 = Below average, several improvements needed  
  3 = Average condition, some improvements beneficial
  4 = Good condition, minor improvements would help
  5 = Excellent condition, maintain current state

  The 10 criteria are:
  1. Landscaping & Gardens
  2. Roofing Condition
  3. Exterior Paint & Siding
  4. Front Porch/Entry
  5. Windows & Shutters
  6. Driveway & Walkways
  7. Lighting & Fixtures
  8. Garage & Storage
  9. Fencing & Boundaries
  10. Overall Symmetry & Design

  Provide specific, actionable feedback and improvement recommendations for each criteria.`

  const userPrompt = `Please analyze this home exterior image and provide a comprehensive curb appeal assessment. For each of the 10 criteria, provide:
  - A score from 1-5
  - Specific feedback about what you observe
  - 3-5 actionable improvement recommendations
  - Cost estimate ranges (low/medium/high budget options)
  
  Also provide an overall summary that's positive in tone but gives direct, helpful guidance.`

  try {
    const response = await fetch('/api/analyze-image', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        image: base64Image,
        systemPrompt,
        userPrompt
      })
    })

    if (!response.ok) {
      throw new Error('Analysis failed')
    }

    const result = await response.json()
    return result.analysis
  } catch (error) {
    console.error('Production analysis failed, falling back to mock:', error)
    return mockAnalyzeImage(file)
  }
}

// Export the main analysis function
export const analyzeImage = async (file: File): Promise<QuickAnalysis> => {
  // Use mock analysis for development, production analysis when API is available
  const useMock = !import.meta.env.VITE_OPENAI_API_KEY || import.meta.env.DEV
  
  if (useMock) {
    return mockAnalyzeImage(file)
  } else {
    return productionAnalyzeImage(file)
  }
}