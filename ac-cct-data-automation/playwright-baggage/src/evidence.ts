// Evidence pack: one self-contained HTML page per test (evidence/run<n>.html) plus a run summary
// (evidence/index.html), built from what the suite already wrote under out/<run>/. Everything a reviewer
// needs travels inside the file -- CSS, a little JS, and the screenshots as data: URIs -- so a page can be
// mailed, attached to Jira or opened offline without a single external request. Videos are never used.
//
// Pure rendering only: the caller (scripts/evidence.ts) reads the files and hands over EvidenceData.
// A typed one-time code is masked here too, so a pack never shows one even if a source file did.
import zlib from 'node:zlib';
import type { Message } from './transcript';
import type { Failure } from './judge';
import type { Decision } from './live';
import type { DashResult, MailSeen } from './verify';

export type CheckpointStatus = 'pass' | 'fail' | 'not_reached' | 'unverified';

/** One judged Jira checkpoint, as results/run<n>.json carries it (src/goal.ts). */
export interface CheckpointResult {
  n: number;
  requirement?: string | null;
  kind?: string;
  expected?: string;
  line?: number | null;
  status: CheckpointStatus;
  /** index of the matched message, -1 for the pre-chat consent screen */
  message?: number | null;
  quote?: string;
  reason?: string;
}

/** A plan row the suite did not automate (e.g. IDV), listed so a reviewer sees what was left out. */
export interface SkippedItem { jiraCheckpoint?: string; kind?: string; check?: string; line?: number; reason?: string }

/** A picture on the page: `key` points into EvidenceData.images, so a shot used twice is embedded once. */
export interface Shot { key: string; label: string }

export type ChatMessage = Pick<Message, 'who' | 'text'> & Partial<Omit<Message, 'who' | 'text'>>;

export interface EvidenceData {
  run: number;
  /** the run folder's name (run.json `name`), shown as context */
  runName?: string;
  title: string;
  caseId?: string;
  jiraKey?: string;
  booking?: string;
  passenger?: string;
  caseNumber?: string;
  result: string;
  startedAt?: string;
  endedAt?: string;
  endedAtStep?: string;
  messages: ChatMessage[];
  checkpoints?: CheckpointResult[];
  skipped?: SkippedItem[];
  dashboard?: DashResult[];
  /** the Claims Dashboard verification document (dashboard/run<n>.json), shown raw in a <details> */
  verification?: unknown;
  emails?: MailSeen[];
  failures?: (Failure | (Partial<Failure> & { step: string }))[];
  decisions?: Decision[];
  notes?: string[];
  /** step screenshots in order, then identity / full-chat shots */
  screens?: Shot[];
  /** failure screenshot per failure id (or per index when ids are missing) */
  failureShots?: Record<string, string>;
  /** the whole conversation as the customer saw it: the tall full-chat screenshot(s), top to bottom */
  chatShots?: string[];
  /** key -> data: URI */
  images?: Record<string, string>;
}

// ------------------------------------------------------------------ small helpers

/** HTML-escape anything; the transcript is untrusted text from the bot. */
export function esc(v: unknown): string {
  return String(v ?? '').replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]!));
}

const OTP_ONLY = /^\s*\d{6}\s*$/;
const OTP_ANY = /(?<![\d.,])\d{6}(?![\d.,])/g;

/** A six-digit code typed by the customer is never shown: the whole bubble, or any 6-digit run inside it. */
export function maskOtp(text: string): string {
  if (OTP_ONLY.test(text)) return '••••••';
  return text.replace(OTP_ANY, '••••••');
}

/** The customer's words with codes masked; the bot's and widget's words as they are. */
export function shownText(m: Pick<ChatMessage, 'who' | 'text'>): string {
  return m.who === 'you' ? maskOtp(m.text ?? '') : (m.text ?? '');
}

/** 2026-10-20T11:29:49.331Z -> 2026-10-20 11:29:49 UTC (fixed, so a pack reads the same everywhere). */
function when(iso?: string): string {
  if (!iso) return '—';
  const d = new Date(iso);
  return isNaN(d.getTime()) ? esc(iso) : `${d.toISOString().slice(0, 19).replace('T', ' ')} UTC`;
}

/** `known (BUG-1)` -> `known`, for the badge colour. */
function resultClass(result: string): string {
  const w = (result || '').split(/[\s(]/)[0].toLowerCase();
  return ['pass', 'fail', 'known', 'blocked'].includes(w) ? w : 'other';
}

function badge(text: string, cls: string): string {
  return `<span class="badge b-${esc(cls)}">${esc(text)}</span>`;
}

export interface CheckpointCounts { pass: number; fail: number; not_reached: number; unverified: number; total: number }

export function countCheckpoints(cps: CheckpointResult[] = []): CheckpointCounts {
  const c: CheckpointCounts = { pass: 0, fail: 0, not_reached: 0, unverified: 0, total: cps.length };
  for (const x of cps) if (x.status in c) c[x.status]++;
  return c;
}

export function countDashboard(rows: DashResult[] = []): Record<string, number> {
  const c: Record<string, number> = { pass: 0, review: 0, fail: 0, ui: 0, missing: 0, manual: 0, unmapped: 0 };
  for (const r of rows) c[r.status] = (c[r.status] ?? 0) + 1;
  return c;
}

/** Did the case mail arrive: some message quotes the case number, and carries the amount when that was checked. */
export function emailOk(mails?: MailSeen[]): boolean | undefined {
  if (!mails) return undefined;
  return mails.some(m => m.quotesCase && m.amountFound !== false);
}

const tick = (v: boolean | undefined) => v === undefined ? '<span class="muted">—</span>' : v ? '<span class="ok">✔</span>' : '<span class="no">✘</span>';

// ------------------------------------------------------------------ shared page chrome

const CSS = `
:root{--bg:#f6f7f9;--card:#fff;--fg:#1d2433;--muted:#667085;--line:#e4e7ec;--accent:#d22630;
--bot:#eef1f5;--you:#1f3b70;--youfg:#fff;--chip:#fff;--chipline:#c5cbd5;
--info:#cfe6fc;--warning:#fff7cc;--success:#dff0db;--alert:#fde2e1;--infofg:#0b3a66;--warningfg:#5c4a00;--successfg:#1f4d17;--alertfg:#7a1010;
--pass:#1e7b34;--fail:#c62828;--nr:#8a6d00;--unv:#6b4fa0;--rev:#b35c00;--grey:#6b7280}
@media (prefers-color-scheme:dark){:root{--bg:#0f1218;--card:#181c24;--fg:#e6e9ef;--muted:#9aa3b2;--line:#2a303c;--accent:#ff5a63;
--bot:#232937;--you:#3b5ea8;--youfg:#fff;--chip:#1c212b;--chipline:#3a4252;
--info:#173a5c;--warning:#4a3f0c;--success:#1f3d1b;--alert:#4d1c1c;--infofg:#d4e8ff;--warningfg:#ffeeb0;--successfg:#d5f2cf;--alertfg:#ffd6d6;
--pass:#4cc36b;--fail:#ff6b6b;--nr:#e0c04a;--unv:#b79cf0;--rev:#ff9f43;--grey:#9aa3b2}}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.45 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
main{max-width:1200px;margin:0 auto;padding:16px}
h1{font-size:1.35rem;margin:0 0 4px}h2{font-size:1.1rem;margin:0 0 10px}
section{background:var(--card);border:1px solid var(--line);border-radius:12px;padding:16px;margin:0 0 16px;overflow-x:auto}
.muted{color:var(--muted)}.ok{color:var(--pass);font-weight:700}.no{color:var(--fail);font-weight:700}
.meta{display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:8px 16px;margin-top:12px}
.meta div{min-width:0}.meta b{display:block;font-size:.75rem;color:var(--muted);font-weight:600;text-transform:uppercase;letter-spacing:.03em}
.meta span{word-break:break-word}
.badge{display:inline-block;padding:2px 8px;border-radius:999px;font-size:.78rem;font-weight:700;color:#fff;background:var(--grey);white-space:nowrap}
.b-pass{background:var(--pass)}.b-fail{background:var(--fail)}.b-not_reached{background:var(--nr)}.b-unverified{background:var(--unv)}
.b-review{background:var(--rev)}.b-known{background:var(--rev)}.b-blocked{background:var(--nr)}.b-missing{background:var(--fail)}
.b-ui,.b-manual,.b-unmapped,.b-other{background:var(--grey)}
.big{font-size:1rem;padding:4px 12px}
table{border-collapse:collapse;width:100%;font-size:.88rem}
th,td{text-align:left;vertical-align:top;padding:6px 8px;border-bottom:1px solid var(--line)}
th{font-size:.75rem;text-transform:uppercase;color:var(--muted);letter-spacing:.03em}
td.q{font-style:italic}
.filters{display:flex;flex-wrap:wrap;gap:6px;margin:0 0 10px}
.filters button{font:inherit;font-size:.85rem;border:1px solid var(--chipline);background:var(--chip);color:var(--fg);border-radius:999px;padding:3px 12px;cursor:pointer}
.filters button.on{background:var(--fg);color:var(--bg);border-color:var(--fg)}
details>summary{cursor:pointer;font-weight:600}
pre{white-space:pre-wrap;word-break:break-word;font-size:.8rem;background:var(--bg);padding:10px;border-radius:8px;max-height:480px;overflow:auto}
a{color:var(--accent)}
`;

const PAGE_JS = `
document.addEventListener('click',function(e){
  var t=e.target;
  // filter buttons: <div class="filters" data-for="tableId"><button data-f="pass">
  if(t.matches&&t.matches('.filters button')){
    var box=t.parentNode,tb=document.getElementById(box.getAttribute('data-for')),f=t.getAttribute('data-f');
    box.querySelectorAll('button').forEach(function(b){b.classList.toggle('on',b===t)});
    tb.querySelectorAll('tbody tr').forEach(function(r){r.hidden=!(f==='all'||r.getAttribute('data-s')===f)});
  }
});
`;

function page(title: string, body: string, extraCss = '', extraJs = ''): string {
  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="color-scheme" content="light dark">
<title>${esc(title)}</title>
<style>${CSS}${extraCss}</style>
</head><body><main>
${body}
</main>
<script>${PAGE_JS}${extraJs}</script>
</body></html>
`;
}

// ------------------------------------------------------------------ per-test page

const TEST_CSS = `
.replay{display:grid;grid-template-columns:minmax(0,1fr) 240px;gap:16px}
@media (max-width:800px){.replay{grid-template-columns:minmax(0,1fr)}}
.chat{background:var(--bg);border:1px solid var(--line);border-radius:12px;padding:12px;max-height:75vh;overflow-y:auto;display:flex;flex-direction:column;gap:8px}
.msg{max-width:82%;display:flex;flex-direction:column;gap:4px}
.msg .who{font-size:.72rem;color:var(--muted)}
.bubble{padding:8px 12px;border-radius:14px;white-space:pre-wrap;word-break:break-word}
.msg.bot{align-self:flex-start}.msg.bot .bubble{background:var(--bot);border-bottom-left-radius:4px}
.msg.you{align-self:flex-end;align-items:flex-end}.msg.you .bubble{background:var(--you);color:var(--youfg);border-bottom-right-radius:4px}
.msg.widget{align-self:center;max-width:92%;align-items:center;text-align:center}
.msg.widget .bubble{background:transparent;color:var(--muted);font-size:.85rem;padding:2px 8px}
.msg.opts{align-self:flex-start}
.box{padding:8px 12px;border-radius:10px;white-space:pre-wrap;word-break:break-word;border-left:4px solid transparent}
.box.info{background:var(--info);color:var(--infofg);border-color:#3a87d6}
.box.warning{background:var(--warning);color:var(--warningfg);border-color:#d6a800}
.box.success{background:var(--success);color:var(--successfg);border-color:#3c9b2f}
.box.alert,.box.plain{background:var(--alert);color:var(--alertfg);border-color:#d33}
.chips{display:flex;flex-wrap:wrap;gap:6px}
.chip{border:1px solid var(--chipline);background:var(--chip);color:var(--fg);border-radius:999px;padding:3px 12px;font-size:.85rem}
.chip.btn{border-color:var(--accent);color:var(--accent);font-weight:600}
.form{font-size:.8rem;color:var(--muted)}.form ul{margin:2px 0 0 18px;padding:0}
.links{font-size:.8rem;color:var(--muted);word-break:break-all}
.msg.hl .bubble,.msg.hl .box{outline:3px solid var(--accent)}
.screens{display:flex;flex-direction:column;gap:10px;max-height:75vh;overflow-y:auto}
.seen{max-height:80vh;overflow-y:auto;border:1px solid var(--line);border-radius:12px;background:#fff;text-align:center}
.seen img{width:100%;max-width:720px;display:block;margin:0 auto;cursor:zoom-in}
@media (max-width:800px){.screens{flex-direction:row;overflow-x:auto;max-height:none}.screens figure{flex:0 0 160px}}
figure{margin:0}figure img{width:100%;border:1px solid var(--line);border-radius:8px;cursor:zoom-in;display:block;background:#fff}
figcaption{font-size:.75rem;color:var(--muted);margin-top:2px}
.fails{display:grid;gap:12px}.fail{border:1px solid var(--line);border-radius:10px;padding:10px;display:grid;grid-template-columns:minmax(0,1fr) 160px;gap:12px}
@media (max-width:640px){.fail{grid-template-columns:1fr}}
.fail p{margin:4px 0}
#lb{position:fixed;inset:0;background:rgba(0,0,0,.85);display:none;align-items:center;justify-content:center;z-index:9;cursor:zoom-out;padding:12px}
#lb.on{display:flex}#lb img{max-width:100%;max-height:100%;object-fit:contain;background:#fff}
ul.notes li{margin:4px 0;word-break:break-word}
`;

const TEST_JS = `
// an image used more than once is embedded once; copies take the first one's src
document.querySelectorAll('img[data-same]').forEach(function(i){
  var src=document.querySelector('img[data-key="'+i.getAttribute('data-same')+'"]');
  if(src)i.src=src.getAttribute('src');
});
var lb=document.getElementById('lb'),lbi=lb.querySelector('img');
document.addEventListener('click',function(e){
  var t=e.target;
  if(t.matches&&t.matches('img.zoom')){lbi.src=t.src;lbi.alt=t.alt;lb.classList.add('on');}
  else if(t===lb||t===lbi){lb.classList.remove('on');}
  else if(t.matches&&t.matches('a.goto')){
    var m=document.getElementById(t.getAttribute('href').slice(1));
    if(m){e.preventDefault();document.querySelectorAll('.msg.hl').forEach(function(x){x.classList.remove('hl')});
      m.classList.add('hl');m.scrollIntoView({block:'center',behavior:'smooth'});}
  }
});
document.addEventListener('keydown',function(e){if(e.key==='Escape')lb.classList.remove('on')});
`;

const ROLE: Record<string, string> = { bot: 'Assistant', you: 'Customer', widget: 'Widget' };

/** One chat message as a bubble (customer right, assistant left, widget centred). */
export function renderMessage(m: ChatMessage, i: number): string {
  const text = shownText(m);
  const boxes = m.boxes ?? [];
  const buttons = m.buttons ?? [];
  const chips = m.chips ?? [];
  const form = m.form ?? [];
  const links = m.links ?? [];
  // a widget row holding only options belongs to the assistant's turn above it
  const optionsOnly = m.who === 'widget' && !text.trim() && !boxes.length && (buttons.length || chips.length);
  const role = optionsOnly ? 'bot opts' : m.who === 'you' ? 'you' : m.who === 'widget' ? 'widget' : 'bot';
  const parts: string[] = [];
  if (!optionsOnly) parts.push(`<div class="who">${esc(ROLE[m.who] ?? m.who)}${m.time ? ` · ${esc(m.time)}` : ''}</div>`);
  // an alert message repeats its box text as the message text: show it once, styled as the box,
  // keeping the message's own line breaks
  const flat = (s: string) => s.replace(/\s+/g, ' ').trim();
  const same = boxes.find(b => flat(b.text) === flat(text));
  if (text.trim()) {
    const kind = same?.kind ?? (m.layout && m.layout !== 'plain' ? m.layout : undefined);
    parts.push(`<div class="${kind ? `box ${esc(kind)}` : 'bubble'}">${esc(text)}</div>`);
  }
  for (const b of boxes) if (b !== same) parts.push(`<div class="box ${esc(b.kind)}">${esc(b.text)}</div>`);
  if (buttons.length || chips.length) {
    parts.push(`<div class="chips">${buttons.map(b => `<span class="chip btn">${esc(b)}</span>`).join('')}${chips.map(c => `<span class="chip">${esc(c)}</span>`).join('')}</div>`);
  }
  if (form.length) parts.push(`<div class="form">Form fields:<ul>${form.map(f => `<li>${esc(f)}</li>`).join('')}</ul></div>`);
  // links are listed as text, never as live anchors: the page makes no outside requests
  if (links.length) parts.push(`<div class="links">Links: ${links.map(l => `${esc(l.text)} (${esc(l.href)})`).join(', ')}</div>`);
  const idx = typeof m.index === 'number' ? m.index : i;
  return `<div class="msg ${role}" id="m${idx}">${parts.join('')}</div>`;
}

/** Turns image keys into <img> tags, embedding each picture once. */
function imager(images: Record<string, string> = {}) {
  const used = new Set<string>();
  return (key: string | undefined, alt: string): string => {
    if (!key || !images[key]) return '';
    if (used.has(key)) return `<img class="zoom" data-same="${esc(key)}" alt="${esc(alt)}">`;
    used.add(key);
    return `<img class="zoom" data-key="${esc(key)}" src="${esc(images[key])}" alt="${esc(alt)}">`;
  };
}

function filterBar(id: string, counts: [string, string, number][]): string {
  return `<div class="filters" data-for="${id}">${counts.map(([f, label, n], i) =>
    `<button type="button" data-f="${f}"${i === 0 ? ' class="on"' : ''}>${esc(label)} (${n})</button>`).join('')}</div>`;
}

const STATUS_LABEL: Record<string, string> = { not_reached: 'not reached' };

export function renderTest(d: EvidenceData): string {
  const img = imager(d.images);
  const title = `Run ${d.run}${d.caseId ? ` · ${d.caseId}` : ''}`;
  const out: string[] = [];

  // header
  out.push(`<section><div style="display:flex;gap:12px;align-items:flex-start;justify-content:space-between;flex-wrap:wrap">
<div><h1>${esc(title)}</h1><div class="muted">${esc(d.title)}</div></div>${badge(d.result, resultClass(d.result)).replace('class="badge', 'class="badge big')}</div>
<div class="meta">
<div><b>Case</b><span>${esc(d.caseId ?? '—')}</span></div>
<div><b>Jira</b><span>${esc(d.jiraKey ?? '—')}</span></div>
<div><b>Booking (PNR)</b><span>${esc(d.booking ?? '—')}</span></div>
<div><b>Passenger</b><span>${esc(d.passenger ?? '—')}</span></div>
<div><b>CCD case</b><span>${esc(d.caseNumber ?? '—')}</span></div>
<div><b>Started</b><span>${when(d.startedAt)}</span></div>
<div><b>Ended</b><span>${when(d.endedAt)}</span></div>
${d.endedAtStep ? `<div><b>Last step</b><span>${esc(d.endedAtStep)}</span></div>` : ''}
${d.runName ? `<div><b>Run</b><span>${esc(d.runName)}</span></div>` : ''}
</div></section>`);

  // the real chat UI first: the full-chat screenshot, scrolled like the widget itself
  const seen = (d.chatShots ?? []).map(k => img(k, 'the chat as the customer saw it')).filter(x => x.includes('<img')).join('\n');
  if (seen) out.push(`<section id="seen"><h2>Chat (as seen) <span class="muted">the real Ask AC window, top to bottom</span></h2>
<div class="seen">${seen}</div></section>`);

  // chat replay + screens
  const msgs = d.messages.map((m, i) => renderMessage(m, i)).join('\n');
  const screens = (d.screens ?? []).map(s => `<figure>${img(s.key, s.label)}<figcaption>${esc(s.label)}</figcaption></figure>`).filter(f => f.includes('<img')).join('\n');
  // lean by default: with the real chat above, the text transcript is not repeated (by request, 2026-10-21; the
  // transcript JSON stays in the run folder for the judge). Without a chat screenshot it is the only chat evidence.
  if (screens || !seen) out.push(screens
    ? `<section><h2>Chat replay <span class="muted">(${d.messages.length} messages)</span></h2>
<div class="replay"><div class="chat">${msgs || '<p class="muted">No transcript.</p>'}</div>
<div><h2>Screens</h2><div class="screens">${screens}</div></div></div></section>`
    : `<section><h2>Chat transcript <span class="muted">(${d.messages.length} messages; the checkpoints' ↗ chat links land here)</span></h2>
<div class="chat">${msgs || '<p class="muted">No transcript.</p>'}</div></section>`);

  // Jira checkpoints
  const cps = d.checkpoints ?? [];
  if (cps.length) {
    const c = countCheckpoints(cps);
    const rows = cps.map(x => {
      // the chat as seen is one tall screenshot, so its link lands on that section; the transcript's on the message
      const goto = typeof x.message !== 'number' || x.message < 0 ? ''
        : seen && !screens ? ` <a class="goto" href="#seen">↗ chat</a>` : ` <a class="goto" href="#m${x.message}">↗ chat</a>`;
      return `<tr data-s="${esc(x.status)}"><td>${esc(x.n)}</td><td>${badge(STATUS_LABEL[x.status] ?? x.status, x.status)}</td><td>${esc(x.requirement ?? '')}</td>
<td>${esc(x.expected ?? '')}</td><td class="q">${x.quote ? `“${esc(x.quote)}”` : ''}${goto}</td><td>${esc(x.reason ?? '')}</td><td>${esc(x.line ?? '')}</td></tr>`;
    }).join('\n');
    out.push(`<section><h2>Jira checkpoints <span class="muted">${c.pass} pass · ${c.fail} fail · ${c.not_reached} not reached · ${c.unverified} unverified of ${c.total}</span></h2>
${filterBar('cps', [['all', 'all', c.total], ['pass', 'pass', c.pass], ['fail', 'fail', c.fail], ['not_reached', 'not reached', c.not_reached], ['unverified', 'unverified', c.unverified]])}
<table id="cps"><thead><tr><th>#</th><th>Status</th><th>Requirement</th><th>Expected</th><th>Bot quote</th><th>Reason</th><th>Feature line</th></tr></thead><tbody>
${rows}</tbody></table></section>`);
  }

  // skipped (not automated)
  if (d.skipped?.length) {
    out.push(`<section><h2>Skipped <span class="muted">(${d.skipped.length} not automated)</span></h2><table><thead><tr><th>Jira row</th><th>Kind</th><th>Check</th><th>Line</th><th>Reason</th></tr></thead><tbody>
${d.skipped.map(s => `<tr><td>${esc(s.jiraCheckpoint ?? '')}</td><td>${esc(s.kind ?? '')}</td><td>${esc(s.check ?? '')}</td><td>${esc(s.line ?? '')}</td><td>${esc(s.reason ?? '')}</td></tr>`).join('\n')}
</tbody></table></section>`);
  }

  // dashboard
  if (d.dashboard?.length || d.verification) {
    const rows = d.dashboard ?? [];
    const c = countDashboard(rows);
    const summary = Object.entries(c).filter(([, n]) => n).map(([k, n]) => `${n} ${k}`).join(' · ');
    out.push(`<section><h2>Claims Dashboard <span class="muted">${esc(summary)}</span></h2>
${rows.length ? `${filterBar('dash', [['all', 'all', rows.length], ...Object.entries(c).filter(([, n]) => n).map(([k, n]) => [k, k, n] as [string, string, number])])}
<table id="dash"><thead><tr><th>Jira row</th><th>API item</th><th>Status</th><th>Check</th><th>Expected</th><th>Value</th></tr></thead><tbody>
${rows.map(r => `<tr data-s="${esc(r.status)}"><td>${esc(r.jiraCheckpoint ?? '')}</td><td>${esc(r.api ?? '')}</td><td>${badge(r.status, r.status)}</td><td>${esc(r.check)}</td><td>${esc(r.expected ?? '')}</td><td><code>${esc(r.value ?? '')}</code></td></tr>`).join('\n')}
</tbody></table>` : ''}
${d.verification ? `<details><summary>Verification document (JSON)</summary><pre>${esc(JSON.stringify(d.verification, null, 2))}</pre></details>` : ''}
</section>`);
  }

  // e-mails
  if (d.emails) {
    out.push(`<section><h2>E-mails <span class="muted">(${d.emails.length})</span></h2>${d.emails.length ? `<table><thead><tr><th>Subject</th><th>From</th><th>Quotes case</th><th>Amount</th><th>Snippet</th></tr></thead><tbody>
${d.emails.map(m => `<tr><td>${esc(m.subject)}</td><td>${esc(m.from ?? '')}</td><td>${tick(m.quotesCase)}</td><td>${tick(m.amountFound)}</td><td class="muted">${esc(/verification code/i.test(m.subject) ? maskOtp(m.snippet ?? '') : m.snippet ?? '')}</td></tr>`).join('\n')}
</tbody></table>` : '<p class="muted">No mail found for the case.</p>'}</section>`);
  }

  // failures
  const fails = d.failures ?? [];
  if (fails.length) {
    out.push(`<section><h2>Failures <span class="muted">(${fails.length})</span></h2><div class="fails">
${fails.map((f, i) => {
      const key = d.failureShots?.[String(f.id ?? i)];
      return `<div class="fail"><div><p><b>${esc(f.step)}</b> ${f.severity ? badge(f.severity, f.severity === 'High' ? 'fail' : 'review') : ''} ${f.kind ? `<span class="muted">${esc(f.kind)}</span>` : ''}${f.known ? ` ${badge(`known: ${f.known}`, 'known')}` : ''}</p>
<p><span class="muted">Expected:</span> ${esc(f.expected ?? '')}</p><p><span class="muted">Got:</span> ${esc(f.got ?? '')}</p>${
        // the last customer action says nothing about a line that was never shown: leave it out there
        // nor about a dashboard or mailbox finding, which comes after the chat
        f.before && !/^not reached/i.test(f.got ?? '') && f.kind !== 'data' ? `<p class="muted">Before: ${esc(maskOtp(f.before))}</p>` : ''}</div>
${key ? `<div>${img(key, `failure ${f.step}`)}</div>` : ''}</div>`;
    }).join('\n')}</div></section>`);
  }

  // AI decisions
  if (d.decisions?.length) {
    out.push(`<section><details><summary>AI decisions (${d.decisions.length} turns)</summary><table><thead><tr><th>Turn</th><th>Action</th><th>Thought</th><th>Outcome</th></tr></thead><tbody>
${d.decisions.map(x => {
      const args = x.args && typeof x.args === 'object' && Object.keys(x.args as object).length ? ` ${maskOtp(JSON.stringify(x.args))}` : '';
      return `<tr><td>${esc(x.turn)}</td><td><code>${esc(x.action + args)}</code></td><td>${esc(x.thought ?? '')}</td><td>${esc(x.outcome ?? '')}</td></tr>`;
    }).join('\n')}
</tbody></table></details></section>`);
  }

  // notes
  if (d.notes?.length) out.push(`<section><h2>Notes</h2><ul class="notes">${d.notes.map(n => `<li>${esc(n)}</li>`).join('')}</ul></section>`);

  out.push('<div id="lb" role="dialog" aria-label="Screenshot"><img alt=""></div>');
  return page(`${title} — evidence`, out.join('\n'), TEST_CSS, TEST_JS);
}

// ------------------------------------------------------------------ run summary

export interface IndexRow {
  run: number;
  file: string;
  title: string;
  caseId?: string;
  jiraKey?: string;
  booking?: string;
  caseNumber?: string;
  result: string;
  checkpoints: CheckpointCounts;
  dashboard: Record<string, number>;
  emailOk?: boolean;
}

export function summarize(d: EvidenceData, file = `run${d.run}.html`): IndexRow {
  return {
    run: d.run, file, title: d.title, caseId: d.caseId, jiraKey: d.jiraKey, booking: d.booking, caseNumber: d.caseNumber, result: d.result,
    checkpoints: countCheckpoints(d.checkpoints), dashboard: countDashboard(d.dashboard), emailOk: emailOk(d.emails),
  };
}

export function renderIndex(rows: IndexRow[], meta: { name?: string; startedAt?: string } = {}): string {
  const byResult = new Map<string, number>();
  for (const r of rows) byResult.set(resultClass(r.result), (byResult.get(resultClass(r.result)) ?? 0) + 1);
  const sum = (f: (r: IndexRow) => number) => rows.reduce((n, r) => n + f(r), 0);
  const body = `<section><h1>Evidence · ${esc(meta.name ?? 'run')}</h1>
<div class="muted">${rows.length} test${rows.length === 1 ? '' : 's'}${meta.startedAt ? `, started ${when(meta.startedAt)}` : ''}.
${[...byResult].map(([k, n]) => `${n} ${esc(k)}`).join(' · ')}</div></section>
<section>
${filterBar('runs', [['all', 'all', rows.length], ...[...byResult].map(([k, n]) => [k, k, n] as [string, string, number])])}
<table id="runs"><thead><tr><th>Run</th><th>Result</th><th>Case</th><th>PNR</th><th>CCD case</th><th>Checkpoints pass / fail / not reached</th><th>Dashboard pass / fail / review</th><th>E-mail</th></tr></thead><tbody>
${rows.map(r => `<tr data-s="${esc(resultClass(r.result))}"><td><a href="${esc(r.file)}">run ${esc(r.run)}</a></td><td>${badge(r.result, resultClass(r.result))}</td>
<td><a href="${esc(r.file)}">${esc(r.caseId ?? r.title)}</a>${r.jiraKey ? ` <span class="muted">${esc(r.jiraKey)}</span>` : ''}<div class="muted" style="font-size:.8rem">${esc(r.title)}</div></td>
<td>${esc(r.booking ?? '—')}</td><td>${esc(r.caseNumber ?? '—')}</td>
<td>${r.checkpoints.total ? `${r.checkpoints.pass} / ${r.checkpoints.fail} / ${r.checkpoints.not_reached}` : '—'}</td>
<td>${r.dashboard.pass + r.dashboard.fail + r.dashboard.review ? `${r.dashboard.pass} / ${r.dashboard.fail} / ${r.dashboard.review}` : '—'}</td>
<td>${tick(r.emailOk)}</td></tr>`).join('\n')}
</tbody><tfoot><tr><th>Total</th><th>${rows.length}</th><th></th><th></th><th></th>
<th>${sum(r => r.checkpoints.pass)} / ${sum(r => r.checkpoints.fail)} / ${sum(r => r.checkpoints.not_reached)}</th>
<th>${sum(r => r.dashboard.pass)} / ${sum(r => r.dashboard.fail)} / ${sum(r => r.dashboard.review)}</th>
<th>${rows.filter(r => r.emailOk).length} ok</th></tr></tfoot></table></section>`;
  return page(`Evidence · ${meta.name ?? 'run'}`, body);
}

// ------------------------------------------------------------------ zip

const CRC_TABLE = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c >>> 0;
  }
  return t;
})();

export function crc32(b: Buffer): number {
  let c = 0xffffffff;
  for (let i = 0; i < b.length; i++) c = CRC_TABLE[(c ^ b[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

/**
 * A minimal ZIP (PKZIP 2.0): each file deflated with node:zlib, or stored when that does not help.
 * No zip64, so every file and the whole archive must stay under 4 GB -- far beyond an evidence pack.
 */
export function zip(files: { name: string; data: Buffer }[], date = new Date()): Buffer {
  const dosTime = (date.getHours() << 11) | (date.getMinutes() << 5) | (date.getSeconds() >> 1);
  const dosDate = ((date.getFullYear() - 1980) << 9) | ((date.getMonth() + 1) << 5) | date.getDate();
  const locals: Buffer[] = [];
  const centrals: Buffer[] = [];
  let offset = 0;
  for (const f of files) {
    const name = Buffer.from(f.name.replace(/\\/g, '/'), 'utf8');
    const deflated = zlib.deflateRawSync(f.data, { level: 9 });
    const store = deflated.length >= f.data.length;
    const body = store ? f.data : deflated;
    const crc = crc32(f.data);
    const head = Buffer.alloc(30);
    head.writeUInt32LE(0x04034b50, 0);
    head.writeUInt16LE(20, 4);              // version needed
    head.writeUInt16LE(0x0800, 6);          // flags: UTF-8 names
    head.writeUInt16LE(store ? 0 : 8, 8);   // method
    head.writeUInt16LE(dosTime, 10);
    head.writeUInt16LE(dosDate, 12);
    head.writeUInt32LE(crc, 14);
    head.writeUInt32LE(body.length, 18);
    head.writeUInt32LE(f.data.length, 22);
    head.writeUInt16LE(name.length, 26);
    head.writeUInt16LE(0, 28);
    locals.push(head, name, body);

    const cen = Buffer.alloc(46);
    cen.writeUInt32LE(0x02014b50, 0);
    cen.writeUInt16LE(20, 4);               // version made by
    cen.writeUInt16LE(20, 6);
    cen.writeUInt16LE(0x0800, 8);
    cen.writeUInt16LE(store ? 0 : 8, 10);
    cen.writeUInt16LE(dosTime, 12);
    cen.writeUInt16LE(dosDate, 14);
    cen.writeUInt32LE(crc, 16);
    cen.writeUInt32LE(body.length, 20);
    cen.writeUInt32LE(f.data.length, 24);
    cen.writeUInt16LE(name.length, 28);
    // extra, comment, disk, internal attrs, external attrs: all zero
    cen.writeUInt32LE(offset, 42);
    centrals.push(cen, name);
    offset += head.length + name.length + body.length;
  }
  const cd = Buffer.concat(centrals);
  const end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0);
  end.writeUInt16LE(files.length, 8);
  end.writeUInt16LE(files.length, 10);
  end.writeUInt32LE(cd.length, 12);
  end.writeUInt32LE(offset, 16);
  return Buffer.concat([...locals, cd, end]);
}
