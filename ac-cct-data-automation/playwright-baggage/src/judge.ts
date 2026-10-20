// Judging (guide section 9): MEANING and LAYOUT, never exact wording.
//  - meaning: key phrases with alternatives, case-insensitive (`any_of`, `all_of`, `text`), each a regex
//    where `|` separates alternatives;
//  - layout, buttons, form fields and order are strict.
import fs from 'node:fs';
import path from 'node:path';
import YAML from 'yaml';
import { DATA_DIR } from './config';
import type { Layout, Message } from './transcript';

export type Kind = 'flow' | 'wording' | 'layout' | 'language' | 'data' | 'error' | 'OTP';
export type Severity = 'High' | 'Medium' | 'Low';

export interface Expect {
  /** board step id, e.g. BAG-03c.S5 */
  step: string;
  /** the board's message or condition, for the report */
  board?: string;
  text?: string;
  any_of?: string[];
  all_of?: string[];
  none_of?: string[];
  /** no bot message in the window may match any of these (e.g. a notice that must not show) */
  absent?: string[];
  /** layout of the message carrying the text */
  layout?: Exclude<Layout, 'alert'>;
  /** some alert box in the window matches; `box_kind` pins its colour */
  box?: string;
  box_kind?: Exclude<Layout, 'plain' | 'alert'>;
  buttons?: string[];
  no_buttons?: string[];
  form?: string[];
  links?: string[];
  /** the matching message must come before a message matching this */
  before?: string;
  /** seconds to wait for the text before judging (default 60) */
  timeout?: number;
  /** a miss is recorded as a note, not a failure */
  optional?: boolean;
  kind?: Kind;
  severity?: Severity;
}

export interface Failure {
  id: number;
  run: number;
  sessionId?: string;
  step: string;
  expected: string;
  got: string;
  before: string;
  kind: Kind;
  severity: Severity;
  known: string | null;
  screenshot?: string;
}

export interface Verdict { ok: boolean; problems: { kind: Kind; what: string }[]; got: string; matched?: Message }

const re = (s: string) => new RegExp(s, 'i');
const SEVERITY: Record<Kind, Severity> = { flow: 'High', error: 'High', data: 'High', OTP: 'High', layout: 'Medium', language: 'Medium', wording: 'Low' };

export function describe(m: Message | undefined): string {
  if (!m) return 'nothing (no new bot message)';
  const where = m.layout === 'plain' ? 'plain' : m.layout === 'info' ? 'blue box' : m.layout === 'warning' ? 'yellow box' : m.layout === 'success' ? 'green alert' : 'alert';
  const words = m.text.replace(/\s+/g, ' ').slice(0, 240);
  const extra = [m.buttons.length ? `buttons [${m.buttons.join('] [')}]` : '', m.form.length ? `form ${m.form.join(', ')}` : ''].filter(Boolean).join(', ');
  return `${where} "${words}${m.text.length > 240 ? '…' : ''}"${extra ? ', ' + extra : ''}`;
}

export function expectedText(e: Expect): string {
  const parts: string[] = [];
  if (e.board) parts.push(e.board);
  if (e.text) parts.push(`text ~ /${e.text}/`);
  if (e.any_of) parts.push(`any of ${e.any_of.map(x => `/${x}/`).join(', ')}`);
  if (e.all_of) parts.push(`all of ${e.all_of.map(x => `/${x}/`).join(', ')}`);
  if (e.layout) parts.push(`layout ${e.layout}`);
  if (e.box) parts.push(`${e.box_kind ?? ''} box ~ /${e.box}/`.trim());
  if (e.buttons) parts.push(`buttons [${e.buttons.join('] [')}]`);
  if (e.form) parts.push(`form ${e.form.join(', ')}`);
  if (e.before) parts.push(`before /${e.before}/`);
  if (e.absent) parts.push(`no message ~ ${e.absent.map(x => `/${x}/`).join(', ')}`);
  return parts.join('; ');
}

/** Does a message carry the expected meaning? */
export function meaningMatches(e: Expect, m: Message): boolean {
  const t = [m.text, ...m.boxes.map(b => b.text)].join('\n');
  if (e.text && !re(e.text).test(t)) return false;
  if (e.any_of && !e.any_of.some(x => re(x).test(t))) return false;
  if (e.all_of && !e.all_of.every(x => re(x).test(t))) return false;
  return true;
}

/**
 * Judge one expectation against `window` (bot messages since the last action) with `all` for order.
 * Pure: no page access, so it is unit-tested offline.
 */
export function judge(e: Expect, window: Message[], all: Message[] = window): Verdict {
  const problems: Verdict['problems'] = [];
  const bot = window.filter(m => m.who !== 'you');
  const hasMeaning = !!(e.text || e.any_of || e.all_of);
  const matched = hasMeaning ? [...bot].reverse().find(m => meaningMatches(e, m)) : bot[bot.length - 1];
  if (hasMeaning && !matched) problems.push({ kind: 'flow', what: 'expected meaning not found' });

  if (matched && e.none_of) {
    const t = [matched.text, ...matched.boxes.map(b => b.text)].join('\n');
    for (const x of e.none_of) if (re(x).test(t)) problems.push({ kind: 'wording', what: `says /${x}/` });
  }
  if (matched && e.layout && matched.layout !== e.layout)
    problems.push({ kind: 'layout', what: `layout ${matched.layout}, expected ${e.layout}` });
  if (e.box) {
    const boxes = bot.flatMap(m => m.boxes);
    const ok = boxes.some(b => re(e.box!).test(b.text) && (!e.box_kind || b.kind === e.box_kind));
    if (!ok) problems.push({ kind: 'layout', what: `no ${e.box_kind ?? ''} box ~ /${e.box}/`.replace('  ', ' ') });
  }
  for (const x of e.absent ?? []) {
    const hit = bot.find(m => re(x).test([m.text, ...m.boxes.map(b => b.text)].join('\n')));
    if (hit) problems.push({ kind: 'flow', what: `should not show /${x}/ but did: ${describe(hit)}` });
  }
  const buttons = new Set(bot.flatMap(m => m.buttons));
  for (const b of e.buttons ?? []) if (!buttons.has(b)) problems.push({ kind: 'layout', what: `button [${b}] missing` });
  for (const b of e.no_buttons ?? []) if (buttons.has(b)) problems.push({ kind: 'layout', what: `unexpected button [${b}]` });
  const form = new Set(bot.flatMap(m => m.form));
  for (const f of e.form ?? []) if (![...form].some(x => x === f || x.replace(/\*$/, '') === f.replace(/\*$/, '')))
    problems.push({ kind: 'layout', what: `form field ${f} missing` });
  const links = bot.flatMap(m => m.links.map(l => l.text));
  for (const l of e.links ?? []) if (!links.some(x => re(l).test(x))) problems.push({ kind: 'layout', what: `link ~ /${l}/ missing` });
  if (matched && e.before) {
    const other = all.find(m => m !== matched && re(e.before!).test([m.text, ...m.boxes.map(b => b.text)].join('\n')));
    if (other && other.index < matched.index) problems.push({ kind: 'flow', what: `came after /${e.before}/, expected before` });
  }
  if (e.kind) problems.forEach(p => (p.kind = e.kind!));
  const shown = matched ?? bot[bot.length - 1];
  return { ok: problems.length === 0, problems, got: describe(shown), matched };
}

export function severityOf(kind: Kind, override?: Severity): Severity { return override ?? SEVERITY[kind]; }

/** Defects checked on every bot message, whatever the scenario expects. */
export function genericDefects(messages: Message[]): { kind: Kind; what: string; m: Message }[] {
  const out: { kind: Kind; what: string; m: Message }[] = [];
  for (const m of messages.filter(x => x.who === 'bot')) {
    for (const u of m.rawUrls) out.push({ kind: 'layout', what: `raw URL in the text: ${u}`, m });
    if (/something went wrong|unexpected error|technical (issue|difficult)|\bundefined\b|\[object Object\]|\{\{\w+\}\}/i.test(m.text))
      out.push({ kind: 'error', what: 'error or raw template text in a reply', m });
  }
  return out;
}

// ---------------------------------------------------------------- known issues

export interface KnownIssue { id: string; what: string; match?: { step?: string; got?: string; expected?: string } }

export function loadKnownIssues(file = path.join(DATA_DIR, 'known-issues.yaml')): KnownIssue[] {
  if (!fs.existsSync(file)) return [];
  return (YAML.parse(fs.readFileSync(file, 'utf8'))?.issues ?? []) as KnownIssue[];
}

/**
 * Tag a failure with a known-issue id when the issue's `match` fits it. Issues the scenario lists are
 * tried first. An issue without `match` never tags anything: a vague known issue must not hide a new one.
 */
export function knownFor(f: Pick<Failure, 'step' | 'got' | 'expected'>, issues: KnownIssue[], scenarioKnown: string[] = []): string | null {
  const hit = (k: KnownIssue) => !!k.match && (!k.match.step || re(k.match.step).test(f.step))
    && (!k.match.got || re(k.match.got).test(f.got)) && (!k.match.expected || re(k.match.expected).test(f.expected));
  const listed = issues.filter(k => scenarioKnown.includes(k.id));
  return (listed.find(hit) ?? issues.find(hit))?.id ?? null;
}
