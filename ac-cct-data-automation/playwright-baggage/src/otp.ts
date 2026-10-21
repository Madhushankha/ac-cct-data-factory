// Getting the email OTP (guide section 5).
//
// Providers, chosen per booking pool (data/bookings.yaml `otp:`):
//   mailinator  the shared private Mailinator inbox; read through the API ("new message since I asked").
//   manual      the code goes to a real person's mailbox (the personal seed sets, e.g. toula.voulgaris@...):
//               the run writes state/otp-requests/<PNR>.txt and waits for someone to drop the six digits
//               into state/otp-inbox/<PNR>.txt (or `npm run otp -- <PNR> <code>`).
//   fixed       OTP_FIXED_CODE, for a LOCAL backend with OTP_SELF_MINT only. Refused unless ALLOW_FIXED_OTP=1.
//
// A request to the SHARED inbox goes through one global queue (a file lock shared by all workers and
// runs), at least OTP.gapMs after the previous request: that is the only thing keeping two same-name
// bookings from reading each other's code. A booking with its OWN inbox (`own: true`, written by the
// seeder's --inbox-per-case) needs neither, so those run in parallel. A ledger refuses a 6th code per
// booking per 24 h either way.
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import lockfile from 'proper-lockfile';
import { OTP, STATE_DIR, ensureDir } from './config';
import type { ChatPage } from './chat';
import { envSettings, profileArgs } from './envs';

export type OtpProvider =
  /** `own`: the inbox belongs to this one booking (the seeder's per-case address), so nothing else's mail lands in it */
  | { provider: 'mailinator'; domain?: string; inbox?: string; own?: boolean }
  | { provider: 'manual'; sentTo?: string }
  | { provider: 'fixed' };

export class OtpNotSent extends Error { constructor(m = "chat says the code couldn't be sent") { super(m); } }
export class OtpBudgetExceeded extends Error {}
export class OtpUnavailable extends Error {}

// ---------------------------------------------------------------- parsing (5.3)

/**
 * Six digits AFTER "verification" — the HTML carries six-digit CSS colours (#005078), so a bare \d{6}
 * picks the wrong number. A short run of non-digits may sit between (French wording differs); styles
 * and tags are stripped by bodyText() first, so no colour survives to be matched.
 */
export const CODE = /v[ée]rification[^\d#]{0,80}?(\d{6})(?!\d)/i;
/** English greeting "<FIRSTNAME>, use the code below…". French emails do not match; see firstNameMatches. */
export const GREETING = /([A-Za-zÀ-ÿ'-]+),\s+use the code/i;

export function bodyText(msg: any): string {
  let t = (msg?.parts ?? []).map((p: any) => p?.body ?? '').join(' ') || msg?.body || '';
  t = t.replace(/<style[\s\S]*?<\/style>/gi, ' ').replace(/<[^>]+>/g, ' ').replace(/&nbsp;/g, ' ')
    .replace(/[^{}]*\{[^{}]*\}/g, ' ');
  return t.replace(/\s+/g, ' ');
}

export function extractCode(body: string): string | undefined { return body.match(CODE)?.[1]; }

/** English: the greeting names the passenger. French: the name appears somewhere in the body. */
export function firstNameMatches(body: string, firstName: string): boolean {
  const g = body.match(GREETING);
  if (g) return g[1].toLowerCase() === firstName.toLowerCase();
  return new RegExp(`\\b${firstName.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`, 'i').test(body);
}

// ---------------------------------------------------------------- Mailinator (5.2)

let cachedToken: string | undefined;

/** MAILINATOR_API_TOKEN (env or .env), else Secrets Manager via the aws CLI. Never printed. */
export function mailinatorToken(): string {
  if (cachedToken) return cachedToken;
  if (process.env.MAILINATOR_API_TOKEN) return (cachedToken = process.env.MAILINATOR_API_TOKEN);
  try {
    // an explicit profile: the default one's credentials expire on their own schedule, and an expired
    // default silently broke a run mid-chat while int-cce (the profile everything else here uses) was fine
    const profile = process.env.MAILINATOR_PROFILE || process.env.AWS_PROFILE || envSettings().mailinator.profile;
    const raw = execFileSync('aws', ['secretsmanager', 'get-secret-value', '--secret-id', OTP.secretId,
      '--region', OTP.secretRegion, ...profileArgs(profile), '--query', 'SecretString', '--output', 'text'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], timeout: 30_000 }).trim();
    let tok = raw;
    try { const j = JSON.parse(raw); tok = j.token ?? j.api_token ?? j.apiToken ?? j.MAILINATOR_API_TOKEN ?? Object.values(j)[0]; } catch { /* plain string */ }
    if (!tok) throw new Error('empty secret');
    return (cachedToken = String(tok));
  } catch (e: any) {
    const why = String(e?.stderr || e?.message || e).split('\n').find(l => l.trim()) || 'unknown error';
    throw new OtpUnavailable(`could not read the Mailinator token (set MAILINATOR_API_TOKEN or refresh AWS creds): ${why.slice(0, 200)}`);
  }
}

interface InboxMsg { id: string; subject?: string; from?: string; seconds_ago: number }

async function mailinator(pathPart: string): Promise<any> {
  const res = await fetch(`https://mailinator.com/api/v2/${pathPart}`, { headers: { Authorization: mailinatorToken() } });
  if (res.status === 401 || res.status === 403) throw new OtpUnavailable(`Mailinator API ${res.status} (bad or expired token)`);
  if (!res.ok) throw new Error(`Mailinator API ${res.status}`);
  return res.json();
}

export async function listInbox(domain = OTP.mailinatorDomain, inbox = OTP.mailinatorInbox): Promise<InboxMsg[]> {
  const j = await mailinator(`domains/${domain}/inboxes/${inbox}`);
  return (j.msgs ?? []) as InboxMsg[];
}

export async function readMessage(id: string, domain = OTP.mailinatorDomain, inbox = OTP.mailinatorInbox): Promise<any> {
  return mailinator(`domains/${domain}/inboxes/${inbox}/messages/${id}`);
}

export async function pollNewCode(before: Set<string>, firstName: string, waitMs: number,
  domain = OTP.mailinatorDomain, inbox = OTP.mailinatorInbox, matchName = true): Promise<string> {
  const end = Date.now() + waitMs;
  const seen = new Set<string>();
  while (Date.now() < end) {
    const fresh = (await listInbox(domain, inbox)).filter(m => !before.has(m.id) && !seen.has(m.id))
      .sort((a, b) => a.seconds_ago - b.seconds_ago);
    for (const m of fresh) {
      const body = bodyText(await readMessage(m.id, domain, inbox));
      if (matchName && !firstNameMatches(body, firstName)) { seen.add(m.id); continue; }
      const c = extractCode(body);
      if (c) return c;
    }
    await sleep(5000);
  }
  throw new OtpUnavailable(`no OTP for ${firstName} within ${Math.round(waitMs / 1000)} s`);
}

/**
 * The code already sent to a booking's OWN inbox since `sinceMs` (the chat's start): for when the chat
 * requested it before the broker could (the customer pressed "Email" itself). Only an own inbox is safe
 * for this: in the shared one, "the newest code" may be another run's.
 */
export async function codeSince(p: OtpProvider, sinceMs: number, waitMs = OTP.waitMs): Promise<string> {
  if (p.provider !== 'mailinator' || !p.own) throw new OtpUnavailable('a code already requested can only be read from a booking\'s own inbox');
  const elapsed = (Date.now() - sinceMs) / 1000 + 5;
  const older = new Set((await listInbox(p.domain, p.inbox)).filter(m => m.seconds_ago > elapsed).map(m => m.id));
  return pollNewCode(older, '', waitMs, p.domain, p.inbox, false);
}

// ---------------------------------------------------------------- queue + ledger (5.4, 5.5)

const LOCK = path.join(STATE_DIR, 'otp.lock');
const LEDGER = path.join(STATE_DIR, 'otp-ledger.json');
const LAST = path.join(STATE_DIR, 'otp-last-request.json');

function readJson<T>(file: string, dflt: T): T {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')) as T; } catch { return dflt; }
}
function writeJson(file: string, v: unknown): void {
  ensureDir(path.dirname(file));
  fs.writeFileSync(file, JSON.stringify(v, null, 2));
}

export const ledger = {
  uses(booking: string, now = Date.now()): number[] {
    const all = readJson<Record<string, string[]>>(LEDGER, {});
    return (all[booking] ?? []).map(t => Date.parse(t)).filter(t => now - t < 24 * 3600_000);
  },
  assertBudget(booking: string): void {
    const n = this.uses(booking).length;
    if (n >= OTP.maxPerBookingPerDay)
      throw new OtpBudgetExceeded(`${booking} already used ${n} codes in 24 h (max ${OTP.maxPerBookingPerDay})`);
  },
  record(booking: string): void {
    const all = readJson<Record<string, string[]>>(LEDGER, {});
    all[booking] = [...(all[booking] ?? []), new Date().toISOString()].slice(-20);
    writeJson(LEDGER, all);
  },
};

async function waitSinceLastRequest(gapMs: number): Promise<void> {
  const last = readJson<{ at?: number }>(LAST, {}).at ?? 0;
  const wait = last + gapMs - Date.now();
  if (wait > 0) await sleep(wait);
}
function markRequest(): void { writeJson(LAST, { at: Date.now() }); }

async function withQueue<T>(fn: () => Promise<T>): Promise<T> {
  ensureDir(STATE_DIR);
  if (!fs.existsSync(LOCK)) fs.writeFileSync(LOCK, '');
  const release = await lockfile.lock(LOCK, {
    retries: { retries: 400, minTimeout: 2000, maxTimeout: 5000 }, stale: 10 * 60_000,
  });
  try { return await fn(); } finally { await release(); }
}

// ---------------------------------------------------------------- the broker

export interface OtpRequest { firstName: string; booking: string; provider: OtpProvider }

/** Whether this booking's code has to wait its turn in the global queue: only a shared inbox does. */
export function needsQueue(p: OtpProvider): boolean {
  return !(p.provider === 'mailinator' && p.own);
}

/**
 * Tap the email channel and return the code. A shared inbox holds the global queue until the code is
 * read; a booking's own inbox does not queue, wait out the gap, or need the first name to match.
 */
export async function getOtp(chat: ChatPage, req: OtpRequest): Promise<string> {
  ledger.assertBudget(req.booking);
  if (req.provider.provider === 'mailinator') mailinatorToken();   // fail before tapping, not after
  if (req.provider.provider === 'fixed' && (!process.env.OTP_FIXED_CODE || process.env.ALLOW_FIXED_OTP !== '1'))
    throw new OtpUnavailable('fixed OTP needs OTP_FIXED_CODE and ALLOW_FIXED_OTP=1 (local backend only, never QA)');

  const p = req.provider;
  const request = async (): Promise<string> => {
    const before = p.provider === 'mailinator' ? new Set((await listInbox(p.domain, p.inbox)).map(m => m.id)) : new Set<string>();
    if (p.provider === 'manual') clearManual(req.booking);

    await chat.tap(/^(Email|Courriel)/, { settle: false });
    ledger.record(req.booking);
    const notSent = await chat.root().getByText(/couldn't be sent|could not be sent|n'a pas pu être envoyé/i)
      .last().waitFor({ state: 'visible', timeout: 6000 }).then(() => true, () => false);
    if (notSent) throw new OtpNotSent();

    switch (p.provider) {
      case 'mailinator': return pollNewCode(before, req.firstName, OTP.waitMs, p.domain, p.inbox, !p.own);
      case 'manual': return waitForManual(req.booking, req.firstName, p.sentTo, OTP.manualWaitMs);
      case 'fixed': return process.env.OTP_FIXED_CODE!;
    }
  };
  if (!needsQueue(p)) return request();
  return withQueue(async () => {
    await waitSinceLastRequest(OTP.gapMs);
    markRequest();
    return request();
  });
}

// ---------------------------------------------------------------- manual drop box

const REQ_DIR = path.join(STATE_DIR, 'otp-requests');
const INBOX_DIR = path.join(STATE_DIR, 'otp-inbox');

function clearManual(booking: string): void {
  for (const d of [REQ_DIR, INBOX_DIR]) fs.rmSync(path.join(d, `${booking}.txt`), { force: true });
}

async function waitForManual(booking: string, firstName: string, sentTo: string | undefined, waitMs: number): Promise<string> {
  ensureDir(REQ_DIR); ensureDir(INBOX_DIR);
  const ask = `${new Date().toISOString()} code requested for ${booking} (${firstName}) -> ${sentTo ?? 'the booking contact'}\n` +
    `drop the 6 digits into state/otp-inbox/${booking}.txt  or run: npm run otp -- ${booking} <code>\n`;
  fs.writeFileSync(path.join(REQ_DIR, `${booking}.txt`), ask);
  console.log(`[otp] ${ask.trim()}`);
  const end = Date.now() + waitMs;
  const file = path.join(INBOX_DIR, `${booking}.txt`);
  while (Date.now() < end) {
    const c = fs.existsSync(file) ? fs.readFileSync(file, 'utf8').match(/\b(\d{6})\b/)?.[1] : undefined;
    if (c) { clearManual(booking); return c; }
    await sleep(2000);
  }
  clearManual(booking);
  throw new OtpUnavailable(`nobody dropped a code for ${booking} within ${Math.round(waitMs / 60_000)} min`);
}

function sleep(ms: number): Promise<void> { return new Promise(r => setTimeout(r, ms)); }
