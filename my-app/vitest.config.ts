import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  resolve: {
    // Vite supports tsconfig paths natively (Vite 5+).
    tsconfigPaths: true,
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    include: ['**/*.{test,spec}.{ts,tsx}'],
    // Windows can be flaky with forked workers; keep tests single-threaded for CI stability.
    pool: 'threads',
    singleThread: true,
  },
})

