import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { XMarkIcon, EnvelopeIcon, UserIcon } from '@heroicons/react/24/outline'
import type { EmailCaptureData } from '../../../shared/types'
import LoadingSpinner from './LoadingSpinner'

const emailSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  fullName: z.string().min(1, 'Please enter your name'),
  userType: z.enum(['homeowner', 'realtor', 'investor', 'contractor']),
  marketingOptIn: z.boolean().default(false)
})

interface EmailCaptureProps {
  onComplete: (data: EmailCaptureData) => void
  onCancel: () => void
}

export default function EmailCapture({ onComplete, onCancel }: EmailCaptureProps) {
  const [isSubmitting, setIsSubmitting] = useState(false)
  
  const { register, handleSubmit, formState: { errors } } = useForm<EmailCaptureData>({
    resolver: zodResolver(emailSchema)
  })

  const onSubmit = async (data: EmailCaptureData) => {
    setIsSubmitting(true)
    
    try {
      // Simulate API call delay
      await new Promise(resolve => setTimeout(resolve, 1500))
      onComplete(data)
    } catch (error) {
      console.error('Error submitting email:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-xl shadow-2xl max-w-md w-full p-8 relative">
        {/* Close Button */}
        <button
          onClick={onCancel}
          className="absolute top-4 right-4 text-gray-400 hover:text-gray-600 transition-colors"
        >
          <XMarkIcon className="w-6 h-6" />
        </button>

        {/* Header */}
        <div className="text-center mb-8">
          <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <EnvelopeIcon className="w-8 h-8 text-primary-600" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">
            Get Your Detailed Report
          </h2>
          <p className="text-gray-600">
            Enter your details to receive a comprehensive 8-10 page analysis 
            with specific recommendations and cost estimates.
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
          {/* Full Name */}
          <div>
            <label htmlFor="fullName" className="block text-sm font-medium text-gray-700 mb-2">
              Full Name
            </label>
            <div className="relative">
              <input
                {...register('fullName')}
                type="text"
                id="fullName"
                className="input-field pl-10"
                placeholder="Enter your full name"
              />
              <UserIcon className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
            </div>
            {errors.fullName && (
              <p className="mt-1 text-sm text-red-600">{errors.fullName.message}</p>
            )}
          </div>

          {/* Email */}
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
              Email Address
            </label>
            <div className="relative">
              <input
                {...register('email')}
                type="email"
                id="email"
                className="input-field pl-10"
                placeholder="Enter your email address"
              />
              <EnvelopeIcon className="w-5 h-5 text-gray-400 absolute left-3 top-1/2 transform -translate-y-1/2" />
            </div>
            {errors.email && (
              <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
            )}
          </div>

          {/* User Type */}
          <div>
            <label htmlFor="userType" className="block text-sm font-medium text-gray-700 mb-2">
              I am a...
            </label>
            <select
              {...register('userType')}
              id="userType"
              className="input-field"
            >
              <option value="homeowner">Homeowner</option>
              <option value="realtor">Real Estate Agent</option>
              <option value="investor">Property Investor</option>
              <option value="contractor">Contractor</option>
            </select>
            {errors.userType && (
              <p className="mt-1 text-sm text-red-600">{errors.userType.message}</p>
            )}
          </div>

          {/* Marketing Opt-in */}
          <div className="flex items-start space-x-3">
            <input
              {...register('marketingOptIn')}
              type="checkbox"
              id="marketingOptIn"
              className="mt-1 w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
            />
            <label htmlFor="marketingOptIn" className="text-sm text-gray-600">
              Send me tips and updates about improving curb appeal and home value
            </label>
          </div>

          {/* Submit Button */}
          <div className="flex space-x-4">
            <button
              type="button"
              onClick={onCancel}
              className="flex-1 btn-secondary"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={isSubmitting}
              className="flex-1 btn-primary relative"
            >
              {isSubmitting ? (
                <>
                  <LoadingSpinner size="small" className="mr-2" />
                  Processing...
                </>
              ) : (
                'Get Report ($9.99)'
              )}
            </button>
          </div>
        </form>

        {/* Footer */}
        <div className="mt-6 text-center">
          <p className="text-xs text-gray-500">
            Your information is secure and will never be shared with third parties.
          </p>
        </div>
      </div>
    </div>
  )
}