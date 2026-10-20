// Identity check before the real runs (project "preflight"; "baggage" depends on it).
//   PREFLIGHT_PNR=FYO4TS   one seeded booking from the run's pool
// Opens a chat, says the bag is delayed, answers the notice, fills the identity form and waits for the
// OTP channel choice. No code is requested, so it costs no OTP and does not mark the booking used.
// If the chat's backend cannot see the seeded booking (another environment's data), this fails and
// Playwright does not start the dependent tests: one failed check instead of N failed chats.
import { test, expect } from './fixtures/cdp';   // plain @playwright/test unless CDP_URL is set
import { Run } from '../src/steps';
import { saveVideo } from '../src/video';
import type { Scenario } from '../src/scenario';

const pnr = process.env.PREFLIGHT_PNR;

test('run0 preflight-identity: the chat backend finds the seeded booking', async ({ page }, testInfo) => {
  test.skip(!pnr, 'no PREFLIGHT_PNR: identity check not requested');
  const s: Scenario = {
    id: 'preflight-identity', run: 0, file: 'preflight.spec.ts',
    title: `Identity check · ${pnr} (no code requested)`,
    booking: { pnr: pnr!, ...(process.env.BOOKING_POOL ? { pool: process.env.BOOKING_POOL } : {}) },
    first_message: "My checked bag didn't arrive and I want to follow it up.",
    steps: [{ notice: 'yes' }, { identify: true }, { stop: 'end' }],
  };
  const r = await new Run(page, s, testInfo).execute();
  await saveVideo(page, 0, testInfo);
  testInfo.annotations.push({ type: 'result', description: r.result }, { type: 'session', description: r.sessionId ?? '—' });
  expect(r.result, `${r.endedAt_step}: ${r.failures.map(f => f.got).join(' | ')}`).toBe('pass');
});
