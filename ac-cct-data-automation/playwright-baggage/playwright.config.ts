import path from 'node:path';
import { defineConfig } from '@playwright/test';
import { BASE_URL, CHAT_DIR, CHAT_PORT, LOCAL_CHAT } from './src/config';

// A launcher (agentic-qa) that sets RUN_DIR gets the HTML/JSON reports inside that run's folder;
// a plain `npm test` keeps them in out/html.
const RUN_DIR = process.env.RUN_DIR;

const BROWSER = {
  browserName: 'chromium' as const,
  baseURL: BASE_URL,
  viewport: { width: 1280, height: 1000 },
  headless: process.env.HEADED !== '1',     // HEADED=1 shows the browser windows (one per parallel chat)
  trace: 'retain-on-failure' as const,
  // no video by default (VIDEO=on records every chat, VIDEO=retain-on-failure only failures; saved as <run>/videos/run<n>.webm)
  video: (process.env.VIDEO || 'off') as 'on' | 'retain-on-failure' | 'off',
  screenshot: 'only-on-failure' as const,
};

export default defineConfig({
  timeout: 15 * 60_000,              // a full claim road takes 5-10 min
  expect: { timeout: 60_000 },
  workers: Number(process.env.WORKERS || 5),   // parallel chats; the OTP broker serialises the codes
  retries: 0,                        // never auto-retry: a retry burns OTP codes and bookings
  outputDir: RUN_DIR ? path.join(RUN_DIR, 'test-results') : 'test-results',
  globalSetup: require.resolve('./tests/global-setup'),
  globalTeardown: require.resolve('./tests/global-teardown'),
  reporter: [
    ['list'],
    ['html', { outputFolder: RUN_DIR ? path.join(RUN_DIR, 'html') : 'out/html', open: 'never' }],
    ['json', { outputFile: RUN_DIR ? path.join(RUN_DIR, 'pw-results.json') : 'out/pw-results.json' }],
  ],
  projects: [
    {
      // Offline checks: OTP parsing, safety walk of every scenario, judge, report. No browser, no backend.
      name: 'unit',
      testDir: 'tests/unit',
      timeout: 60_000,
    },
    {
      // Identity check: one seeded booking through the identity form, no code requested. Runs first when
      // PREFLIGHT_PNR is set (skipped otherwise); if it fails, the baggage tests that depend on it do not start.
      name: 'preflight',
      testDir: 'tests',
      testMatch: 'preflight.spec.ts',
      use: BROWSER,
    },
    {
      name: 'baggage',
      testDir: 'tests',
      testMatch: 'baggage.spec.ts',
      dependencies: ['preflight'],
      use: BROWSER,
    },
    {
      // AI-customer chats from GOAL_PLAN (src/goal.ts); same identity check first
      name: 'goal',
      testDir: 'tests',
      testMatch: 'goal.spec.ts',
      dependencies: ['preflight'],
      use: BROWSER,
    },
  ],
  // the local public-qa copy needs serving; the hosted stable page does not
  webServer: LOCAL_CHAT ? {
    command: `node scripts/serve.js "${CHAT_DIR}" ${CHAT_PORT}`,
    url: `${BASE_URL}/index.html`,
    reuseExistingServer: true,
  } : undefined,
});
