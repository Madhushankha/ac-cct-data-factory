// results/run<n>.json -> results.json + report.md (guide 11.2).
//   npm run report                 the newest out/<run> folder
//   npm run report -- out/<run>    a given one
import fs from 'node:fs';
import path from 'node:path';
import type { RunResult } from '../src/steps';

const esc = (s: unknown) => String(s ?? '').replace(/\|/g, '\\|').replace(/\r?\n/g, ' ');
const hm = (iso?: string) => (iso ? new Date(iso).toTimeString().slice(0, 5) : '?');

export function loadResults(dir: string): RunResult[] {
  const rd = path.join(dir, 'results');
  if (!fs.existsSync(rd)) return [];
  return fs.readdirSync(rd).filter(f => /^run\d+\.json$/.test(f))
    .map(f => JSON.parse(fs.readFileSync(path.join(rd, f), 'utf8')) as RunResult)
    .sort((a, b) => a.run - b.run);
}

export function renderReport(runs: RunResult[], meta: { name?: string; startedAt?: string; workers?: number; build?: string | null } = {}): string {
  const start = meta.startedAt ?? runs.map(r => r.startedAt).sort()[0];
  const end = runs.map(r => r.endedAt ?? r.startedAt).sort().pop();
  const pools = [...new Set(runs.map(r => r.pool).filter(Boolean))];
  const codes = runs.reduce((n, r) => n + (r.otpCodes ?? 0), 0);
  const gap = Math.round(Number(process.env.OTP_GAP_MS || 70_000) / 1000);
  const header = [
    `# Baggage ${meta.name ?? 'run'}`,
    '',
    `public-qa, ${start?.slice(0, 10)} ${hm(start)}–${hm(end)}, build ${meta.build || 'unknown'}. ${runs.length} runs, ${meta.workers ?? '?'} in parallel.`,
    `Bookings: ${pools.join(', ') || '—'}. OTP: ${codes} codes used, queue gap ${gap} s.`,
    '',
  ];

  const t1 = [
    '## Table 1: one row per run',
    '',
    '| Run | Path | Booking | Session id | Board steps seen (in order, with step IDs) | Ended at | Result | Failures (issue ids) | Screenshot |',
    '|---|---|---|---|---|---|---|---|---|',
    ...runs.map(r => `| ${r.run} | ${esc(r.title)} | ${esc(r.booking)} | \`${esc(r.sessionId ?? '—')}\` | ${esc(r.stepsSeen.join(', ') || '—')} | ${esc(r.endedAt_step)} | ${esc(r.result)} | ${r.failures.map(f => `#${f.run}.${f.id}${f.known ? ` (${f.known})` : ''}`).join(', ') || '—'} | ${r.screenshots[0] ? `![](${r.screenshots[0]})` : '—'} |`),
    '',
  ];

  const failures = runs.flatMap(r => r.failures);
  const t2 = [
    '## Table 2: one row per failed step (the fix list)',
    '',
    '| # | Run | Session id | Step (ID + the board\'s message or condition) | Expected (board / user story) | Got (bot\'s words, layout, buttons) | What I did just before | Kind | Severity |',
    '|---|---|---|---|---|---|---|---|---|',
    ...failures.map(f => `| ${f.run}.${f.id} | ${f.run} | \`${esc(f.sessionId ?? '—')}\` | ${esc(f.step)} | ${esc(f.expected)} | ${esc(f.got)} | ${esc(f.before)} | ${f.kind} | ${f.known ? `known (${f.known})` : f.severity} |`),
    ...(failures.length ? [] : ['| — | | | | | | | | |']),
    '',
  ];

  const count = (p: (r: RunResult) => boolean) => runs.filter(p).length;
  const fresh = failures.filter(f => !f.known);
  const expected = [...new Set(runs.flatMap(r => r.stepsExpected ?? []))];
  const seen = new Set(runs.flatMap(r => r.stepsSeen));
  const notes = runs.flatMap(r => (r.notes ?? []).map(n => `run ${r.run}: ${n}`));
  const summary = [
    '## Summary',
    '',
    `- Runs: ${count(r => r.result === 'pass')} pass / ${count(r => r.result === 'fail')} fail / ${count(r => r.result.startsWith('known'))} known / ${count(r => r.result.startsWith('blocked'))} blocked.`,
    ...runs.filter(r => r.result.startsWith('blocked')).map(r => `  - run ${r.run} ${r.booking}: ${r.result}`),
    `- New failures: ${fresh.length || 'none'}`,
    ...fresh.map(f => `  - **#${f.run}.${f.id}** run ${f.run}, session \`${f.sessionId ?? '—'}\`, ${f.step} (${f.kind}, ${f.severity}): ${esc(f.got)}`),
    `- Known issues hit: ${[...new Set(failures.filter(f => f.known).map(f => f.known))].join(', ') || 'none'}`,
    `- Board steps reached: ${[...seen].join(', ') || 'none'}`,
    `- Board steps not reached: ${expected.filter(s => !seen.has(s)).join(', ') || 'none'}`,
    ...(notes.length ? ['- Notes (optional checks):', ...notes.map(n => `  - ${esc(n)}`)] : []),
    '',
  ];
  return [...header, ...t1, ...t2, ...summary].join('\n');
}

export function writeReport(dir: string): string {
  const runs = loadResults(dir);
  let meta: any = {};
  try { meta = JSON.parse(fs.readFileSync(path.join(dir, 'run.json'), 'utf8')); } catch { /* adhoc */ }
  fs.writeFileSync(path.join(dir, 'results.json'), JSON.stringify(runs, null, 2));
  const file = path.join(dir, 'report.md');
  fs.writeFileSync(file, renderReport(runs, meta));
  return file;
}

if (require.main === module) {
  const out = path.join(__dirname, '..', 'out');
  const dir = process.argv[2] ? path.resolve(process.argv[2])
    : fs.readdirSync(out).filter(d => fs.existsSync(path.join(out, d, 'results'))).sort().map(d => path.join(out, d)).pop();
  if (!dir) { console.error('no run folder with results/ under out/'); process.exit(1); }
  console.log(writeReport(dir));
}
