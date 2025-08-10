// Helper functions for Claude web automation testing
export const waitForAnalysisComplete = async (): Promise<Element | null> => {
  return new Promise((resolve) => {
    const checkInterval = setInterval(() => {
      const resultsElement = document.querySelector('.score-display')
      if (resultsElement) {
        clearInterval(checkInterval)
        resolve(resultsElement)
      }
    }, 1000)
    
    // Timeout after 60 seconds
    setTimeout(() => {
      clearInterval(checkInterval)
      resolve(null)
    }, 60000)
  })
}

export const getUploadElements = () => {
  return {
    fileInput: document.querySelector('input[type="file"]') as HTMLInputElement,
    dropZone: document.querySelector('[data-testid="dropzone"]') as HTMLElement,
    uploadButton: document.querySelector('button[type="submit"]') as HTMLButtonElement
  }
}

export const getAnalysisResults = () => {
  return {
    scoreDisplay: document.querySelector('.score-display') as HTMLElement,
    scorePercentage: document.querySelector('.score-percentage')?.textContent,
    scoreRating: document.querySelector('.score-rating')?.textContent,
    criteriaScores: Array.from(document.querySelectorAll('.criteria-item')).map(item => ({
      name: item.querySelector('.criteria-name')?.textContent,
      score: item.querySelector('.criteria-score')?.textContent
    }))
  }
}

export const waitForPageLoad = async (selector: string): Promise<boolean> => {
  return new Promise((resolve) => {
    const observer = new MutationObserver(() => {
      if (document.querySelector(selector)) {
        observer.disconnect()
        resolve(true)
      }
    })
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    })
    
    // If element already exists
    if (document.querySelector(selector)) {
      observer.disconnect()
      resolve(true)
    }
    
    // Timeout after 30 seconds
    setTimeout(() => {
      observer.disconnect()
      resolve(false)
    }, 30000)
  })
}

// Automation test scenarios
export const testScenarios = {
  homepage: {
    url: 'http://localhost:5179',
    selectors: {
      heroSection: '[data-testid="hero-section"]',
      uploadButton: '[data-testid="upload-button"]',
      featuresSection: '[data-testid="features"]'
    }
  },
  analysis: {
    url: 'http://localhost:5179/analyze',
    selectors: {
      fileInput: 'input[type="file"]',
      dropZone: '[data-testid="dropzone"]',
      analyzeButton: '[data-testid="analyze-button"]'
    }
  },
  results: {
    selectors: {
      scoreDisplay: '.score-display',
      criteriaGrid: '[data-testid="criteria-grid"]',
      emailForm: '[data-testid="email-form"]'
    }
  }
}