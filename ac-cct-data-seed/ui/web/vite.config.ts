import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// `npm run build` writes into ui/static, which the Python server serves.
// `npm run dev` proxies the API to a running `python -m ui --no-browser`.
export default defineConfig({
  plugins: [react()],
  build: { outDir: '../static', emptyOutDir: true },
  server: { port: 5173, proxy: { '/api': 'http://127.0.0.1:8770' } },
});
