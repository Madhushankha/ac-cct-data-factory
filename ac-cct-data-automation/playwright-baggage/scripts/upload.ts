// Publish a run's evidence to the bucket the CCT report viewer (ac-cct-report) reads.
//
//   npm run upload -- <run-dir> --flow fd --suite uat [--env int] [--run-id <name>] [--dry]
//
// The viewer lists s3://<bucket>/runs/<env>/<flow>/[<suite>/]<run-id>/ and shows one test per
// `<case>.evidence.html`, a run's `index.html` as its landing page, and `<case>.result.json` as the raw
// result. This writes exactly those, from what `npm run evidence` produced:
//
//   evidence/index.html        -> index.html
//   evidence/run<n>.html       -> <caseId>.evidence.html
//   results/run<n>.json        -> <caseId>.result.json
//
// Video is never uploaded. Credentials: the int-cce profile (UPLOAD_PROFILE overrides), through the
// aws CLI, so nothing here holds a key. Nothing is deleted from the bucket.
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { ENVS, envName, profileArgs, type EnvName } from '../src/envs';

const PREFIX = process.env.REPORT_PREFIX || 'runs';
const SAFE = /^[A-Za-z0-9_.-]{1,120}$/;

function arg(name: string, dflt = ''): string {
  const i = process.argv.indexOf(`--${name}`);
  return i > 0 ? process.argv[i + 1] ?? dflt : dflt;
}

const runDir = process.argv[2];
if (!runDir || !fs.existsSync(runDir)) {
  console.error('usage: npm run upload -- <run-dir> --flow fd --suite uat [--env int] [--run-id <name>] [--dry]');
  process.exit(2);
}
const env = arg('env', envName()), flow = arg('flow'), suite = arg('suite');
const target = ENVS[env as EnvName]?.upload ?? ENVS.int.upload;
const BUCKET = process.env.REPORT_BUCKET || target.bucket;
const runId = arg('run-id', path.basename(path.resolve(runDir)));
for (const [k, v] of [['env', env], ['flow', flow], ['run-id', runId], ...(suite ? [['suite', suite]] : [])])
  if (!SAFE.test(v)) { console.error(`--${k} must be letters, digits, '_', '-' or '.', got ${JSON.stringify(v)}`); process.exit(2); }

const evidence = path.join(runDir, 'evidence');
if (!fs.existsSync(path.join(evidence, 'index.html'))) {
  console.error(`no ${path.join(evidence, 'index.html')}: run \`npm run evidence -- ${runDir}\` first`);
  process.exit(1);
}

// stage the files under the names the viewer expects, then copy the folder in one call
const stage = fs.mkdtempSync(path.join(os.tmpdir(), 'cct-upload-'));
fs.copyFileSync(path.join(evidence, 'index.html'), path.join(stage, 'index.html'));
let tests = 0;
for (const f of fs.readdirSync(evidence).filter(f => /^run\d+\.html$/.test(f))) {
  const n = f.match(/\d+/)![0];
  const resFile = path.join(runDir, 'results', `run${n}.json`);
  const res = fs.existsSync(resFile) ? JSON.parse(fs.readFileSync(resFile, 'utf8')) : {};
  const caseId = String(res.caseId || `run${n}`).replace(/[^A-Za-z0-9_.-]+/g, '_');
  fs.copyFileSync(path.join(evidence, f), path.join(stage, `${caseId}.evidence.html`));
  if (fs.existsSync(resFile)) fs.copyFileSync(resFile, path.join(stage, `${caseId}.result.json`));
  tests++;
}

const dest = `s3://${BUCKET}/${[PREFIX, ENVS[env as EnvName]?.upload.envPath ?? env, flow, suite, runId].filter(Boolean).join('/')}/`;
const profile = process.env.UPLOAD_PROFILE || target.profile;
console.log(`[upload] ${tests} test(s) + index.html -> ${dest}${process.argv.includes('--dry') ? '  (dry run)' : ''}`);
for (const f of fs.readdirSync(stage)) console.log(`  ${f}`);
if (!process.argv.includes('--dry')) {
  execFileSync('aws', ['s3', 'cp', stage, dest, '--recursive', ...profileArgs(profile), '--region', 'ca-central-1',
    '--exclude', '*.webm'], { stdio: 'inherit' });
  console.log(`[upload] done: ${dest}`);
}
fs.rmSync(stage, { recursive: true, force: true });
