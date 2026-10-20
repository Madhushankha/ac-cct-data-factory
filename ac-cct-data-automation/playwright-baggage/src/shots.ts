// Full-chat screenshots with the OTP hidden (guide section 10).
//
// The message list scrolls inside the widget, so a plain shot only shows the last screenful. Two ways to
// get the whole conversation, tried in order:
//   1. tall window: grow the browser viewport by however much the list overflows, so every message is laid
//      out on screen, take ONE picture of the panel, then put the viewport back;
//   2. scrolled parts: scroll the list from the top one screenful at a time and save _part1.png, _part2.png...
// The container #ac-chat-widget-container has no box of its own, so shots target its first child, the panel.
import fs from 'node:fs';
import path from 'node:path';
import type { Locator, Page } from '@playwright/test';

const OTP_INPUTS = 'input[aria-label*="Verification" i], input[aria-label*="code" i], input[autocomplete="one-time-code"], input[inputmode="numeric"]';
const MAX_HEIGHT = 16_000;     // Chromium's practical limit for one capture

/** Replace every OTP-looking value with dots so it cannot be read even where `mask` misses. */
async function hideOtp(page: Page): Promise<void> {
  await page.locator('#ac-chat-widget-container').evaluate((r, sel) => {
    for (const el of r.querySelectorAll<HTMLInputElement>(sel)) if (el.value) { el.setAttribute('value', '••••••'); el.value = '••••••'; }
    for (const el of r.querySelectorAll<HTMLElement>('p,span,div')) {
      if (el.children.length === 0 && /^\s*\d{6}\s*$/.test(el.textContent || '')) el.textContent = '••••••';
    }
  }, OTP_INPUTS).catch(() => {});
}

/** How much the message list overflows its box: the scrollable element inside the widget with the most hidden content. */
async function overflow(root: Locator): Promise<{ hidden: number; height: number }> {
  return root.evaluate(r => {
    let best = { hidden: 0, height: 0 };
    for (const el of r.querySelectorAll<HTMLElement>('*')) {
      const s = getComputedStyle(el);
      if (!/(auto|scroll)/.test(s.overflowY)) continue;
      const hidden = el.scrollHeight - el.clientHeight;
      if (hidden > best.hidden) best = { hidden, height: el.clientHeight };
    }
    return best;
  }).catch(() => ({ hidden: 0, height: 0 }));
}

async function scrollList(root: Locator, to: 'top' | 'bottom' | number): Promise<void> {
  await root.evaluate((r, where) => {
    let best: HTMLElement | null = null, most = 0;
    for (const el of r.querySelectorAll<HTMLElement>('*')) {
      const s = getComputedStyle(el);
      const hidden = el.scrollHeight - el.clientHeight;
      if (/(auto|scroll)/.test(s.overflowY) && hidden > most) { most = hidden; best = el; }
    }
    if (best) best.scrollTop = where === 'top' ? 0 : where === 'bottom' ? best.scrollHeight : Number(where);
  }, to).catch(() => {});
}

/** One PNG of the whole conversation (or several scrolled parts). Returns the files written. */
export async function fullChatShot(page: Page, file: string): Promise<string[]> {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const root = page.locator('#ac-chat-widget-container');
  const panel = root.locator(':scope > div').first();
  const mask = [root.locator(OTP_INPUTS)];
  await hideOtp(page);
  // a floating widget does not grow with the window: switch it to full screen first (the end of a chat, or a failure)
  const full = root.getByRole('button', { name: 'Full screen', exact: true });
  if (await full.isVisible().catch(() => false)) { await full.click().catch(() => {}); await page.waitForTimeout(500); }

  // 1. tall window
  const vp = page.viewportSize();
  const { hidden } = await overflow(root);
  if (vp && hidden > 0 && vp.height + hidden + 40 <= MAX_HEIGHT) {
    try {
      await page.setViewportSize({ width: vp.width, height: vp.height + hidden + 40 });
      await page.waitForTimeout(400);
      await scrollList(root, 'top');
      const left = (await overflow(root)).hidden;
      if (left <= 8) {
        await panel.screenshot({ path: file, mask, maskColor: '#888', timeout: 20_000 });
        return [file];
      }
    } catch { /* fall through to scrolled parts */ } finally {
      await page.setViewportSize(vp).catch(() => {});
      await scrollList(root, 'bottom');
    }
  } else if (hidden <= 0) {
    try {
      await panel.screenshot({ path: file, mask, maskColor: '#888', timeout: 20_000 });
      return [file];
    } catch { /* fall through */ }
  }

  // 2. scrolled parts, top to bottom
  const files: string[] = [];
  const { hidden: h2, height } = await overflow(root);
  const step = Math.max(200, height - 60);           // a little overlap so no message is cut in two unseen
  for (let y = 0, part = 1; y <= h2 + step - 1 && part <= 40; y += step, part++) {
    await scrollList(root, y);
    await page.waitForTimeout(150);
    const f = file.replace(/\.png$/, `_part${part}.png`);
    const ok = await panel.screenshot({ path: f, mask, maskColor: '#888', timeout: 10_000 }).then(() => true, () => false);
    if (!ok) await page.screenshot({ path: f, mask, maskColor: '#888' });
    files.push(f);
    if (h2 <= 0) break;
  }
  await scrollList(root, 'bottom');
  return files;
}

/** The latest screenful, scrolled to the newest message (the live view). */
export async function liveShot(page: Page, file: string): Promise<boolean> {
  const root = page.locator('#ac-chat-widget-container');
  await scrollList(root, 'bottom');
  return root.locator(':scope > div').first()
    .screenshot({ path: file, timeout: 5000, mask: [root.locator(OTP_INPUTS)], maskColor: '#888' })
    .then(() => true, () => false);
}
