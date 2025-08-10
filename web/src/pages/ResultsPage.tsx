import { useParams, useNavigate } from 'react-router-dom'
import { useAppStore } from '../store/appStore'
import { ArrowLeftIcon, DownloadIcon, ShareIcon } from '@heroicons/react/24/outline'
import ScoreDisplay from '../components/ScoreDisplay'
import CriteriaGrid from '../components/CriteriaGrid'

export default function ResultsPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const { currentAnalysis } = useAppStore()

  // If no analysis in store, redirect to analyze page
  if (!currentAnalysis) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <h2 className="text-2xl font-bold text-gray-900 mb-4">
            No Analysis Found
          </h2>
          <p className="text-gray-600 mb-8">
            We couldn't find the analysis you're looking for.
          </p>
          <button
            onClick={() => navigate('/analyze')}
            className="btn-primary"
          >
            Start New Analysis
          </button>
        </div>
      </div>
    )
  }

  const handleShare = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'My Curb Appeal Analysis',
          text: `Check out my home's curb appeal score: ${currentAnalysis.percentage}%`,
          url: window.location.href,
        })
      } catch (error) {
        console.log('Error sharing:', error)
      }
    } else {
      // Fallback: copy to clipboard
      navigator.clipboard.writeText(window.location.href)
      alert('Link copied to clipboard!')
    }
  }

  const handleDownloadReport = () => {
    // This would trigger PDF generation in a real app
    alert('Report download functionality would be implemented here')
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center space-x-4">
            <button
              onClick={() => navigate('/analyze')}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <ArrowLeftIcon className="w-5 h-5 text-gray-600" />
            </button>
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                Curb Appeal Analysis Results
              </h1>
              <p className="text-gray-600 mt-1">
                Analysis completed on {new Date(currentAnalysis.createdAt).toLocaleDateString()}
              </p>
            </div>
          </div>

          <div className="flex items-center space-x-3">
            <button
              onClick={handleShare}
              className="btn-secondary inline-flex items-center"
            >
              <ShareIcon className="w-4 h-4 mr-2" />
              Share
            </button>
            <button
              onClick={handleDownloadReport}
              className="btn-primary inline-flex items-center"
            >
              <DownloadIcon className="w-4 h-4 mr-2" />
              Download Report
            </button>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-8">
            {/* Overall Score Section */}
            <div className="card p-8">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
                <div>
                  <ScoreDisplay
                    score={currentAnalysis.overallScore}
                    percentage={currentAnalysis.percentage}
                    size="large"
                  />
                </div>
                <div>
                  <h3 className="text-2xl font-bold text-gray-900 mb-4">
                    Your Curb Appeal Score
                  </h3>
                  <p className="text-lg text-gray-600 leading-relaxed">
                    {currentAnalysis.summary}
                  </p>
                </div>
              </div>
            </div>

            {/* Detailed Criteria Breakdown */}
            <div className="card p-6">
              <h3 className="text-xl font-bold text-gray-900 mb-6">
                Detailed Assessment
              </h3>
              <CriteriaGrid 
                criteria={currentAnalysis.criteria} 
                detailed={true}
              />
            </div>

            {/* Key Recommendations */}
            <div className="card p-6">
              <h3 className="text-xl font-bold text-gray-900 mb-6">
                Priority Recommendations
              </h3>
              <div className="space-y-4">
                {currentAnalysis.criteria
                  .filter(c => c.score <= 3)
                  .sort((a, b) => a.score - b.score)
                  .slice(0, 3)
                  .map((criterion) => (
                    <div key={criterion.id} className="p-4 border border-gray-200 rounded-lg">
                      <div className="flex items-start justify-between mb-2">
                        <h4 className="font-semibold text-gray-900">
                          {criterion.name}
                        </h4>
                        <span className="text-sm text-gray-500">
                          Score: {criterion.score}/5
                        </span>
                      </div>
                      <p className="text-gray-600 mb-3">
                        {criterion.feedback}
                      </p>
                      <div>
                        <div className="text-sm font-medium text-gray-900 mb-2">
                          Top Recommendations:
                        </div>
                        <ul className="space-y-1">
                          {criterion.recommendations.slice(0, 3).map((rec, idx) => (
                            <li key={idx} className="text-sm text-gray-600 flex items-start">
                              <span className="w-1.5 h-1.5 bg-primary-500 rounded-full mt-2 mr-3 flex-shrink-0" />
                              {rec}
                            </li>
                          ))}
                        </ul>
                      </div>
                    </div>
                  ))}
              </div>
            </div>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Analyzed Image */}
            <div className="card p-4">
              <h4 className="font-semibold text-gray-900 mb-4">
                Analyzed Image
              </h4>
              <img
                src={currentAnalysis.imageUrl}
                alt="Analyzed home exterior"
                className="w-full rounded-lg shadow-sm"
              />
            </div>

            {/* Score Breakdown */}
            <div className="card p-4">
              <h4 className="font-semibold text-gray-900 mb-4">
                Score Breakdown
              </h4>
              <div className="space-y-3">
                {currentAnalysis.criteria.map((criterion) => (
                  <div key={criterion.id} className="flex items-center justify-between">
                    <span className="text-sm text-gray-600 truncate">
                      {criterion.name}
                    </span>
                    <div className="flex items-center space-x-2">
                      <div className="flex">
                        {[...Array(5)].map((_, i) => (
                          <div
                            key={i}
                            className={`w-2 h-2 rounded-full ${
                              i < criterion.score ? 'bg-primary-500' : 'bg-gray-200'
                            }`}
                          />
                        ))}
                      </div>
                      <span className="text-sm font-medium text-gray-900 w-8 text-right">
                        {criterion.score}/5
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Next Steps CTA */}
            <div className="card p-6 bg-gradient-to-br from-primary-50 to-blue-50 border-primary-200">
              <h4 className="font-bold text-gray-900 mb-3">
                Want More Detailed Insights?
              </h4>
              <p className="text-sm text-gray-600 mb-4">
                Get a comprehensive 8-10 page report with specific contractor 
                recommendations, detailed cost breakdowns, and ROI projections.
              </p>
              <button className="w-full btn-primary">
                Upgrade to Detailed Report
              </button>
            </div>

            {/* Analysis Actions */}
            <div className="card p-4">
              <h4 className="font-semibold text-gray-900 mb-4">
                Next Steps
              </h4>
              <div className="space-y-3">
                <button 
                  onClick={() => navigate('/analyze')}
                  className="w-full btn-secondary text-sm"
                >
                  Analyze Another Photo
                </button>
                <button className="w-full btn-secondary text-sm">
                  Find Local Contractors
                </button>
                <button className="w-full btn-secondary text-sm">
                  Schedule Consultation
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}