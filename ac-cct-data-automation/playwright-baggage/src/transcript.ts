// Reading the bot: one entry per message with its text and layout (plain / info / warning / success),
// its buttons, form fields and links. The DOM is the source: the widget's `ac-chat:message` event only
// carries {participantRole, messageId}, never the content (checked in public-qa-chat ac-chat.js).
//
// Structure (probed 2026-10-08 on public-qa-chat, widget v2.5 INT): class names are styled-components
// hashes, so nothing here keys on them. Every bot message has a footer span holding the session UUID;
// the message list is the lowest common ancestor of those spans and each child of it is one message row.
import type { Locator, Page } from '@playwright/test';

export type Layout = 'plain' | 'info' | 'warning' | 'success' | 'alert';
export type Who = 'bot' | 'you' | 'widget';

export interface Message {
  index: number;
  who: Who;
  time?: string;
  text: string;
  layout: Layout;
  /** text of each [role=alert] box in the message, with its kind */
  boxes: { kind: Layout; text: string }[];
  buttons: string[];
  /** non-interactive chips, e.g. the language answer the widget keeps in the history */
  chips: string[];
  form: string[];
  links: { text: string; href: string }[];
  /** raw https:// in the visible text (a defect: links must be anchors) */
  rawUrls: string[];
}

export const UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/;

/** Background colours of the alert boxes (guide 7.2). */
export function layoutOf(bg: string): Layout {
  const c = bg.replace(/\s+/g, '');
  if (c === 'rgb(207,230,252)') return 'info';
  if (c === 'rgb(255,247,204)') return 'warning';
  if (c === 'rgb(223,240,219)') return 'success';
  return 'alert';
}

/** Widget chrome, never part of a message's buttons. */
export const CHROME = /^(helpful|not helpful|minimize( chat)?|full screen|exit full screen|download( transcript)?|close chat|flight details|new message|send message|close|dismiss)$/i;

interface RawRow {
  text: string;
  hasUuid: boolean;
  alerts: { bg: string; text: string }[];
  buttons: string[];
  chips: string[];
  form: string[];
  links: { text: string; href: string }[];
}

/** Runs in the page. Kept free of closures over Node values. */
function readRows(root: HTMLElement): RawRow[] {
  const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
  const scope = (root.querySelector('main') as HTMLElement) || root;
  const tags = [...scope.querySelectorAll<HTMLElement>('span,div')].filter(
    e => e.children.length === 0 && uuid.test((e.textContent || '').trim()));
  if (!tags.length) return [];
  let list: HTMLElement;
  if (tags.length === 1) {
    // one message so far: climb until the parent holds more than this row
    let el: HTMLElement = tags[0];
    while (el.parentElement && el.parentElement !== scope && el.parentElement.children.length === 1) el = el.parentElement;
    list = (el.parentElement && el.parentElement !== scope ? el.parentElement.parentElement : el.parentElement) || scope;
  } else {
    list = tags[0];
    while (list && !tags.every(t => list.contains(t))) list = list.parentElement as HTMLElement;
  }
  const visible = (e: Element) => {
    const r = (e as HTMLElement).getBoundingClientRect();
    const s = getComputedStyle(e as HTMLElement);
    return s.visibility !== 'hidden' && s.display !== 'none' && (r.width > 0 || r.height > 0);
  };
  const clean = (s: string) => (s || '').replace(/\s+/g, ' ').trim();
  const rows: RawRow[] = [];
  for (const row of [...list.children] as HTMLElement[]) {
    const text = (row.innerText || '').trim();
    if (!text) continue;
    const alerts = [...row.querySelectorAll<HTMLElement>('[role=alert]')].map(a => ({
      bg: getComputedStyle(a).backgroundColor, text: clean(a.innerText) }));
    const interactive = [...row.querySelectorAll<HTMLElement>(
      'button,[role=button],[role=checkbox],[role=option],[role=radio],[role=menuitem],input[type=checkbox],input[type=radio]')]
      .filter(visible);
    const buttons = interactive.map(b => {
      if (b instanceof HTMLInputElement) {
        const lab = b.labels && b.labels[0];
        return clean(lab ? lab.innerText : b.getAttribute('aria-label') || '');
      }
      return clean(b.innerText || b.getAttribute('aria-label') || '');
    }).filter(Boolean);
    const inField = (e: Element) => interactive.some(b => b.contains(e));
    const chips = [...row.querySelectorAll<HTMLElement>('span')]
      .filter(s => s.children.length === 0 && !inField(s) && !s.closest('p') && !uuid.test(clean(s.innerText)))
      .map(s => clean(s.innerText)).filter(Boolean);
    const form = [...row.querySelectorAll<HTMLElement>('label,input:not([type=checkbox]):not([type=radio]),textarea,select')]
      .filter(visible)
      .map(f => f.tagName === 'LABEL' ? clean(f.innerText)
        : clean(f.getAttribute('aria-label') || (f as HTMLInputElement).placeholder || ''))
      .filter(Boolean);
    const links = [...row.querySelectorAll<HTMLAnchorElement>('a[href]')].map(a => ({ text: clean(a.innerText), href: a.href }));
    rows.push({ text, hasUuid: tags.some(t => row.contains(t)), alerts, buttons, chips, form: [...new Set(form)], links });
  }
  return rows;
}

const HEADER = /^(Ask AC|You|Vous)\s*\n\s*(\d{1,2}:\d{2}(?:\s?[AP]M)?)\s*\n?/;

export function toMessages(rows: RawRow[]): Message[] {
  const out: Message[] = [];
  for (const r of rows) {
    let text = r.text;
    // a row without the "Ask AC / You + time" header is widget furniture (e.g. the language chips),
    // even though it carries the session-id footer
    let who: Who = 'widget';
    let time: string | undefined;
    const h = text.match(HEADER);
    if (h) { who = h[1] === 'Ask AC' ? 'bot' : 'you'; time = h[2]; text = text.slice(h[0].length); }
    for (const b of [...r.buttons, ...r.chips]) {
      // drop the button labels from the body text; they are listed separately
      if (b && !CHROME.test(b)) text = text.split('\n').filter(l => l.trim() !== b).join('\n');
    }
    text = text.replace(new RegExp(UUID.source, 'g'), '').split('\n').map(l => l.trim())
      .filter(l => l && !CHROME.test(l)).join('\n').trim();
    const boxes = r.alerts.map(a => ({ kind: layoutOf(a.bg), text: a.text }));
    const flat = text.replace(/\s+/g, ' ');
    // the message is "boxed" when the box carries most of its words; a box inside a longer plain reply stays a box entry
    const main = boxes.find(b => b.text && flat.length > 0 && b.text.length >= flat.length * 0.6);
    const buttons = r.buttons.filter(b => !CHROME.test(b));
    const chips = r.chips.filter(c => !CHROME.test(c) && c !== 'Ask AC' && c !== time && !buttons.includes(c));
    out.push({
      index: out.length, who, time, text, layout: main ? main.kind : 'plain', boxes, buttons,
      chips: who === 'widget' ? chips : [], form: r.form, links: r.links,
      rawUrls: (flat.match(/https?:\/\/\S+/g) || []).filter(u => !r.links.some(l => l.text.includes(u))),
    });
  }
  return out;
}

export async function readMessages(root: Locator): Promise<Message[]> {
  const rows = await root.evaluate(readRows);
  return toMessages(rows);
}

/** Split a plain innerText dump into messages (fallback / offline use; no layout). Guide 7.1. */
export function splitInnerText(t: string): { who: Who; time: string; text: string }[] {
  const parts = t.split(/^(Ask AC|You)\n(\d{1,2}:\d{2}(?: [AP]M)?)$/m);
  const out: { who: Who; time: string; text: string }[] = [];
  for (let i = 1; i + 2 < parts.length + 1; i += 3) {
    const body = (parts[i + 2] || '').replace(new RegExp(UUID.source, 'g'), '').trim();
    out.push({ who: parts[i] === 'Ask AC' ? 'bot' : 'you', time: parts[i + 1], text: body });
  }
  return out;
}

export async function sessionId(page: Page): Promise<string | undefined> {
  const t = await page.locator('#ac-chat-widget-container').innerText().catch(() => '');
  return t.match(UUID)?.[0];
}
