// Booking pool + usage ledger (guide section 12).
//
// data/bookings.yaml holds the pools (hand-written or `npm run import-seed`). The ledger lives in
// state/booking-ledger.json rather than inside the YAML so parallel workers can claim bookings under
// a lock without rewriting a hand-edited file.
import fs from 'node:fs';
import path from 'node:path';
import lockfile from 'proper-lockfile';
import YAML from 'yaml';
import { DATA_DIR, STATE_DIR, ensureDir } from './config';
import type { OtpProvider } from './otp';

export interface Booking {
  pnr: string;
  /** optional when the pool names every booking's passenger (first/last on the pool) */
  first?: string;
  last?: string;
  /** state tags used to pick a booking for a road: open, delivered, closed, no-ahl, outside-21, ... */
  tags?: string[];
  flight?: string;
  landed?: string;
  card?: string;
  caseId?: string;
  /**
   * The Aeroplan number of the member minted for this case, when the seeder made one. A chat run
   * that quotes a number has to quote the one the booking's customer profile actually carries --
   * the number in the fixture is only a marker that the case wanted a member, and a fresh one is
   * minted per run.
   */
  aeroplan?: string;
  note?: string;
}

export interface Pool {
  dataset?: string;
  source?: string;
  otp: OtpProvider;
  /** defaults for every booking in the pool */
  first?: string;
  last?: string;
  bookings: Booking[];
}

export interface PoolFile { pools: Record<string, Pool> }

export interface PickedBooking extends Booking { first: string; last: string; pool: string; otp: OtpProvider }

export interface LedgerEntry {
  used: string[];
  reservedBy?: string;
  reservedAt?: string;
  lastEnd?: string;
  claimConfirmed?: boolean;
}

export const BOOKINGS_FILE = path.join(DATA_DIR, 'bookings.yaml');
const LEDGER = path.join(STATE_DIR, 'booking-ledger.json');
const LOCK = path.join(STATE_DIR, 'booking.lock');
/** a reservation older than this is considered abandoned (a crashed run) */
const RESERVATION_TTL = 30 * 60_000;

/** Generated pools (one file each, e.g. from an agentic-qa seed dataset) live here beside bookings.yaml. */
export const POOLS_DIR = path.join(DATA_DIR, 'pools');

export function loadPools(file = BOOKINGS_FILE, extraDir: string | null = POOLS_DIR): PoolFile {
  const pools: Record<string, Pool> = {};
  const files = [file, ...(extraDir && fs.existsSync(extraDir)
    ? fs.readdirSync(extraDir).filter(f => /\.ya?ml$/i.test(f)).sort().map(f => path.join(extraDir, f)) : [])];
  for (const f of files) {
    if (!fs.existsSync(f)) continue;
    Object.assign(pools, (YAML.parse(fs.readFileSync(f, 'utf8')) ?? {}).pools ?? {});
  }
  return { pools };
}

/** BOOKING_POOL=<name> pins every "any pool" scenario of this run to one pool (set by the agentic-qa launcher). */
function forcedPool(spec: { pool?: string }): string | undefined {
  const forced = process.env.BOOKING_POOL;
  return forced && (!spec.pool || spec.pool === 'any') ? forced : spec.pool;
}

export function readLedger(): Record<string, LedgerEntry> {
  try { return JSON.parse(fs.readFileSync(LEDGER, 'utf8')); } catch { return {}; }
}
function writeLedger(l: Record<string, LedgerEntry>): void {
  ensureDir(STATE_DIR);
  fs.writeFileSync(LEDGER, JSON.stringify(l, null, 2));
}

async function locked<T>(fn: () => T | Promise<T>): Promise<T> {
  ensureDir(STATE_DIR);
  if (!fs.existsSync(LOCK)) fs.writeFileSync(LOCK, '');
  const release = await lockfile.lock(LOCK, { retries: { retries: 100, minTimeout: 200, maxTimeout: 1000 }, stale: 60_000 });
  try { return await fn(); } finally { await release(); }
}

export type BookingSpec =
  | { pnr: string; first?: string; last?: string; pool?: string }
  | { pool?: string; pick: 'next-unused' | 'any'; need?: string[]; avoid?: string[]; allowUsed?: boolean };

function full(poolName: string, pool: Pool, b: Booking): PickedBooking {
  return { ...b, first: b.first ?? pool.first ?? '', last: b.last ?? pool.last ?? '', pool: poolName, otp: pool.otp };
}

/**
 * Choose and reserve a booking for one run. `next-unused` skips bookings that were ever used, are
 * reserved by another worker, or confirmed a claim (those go to the duplicate-claim road).
 */
export async function claimBooking(spec: BookingSpec, runKey: string, file = BOOKINGS_FILE): Promise<PickedBooking> {
  const { pools } = loadPools(file);
  return locked(() => {
    const ledger = readLedger();
    const now = Date.now();
    let picked: PickedBooking | undefined;
    if ('pnr' in spec) {
      for (const [name, pool] of Object.entries(pools)) {
        if (spec.pool && spec.pool !== name) continue;
        const b = pool.bookings.find(x => x.pnr.toUpperCase() === spec.pnr.toUpperCase());
        if (b) { picked = full(name, pool, b); break; }
      }
      if (!picked) throw new Error(`booking ${spec.pnr} is not in ${path.basename(file)}`);
      if (spec.first) picked.first = spec.first;
      if (spec.last) picked.last = spec.last;
    } else {
      const need = spec.need ?? [];
      const avoid = spec.avoid ?? [];
      const want = forcedPool(spec);
      if (want && want !== 'any' && !pools[want]) throw new NoBooking(`pool ${want} does not exist`);
      for (const [name, pool] of Object.entries(pools)) {
        if (want && want !== 'any' && want !== name) continue;
        for (const b of pool.bookings) {
          const tags = b.tags ?? [];
          if (!need.every(t => tags.includes(t)) || avoid.some(t => tags.includes(t))) continue;
          const e = ledger[b.pnr];
          const reserved = e?.reservedBy && e.reservedBy !== runKey && now - Date.parse(e.reservedAt ?? '0') < RESERVATION_TTL;
          if (reserved) continue;
          if (spec.pick === 'next-unused' && !spec.allowUsed && (e?.used?.length || e?.claimConfirmed)) continue;
          picked = full(name, pool, b);
          break;
        }
        if (picked) break;
      }
      if (!picked) throw new NoBooking(`no ${spec.pick} booking in pool ${want ?? 'any'} with tags [${need.join(', ')}]`);
    }
    const e = ledger[picked.pnr] ?? { used: [] };
    ledger[picked.pnr] = { ...e, reservedBy: runKey, reservedAt: new Date(now).toISOString() };
    writeLedger(ledger);
    return picked;
  });
}

export class NoBooking extends Error {}

export async function releaseBooking(pnr: string, runKey: string, outcome: { lastEnd?: string; claimConfirmed?: boolean; used: boolean }): Promise<void> {
  await locked(() => {
    const ledger = readLedger();
    const e = ledger[pnr] ?? { used: [] };
    if (e.reservedBy === runKey) { delete e.reservedBy; delete e.reservedAt; }
    if (outcome.used) e.used = [...(e.used ?? []), new Date().toISOString()];
    if (outcome.lastEnd) e.lastEnd = outcome.lastEnd;
    if (outcome.claimConfirmed) e.claimConfirmed = true;
    ledger[pnr] = e;
    writeLedger(ledger);
  });
}
