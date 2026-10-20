// Live view of a chat while it runs: transcripts/run<n>.live.json (the conversation so far, the current step,
// and for goal runs the agent's decisions) plus screenshots/run<n>_live.png (the visible panel, OTP masked).
// Written after every step; a launcher (agentic-qa) polls them. Best effort: never fails a run.
import fs from 'node:fs';
import path from 'node:path';
import type { Page } from '@playwright/test';
import type { Message } from './transcript';
import { liveShot } from './shots';
import { saveChatHtml } from './chathtml';

export interface Decision {
  turn: number;
  at: string;
  /** what the agent said it is doing, in its own words */
  thought?: string;
  action: string;
  args?: unknown;
  outcome?: string;
}

export interface LiveState {
  run: number;
  id: string;
  title: string;
  booking?: string;
  sessionId?: string;
  state: 'running' | 'finished';
  step: string;
  lastAction: string;
  goal?: string;
  decisions?: Decision[];
  messages: Pick<Message, 'who' | 'time' | 'text' | 'layout' | 'buttons' | 'form' | 'chips'>[];
  updatedAt: string;
  screenshot?: string;
}

export async function writeLive(dir: string, page: Page | undefined, s: Omit<LiveState, 'updatedAt' | 'screenshot'>, shot = true): Promise<void> {
  try {
    const t = path.join(dir, 'transcripts');
    fs.mkdirSync(t, { recursive: true });
    let screenshot: string | undefined;
    if (shot && page) {
      const rel = `screenshots/run${s.run}_live.png`;
      const file = path.join(dir, rel);
      fs.mkdirSync(path.dirname(file), { recursive: true });
      const ok = await liveShot(page, file);
      if (ok) { screenshot = rel; keepStep(dir, s.run, file); }
    }
    // the chat itself as a scrollable page, refreshed every step (and once more when the chat ends)
    if (page) await saveChatHtml(page, path.join(dir, 'chat', `run${s.run}.html`));
    const body: LiveState = {
      ...s,
      // a typed one-time code echoed back by the widget is never written out
      messages: s.messages.map(m => ({ ...m, text: m.who === 'you' && /^\s*\d{6}\s*$/.test(m.text) ? '••••••' : m.text })),
      updatedAt: new Date().toISOString(), screenshot,
    };
    const file = path.join(t, `run${s.run}.live.json`);
    fs.writeFileSync(`${file}.tmp`, JSON.stringify(body, null, 2));
    fs.renameSync(`${file}.tmp`, file);     // a poller never reads half a file
  } catch { /* live view is best effort */ }
}

/**
 * The chat as the customer saw it, one picture per step: a copy of the live screenshot under
 * screenshots/run<n>_step<NN>.png, skipped when nothing on screen changed since the last one.
 */
const lastStep = new Map<string, { n: number; bytes: Buffer }>();
function keepStep(dir: string, run: number, file: string): void {
  try {
    const bytes = fs.readFileSync(file);
    const key = `${dir}|${run}`;
    const prev = lastStep.get(key);
    if (prev && prev.bytes.equals(bytes)) return;
    const n = (prev?.n ?? 0) + 1;
    fs.writeFileSync(path.join(dir, 'screenshots', `run${run}_step${String(n).padStart(2, '0')}.png`), bytes);
    lastStep.set(key, { n, bytes });
  } catch { /* best effort */ }
}

export function slim(messages: Message[]): LiveState['messages'] {
  return messages.map(m => ({ who: m.who, time: m.time, text: m.text, layout: m.layout, buttons: m.buttons, form: m.form, chips: m.chips }));
}
