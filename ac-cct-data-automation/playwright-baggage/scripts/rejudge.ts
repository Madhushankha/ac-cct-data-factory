// Judge a finished chat again, from its saved transcript, against a (possibly newer) plan.
//
//   npm run rejudge -- <run-dir> --plan data/plans/<plan>.json [--run 1]
//
// For when the judge or the plan changed after a chat ran -- an alert box the judge could not see, an IDV
// line now skipped -- and running the chat again would cost a booking, a code and a submitted claim.
// Rewrites results/run<n>.json: the checkpoints, the checkpoint failures (re-raised without a screenshot
// or a "before"), the result and the checkpoint note. Dashboard and mail findings are kept as they were.
import fs from 'node:fs';
import path from 'node:path';
import { checkpointNote, judgeTranscript, type GoalItem } from '../src/goal';

function arg(name: string): string | undefined {
  const i = process.argv.indexOf(`--${name}`);
  return i > 0 ? process.argv[i + 1] : undefined;
}

async function main(): Promise<void> {
  const dir = process.argv[2];
  const planFile = arg('plan');
  const n = arg('run') ?? '1';
  if (!dir || !planFile) throw new Error('usage: npm run rejudge -- <run-dir> --plan <plan.json> [--run 1]');
  const resFile = path.join(dir, 'results', `run${n}.json`);
  const r = JSON.parse(fs.readFileSync(resFile, 'utf8'));
  const t = JSON.parse(fs.readFileSync(path.join(dir, 'transcripts', `run${n}.json`), 'utf8'));
  const plan: GoalItem[] = JSON.parse(fs.readFileSync(planFile, 'utf8'));
  const item = plan.find(i => i.pnr === r.booking) ?? plan.find(i => i.caseId === r.caseId);
  if (!item) throw new Error(`no plan item for booking ${r.booking} in ${planFile}`);
  // the consent screen's words were kept in the notes when the chat ran
  const consent = (r.notes as string[]).find(x => x.startsWith('pre-chat consent screen: '))?.slice('pre-chat consent screen: '.length);

  const out = await judgeTranscript(item.checkpoints ?? [], t.messages, consent);
  if ('error' in out) throw new Error(`judge unavailable: ${out.error}`);

  // checkpoint failures carry "(feature line …)" in their step; everything else is kept
  const kept = (r.failures as any[]).filter(f => !/\(feature line /.test(f.step));
  const fresh = out.results.filter(x => x.status === 'fail' || x.status === 'not_reached').map(x => ({
    id: 0, run: r.run, sessionId: r.sessionId, step: `${x.requirement || 'checkpoint'} #${x.n} (feature line ${x.line ?? '?'})`,
    expected: String(x.expected || '').slice(0, 300),
    got: x.status === 'not_reached' ? `not reached — ${x.reason}` : `${x.reason}${x.quote ? ` — assistant: "${x.quote.slice(0, 200)}"` : ''}`,
    kind: x.status === 'not_reached' ? 'flow' : 'wording', severity: x.status === 'not_reached' ? 'High' : 'Medium', known: null,
  }));
  r.failures = [...fresh, ...kept].map((f, i) => ({ ...f, id: i + 1 }));
  r.checkpoints = out.results;
  r.skipped = (item as any).skipped ?? r.skipped;
  r.notes = [...(r.notes as string[]).filter(x => !x.startsWith('checkpoints: ')), checkpointNote(out.results),
             `re-judged ${new Date().toISOString()} against ${path.basename(planFile)}`];
  if (!String(r.result).startsWith('blocked'))
    r.result = r.failures.some((f: any) => !f.known) ? 'fail' : r.failures.length ? r.result : 'pass';
  fs.writeFileSync(resFile, JSON.stringify(r, null, 2));
  console.log(`${resFile}: ${checkpointNote(out.results)}; ${r.failures.length} failure(s); result ${r.result}`);
}

main().catch(e => { console.error(String(e?.message ?? e)); process.exit(1); });
