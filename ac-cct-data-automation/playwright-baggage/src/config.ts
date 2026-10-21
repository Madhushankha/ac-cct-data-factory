// Paths and settings shared by the suite, the OTP broker and the scripts.
import fs from 'node:fs';
import path from 'node:path';
import { ENVS, envSettings } from './envs';
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
 * The chat page under test. Default: the main INT page (INT_URL below). CHAT_URL=stable uses the hosted
 * INT stable preview, whose widget calls the same INT gateway (rg9r0wtonl, cmp-v2.ac-cct-int) the
 * agentic-qa seed and agent runs use; it has a password screen, and CHAT_PASSWORD (in .env) is typed into it.
 * CHAT_URL=local uses the public-qa copy served by scripts/serve.js instead (its widget calls bcnxq39777).
 */
export const STABLE_URL = 'https://cct-chat-stable.ac-cct-int.cloud.aircanada.com/';
/** The env this run targets (ENV=int|bat, see src/envs.ts): chat page, AWS profiles, dashboard, IDV. */
export const ENV = envSettings();
export const INT_URL = ENVS.int.chatUrl;
/**
 * The BAT chat (2026-10-21, by request): the uat2 site's trips page, which carries the chat widget. The site
 * sits behind HTTP Basic auth; UAT2_USER and UAT2_PASS in .env (typed there by the owner) are sent as the
 * browser's credentials and never written anywhere else.
 */
export const BAT_URL = ENVS.bat.chatUrl;
export const CHAT_URL = !process.env.CHAT_URL || process.env.CHAT_URL === 'int' || process.env.CHAT_URL === 'bat'
  ? ENVS[process.env.CHAT_URL === 'bat' ? 'bat' : ENV.name].chatUrl
  : process.env.CHAT_URL === 'stable' ? STABLE_URL
  : process.env.CHAT_URL === 'local' ? `${BASE_URL}/index.html` : process.env.CHAT_URL;
export const LOCAL_CHAT = CHAT_URL.startsWith(BASE_URL);
export const ON_BAT = CHAT_URL === BAT_URL;
/** Basic-auth credentials for the page, read from the .env variables the env names (values never logged). */
const auth = ENVS[ON_BAT ? 'bat' : ENV.name].basicAuth;
export const HTTP_CREDENTIALS = auth && process.env[auth.user] && process.env[auth.pass]
  ? { username: process.env[auth.user]!, password: process.env[auth.pass]! } : undefined;
/**
 * BAT's identity check passes by itself once the link is opened: open the Verify link, close it, then wait
 * for and click the chat's "Done" button (by request, 2026-10-21). PERSONA_MODE=done or =link overrides it.
 */
export const PERSONA_DONE = (process.env.PERSONA_MODE
  || (ENVS[ON_BAT ? 'bat' : ENV.name].idv === 'link-then-done-button' ? 'done' : 'link')) === 'done';

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
  mailinatorDomain: process.env.MAILINATOR_DOMAIN || ENV.mailinator.domain,
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
