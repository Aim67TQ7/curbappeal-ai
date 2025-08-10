import { useState, useCallback } from 'react'
import { useDropzone } from 'react-dropzone'
import { useAppStore } from '../store/appStore'
import { useNavigate } from 'react-router-dom'
import { 
  CameraIcon, 
  CloudArrowUpIcon,
  PhotoIcon,
  ExclamationTriangleIcon,
  CheckCircleIcon
} from '@heroicons/react/24/outline'
import LoadingSpinner from '../components/LoadingSpinner'
import ScoreDisplay from '../components/ScoreDisplay'
import CriteriaGrid from '../components/CriteriaGrid'
import EmailCapture from '../components/EmailCapture'
import { analyzeImage } from '../services/aiService'

export default function AnalysisPage() {
  const navigate = useNavigate()
  const { 
    currentAnalysis, 
    isAnalyzing, 
    analysisError,
    currentStep,
    showEmailCapture,
    setCurrentAnalysis,
    setIsAnalyzing,
    setAnalysisError,
    setCurrentStep,
    setShowEmailCapture
  } = useAppStore()
  
  const [uploadedImage, setUploadedImage] = useState<string | null>(null)

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    const file = acceptedFiles[0]
    if (!file) return

    // Create preview
    const preview = URL.createObjectURL(file)
    setUploadedImage(preview)

    // Start analysis
    setIsAnalyzing(true)
    setAnalysisError(null)
    setCurrentStep('analyzing')

    try {
      const analysis = await analyzeImage(file)
      setCurrentAnalysis(analysis)
      setCurrentStep('results')
    } catch (error) {
      setAnalysisError(error instanceof Error ? error.message : 'Analysis failed')
      setCurrentStep('upload')
    } finally {
      setIsAnalyzing(false)
    }
  }, [setCurrentAnalysis, setIsAnalyzing, setAnalysisError, setCurrentStep])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.webp']
    },
    maxFiles: 1,
    maxSize: 10 * 1024 * 1024, // 10MB
  })

  const handleGetDetailedReport = () => {
    setShowEmailCapture(true)
    setCurrentStep('email')
  }

  const handleRestartAnalysis = () => {
    setCurrentAnalysis(null)
    setUploadedImage(null)
    setAnalysisError(null)
    setCurrentStep('upload')
    setShowEmailCapture(false)
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-4">
            Curb Appeal Analysis
          </h1>
          <p className="text-lg text-gray-600">
            Upload a photo of your home's exterior for instant AI-powered evaluation
          </p>
        </div>

        {/* Upload Section */}
        {currentStep === 'upload' && (
          <div className="card p-8 mb-8">
            <div 
              {...getRootProps()} 
              className={`upload-area cursor-pointer ${isDragActive ? 'dragover' : ''}`}
            >
              <input {...getInputProps()} />
              <div className="flex flex-col items-center">
                <CloudArrowUpIcon className="w-16 h-16 text-gray-400 mb-4" />
                <h3 className="text-xl font-semibold text-gray-900 mb-2">
                  {isDragActive ? 'Drop your photo here' : 'Upload Your Home Photo'}
                </h3>
                <p className="text-gray-600 mb-4 text-center max-w-md">
                  Drag and drop a photo of your home's front exterior, or click to select from your device
                </p>
                <button className="btn-primary inline-flex items-center">
                  <PhotoIcon className="w-5 h-5 mr-2" />
                  Choose Photo
                </button>
              </div>
            </div>

            <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4 text-sm text-gray-600">
              <div className="flex items-center">
                <CheckCircleIcon className="w-5 h-5 text-green-500 mr-2" />
                JPEG, PNG, or WebP format
              </div>
              <div className="flex items-center">
                <CheckCircleIcon className="w-5 h-5 text-green-500 mr-2" />
                Maximum 10MB file size
              </div>
              <div className="flex items-center">
                <CheckCircleIcon className="w-5 h-5 text-green-500 mr-2" />
                Front exterior view preferred
              </div>
            </div>

            {analysisError && (
              <div className="mt-6 p-4 bg-red-50 border border-red-200 rounded-lg">
                <div className="flex items-center">
                  <ExclamationTriangleIcon className="w-5 h-5 text-red-500 mr-2" />
                  <span className="text-red-700">{analysisError}</span>
                </div>
              </div>
            )}
          </div>
        )}

        {/* Analyzing Section */}
        {currentStep === 'analyzing' && (
          <div className="card p-8 text-center">
            <LoadingSpinner size="large" />
            <h3 className="text-xl font-semibold text-gray-900 mt-6 mb-2">
              Analyzing Your Home
            </h3>
            <p className="text-gray-600">
              Our AI is evaluating your home across 10 key criteria...
            </p>
            {uploadedImage && (
              <div className="mt-6 max-w-md mx-auto">
                <img 
                  src={uploadedImage} 
                  alt="Uploaded home" 
                  className="rounded-lg shadow-md"
                />
              </div>
            )}
          </div>
        )}

        {/* Results Section */}
        {currentStep === 'results' && currentAnalysis && (
          <div className="space-y-8">
            {/* Overall Score */}
            <div className="card p-8 text-center">
              <ScoreDisplay 
                score={currentAnalysis.overallScore}
                percentage={currentAnalysis.percentage}
                size="large"
              />
              <h3 className="text-2xl font-bold text-gray-900 mt-6 mb-2">
                Your Curb Appeal Score
              </h3>
              <p className="text-lg text-gray-600 max-w-2xl mx-auto">
                {currentAnalysis.summary}
              </p>
            </div>

            {/* Uploaded Image */}
            {uploadedImage && (
              <div className="card p-6">
                <h4 className="text-lg font-semibold text-gray-900 mb-4">
                  Analyzed Image
                </h4>
                <div className="max-w-2xl mx-auto">
                  <img 
                    src={uploadedImage} 
                    alt="Analyzed home" 
                    className="rounded-lg shadow-md w-full"
                  />
                </div>
              </div>
            )}

            {/* Criteria Breakdown */}
            <div className="card p-6">
              <h4 className="text-lg font-semibold text-gray-900 mb-6">
                Detailed Breakdown
              </h4>
              <CriteriaGrid criteria={currentAnalysis.criteria} />
            </div>

            {/* Call to Action */}
            <div className="card p-8 text-center bg-gradient-to-r from-primary-50 to-blue-50 border-primary-200">
              <h4 className="text-2xl font-bold text-gray-900 mb-4">
                Want a Detailed Report?
              </h4>
              <p className="text-lg text-gray-600 mb-6 max-w-2xl mx-auto">
                Get a comprehensive 8-10 page report with specific recommendations, 
                cost estimates, and contractor suggestions to maximize your home's appeal.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 justify-center">
                <button 
                  onClick={handleGetDetailedReport}
                  className="btn-primary text-lg px-8 py-3"
                >
                  Get Detailed Report ($9.99)
                </button>
                <button 
                  onClick={handleRestartAnalysis}
                  className="btn-secondary text-lg px-8 py-3"
                >
                  Analyze Another Photo
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Email Capture */}
        {showEmailCapture && (
          <EmailCapture 
            onComplete={() => {
              // Navigate to detailed analysis flow
              navigate('/results/detailed')
            }}
            onCancel={() => {
              setShowEmailCapture(false)
              setCurrentStep('results')
            }}
          />
        )}
      </div>
    </div>
  )
}