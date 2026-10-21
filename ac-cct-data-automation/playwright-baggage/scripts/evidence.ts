// out/<run>/ -> out/<run>/evidence/: run<n>.html per test, index.html, evidence.zip (src/evidence.ts renders).
//   npm run evidence                          the newest out/<run> folder
//   npm run evidence -- out/<run>             a given one
//   npm run evidence -- out/<run> --out dir   somewhere else
// Reads results/, transcripts/, dashboard/, emails/ and screenshots/ (PNG/JPEG only; videos are ignored).
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { renderIndex, renderTest, summarize, zip, type EvidenceData, type Shot, type SkippedItem } from '../src/evidence';

const ROOT = path.resolve(__dirname, '..');

const readJson = (file: string): any => {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')); } catch { return undefined; }
};

function newestRun(): string {
  const out = path.join(ROOT, 'out');
  const dirs = fs.readdirSync(out).filter(d => fs.existsSync(path.join(out, d, 'run.json'))).sort();
  if (!dirs.length) throw new Error('no out/<run> folder with a run.json');
  return path.join(out, dirs[dirs.length - 1]);
}

/** Run numbers that have a result or a transcript. */
function runNumbers(dir: string): number[] {
  const n = new Set<number>();
  for (const sub of ['results', 'transcripts']) {
    const d = path.join(dir, sub);
    if (!fs.existsSync(d)) continue;
    for (const f of fs.readdirSync(d)) { const m = /^run(\d+)\.json$/.exec(f); if (m) n.add(Number(m[1])); }
  }
  return [...n].sort((a, b) => a - b);
}

/** The GOAL_PLAN item this run came from (for the Jira key and the skipped rows): run.json `plan`, else any plan in data/plans with the same PNR. */
function planItem(runMeta: any, r: any): any {
  const files: string[] = [];
  if (runMeta?.plan) files.push(path.resolve(ROOT, String(runMeta.plan)));
  const plans = path.join(ROOT, 'data', 'plans');
  if (fs.existsSync(plans)) files.push(...fs.readdirSync(plans).filter(f => f.endsWith('.json')).map(f => path.join(plans, f)));
  for (const f of files) {
    const p = readJson(f);
    const items: any[] = Array.isArray(p) ? p : Array.isArray(p?.items) ? p.items : [];
    const hit = items.find(i => i?.pnr === r.booking && (!i.caseId || !r.caseId || i.caseId === r.caseId));
    if (hit) return hit;
  }
  return undefined;
}

/** Collect a picture once by content hash; returns its key, or undefined when the file is missing or not an image. */
function adder(dir: string, images: Record<string, string>) {
  return (rel: string | undefined): string | undefined => {
    if (!rel || !/\.(png|jpe?g)$/i.test(rel)) return undefined;
    const file = path.join(dir, rel);
    if (!fs.existsSync(file)) return undefined;
    const bytes = fs.readFileSync(file);
    const key = crypto.createHash('sha1').update(bytes).digest('hex').slice(0, 12);
    if (!images[key]) images[key] = `data:image/${/png$/i.test(rel) ? 'png' : 'jpeg'};base64,${bytes.toString('base64')}`;
    return key;
  };
}

function load(dir: string, n: number, runMeta: any, withScreens = false): EvidenceData {
  const result = readJson(path.join(dir, 'results', `run${n}.json`));
  const transcript = readJson(path.join(dir, 'transcripts', `run${n}.json`));
  const live = readJson(path.join(dir, 'transcripts', `run${n}.live.json`));
  const r = { ...(transcript ?? {}), ...(result ?? {}) };
  const item = planItem(runMeta, r);

  const images: Record<string, string> = {};
  const add = adder(dir, images);
  const shotsDir = path.join(dir, 'screenshots');
  const allShots = fs.existsSync(shotsDir) ? fs.readdirSync(shotsDir) : [];
  // the chat as the customer saw it: the tall full-chat screenshot (or its scrolled parts), always included
  const chatShots = allShots.filter(f => r.booking && new RegExp(`^run${n}_${r.booking}(_part\\d+)?\\.png$`).test(f))
    .sort().map(f => add(`screenshots/${f}`)).filter((k): k is string => !!k);
  // the step/identity pictures only with --with-screens
  const shotFiles = withScreens ? allShots : [];
  const screens: Shot[] = [];
  const push = (f: string, label: string) => { const key = add(`screenshots/${f}`); if (key) screens.push({ key, label }); };
  // the chat step by step, then the identity check pages, then the whole conversation
  for (const f of shotFiles.filter(f => new RegExp(`^run${n}_step\\d+\\.png$`).test(f)).sort()) push(f, `Step ${Number(/step(\d+)/.exec(f)![1])}`);
  for (const f of shotFiles.filter(f => new RegExp(`^run${n}_persona.*\\.png$`).test(f)).sort()) push(f, /after/.test(f) ? 'Identity check (after)' : 'Identity check');

  const failures: any[] = r.failures ?? [];
  // each failure's own screenshot is the same full chat again: the checkpoint links point into the chat
  // instead, so these come only with --with-screens
  const failureShots: Record<string, string> = {};
  if (withScreens) failures.forEach((f, i) => { const key = add(f.screenshot); if (key) failureShots[String(f.id ?? i)] = key; });

  const skipped: SkippedItem[] | undefined = r.skipped ?? item?.skipped;
  return {
    run: n, runName: runMeta?.name, title: r.title ?? `run ${n}`, caseId: r.caseId ?? item?.caseId, jiraKey: r.jiraKey ?? item?.jiraKey,
    booking: r.booking, passenger: r.passenger, caseNumber: r.caseNumber, result: r.result ?? 'unknown',
    startedAt: r.startedAt, endedAt: r.endedAt, endedAtStep: r.endedAt_step,
    messages: transcript?.messages ?? live?.messages ?? [],
    checkpoints: r.checkpoints, skipped: skipped?.length ? skipped : undefined,
    dashboard: r.dashboard, verification: readJson(path.join(dir, 'dashboard', `run${n}.json`)),
    emails: r.emails ?? readJson(path.join(dir, 'emails', `run${n}.json`)),
    failures, decisions: r.decisions ?? live?.decisions, notes: r.notes,
    screens, failureShots, chatShots, images,
  };
}

function main(): void {
  const args = process.argv.slice(2);
  const o = args.indexOf('--out');
  const outArg = o >= 0 ? args[o + 1] : undefined;
  const pos = args.filter((a, i) => !a.startsWith('--') && (o < 0 || i !== o + 1));
  const withScreens = args.includes('--with-screens');
  const dir = pos[0] ? path.resolve(pos[0]) : newestRun();
  if (!fs.existsSync(dir)) throw new Error(`no such run folder: ${dir}`);
  const outDir = outArg ? path.resolve(outArg) : path.join(dir, 'evidence');
  fs.mkdirSync(outDir, { recursive: true });

  const runMeta = readJson(path.join(dir, 'run.json')) ?? {};
  const files: { name: string; data: Buffer }[] = [];
  const rows = runNumbers(dir).map(n => {
    const data = load(dir, n, runMeta, withScreens);
    const name = `run${n}.html`;
    const html = Buffer.from(renderTest(data), 'utf8');
    fs.writeFileSync(path.join(outDir, name), html);
    files.push({ name, data: html });
    console.log(`  ${name}  ${(html.length / 1024).toFixed(0)} KB  ${data.result}`);
    return summarize(data, name);
  });
  const index = Buffer.from(renderIndex(rows, { name: runMeta.name ?? path.basename(dir), startedAt: runMeta.startedAt }), 'utf8');
  fs.writeFileSync(path.join(outDir, 'index.html'), index);
  files.unshift({ name: 'index.html', data: index });
  const z = zip(files);
  fs.writeFileSync(path.join(outDir, 'evidence.zip'), z);
  console.log(`evidence: ${rows.length} test(s) -> ${outDir} (index.html, evidence.zip ${(z.length / 1024).toFixed(0)} KB)`);
}

main();
