import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import HomePage from './pages/HomePage'
import AnalysisPage from './pages/AnalysisPage' 
import ResultsPage from './pages/ResultsPage'
import Header from './components/Header'
import Footer from './components/Footer'
import { useAppStore } from './store/appStore'
import { useEffect } from 'react'

const queryClient = new QueryClient()

function AppContent() {
  const { user, setUser } = useAppStore()

  useEffect(() => {
    // Check for existing user session
    const savedUser = localStorage.getItem('curbappeal-user')
    if (savedUser) {
      try {
        const userData = JSON.parse(savedUser)
        setUser(userData)
      } catch (error) {
        console.error('Error parsing saved user data:', error)
        localStorage.removeItem('curbappeal-user')
      }
    }
  }, [setUser])

  return (
    <Router>
      <div className="min-h-screen bg-gray-50 flex flex-col">
        <Header />
        
        <main className="flex-1">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route path="/analyze" element={<AnalysisPage />} />
            <Route path="/results/:id" element={<ResultsPage />} />
          </Routes>
        </main>
        
        <Footer />
      </div>
    </Router>
  )
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AppContent />
    </QueryClientProvider>
  )
}

export default App