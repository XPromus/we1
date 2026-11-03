import { defineConfig } from 'vite'

// Proxy API calls to the Java backend so the frontend can use relative URLs
export default defineConfig({
  server: {
    proxy: {
      '/api': 'http://localhost:8888',
    },
  },
})
