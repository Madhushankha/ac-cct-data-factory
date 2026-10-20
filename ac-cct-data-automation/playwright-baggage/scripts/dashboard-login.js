// One-time Claims Dashboard sign-in: opens a visible browser at the INT dashboard, waits for the tester to
// sign in with SSO (incl. MFA), then saves the session to state/dashboard-auth.json (gitignored) so the
// dashboard checks can reuse it until it expires. No password is typed or stored by this script.
//   node scripts/dashboard-login.js
// The session is saved once the dashboard shows a case (a "CCD-" case number) or its cases list, and again
// every few seconds while signed in, so closing the window after signing in also keeps it.
const fs = require('node:fs');
const path = require('node:path');
const { chromium } = require('@playwright/test');

const URL = process.env.DASHBOARD_URL || 'https://claims-dashboard.ac-cct-int.cloud.aircanada.com';
const OUT = path.join(__dirname, '..', 'state', 'dashboard-auth.json');
const host = new globalThis.URL(URL).host;

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({ viewport: { width: 1400, height: 900 } });
  const page = await context.newPage();
  await page.goto(`${URL}/login`);
  console.log('[dashboard] sign in with your SSO in the browser window (waiting up to 10 minutes)...');
  fs.mkdirSync(path.dirname(OUT), { recursive: true });
  const end = Date.now() + 10 * 60_000;
  let saved = false;
  while (Date.now() < end && !page.isClosed()) {
    await page.waitForTimeout(3000).catch(() => {});
    if (page.isClosed()) break;
    const u = page.url();
    const onDashboard = u.includes(host) && !/\/login\b/i.test(new globalThis.URL(u).pathname);
    if (!onDashboard) continue;
    await context.storageState({ path: OUT }).catch(() => {});
    saved = true;
    const ready = await page.getByText(/CCD-\d{5,}/).first().isVisible().catch(() => false);
    if (ready) break;
  }
  console.log(saved ? `[dashboard] signed in at ${page.isClosed() ? URL : page.url()} — session saved to ${OUT}`
    : '[dashboard] no signed-in dashboard page seen; nothing saved');
  await browser.close().catch(() => {});
  process.exit(saved ? 0 : 1);
})().catch(e => { console.error(`[dashboard] ${e.message}`); process.exit(1); });
