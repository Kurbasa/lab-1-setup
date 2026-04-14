import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  // GitHub Pages serves the site under /<repo>/, while Vercel serves from /.
  // Detect GitHub Actions builds to set the correct base automatically.
  base: process.env.GITHUB_ACTIONS ? '/lab-1-setup/' : '/',
  plugins: [react()],
})
