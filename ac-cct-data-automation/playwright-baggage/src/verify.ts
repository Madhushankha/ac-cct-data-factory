// After a goal chat: what the Claims Dashboard and the mailbox say about the case the chat opened.
//
// The AI judge reads the chat. These checks read the systems behind it, and decide nothing by model:
//   1. the case number (CCD-…) the chat quoted, read from the transcript
//   2. GET <dashboard>/v1/testing/cases/<CCD>/verification   (x-api-key TESTING_CASE_INFO_API_KEY)
//      -> sections[].items[] {id: CP102..CP156, fact, present: true|false|null, value, source, note}
//      each dashboard row of the Jira test that the plan mapped to an item id is checked against it
//   3. the case's e-mails: the booking's own inbox when it has one, else the shared inbox narrowed to
//      mail that quotes the case number; each must carry the case number, and a payout the amount
//
// The key is read from Secrets Manager with the int-cce profile, kept in memory, never printed or
// written. The dashboard and the mail lag the chat by seconds to minutes, so both are retried.
import { execFileSync } from 'node:child_process';
import { listInbox, readMessage, bodyText, type OtpProvider } from './otp';
import { OTP } from './config';
import type { Message } from './transcript';
import { ENVS, profileArgs } from './envs';

/** A Jira dashboard row as the plan carries it (ac-cct-data-seed domain/goal_plan.py). */
export interface DashboardCheck { jiraCheckpoint?: string; api?: string | null; check: string; expected?: string | null; manual?: boolean }
export interface EmailCheck { jiraCheckpoint?: string; check: string; expected?: string | null }

export interface VerificationItem { id: string; fact?: string; present: boolean | null; value?: unknown; source?: string; note?: string | null }
export interface Verification { caseNumber?: string; sections?: { section: string; items: VerificationItem[] }[] }

/** pass: present and every word of the expected value found · review: present, value differs or can't be read
 *  by words · fail: the dashboard says absent · ui: decided in the UI, not checkable here · missing: no such item
 *  · manual/unmapped: not checked here */
export type DashStatus = 'pass' | 'review' | 'fail' | 'ui' | 'missing' | 'manual' | 'unmapped';
export interface DashResult { jiraCheckpoint?: string; api?: string | null; check: string; expected?: string | null; status: DashStatus; value?: string }

/** a dashboard row that expects nothing there: absent is its pass */
export const EXPECTS_NONE = /\b(should be (empty|none|blank)|is empty|are empty|no (related|ancillary|attachments?|banners?|duplicates?)|expected [\w\s]* should be none|none\b)/i;

export const CASE_NUMBER =/\bCCD-\d{5,9}-[A-Z0-9]{4,8}\b/;

// ---------------------------------------------------------------- pure

/** The last case number the assistant quoted (a chat can mention an older case before opening its own). */
export function caseNumberFrom(messages: Pick<Message, 'who' | 'text'>[]): string | undefined {
  for (let i = messages.length - 1; i >= 0; i--) {
    if (messages[i].who === 'you') continue;
    const m = messages[i].text.match(CASE_NUMBER);
    if (m) return m[0];
  }
  return undefined;
}

/** Words for a loose comparison: codes and labels meet halfway ("not_eligible" ~ "Not Eligible"). */
export function words(v: unknown): string[] {
  const s = (typeof v === 'string' ? v : JSON.stringify(v ?? '')).normalize('NFKD').toLowerCase();
  return s.replace(/[_→>\-/]+/g, ' ').replace(/[^a-z0-9.$ ]+/g, ' ').split(/\s+/).filter(w => w.length > 1);
}

export function itemsById(v: Verification): Map<string, VerificationItem> {
  const out = new Map<string, VerificationItem>();
  for (const s of v.sections ?? []) for (const it of s.items ?? []) out.set(it.id, it);
  return out;
}

/** Each mapped dashboard row against the API's item. Nothing here fails on wording alone: a value that
 *  does not contain the expected words is "review", for a person, because labels and stored codes differ. */
export function checkDashboard(checks: DashboardCheck[], v: Verification): DashResult[] {
  const items = itemsById(v);
  return checks.map(c => {
    const base = { jiraCheckpoint: c.jiraCheckpoint, api: c.api, check: c.check, expected: c.expected ?? null };
    if (c.manual) return { ...base, status: 'manual' as const };
    if (!c.api) return { ...base, status: 'unmapped' as const };
    const it = items.get(c.api);
    if (!it) return { ...base, status: 'missing' as const };
    const value = JSON.stringify(it.value ?? null).slice(0, 400);
    if (it.present === null) return { ...base, status: 'ui' as const, value };
    // "should be empty / none / no related cases": the API's absent is exactly what the test asks for
    if (it.present === false) return { ...base, status: EXPECTS_NONE.test(`${c.check} ${c.expected ?? ''}`) ? 'pass' as const : 'fail' as const, value };
    if (!c.expected) return { ...base, status: 'pass' as const, value };
    const have = new Set(words(it.value));
    const want = words(c.expected);
    return { ...base, status: want.length && want.every(w => have.has(w)) ? 'pass' as const : 'review' as const, value };
  });
}

/** The amount the dashboard says was chosen (CP132), e.g. "400.00", for the payout e-mail check. */
export function chosenAmount(v: Verification): string | undefined {
  const it = itemsById(v).get('CP132');
  const amount = (it?.value as any)?.amount;
  return it?.present && amount ? String(amount) : undefined;
}

export interface MailSeen { id: string; subject: string; from?: string; quotesCase: boolean; amountFound?: boolean; snippet: string }

/** Which of the inbox's messages belong to the case, and whether each quotes the case number and the amount. */
export function caseMails(mails: { id: string; subject?: string; from?: string; body: string }[], caseNumber: string,
                          opts: { ownInbox: boolean; amount?: string }): MailSeen[] {
  const amt = opts.amount ? opts.amount.replace(/\.00$/, '') : undefined;
  return mails
    .map(m => ({ m, quotes: m.body.includes(caseNumber) || (m.subject ?? '').includes(caseNumber) }))
    // a shared inbox holds every case's mail: only what quotes this case is evidence for it
    .filter(x => opts.ownInbox || x.quotes)
    .map(({ m, quotes }) => ({
      id: m.id, subject: m.subject ?? '', from: m.from, quotesCase: quotes,
      amountFound: amt ? new RegExp(`\\$?\\s?${amt.replace('.', '\\.')}(\\.00)?\\b`).test(m.body) : undefined,
      snippet: m.body.replace(/\s+/g, ' ').slice(0, 300),
    }));
}

// ---------------------------------------------------------------- the systems

let cachedKey: string | undefined;

/**
 * Where an env's Claims Dashboard and its testing key live. BAT's key sits in BAT's own account, so it is
 * read with the BAT profile; reading it as int-cce fails. The BAT route went live by 2026-10-21.
 */
export function dashboardSource(env = 'int'): { url: string | undefined; secret: string; profile: string } {
  const d = (ENVS as Record<string, { dashboard: { url: string; secret: string; profile: string } }>)[env]?.dashboard;
  return {
    url: process.env.DASHBOARD_URL || d?.url,
    secret: process.env.DASHBOARD_SECRET_ID || d?.secret || 'cct-int-secrets',
    profile: process.env.DASHBOARD_PROFILE || d?.profile || 'int-cce',
  };
}

/** TESTING_CASE_INFO_API_KEY from the environment, else Secrets Manager through the aws CLI. Never printed. */
export function dashboardKey(env = 'int'): string {
  if (cachedKey) return cachedKey;
  if (process.env.TESTING_CASE_INFO_API_KEY) return (cachedKey = process.env.TESTING_CASE_INFO_API_KEY);
  const { secret, profile } = dashboardSource(env);
  try {
    const raw = execFileSync('aws', ['secretsmanager', 'get-secret-value', '--secret-id', secret, '--region', 'ca-central-1',
      ...profileArgs(profile), '--query', 'SecretString', '--output', 'text'],
      { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], timeout: 30_000 }).trim();
    const key = JSON.parse(raw).TESTING_CASE_INFO_API_KEY;
    if (!key) throw new Error(`no TESTING_CASE_INFO_API_KEY in ${secret}`);
    return (cachedKey = String(key));
  } catch (e: any) {
    const why = String(e?.stderr || e?.message || e).split('\n').find(l => l.trim()) || 'unknown error';
    throw new Error(`could not read the dashboard testing key (${secret}, profile ${profile}): ${why.slice(0, 160)}`);
  }
}

/** The verification document, retried while the case is not there yet (404) — the dashboard lags the chat. */
export async function fetchVerification(caseNumber: string, env = 'int',
                                        waitMs = Number(process.env.DASHBOARD_WAIT_MS || 180_000)): Promise<Verification> {
  const base = dashboardSource(env).url;
  if (!base) throw new Error(`no dashboard URL for ${env}`);
  const end = Date.now() + waitMs;
  for (;;) {
    const res = await fetch(`${base}/v1/testing/cases/${encodeURIComponent(caseNumber)}/verification`,
      { headers: { 'x-api-key': dashboardKey(env), accept: 'application/json' } });
    if (res.ok) return res.json() as Promise<Verification>;
    if (res.status === 401 || res.status === 403) throw new Error(`dashboard API ${res.status}: the testing key was refused`);
    if (res.status !== 404 || Date.now() > end) throw new Error(`dashboard API ${res.status} for ${caseNumber}`);
    await sleep(15_000);
  }
}

/** The inbox's messages newer than `sinceMs`, read in full, retried until at least one quotes the case. */
export async function readCaseMail(provider: OtpProvider, caseNumber: string, sinceMs: number,
                                   waitMs = Number(process.env.MAIL_WAIT_MS || 240_000)) {
  if (provider.provider !== 'mailinator') return { ownInbox: false, mails: [] as { id: string; subject?: string; from?: string; body: string }[] };
  const domain = provider.domain ?? OTP.mailinatorDomain, inbox = provider.inbox ?? OTP.mailinatorInbox;
  const end = Date.now() + waitMs;
  const read = new Map<string, { id: string; subject?: string; from?: string; body: string }>();
  for (;;) {
    const ageLimit = (Date.now() - sinceMs) / 1000 + 5;
    for (const m of (await listInbox(domain, inbox)).filter(m => m.seconds_ago <= ageLimit)) {
      if (!read.has(m.id)) read.set(m.id, { id: m.id, subject: m.subject, from: m.from, body: bodyText(await readMessage(m.id, domain, inbox)) });
    }
    const mails = [...read.values()];
    if (mails.some(m => m.body.includes(caseNumber)) || Date.now() > end) return { ownInbox: !!provider.own, mails };
    await sleep(15_000);
  }
}

function sleep(ms: number): Promise<void> { return new Promise(r => setTimeout(r, ms)); }
