import { Link } from 'react-router-dom'
import { 
  CameraIcon, 
  ChartBarIcon, 
  DocumentTextIcon,
  CheckCircleIcon,
  StarIcon,
  ArrowRightIcon
} from '@heroicons/react/24/outline'

const features = [
  {
    name: 'Instant AI Analysis',
    description: 'Upload a photo and get professional curb appeal scoring in under 30 seconds.',
    icon: CameraIcon,
  },
  {
    name: '10-Point Assessment',
    description: 'Comprehensive evaluation across landscaping, roofing, paint, and 7 other key areas.',
    icon: ChartBarIcon,
  },
  {
    name: 'Detailed Reports',
    description: 'Get 8-10 page professional reports with cost estimates and priority recommendations.',
    icon: DocumentTextIcon,
  },
]

const benefits = [
  'Increase home sale price by 5-15%',
  'Reduce time on market by 2-4 weeks',
  'Professional contractor recommendations',
  'ROI analysis for every improvement',
  'Market-specific insights',
  'Before/after visualization concepts'
]

const testimonials = [
  {
    name: 'Sarah Johnson',
    role: 'Homeowner',
    content: 'CurbAppeal AI helped me identify exactly which improvements would give me the best return. My home sold 3 weeks faster than expected!',
    rating: 5
  },
  {
    name: 'Mike Rodriguez',
    role: 'Real Estate Agent',
    content: 'This tool has become essential for my clients. The detailed reports help them make smart improvement decisions that actually impact sale price.',
    rating: 5
  },
  {
    name: 'Jennifer Chen',
    role: 'Property Investor',
    content: 'The cost estimates are incredibly accurate. I can now evaluate flip properties with confidence and maximize my profits.',
    rating: 5
  }
]

export default function HomePage() {
  return (
    <div>
      {/* Hero Section */}
      <section className="relative bg-gradient-to-br from-primary-50 to-blue-100 overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 sm:py-24">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 leading-tight">
                Maximize Your Home's{' '}
                <span className="text-primary-600">Curb Appeal</span>
              </h1>
              <p className="mt-6 text-xl text-gray-600 leading-relaxed">
                Get instant AI-powered analysis of your home's exterior with professional 
                recommendations to increase market value and sell faster.
              </p>
              
              <div className="mt-8 flex flex-col sm:flex-row gap-4">
                <Link 
                  to="/analyze"
                  className="btn-primary text-lg px-8 py-3 inline-flex items-center justify-center"
                >
                  Start Free Analysis
                  <ArrowRightIcon className="ml-2 w-5 h-5" />
                </Link>
                <button className="btn-secondary text-lg px-8 py-3">
                  See Examples
                </button>
              </div>

              <div className="mt-8 flex items-center space-x-6 text-sm text-gray-600">
                <div className="flex items-center">
                  <CheckCircleIcon className="w-5 h-5 text-green-500 mr-2" />
                  30-second analysis
                </div>
                <div className="flex items-center">
                  <CheckCircleIcon className="w-5 h-5 text-green-500 mr-2" />
                  No signup required
                </div>
                <div className="flex items-center">
                  <CheckCircleIcon className="w-5 h-5 text-green-500 mr-2" />
                  Professional insights
                </div>
              </div>
            </div>

            <div className="lg:pl-12">
              <div className="relative">
                <img
                  src="https://images.unsplash.com/photo-1570129477492-45c003edd2be?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"
                  alt="Beautiful home with excellent curb appeal"
                  className="rounded-2xl shadow-2xl"
                />
                <div className="absolute -top-4 -right-4 bg-white p-4 rounded-xl shadow-lg">
                  <div className="text-3xl font-bold text-primary-600">92%</div>
                  <div className="text-sm text-gray-600">Curb Appeal Score</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-gray-900">
              How CurbAppeal AI Works
            </h2>
            <p className="mt-4 text-lg text-gray-600 max-w-2xl mx-auto">
              Get professional-grade curb appeal analysis in minutes, not days
            </p>
          </div>

          <div className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-8">
            {features.map((feature, index) => (
              <div key={feature.name} className="text-center">
                <div className="flex justify-center">
                  <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center">
                    <feature.icon className="w-8 h-8 text-primary-600" />
                  </div>
                </div>
                <h3 className="mt-4 text-xl font-semibold text-gray-900">
                  {feature.name}
                </h3>
                <p className="mt-2 text-gray-600">
                  {feature.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl font-bold text-gray-900">
                Why Curb Appeal Matters
              </h2>
              <p className="mt-4 text-lg text-gray-600">
                First impressions matter in real estate. Properties with excellent 
                curb appeal sell faster and for higher prices.
              </p>

              <div className="mt-8 grid grid-cols-1 sm:grid-cols-2 gap-4">
                {benefits.map((benefit, index) => (
                  <div key={index} className="flex items-start">
                    <CheckCircleIcon className="w-6 h-6 text-green-500 mr-3 flex-shrink-0 mt-0.5" />
                    <span className="text-gray-700">{benefit}</span>
                  </div>
                ))}
              </div>

              <div className="mt-8">
                <Link 
                  to="/analyze"
                  className="btn-primary inline-flex items-center"
                >
                  Analyze My Home
                  <ArrowRightIcon className="ml-2 w-4 h-4" />
                </Link>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <img
                src="https://images.unsplash.com/photo-1560518883-ce09059eeffa?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"
                alt="Home exterior before improvement"
                className="rounded-lg shadow-md"
              />
              <img
                src="https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&auto=format&fit=crop&w=400&q=80"
                alt="Home exterior after improvement"
                className="rounded-lg shadow-md mt-8"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h2 className="text-3xl font-bold text-gray-900">
              What Our Users Say
            </h2>
            <p className="mt-4 text-lg text-gray-600">
              Join thousands of homeowners and real estate professionals
            </p>
          </div>

          <div className="mt-16 grid grid-cols-1 md:grid-cols-3 gap-8">
            {testimonials.map((testimonial, index) => (
              <div key={index} className="card p-6">
                <div className="flex items-center mb-4">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <StarIcon key={i} className="w-5 h-5 text-yellow-400 fill-current" />
                  ))}
                </div>
                <p className="text-gray-600 mb-4">
                  "{testimonial.content}"
                </p>
                <div>
                  <div className="font-semibold text-gray-900">
                    {testimonial.name}
                  </div>
                  <div className="text-sm text-gray-500">
                    {testimonial.role}
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="bg-gradient-to-r from-primary-600 to-primary-700 py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold text-white mb-4">
            Ready to Boost Your Home's Appeal?
          </h2>
          <p className="text-xl text-primary-100 mb-8 max-w-2xl mx-auto">
            Get your free curb appeal analysis in under 30 seconds. 
            No signup required, instant results.
          </p>
          <Link 
            to="/analyze"
            className="bg-white text-primary-600 hover:bg-primary-50 font-medium py-3 px-8 rounded-lg transition-colors duration-200 inline-flex items-center text-lg"
          >
            Start Free Analysis
            <CameraIcon className="ml-2 w-5 h-5" />
          </Link>
        </div>
      </section>
    </div>
  )
}