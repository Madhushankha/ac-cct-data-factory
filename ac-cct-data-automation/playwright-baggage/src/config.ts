// Paths and settings shared by the suite, the OTP broker and the scripts.
import fs from 'node:fs';
import path from 'node:path';
import { CHAT_HOST_DIR } from './external';

export const ROOT = path.resolve(__dirname, '..');

/** Load ROOT/.env into process.env once (KEY=VALUE lines; existing env wins). No dependency. */
export function loadDotEnv(file = path.join(ROOT, '.env')): void {
  if (!fs.existsSync(file)) return;
  for (const line of fs.readFileSync(file, 'utf8').split(/\r?\n/)) {
    const m = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
    if (!m || line.trimStart().startsWith('#')) continue;
    const v = m[2].replace(/^(['"])(.*)\1$/, '$2');
    if (process.env[m[1]] === undefined) process.env[m[1]] = v;
  }
}
loadDotEnv();

// resolved in src/external.ts, which knows where this project sits; a walk up from here was
// only correct for one directory layout
export const CHAT_DIR = CHAT_HOST_DIR;
export const CHAT_PORT = Number(process.env.CHAT_PORT || 8765);
export const BASE_URL = process.env.BASE_URL || `http://localhost:${CHAT_PORT}`;

/**
 * The chat page under test. Default: the hosted INT stable preview, whose widget calls the same INT
 * gateway (rg9r0wtonl, cmp-v2.ac-cct-int) the agentic-qa seed and agent runs use. CHAT_URL=local uses the
 * public-qa copy served by scripts/serve.js instead (its widget calls bcnxq39777).
 * The stable page has a password screen; CHAT_PASSWORD (in .env) is typed into it.
 */
export const STABLE_URL = 'https://cct-chat-stable.ac-cct-int.cloud.aircanada.com/';
export const CHAT_URL = !process.env.CHAT_URL ? STABLE_URL
  : process.env.CHAT_URL === 'local' ? `${BASE_URL}/index.html` : process.env.CHAT_URL;
export const LOCAL_CHAT = CHAT_URL.startsWith(BASE_URL);

export const SCENARIO_DIR = path.join(ROOT, 'scenarios');
export const DATA_DIR = path.join(ROOT, 'data');
/** Cross-run state: OTP lock, OTP ledger, booking ledger, manual OTP drop box. Survives runs on purpose. */
export const STATE_DIR = path.join(ROOT, 'state');
export const OUT_DIR = path.join(ROOT, 'out');

export const OTP = {
  /** Minimum gap between ANY two code requests, across all workers and runs. */
  gapMs: Number(process.env.OTP_GAP_MS || 70_000),
  /** How long to poll Mailinator for the new message. */
  waitMs: Number(process.env.OTP_WAIT_MS || 180_000),
  /** How long a manual-provider run waits for a person to drop the code in state/otp-inbox/<PNR>.txt. */
  manualWaitMs: Number(process.env.OTP_MANUAL_WAIT_MS || 10 * 60_000),
  maxPerBookingPerDay: Number(process.env.OTP_MAX_PER_DAY || 5),
  mailinatorDomain: process.env.MAILINATOR_DOMAIN || 'ae-qa1-aircanada.mailinator.com',
  mailinatorInbox: process.env.MAILINATOR_INBOX || 'lahiru',
  secretId: process.env.MAILINATOR_SECRET_ID || 'cct-qa/mailinator-token',
  secretRegion: process.env.MAILINATOR_SECRET_REGION || 'ca-central-1',
};

/** The current run's output folder. globalSetup sets RUN_DIR; workers inherit it. */
export function runDir(): string {
  const dir = process.env.RUN_DIR || path.join(OUT_DIR, 'adhoc');
  fs.mkdirSync(dir, { recursive: true });
  return dir;
}

export function ensureDir(p: string): string {
  fs.mkdirSync(p, { recursive: true });
  return p;
}
