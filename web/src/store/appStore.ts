import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import type { AppStore, User, QuickAnalysis, DetailedAnalysis } from '../../../shared/types'

export const useAppStore = create<AppStore>()(
  devtools(
    persist(
      (set, get) => ({
        // Current analysis state
        currentAnalysis: null,
        isAnalyzing: false,
        analysisError: null,

        // User state
        user: null,
        isAuthenticated: false,

        // UI state
        showEmailCapture: false,
        currentStep: 'upload',

        // Actions
        setCurrentAnalysis: (analysis) => {
          set({ currentAnalysis: analysis }, false, 'setCurrentAnalysis')
        },

        setIsAnalyzing: (analyzing) => {
          set({ isAnalyzing: analyzing }, false, 'setIsAnalyzing')
        },

        setAnalysisError: (error) => {
          set({ analysisError: error }, false, 'setAnalysisError')
        },

        setUser: (user) => {
          set({ 
            user, 
            isAuthenticated: !!user 
          }, false, 'setUser')
          
          // Persist user to localStorage
          if (user) {
            localStorage.setItem('curbappeal-user', JSON.stringify(user))
          } else {
            localStorage.removeItem('curbappeal-user')
          }
        },

        setShowEmailCapture: (show) => {
          set({ showEmailCapture: show }, false, 'setShowEmailCapture')
        },

        setCurrentStep: (step) => {
          set({ currentStep: step }, false, 'setCurrentStep')
        },

        reset: () => {
          set({
            currentAnalysis: null,
            isAnalyzing: false,
            analysisError: null,
            showEmailCapture: false,
            currentStep: 'upload'
          }, false, 'reset')
        }
      }),
      {
        name: 'curbappeal-store',
        partialize: (state) => ({
          user: state.user,
          isAuthenticated: state.isAuthenticated
        }),
      }
    ),
    {
      name: 'CurbAppeal Store'
    }
  )
)