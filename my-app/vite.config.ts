import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  // GitHub Pages serves the site under /<repo>/.
  // For the lab repo name `lab-1-setup`, the correct base is `/lab-1-setup/`.
  base: '/lab-1-setup/',
  plugins: [react()],
})
