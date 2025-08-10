interface LoadingSpinnerProps {
  size?: 'small' | 'medium' | 'large'
  className?: string
}

export default function LoadingSpinner({ size = 'medium', className = '' }: LoadingSpinnerProps) {
  const sizeClasses = {
    small: 'w-5 h-5',
    medium: 'w-8 h-8', 
    large: 'w-12 h-12'
  }

  return (
    <div className={`flex justify-center items-center ${className}`}>
      <div 
        className={`${sizeClasses[size]} animate-spin rounded-full border-3 border-gray-200 border-t-primary-600`}
        style={{ borderWidth: '3px' }}
      >
        <span className="sr-only">Loading...</span>
      </div>
    </div>
  )
}