// One output folder per `playwright test` invocation: out/<YYYY-MM-DD>_<name>/.
// Environment set here reaches every worker.
import fs from 'node:fs';
import path from 'node:path';
import { OUT_DIR, STATE_DIR } from '../src/config';

export default async function globalSetup(): Promise<void> {
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
  }, null, 2));
}
