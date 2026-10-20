import fs from 'node:fs';
import path from 'node:path';
import { writeReport } from '../scripts/report';

export default async function globalTeardown(): Promise<void> {
  const dir = process.env.RUN_DIR;
  if (!dir || !fs.existsSync(path.join(dir, 'results'))) return;   // unit-only runs write no results
  const file = writeReport(dir);
  console.log(`\n[report] ${file}`);
}
