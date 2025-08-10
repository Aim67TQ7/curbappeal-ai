interface ScoreDisplayProps {
  score: number // 1-50
  percentage: number // 0-100
  size?: 'small' | 'medium' | 'large'
  showDetails?: boolean
}

export default function ScoreDisplay({ 
  score, 
  percentage, 
  size = 'medium', 
  showDetails = true 
}: ScoreDisplayProps) {
  const sizeClasses = {
    small: { 
      container: 'w-20 h-20', 
      text: 'text-lg', 
      subtext: 'text-xs',
      stroke: '6'
    },
    medium: { 
      container: 'w-32 h-32', 
      text: 'text-2xl', 
      subtext: 'text-sm',
      stroke: '8'
    },
    large: { 
      container: 'w-48 h-48', 
      text: 'text-4xl', 
      subtext: 'text-lg',
      stroke: '10'
    }
  }

  const classes = sizeClasses[size]
  const radius = 45
  const circumference = 2 * Math.PI * radius
  const strokeDashoffset = circumference - (percentage / 100) * circumference

  const getScoreColor = (percentage: number) => {
    if (percentage >= 80) return 'text-green-600'
    if (percentage >= 60) return 'text-yellow-600'
    if (percentage >= 40) return 'text-orange-600'
    return 'text-red-600'
  }

  const getStrokeColor = (percentage: number) => {
    if (percentage >= 80) return '#10b981' // green-500
    if (percentage >= 60) return '#f59e0b' // yellow-500  
    if (percentage >= 40) return '#f97316' // orange-500
    return '#ef4444' // red-500
  }

  return (
    <div className="flex flex-col items-center">
      <div className={`relative ${classes.container}`}>
        {/* Background circle */}
        <svg className="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
          <circle
            cx="50"
            cy="50"
            r={radius}
            stroke="#e5e7eb"
            strokeWidth={classes.stroke}
            fill="none"
          />
          {/* Progress circle */}
          <circle
            cx="50"
            cy="50"
            r={radius}
            stroke={getStrokeColor(percentage)}
            strokeWidth={classes.stroke}
            fill="none"
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
            className="transition-all duration-1000 ease-out"
          />
        </svg>
        
        {/* Score text */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span className={`font-bold ${classes.text} ${getScoreColor(percentage)}`}>
            {percentage}%
          </span>
          {showDetails && (
            <span className={`${classes.subtext} text-gray-500`}>
              {score}/50
            </span>
          )}
        </div>
      </div>

      {showDetails && (
        <div className="mt-4 text-center">
          <div className={`font-semibold ${getScoreColor(percentage)}`}>
            {percentage >= 80 ? 'Excellent' :
             percentage >= 60 ? 'Good' :
             percentage >= 40 ? 'Fair' : 'Needs Improvement'}
          </div>
          <div className="text-sm text-gray-500 mt-1">
            Curb Appeal Score
          </div>
        </div>
      )}
    </div>
  )
}