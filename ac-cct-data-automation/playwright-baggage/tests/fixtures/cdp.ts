// Run the suite against a browser that is already listening, instead of launching Chromium.
//
//   CDP_URL=http://127.0.0.1:9222 npx playwright test --project=baggage -g smoke-identify
//
// Why this exists: Moli is a headless browser built for agents ("structure first, pixels on
// demand") and serves CDP, WebDriver Classic and WebDriver BiDi on one endpoint. Playwright can
// drive it, but only through `chromium.connectOverCDP` -- `use.connectOptions` speaks the
// Playwright protocol, not CDP, so there is no declarative way to say it in the config.
//
// With CDP_URL unset this module is the plain `@playwright/test` export, so the default behaviour
// (launch our own Chromium) is untouched and no scenario changes meaning.
import { test as base, expect, chromium, type Browser, type BrowserContext } from '@playwright/test';
import { cdpEndpoints, endpointOrder } from '../../src/cdp-endpoints';
import { HTTP_CREDENTIALS } from '../../src/config';

// CDP_URL, CDP_URLS or CDP_PORTS (see src/cdp-endpoints.ts): one Moli per worker when there are several
const ENDPOINTS = cdpEndpoints();

/** One connection per worker: a CDP endpoint is a running browser, not a process to spawn. */
const cdpTest = base.extend<{ cdpContext: BrowserContext }, { cdpBrowser: Browser }>({
  cdpBrowser: [async ({}, use, workerInfo) => {
    let browser: Browser | undefined;
    const tried: string[] = [];
    for (const url of endpointOrder(ENDPOINTS, workerInfo.parallelIndex)) {
      try { browser = await chromium.connectOverCDP(url, { timeout: 20_000 }); break; }
      catch (e: any) { tried.push(`${url}: ${String(e?.message ?? e).split(/\r?\n/)[0].slice(0, 80)}`); }
    }
    if (!browser) throw new Error(`no CDP browser answered (start Moli first): ${tried.join('; ')}`);
    await use(browser);
    // close the connection, not the browser: the endpoint outlives the run and may serve others
    await browser.close();
  }, { scope: 'worker' }],

  cdpContext: async ({ cdpBrowser }, use) => {
    // prefer a fresh context so parallel workers do not share cookies or a chat session; fall back
    // to the default one, which is all some CDP implementations expose
    let context: BrowserContext;
    let own = false;
    try {
      // the same viewport and site login a launched browser gets (uat2 sits behind Basic auth)
      context = await cdpBrowser.newContext({ viewport: { width: 1280, height: 1000 }, httpCredentials: HTTP_CREDENTIALS });
      own = true;
    } catch {
      context = cdpBrowser.contexts()[0];
      if (!context) throw new Error('the CDP browser exposes no browser context');
    }
    await use(context);
    if (own) await context.close();
  },

  page: async ({ cdpContext }, use) => {
    const page = cdpContext.pages()[0] ?? await cdpContext.newPage();
    await use(page);
  },
});

export const test = ENDPOINTS.length ? cdpTest : base;
export { expect };
