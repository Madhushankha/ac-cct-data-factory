// Driving the Ask AC widget (guide section 4). Every click and typed text goes through the guards.
import { expect, type Locator, type Page } from '@playwright/test';
import { assertAllowed, type StopKind } from './guards';
import { CHAT_URL, ON_BAT } from './config';
import { readMessages, sessionId, type Message } from './transcript';

export const BUSY = /Thinking|Checking our systems|Checking your baggage|Opening your case|Sending your verification|Checking your code|Confirming your reimbursement|Réflexion|Vérification|…$/;

/** settled = the chat text hasn't changed for `quietMs` and no busy indicator is showing (guide 4.3). */
export async function settle(root: Locator, quietMs = 6000, maxMs = 90_000): Promise<void> {
  const page = root.page();
  const end = Date.now() + maxMs;
  let last = await root.innerText().catch(() => '');
  let since = Date.now();
  while (Date.now() < end) {
    await page.waitForTimeout(700);
    const t = await root.innerText().catch(() => last);
    if (t !== last) { last = t; since = Date.now(); continue; }
    if (Date.now() - since >= quietMs && !BUSY.test(t.slice(-200).trim())) return;
  }
  throw new Error('bot did not settle');
}

export type Lang = 'English' | 'Français';

/** Per-keystroke delay: the chat is typed like a person would, so a watcher (Show browser) sees it happen. */
export const TYPE_DELAY_MS = Number(process.env.TYPE_DELAY_MS ?? 35);

/** Click into a field, clear it and type the value key by key; fall back to the React setter if it did not stick. */
export async function typeInto(f: Locator, value: string): Promise<void> {
  await f.click();
  await f.fill('');
  await f.pressSequentially(value, { delay: TYPE_DELAY_MS });
  if ((await f.inputValue().catch(() => value)) !== value) await setReactValue(f, value);
}

export class ChatPage {
  /** stops the current scenario explicitly allows (guards.assertAllowed) */
  allow: StopKind[] = [];
  /** the last action, for the failure table's "What I did just before" */
  lastAction = 'opened the chat';
  lang: Lang = 'English';
  /** the text of the pre-chat consent/privacy screen, captured before it is accepted */
  consent = '';

  constructor(public page: Page) {}

  root(): Locator { return this.page.locator('#ac-chat-widget-container'); }
  /** the visible panel (the container itself has no box; screenshots target this) */
  panel(): Locator { return this.root().locator(':scope > div').first(); }

  /**
   * Open the widget, accept the notice, pick the language and wait for the greeting. INT sometimes takes
   * minutes to greet; `requireGreeting: false` (the AI customer) carries on once the language is chosen.
   */
  async open(lang: Lang = 'English', opts: { requireGreeting?: boolean } = {}): Promise<void> {
    this.lang = lang;
    // domcontentloaded: the uat2 (BAT) page's ad and tracking frames can hold the load event for ever
    await this.page.goto(CHAT_URL, { waitUntil: 'domcontentloaded', timeout: 120_000 });
    // the hosted preview has a password screen before it loads the widget
    const pass = this.page.locator('#password');
    if (await pass.isVisible({ timeout: 3000 }).catch(() => false)) {
      if (!process.env.CHAT_PASSWORD) throw new Error(`${CHAT_URL} asks for a password: set CHAT_PASSWORD in .env`);
      await pass.fill(process.env.CHAT_PASSWORD);
      await pass.press('Enter');
    }
    // the uat2 (BAT) site shows a cookie banner over the launcher: keep only the essential cookies
    // it renders seconds after the page: wait for it (isVisible does not wait), and only where it exists
    const prefs = this.page.getByRole('button', { name: 'Manage preferences' });
    const launcher = this.page.getByRole('button', { name: 'Open chat' });
    // under load the banner can arrive after the launcher and cover it: keep dismissing and retrying for 2 min
    const until = Date.now() + 120_000;
    for (;;) {
      if (ON_BAT && await prefs.isVisible().catch(() => false)) {
        await prefs.click({ timeout: 10_000 }).catch(() => {});
        await this.page.getByRole('button', { name: 'Confirm My Choices' }).click({ timeout: 10_000 }).catch(() => {});
      }
      const opened = await launcher.click({ timeout: ON_BAT ? 10_000 : 60_000 }).then(() => true, () => false);
      if (opened) break;
      if (Date.now() > until) { await launcher.click({ timeout: 5000 }); break; }   // throws with Playwright's reason
    }
    // the privacy/consent notice is a screen before the chat on INT: keep its words for the checkpoints
    const agree = this.btn(lang === 'English' ? 'I agree' : "J'accepte");
    await agree.waitFor({ state: 'visible', timeout: 60_000 }).catch(() => {});
    this.consent = (await this.root().innerText().catch(() => '')).replace(/\s+/g, ' ').trim().slice(0, 2000);
    await agree.click().catch(async () => this.btn('I agree').click());
    await this.btn(lang).click();
    const greeted = await expect(this.root()).toContainText(/How can I help you today\?|Comment puis-je vous aider/, { timeout: 180_000 })
      .then(() => true, e => { if (opts.requireGreeting !== false) throw e; return false; });
    if (greeted) await settle(this.root(), 2500);
    this.lastAction = greeted ? 'opened the chat' : 'opened the chat (no greeting yet after 3 min)';
  }

  /** Last visible enabled button with this exact name, scoped to the widget (old messages keep theirs). */
  btn(name: string | RegExp): Locator {
    const opts = typeof name === 'string' ? { name, exact: true } : { name };
    return this.root().getByRole('button', opts).filter({ visible: true }).last();
  }

  async tap(name: string | RegExp, opts: { settle?: boolean } = {}): Promise<void> {
    assertAllowed({ tap: String(name) }, this.allow);
    const b = this.btn(name);
    await expect(b).toBeEnabled({ timeout: 60_000 });
    // the guard sees the real label too (a regex could match a forbidden one)
    assertAllowed({ tap: (await b.innerText()).trim() || String(name) }, this.allow);
    await b.click();
    this.lastAction = `tapped \`${String(name)}\``;
    if (opts.settle !== false) await settle(this.root());
  }

  messageBox(): Locator {
    return this.root().locator('[aria-label="Message input"], [aria-label="Zone de saisie du message"]');
  }

  async say(text: string): Promise<void> {
    assertAllowed({ type: text }, this.allow);
    const box = this.messageBox();
    await expect(box).toBeEnabled({ timeout: 60_000 });
    // as a customer would: type in the box at the bottom, then press the send button
    await typeInto(box, text);
    const send = this.root().getByRole('button', { name: /^(Send message|Envoyer le message)$/ }).filter({ visible: true }).last();
    if (await send.isEnabled({ timeout: 5000 }).catch(() => false)) await send.click();
    else await box.press('Enter');
    this.lastAction = `typed \`${text}\``;
    await settle(this.root());
  }

  /** Fill a form field by its visible label (last one on screen). */
  async fill(label: string | RegExp, value: string, scope?: Locator): Promise<void> {
    assertAllowed({ fillLabel: String(label).replace(/^\/|\/[a-z]*$/g, '') }, this.allow);
    const f = (scope ?? this.root()).getByLabel(label).filter({ visible: true }).last();
    await expect(f).toBeVisible({ timeout: 60_000 });
    await typeInto(f, value);
  }

  /**
   * Tick one option in a "Choose one or more options" list. The widget renders these as checkboxes,
   * listbox options or labelled spans depending on the message, so try each and take the first visible.
   */
  async choose(label: string | RegExp, scope?: Locator): Promise<void> {
    assertAllowed({ tap: String(label) }, this.allow);
    const s = scope ?? this.root();
    const name = typeof label === 'string' ? new RegExp(escapeRe(label), 'i') : label;
    const candidates = [
      s.getByRole('checkbox', { name }), s.getByRole('option', { name }), s.getByRole('radio', { name }),
      s.getByLabel(name), s.getByRole('button', { name }), s.getByText(name),
    ];
    for (const c of candidates) {
      const v = c.filter({ visible: true }).last();
      if (await v.count().then(n => n > 0).catch(() => false)) { await v.click(); this.lastAction = `ticked \`${String(label)}\``; return; }
    }
    throw new Error(`option not found: ${String(label)}`);
  }

  /** The topmost open dialog (contents pop-up, receipt upload). */
  dialog(): Locator { return this.page.getByRole('dialog').filter({ visible: true }).last(); }

  async messages(): Promise<Message[]> { return readMessages(this.root()); }
  async sessionId(): Promise<string | undefined> { return sessionId(this.page); }

  /** Wait until some bot text matching `re` is on screen (bounded), then settle. */
  async waitForText(re: RegExp, timeout = 90_000): Promise<boolean> {
    const ok = await expect(this.root()).toContainText(re, { timeout }).then(() => true, () => false);
    if (ok) await settle(this.root(), 3000);
    return ok;
  }
}

export function escapeRe(s: string): string { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }

/** React-controlled inputs: native setter + input/change events (only when fill() does not stick). */
async function setReactValue(f: Locator, value: string): Promise<void> {
  await f.evaluate((el, v) => {
    const proto = el instanceof HTMLTextAreaElement ? HTMLTextAreaElement.prototype : HTMLInputElement.prototype;
    Object.getOwnPropertyDescriptor(proto, 'value')!.set!.call(el, v);
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }, value);
}
