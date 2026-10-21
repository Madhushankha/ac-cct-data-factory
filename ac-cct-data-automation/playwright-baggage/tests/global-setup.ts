// One output folder per `playwright test` invocation: out/<YYYY-MM-DD>_<name>/.
// Environment set here reaches every worker.
import { execFileSync, spawn } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { ENV, OUT_DIR, STATE_DIR } from '../src/config';

/**
 * The AI customer, the judge, the dashboard key and the Mailinator token all come through the int-cce SSO
 * session. If it has expired, open the sign-in (the browser opens; the person approves it) and wait for it,
 * rather than start chats that fail at their first model call. AWS_GUARD=0 skips the check.
 */
async function ensureAws(): Promise<void> {
  if (process.env.AWS_GUARD === '0' || process.env.TASK_ROLE === '1') return;   // inside AWS: the task role
  // int-cce for the models and Mailinator, plus the env's own profile (bat-sso reads BAT's dashboard key);
  // they share one SSO session, so one sign-in refreshes both
  const profile = process.env.AWS_GUARD_PROFILE || 'int-cce';
  const profiles = [...new Set([profile, ENV.awsProfile])];
  const ok = () => profiles.every(p => { try { execFileSync('aws', ['sts', 'get-caller-identity', '--profile', p], { stdio: 'ignore', timeout: 45_000 }); return true; } catch { return false; } });
  if (ok()) return;
  console.log(`[aws] the ${profile} sign-in has expired: opening it in the browser. Approve it there; waiting up to 15 min.`);
  spawn('aws', ['sso', 'login', '--profile', profile], { detached: true, stdio: 'ignore' }).unref();
  for (let waited = 0; waited < 15 * 60_000; waited += 10_000) {
    await new Promise(r => setTimeout(r, 10_000));
    if (ok()) { console.log(`[aws] signed in again after ${Math.round(waited / 1000) + 10}s`); return; }
  }
  throw new Error(`no AWS sign-in for ${profile} within 15 minutes`);
}

export default async function globalSetup(): Promise<void> {
  await ensureAws();
  const d = new Date();
  if (process.env.RUN_DIR) {
    // a launcher chose the folder (agentic-qa); still record the run header the report needs
    const dir = process.env.RUN_DIR;
    fs.mkdirSync(dir, { recursive: true });
    fs.mkdirSync(STATE_DIR, { recursive: true });
    const file = path.join(dir, 'run.json');
    if (!fs.existsSync(file)) fs.writeFileSync(file, JSON.stringify({
      startedAt: d.toISOString(), name: process.env.RUN_NAME || path.basename(dir),
      workers: Number(process.env.WORKERS || 5), build: process.env.BUILD_SHA || null,
    }, null, 2));
    return;
  }
  const day = d.toISOString().slice(0, 10);
  const hm = `${String(d.getHours()).padStart(2, '0')}${String(d.getMinutes()).padStart(2, '0')}`;
  const name = (process.env.RUN_NAME || 'baggage').replace(/[^\w-]+/g, '-');
  const dir = path.join(OUT_DIR, `${day}_${name}_${hm}`);
  fs.mkdirSync(dir, { recursive: true });
  fs.mkdirSync(STATE_DIR, { recursive: true });
  process.env.RUN_DIR = dir;
  process.env.RUN_STARTED = d.toISOString();
  fs.writeFileSync(path.join(dir, 'run.json'), JSON.stringify({
    startedAt: d.toISOString(), name, workers: Number(process.env.WORKERS || 5), build: process.env.BUILD_SHA || null,
    ...planned(),
  }, null, 2));
}

/** How many chats a goal run will hold and which plan they come from: a monitor shows the rest as queued. */
function planned(): { plan?: string; planned?: number; cases?: string[] } {
  const file = process.env.GOAL_PLAN;
  if (!file || !fs.existsSync(file)) return {};
  try {
    const items = JSON.parse(fs.readFileSync(file, 'utf8')) as { caseId?: string; pnr?: string }[];
    return { plan: path.resolve(file), planned: items.length, cases: items.map(i => i.caseId ?? i.pnr ?? '?') };
  } catch { return {}; }
}
