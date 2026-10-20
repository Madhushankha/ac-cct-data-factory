// Where things outside this project are, in one place.
//
// The mirror of the Python half's `core/paths.py`, and here for the same reason. Two paths used to be
// written as `path.resolve(__dirname, '..', '..', '..', '..', 'baggage')` — a walk up out of the
// project that is only correct for one directory layout. Moving the suite one level deeper made the
// seed-report path land one directory short, and the test that reads a real report went from passing
// to `test.skip('seed report not on this machine')`: coverage lost without a single failure.
//
// So: resolved from the environment, with a default, and a `require` that says which variable to set.
//
//   AQA_SEED_REPORTS   the folder of seed-report HTML pages (default: <workspace>/baggage)
//   CHAT_DIR           the Ask AC host page to serve locally (default: <workspace>/public-qa-chat/public)
//   AQA_WORKSPACE      the folder holding those siblings (default: found, see findWorkspace)
//
// `<workspace>` is the directory holding this project, found by walking up from here, so a checkout
// somewhere else works without setting anything.
import fs from 'node:fs';
import path from 'node:path';

/** ac-cct-data-automation/playwright-baggage */
export const SUITE_ROOT = path.resolve(__dirname, '..');
/** ac-cct-data-factory: this suite's sub-project and the seeder (ac-cct-data-seed) sit side by side in it */
export const PROJECT_ROOT = path.resolve(SUITE_ROOT, '..', '..');

/**
 * Where the sibling checkouts (baggage/, public-qa-chat/) are. AQA_WORKSPACE when set; otherwise
 * the first candidate that holds one of them. The suite used to live in agentic-qa-latest, so that
 * folder beside ac-cct-data-factory is tried before giving up on the plain parent.
 */
function findWorkspace(): string {
  if (process.env.AQA_WORKSPACE) return path.resolve(process.env.AQA_WORKSPACE);
  const parent = path.resolve(PROJECT_ROOT, '..');
  for (const dir of [parent, path.join(parent, 'agentic-qa-latest')]) {
    if (fs.existsSync(path.join(dir, 'public-qa-chat')) || fs.existsSync(path.join(dir, 'baggage'))) return dir;
  }
  return parent;
}
/** the directory the sibling checkouts are in */
export const WORKSPACE = findWorkspace();

/** Seed-report HTML pages, the legacy route into a booking pool (`npm run import-seed`). */
export const SEED_REPORTS = path.resolve(process.env.AQA_SEED_REPORTS || path.join(WORKSPACE, 'baggage'));

/** The Ask AC host page served by scripts/serve.js when CHAT_URL=local. */
export const CHAT_HOST_DIR = path.resolve(
  process.env.CHAT_DIR || path.join(WORKSPACE, 'public-qa-chat', 'public'));

/** Where the Python half writes a pool for a run it seeded: the handoff, as a file. */
export const POOLS_FROM_SEED = path.join(SUITE_ROOT, 'data', 'pools');

/**
 * One of the external paths, checked. Throws naming the variable to set and what was missing,
 * rather than letting a caller fail later on a path that was never going to exist.
 */
export function require_(what: 'seed-reports' | 'chat-host'): string {
  const table = {
    'seed-reports': [SEED_REPORTS, 'AQA_SEED_REPORTS'],
    'chat-host': [CHAT_HOST_DIR, 'CHAT_DIR'],
  } as const;
  const [dir, variable] = table[what];
  if (!fs.existsSync(dir)) {
    throw new Error(`${what} not found: ${dir} does not exist. Set ${variable} to the right ` +
      `directory (see src/external.ts).`);
  }
  return dir;
}

/** A named seed report, e.g. `toula-v72-bag-sit-test-bookings.html`. */
export function seedReport(file: string): string {
  return path.join(SEED_REPORTS, file);
}
