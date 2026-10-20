// Scenarios as data (guide section 8): one YAML per path, steps run in order.
import fs from 'node:fs';
import path from 'node:path';
import YAML from 'yaml';
import { ROOT, SCENARIO_DIR } from './config';
import { FORBIDDEN_TAPS, FORBIDDEN_THIRD_PARTY, STOPS, type StopKind } from './guards';
import type { BookingSpec } from './bookings';
import type { Expect } from './judge';
import type { Lang } from './chat';

export interface ContentsItem { item: string; qty?: number; amount: number }
export interface ContentsSpec {
  /** one or more categories, e.g. Clothing */
  category: string | string[];
  /** true = amounts in CAD; false = answer No and type `currency` */
  cad?: boolean;
  currency?: string;
  /** shorthand for a single item */
  item?: string; qty?: number; amount?: number;
  items?: ContentsItem[];
}

export type Step =
  | { notice: 'yes' | 'no' | 'skip' }
  | { identify: true | { first?: string; last?: string; pnr?: string } }
  | { verify: true }
  | { journey: 'one' | 'no' | { match: string } }
  | { delivery: 'yes' | 'no' | { answer: 'yes'; date: string } }
  | { readiness: 'yes' | 'no' }
  | { contents: ContentsSpec }
  | { confirm: true | 'change' }
  | { upload: string[] }
  | { say: string }
  | { tap: string }
  | { choose: string[]; submit?: boolean }
  | { expect: Expect }
  | { wait: number }
  | { stop: StopKind | 'end' };

export const STEP_KINDS = ['notice', 'identify', 'verify', 'journey', 'delivery', 'readiness', 'contents', 'confirm',
  'upload', 'say', 'tap', 'choose', 'expect', 'wait', 'stop'] as const;

export interface Scenario {
  id: string;
  title: string;
  /** e.g. [smoke] -> runs under --grep @smoke */
  tags?: string[];
  lang?: Lang;
  booking?: BookingSpec;
  first_message: string;
  /** stops this scenario may go past (default none) */
  allow?: StopKind[];
  steps: Step[];
  /** known-issue ids this path is expected to hit (data/known-issues.yaml) */
  known?: string[];
  /** set by the loader */
  file?: string;
  run?: number;
  /** the seeded case this run is bound to (a run plan from agentic-qa) */
  caseId?: string;
}

export function stepKind(s: Step): (typeof STEP_KINDS)[number] {
  const keys = Object.keys(s).filter(k => k !== 'submit');
  return keys[0] as (typeof STEP_KINDS)[number];
}

export function loadScenarios(dir = SCENARIO_DIR): Scenario[] {
  const files = fs.readdirSync(dir).filter(f => /\.ya?ml$/i.test(f)).sort();
  return files.map((f, i) => {
    const s = YAML.parse(fs.readFileSync(path.join(dir, f), 'utf8')) as Scenario;
    return { ...s, file: f, run: i + 1, steps: s.steps ?? [] };
  });
}

/**
 * Static safety walk (guide section 14: "a unit check walks every scenario's steps").
 * Returns problems; an empty list means the scenario can never cross a safety stop on its own.
 */
export function validateScenario(s: Scenario): string[] {
  const p: string[] = [];
  const allow = new Set(s.allow ?? []);
  const kinds = new Set(STOPS.map(x => x.kind));
  if (!s.id) p.push('missing id');
  if (!s.title) p.push('missing title');
  if (!s.first_message) p.push('missing first_message');
  for (const a of allow) if (!kinds.has(a as StopKind) && a !== 'receipt-upload') p.push(`unknown allow "${a}"`);
  let stopped = -1;
  s.steps.forEach((st, i) => {
    const keys = Object.keys(st).filter(k => k !== 'submit');
    if (keys.length !== 1) { p.push(`step ${i + 1}: one key per step, got [${keys.join(', ')}]`); return; }
    const k = keys[0];
    if (!(STEP_KINDS as readonly string[]).includes(k)) p.push(`step ${i + 1}: unknown step "${k}"`);
    if (stopped >= 0 && k !== 'expect') p.push(`step ${i + 1}: "${k}" after stop at step ${stopped + 1}`);
    const v: any = (st as any)[k];
    if (k === 'stop') {
      stopped = i;
      if (v !== 'end' && !kinds.has(v)) p.push(`step ${i + 1}: unknown stop "${v}"`);
    }
    const taps: string[] = k === 'tap' ? [v] : k === 'choose' ? v : [];
    for (const t of taps) {
      if (FORBIDDEN_TAPS.some(r => r.test(t))) p.push(`step ${i + 1}: taps forbidden "${t}" (GenUC-16)`);
      if (FORBIDDEN_THIRD_PARTY.test(t) && !allow.has('third-party')) p.push(`step ${i + 1}: answers the third-party question "${t}" (GenUC-23)`);
    }
    if (k === 'say' && /\b(iban|swift|routing|transit number|account number)\b/i.test(v)) p.push(`step ${i + 1}: types bank details`);
    if (k === 'upload') {
      if (!Array.isArray(v) || !v.length) p.push(`step ${i + 1}: upload needs a list of files`);
      else for (const f of v) if (!fs.existsSync(path.resolve(ROOT, f))) p.push(`step ${i + 1}: upload file missing: ${f}`);
    }
    if (k === 'contents') {
      const items = v.items ?? (v.item ? [{ item: v.item, qty: v.qty, amount: v.amount }] : []);
      if (!items.length) p.push(`step ${i + 1}: contents needs item(s)`);
      if (v.cad === false && !v.currency) p.push(`step ${i + 1}: contents cad:false needs currency`);
    }
  });
  return p;
}
