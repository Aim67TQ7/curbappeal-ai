import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // Enable network access for testing
    cors: true,
    port: 5179
  },
  preview: {
    host: true,
    port: 5179
  }
})
