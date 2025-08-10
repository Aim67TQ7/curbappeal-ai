import { 
  HomeIcon,
  BuildingOfficeIcon,
  PaintBrushIcon,
  ArchiveBoxIcon,
  WindowIcon,
  RectangleStackIcon,
  LightBulbIcon,
  CubeIcon,
  ShieldCheckIcon,
  Squares2X2Icon
} from '@heroicons/react/24/outline'
import type { CurbAppealCriteria } from '../../../shared/types'

const criteriaIcons = {
  1: HomeIcon, // Landscaping & Gardens
  2: BuildingOfficeIcon, // Roofing Condition  
  3: PaintBrushIcon, // Exterior Paint & Siding
  4: ArchiveBoxIcon, // Front Porch/Entry
  5: WindowIcon, // Windows & Shutters
  6: RectangleStackIcon, // Driveway & Walkways
  7: LightBulbIcon, // Lighting & Fixtures
  8: CubeIcon, // Garage & Storage
  9: ShieldCheckIcon, // Fencing & Boundaries
  10: Squares2X2Icon, // Overall Symmetry & Design
}

interface CriteriaGridProps {
  criteria: CurbAppealCriteria[]
  detailed?: boolean
}

export default function CriteriaGrid({ criteria, detailed = false }: CriteriaGridProps) {
  const getScoreColor = (score: number) => {
    if (score >= 4) return 'text-green-600 bg-green-50 border-green-200'
    if (score >= 3) return 'text-yellow-600 bg-yellow-50 border-yellow-200'
    if (score >= 2) return 'text-orange-600 bg-orange-50 border-orange-200'
    return 'text-red-600 bg-red-50 border-red-200'
  }

  const getScoreBadgeColor = (score: number) => {
    if (score >= 4) return 'bg-green-100 text-green-800'
    if (score >= 3) return 'bg-yellow-100 text-yellow-800'
    if (score >= 2) return 'bg-orange-100 text-orange-800'
    return 'bg-red-100 text-red-800'
  }

  const renderStars = (score: number) => {
    return Array.from({ length: 5 }, (_, i) => (
      <svg
        key={i}
        className={`w-4 h-4 ${
          i < score ? 'text-yellow-400 fill-current' : 'text-gray-300'
        }`}
        viewBox="0 0 20 20"
        fill="currentColor"
      >
        <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
      </svg>
    ))
  }

  return (
    <div className="criteria-grid">
      {criteria.map((criterion) => {
        const IconComponent = criteriaIcons[criterion.id as keyof typeof criteriaIcons]
        
        return (
          <div
            key={criterion.id}
            className={`p-4 rounded-lg border transition-colors ${getScoreColor(criterion.score)}`}
          >
            <div className="flex items-start justify-between mb-3">
              <div className="flex items-center space-x-3">
                <div className="flex-shrink-0">
                  <IconComponent className="w-6 h-6" />
                </div>
                <div className="min-w-0 flex-1">
                  <h4 className="font-semibold text-gray-900 text-sm leading-tight">
                    {criterion.name}
                  </h4>
                </div>
              </div>
              <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${getScoreBadgeColor(criterion.score)}`}>
                {criterion.score}/5
              </span>
            </div>

            {/* Star Rating */}
            <div className="flex items-center space-x-1 mb-3">
              {renderStars(criterion.score)}
            </div>

            {/* Feedback */}
            <p className="text-sm text-gray-600 mb-3 line-clamp-2">
              {criterion.feedback}
            </p>

            {/* Cost Estimate (if detailed) */}
            {detailed && criterion.costEstimate && (
              <div className="border-t border-gray-200 pt-3 mt-3">
                <div className="text-xs text-gray-500 mb-1">Improvement Cost Range:</div>
                <div className="flex items-center justify-between text-xs">
                  <span className="text-green-600">${criterion.costEstimate.low.toLocaleString()}</span>
                  <span className="text-gray-400">-</span>
                  <span className="text-red-600">${criterion.costEstimate.high.toLocaleString()}</span>
                </div>
              </div>
            )}

            {/* Top Recommendations (if detailed) */}
            {detailed && criterion.recommendations && criterion.recommendations.length > 0 && (
              <div className="border-t border-gray-200 pt-3 mt-3">
                <div className="text-xs text-gray-500 mb-2">Quick Fixes:</div>
                <ul className="space-y-1">
                  {criterion.recommendations.slice(0, 2).map((rec, idx) => (
                    <li key={idx} className="text-xs text-gray-600 flex items-start">
                      <span className="w-1 h-1 bg-gray-400 rounded-full mt-1.5 mr-2 flex-shrink-0" />
                      <span className="line-clamp-1">{rec}</span>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        )
      })}
    </div>
  )
}