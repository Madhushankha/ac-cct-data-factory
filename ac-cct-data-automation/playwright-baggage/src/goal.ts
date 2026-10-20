// AI customer: Playwright driven by a model that looks at the screen, like a person at the keyboard.
//
// Each turn the model gets a screenshot of the chat and a numbered list of every control on the page
// right now (buttons, options, checkboxes, text fields, the message box, an open pop-up) and answers
// with ONE action: click #n, type into #n, send a message, upload files, scroll, wait, get the email
// code, or finish. A failed action is reported back to it and it tries something else; three failures
// in a row end the chat. The booking, the case brief and any extra instructions come from the launcher.
//
// Safety is enforced in code, not left to the model: every click and every typed field goes through
// guards.assertAllowed (never "Yes, proceed", never payout country / bank details / the manual-review
// email form / a third-party answer), and a safety stop showing on screen ends the chat.
//
// Model: Bedrock Converse, GOAL_MODEL_ID (default global.anthropic.claude-sonnet-4-6) in AGENT_REGION
// (default ca-central-1) with BEDROCK_PROFILE / AWS_PROFILE (default int-cce).
import fs from 'node:fs';
import path from 'node:path';
import { expect, type Page, type TestInfo } from '@playwright/test';
import { BedrockRuntimeClient, ConverseCommand, type ContentBlock, type Tool } from '@aws-sdk/client-bedrock-runtime';
import { fromIni } from '@aws-sdk/credential-providers';
import { settle, typeInto } from './chat';
import { ROOT } from './config';
import { assertAllowed, detect, SafetyStopError, STOPS, type StopKind } from './guards';
import { describe, genericDefects } from './judge';
import type { Scenario } from './scenario';
import { EndRun, Run } from './steps';
import type { Message } from './transcript';

/**
 * One goal chat. From a seeded case: `title`, `brief` (the gap-doc description without its "Expected:" part,
 * i.e. what the customer does) and `expect` (what the assistant should conclude; shown to the judge only,
 * never to the customer). `goal` adds free-text instructions on top, or stands alone for a hand-written chat.
 */
export interface GoalItem {
  pnr: string; caseId?: string; pool?: string; maxTurns?: number;
  title?: string; brief?: string; expect?: string; goal?: string;
  /** a Jira/Xray test: its Cucumber customer steps, in order (the AI follows them, not a goal) */
  script?: ScriptStep[];
  /** the bot lines/alerts/options the test expects, judged after the chat */
  checkpoints?: Checkpoint[];
  /** the test's own example data, mapped to the seeded booking in the instructions */
  sample?: { name?: string; first?: string; pnr?: string };
  /** safety stops this test is meant to pass (FD submits its claim on INT: payout-country, payment-proceed) */
  allow?: StopKind[];
  jiraKey?: string;
}

export interface ScriptStep { type: string; value?: string; line?: number; reason?: string; after_line?: number }
export interface Checkpoint { kind?: string; text?: string; line?: number; requirement?: string | null }

interface Control { id: number; role: string; label: string; checked?: boolean; value?: string; inDialog: boolean }

const DEFAULT_GOAL = 'Play out this test case as the customer until the assistant gives its answer for it ' +
  '(a decision, an eligibility outcome, a hand-off, or the next form it needs), then call finish.';
const MODEL = process.env.GOAL_MODEL_ID || 'global.anthropic.claude-sonnet-4-6';
const REGION = process.env.AGENT_REGION || 'ca-central-1';
const PROFILE = process.env.BEDROCK_PROFILE || process.env.AWS_PROFILE || 'int-cce';
const RECEIPTS = ['receipts/clothing-receipt.pdf', 'receipts/toiletries-receipt.pdf'];
const MAX_ERRORS_IN_A_ROW = 3;
/** INT can take 2-3 minutes to answer after a submit (e.g. the payout country): wait this long for a reply */
const REPLY_WAIT_MS = Number(process.env.REPLY_WAIT_MS || 240_000);
/** widget chrome the customer never needs */
const CHROME = /^(helpful|not helpful|minimize( chat)?|full screen|exit full screen|download( transcript)?|close chat|new message|dismiss)$/i;

let client: BedrockRuntimeClient | undefined;
function bedrock(): BedrockRuntimeClient {
  client ??= new BedrockRuntimeClient({ region: REGION, credentials: fromIni({ profile: PROFILE }) });
  return client;
}

const num = (description: string) => ({ type: 'number', description });
const str = (description: string) => ({ type: 'string', description });
const TOOLS: Tool[] = ([
  ['click', 'Click a control from the numbered list (a button, an option, a checkbox, a link, a date in a calendar).', { id: num('control number') }, ['id']],
  ['type', 'Click into a text field from the numbered list and type into it (identity form, amounts, any form field). Does not press Submit: click it next.',
    { id: num('control number of the field'), text: str('what to type') }, ['id', 'text']],
  ['choose_option', 'Pick a value in a dropdown / type-ahead field (a combobox such as Country): types the option and clicks the matching suggestion. Does not press Submit: click it next.',
    { id: num('control number of the combobox'), option: str('the option to pick, e.g. Canada') }, ['id', 'option']],
  ['send_message', 'Type a message in the chat box at the bottom and press Send, as the customer.', { text: str('the message') }, ['text']],
  ['get_email_code', 'Choose to receive the one-time code by email, then type it into the code field and submit. Use when the assistant offers where to send a verification code.', {}, []],
  ['complete_persona', 'Identity verification (Persona), the whole step: clicks "Verify my identity" (or "Get verified"), opens the withpersona.com link the assistant gives, closes it, and types "done" in the chat (the INT skip). Use it once when the assistant asks to verify identity; do not click those buttons yourself.', {}, []],
  ['upload_files', 'Attach the test receipt files to the open upload pop-up (then wait for them to show, and click its Submit).', {}, []],
  ['scroll', 'Scroll the chat.', { direction: { type: 'string', enum: ['up', 'down'] } }, ['direction']],
  ['wait', 'Wait for the assistant (it is still typing or loading).', { seconds: num('2 to 20') }, ['seconds']],
  ['finish', 'End the chat: the goal is reached, or it cannot be reached.',
    { outcome: { type: 'string', enum: ['goal_reached', 'cannot_reach'] }, summary: str('one or two sentences on what happened') },
    ['outcome', 'summary']],
] as [string, string, Record<string, unknown>, string[]][]).map(([name, description, properties, required]) => ({
  toolSpec: { name, description, inputSchema: { json: { type: 'object',
    properties: { why: str('one short sentence: what you see on screen and why you take this action'), ...properties },
    required: ['why', ...required] } as any } },
}) as Tool);

function scripted(item: GoalItem, b: { first: string; last: string; pnr: string }): string {
  const sample = item.sample || {};
  const steps = (item.script || []).map((st, i) => {
    const v = st.value ?? '';
    const what = st.type === 'assumed' ? `answer "${v}" (not scripted in the test: ${st.reason || 'the bot asks'})`
      : st.type === 'otp' ? 'enter the verification code: use get_email_code (the test\'s code is an example)'
      : st.type === 'say' ? `send_message: "${v}"`
      : st.type === 'click' && /get verified/i.test(v) ? 'complete_persona'
      : `${st.type}: "${v}"`;
    return `${i + 1}. ${what}${i === 0 && /english/i.test(v) ? '  (ALREADY DONE: the chat opens in English)' : ''}`;
  }).join('\n');
  return [
    'You are a QA tester executing a Jira/Xray Cucumber test in the "Ask AC" web chat, operating the browser like a person: you see a screenshot and a numbered list of the controls on the page, and you act with one tool call per turn.',
    item.title ? `Test: ${item.jiraKey ? item.jiraKey + ' ' : ''}${item.title}` : '',
    'Perform the customer steps below IN ORDER, one per turn, mapping each to what is on screen (a button or option with that label, the message box, or a form field). Do not skip, add or reorder steps. If the assistant asks something the script does not answer, give the plainest answer that keeps the scripted flow going and say so in why.',
    `The test's sample data is replaced by the seeded booking: name "${sample.name || ''}" -> "${b.first} ${b.last}" (first name ${b.first}), booking reference "${sample.pnr || ''}" -> "${b.pnr}". A masked email/phone option in the script means: pick the Email option on screen.`,
    'Forms: type each value into its own field (first name, last name, booking reference), then click that form\'s Submit.',
    'This test submits its claim on INT: you DO answer the payout country, choose the payout option and confirm/submit exactly as scripted. Never type bank account, card or IBAN numbers.',
    'Customer steps:', steps,
    'The assistant can take 2-3 minutes to answer after a submit (for example after the payout country). The harness already waits for its reply after each click or message; if the screen still shows the same question, use wait -- NEVER repeat a click or re-submit an answer that was already given.',
    'Dropdowns and type-ahead fields (role combobox, e.g. Country): use choose_option once, then click the form\'s Submit once.',
    'Identity check: use complete_persona once. If the assistant still says the verification is incomplete after a second complete_persona, stop and call finish with cannot_reach (the result did not reach the chat); never loop on it.',
    'Do not finish while scripted steps remain: after the claim is submitted, wait for the assistant to ask if there is anything else, answer as the script says (usually No) and wait for its closing message.',
    'Call finish with goal_reached right after the last scripted step is done, or cannot_reach if the assistant goes another way and the next step can no longer be performed.',
    '- Before the tool call, write one short sentence saying what you see and which step you are doing.',
  ].filter(Boolean).join('\n');
}

function system(item: GoalItem, b: { first: string; last: string; pnr: string; flight?: string; landed?: string; note?: string }): string {
  if (item.script?.length) return scripted(item, b);
  return [
    'You are a QA tester role-playing an Air Canada customer in the "Ask AC" web chat, operating the browser like a person: you see a screenshot and a numbered list of the controls on the page, and you act with one tool call per turn.',
    item.title ? `Test case: ${item.title}` : '',
    item.brief ? `What this customer does (from the test design): ${item.brief}` : '',
    `Your goal: ${[item.brief || item.title ? DEFAULT_GOAL : '', item.goal].filter(Boolean).join(' ') || DEFAULT_GOAL}`,
    `You are ${b.first} ${b.last}. Booking reference ${b.pnr}${b.flight ? `, flight ${b.flight}` : ''}${b.landed ? `, arrived ${b.landed}` : ''}.`,
    b.note ? `About your bag: ${b.note}.` : '',
    'The chat is already open and English is already chosen; start by telling the assistant why you are here with send_message.',
    'How to act:',
    '- Act like a real customer: short natural messages, answer what is asked, prefer the buttons or options the assistant offers.',
    "- Follow the normal flow and agree to go ahead at each step; give the special answer the test design describes ONLY at the question it names. Example: \"readiness answered no\" means answering No to \"are you ready to list the items in your bag\" (Yes, let's start / No, not now), not to an earlier question.",
    '- The first "Would you like to get started?" after the automated-decision notice: answer Yes, unless the test design is about that notice.',
    '- Identity form: type your first name, last name and booking reference into its fields (type), then click its Submit.',
    '- Verification code: use get_email_code. Never type a code yourself.',
    '- Multi-choice lists: click each option you want, then click Submit. Pop-ups (bag contents, receipts): fill the fields, then click the pop-up\'s Submit.',
    '- Only use control numbers from the current list; they change every turn. If an action fails, look again and try another way.',
    '- Never give payment or bank details, never confirm a payment, never answer which country a payout goes to, never fill a manual-review email form, never claim to be a third party. The harness stops the chat at those points by itself.',
    '- Call finish with goal_reached as soon as the goal is achieved, or cannot_reach when the assistant clearly cannot do it or keeps looping.',
    '- Before the tool call, write one short sentence saying what you see and why you act.',
  ].filter(Boolean).join('\n');
}

function transcriptText(messages: Message[], tail = 16): string {
  return messages.slice(-tail).map(m => {
    const who = m.who === 'you' ? 'CUSTOMER' : m.who === 'bot' ? `ASSISTANT${m.layout !== 'plain' ? ` [${m.layout} box]` : ''}` : 'WIDGET';
    return `${who}: ${m.text.replace(/\s+/g, ' ').slice(0, 700)}`;
  }).filter(l => !/^WIDGET: $/.test(l)).join('\n');
}

export class GoalRun extends Run {
  private item: GoalItem;
  private maxTurns: number;
  private outcome: 'goal_reached' | 'cannot_reach' | 'stopped' | 'budget' | 'errors' | '' = '';
  private controls: Control[] = [];

  constructor(page: Page, item: GoalItem, run: number, testInfo?: TestInfo) {
    const s: Scenario = {
      id: 'goal', run, caseId: item.caseId, file: 'goal',
      title: (item.title ? `${item.title}${item.goal ? ' · ' + item.goal : ''}` : `Goal: ${item.goal ?? ''}`).slice(0, 160),
      booking: { pnr: item.pnr, ...(item.pool ? { pool: item.pool } : {}) },
      first_message: '', steps: [],
    };
    super(page, s, testInfo);
    this.item = item;
    this.goal = [item.title, item.brief, item.goal].filter(Boolean).join(' — ') || DEFAULT_GOAL;
    this.maxTurns = Math.max(3, Math.min(90, item.maxTurns ?? (item.script?.length ? Math.max(40, item.script.length * 4) : 40)));
    this.chat.allow = item.allow ?? [];
  }

  /** Run.execute calls start() and then walks steps (none here): the whole conversation lives in start(). */
  protected override async start(): Promise<void> {
    this.currentStep = 'open chat';
    await this.chat.open(this.s.lang ?? 'English', { requireGreeting: false });
    // the privacy notice is a screen before the chat on INT: keep its words as evidence for the Jira checkpoints
    if (this.chat.consent) this.r.notes.push(`pre-chat consent screen: ${this.chat.consent.slice(0, 1200)}`);
    this.r.sessionId = await this.chat.sessionId();
    this.messages = await this.chat.messages().catch(() => []);
    await this.live();
    const sys = system(this.item, this.booking!);
    let errors = 0;
    for (let turn = 1; turn <= this.maxTurns; turn++) {
      const decided = await this.decide(sys, turn);
      const d: any = { turn, at: new Date().toISOString(), thought: decided.thought, action: decided.name, args: decided.input };
      this.decisions.push(d);
      if (decided.name === 'finish') {
        const out = decided.input as { outcome: string; summary: string };
        this.outcome = out.outcome === 'goal_reached' ? 'goal_reached' : 'cannot_reach';
        this.r.notes.push(`AI customer: ${out.outcome} — ${out.summary}`);
        this.r.endedAt_step = out.outcome === 'goal_reached' ? 'goal reached' : 'goal not reachable';
        d.outcome = out.outcome;
        if (this.outcome === 'cannot_reach')
          await this.fail({ step: `AI customer gave up (turn ${turn})`, expected: this.goal ?? '', got: `${out.summary} — last reply: ${describe(this.lastBot())}`, kind: 'flow' });
        await this.live();
        return;
      }
      this.currentStep = `turn ${turn}: ${decided.name}`;
      this.windowStart = this.messages.length;
      try {
        const botsBefore = this.messages.filter(m => m.who === 'bot').length;
        d.outcome = (await this.perform(decided.name, decided.input as Record<string, any>)) || 'ok';
        // only an action that sends something gets an answer: opening a field or ticking a box does not
        const sends = /^(send_message|get_email_code|complete_persona)$/.test(decided.name)
          || (decided.name === 'click' && /^(button|link)$/.test(this.controls.find(c => c.id === Number((decided.input as any)?.id))?.role ?? ''));
        if (sends) {
          const replied = await this.waitForReply(botsBefore, REPLY_WAIT_MS);
          if (!replied) d.outcome += ` (no new assistant message after ${Math.round(REPLY_WAIT_MS / 1000)} s)`;
        }
        errors = 0;
      } catch (e: any) {
        // not fatal: the model sees what went wrong next turn and tries another way
        d.outcome = e instanceof SafetyStopError ? `refused by the safety guard: ${e.message}` : `failed: ${String(e?.message ?? e).split('\n')[0].slice(0, 200)}`;
        errors++;
      }
      this.messages = await this.chat.messages().catch(() => this.messages);
      const fresh = this.messages.slice(this.windowStart);
      for (const x of genericDefects(fresh)) await this.fail({ step: `turn ${turn}`, expected: 'no raw URLs or error text', got: `${x.what}: ${describe(x.m)}`, kind: x.kind });
      await this.live();
      await this.checkStops(fresh);
      if (errors >= MAX_ERRORS_IN_A_ROW) {
        this.outcome = 'errors';
        await this.fail({ step: `turn ${turn}`, expected: 'the AI customer can operate the chat',
          got: `${errors} actions in a row failed; last: ${d.outcome}`, kind: 'flow', severity: 'Medium' });
        return;
      }
    }
    this.outcome = 'budget';
    await this.fail({ step: `after ${this.maxTurns} turns`, expected: this.goal ?? '',
      got: `turn budget used up; last reply: ${describe(this.lastBot())}`, kind: 'flow' });
  }

  /** a safety stop is where a goal chat ends, not a failure */
  protected override async checkStops(fresh: Message[]): Promise<void> {
    const hit = detect(fresh).filter(s => !this.chat.allow.includes(s.kind));
    if (!hit.length) return;
    const h = hit[0];
    this.outcome = 'stopped';
    this.r.stepsSeen.push(h.board);
    this.r.endedAt_step = `${h.board} (stopped: never ${h.never})`;
    this.r.notes.push(`safety stop ${h.board} reached; the chat was ended there`);
    this.decisions.push({ turn: this.decisions.length + 1, at: new Date().toISOString(), action: 'safety stop', outcome: h.board });
    await this.live();
    throw new EndRun();
  }

  // ------------------------------------------------------------ what is on screen

  /** Number every visible, usable control in the widget and any open pop-up (data-qa-id on the element). */
  private async readControls(): Promise<Control[]> {
    const list = await this.chat.page.evaluate((chromeSrc: string) => {
      const chrome = new RegExp(chromeSrc, 'i');
      document.querySelectorAll('[data-qa-id]').forEach(e => e.removeAttribute('data-qa-id'));
      const scopes = [document.querySelector('#ac-chat-widget-container'), ...Array.from(document.querySelectorAll('[role=dialog]'))]
        .filter(Boolean) as Element[];
      const sel = 'button,[role=button],[role=checkbox],[role=option],[role=radio],[role=switch],[role=gridcell] button,input,textarea,select,a[href]';
      const seen = new Set<Element>();
      const out: any[] = [];
      let n = 0;
      for (const sc of scopes) for (const el of Array.from(sc.querySelectorAll<HTMLElement>(sel))) {
        if (seen.has(el)) continue;
        seen.add(el);
        const r = el.getBoundingClientRect();
        const s = getComputedStyle(el);
        if (s.visibility === 'hidden' || s.display === 'none' || (r.width === 0 && r.height === 0)) continue;
        const input = el instanceof HTMLInputElement ? el : null;
        if (input && (input.type === 'hidden' || input.type === 'file')) continue;
        // custom checkboxes/radios: the input is visually hidden under its label; the label is what a person clicks
        let target: HTMLElement = el;
        if (input && (input.type === 'checkbox' || input.type === 'radio') && (r.width < 4 || r.height < 4 || Number(s.opacity) === 0)) {
          const lab = (input.labels?.[0] as HTMLElement | undefined) || (input.closest('label') as HTMLElement | null) || undefined;
          if (!lab) continue;
          seen.add(lab);
          target = lab;
        }
        const disabled = (el as HTMLButtonElement).disabled || el.getAttribute('aria-disabled') === 'true';
        const tag = el.tagName.toLowerCase();
        const role = el.getAttribute('role') || (tag === 'a' ? 'link' : input ? (input.type === 'checkbox' ? 'checkbox' : input.type === 'radio' ? 'radio' : 'textbox')
          : tag === 'textarea' ? 'textbox' : tag === 'select' ? 'select' : 'button');
        if (disabled && role !== 'textbox') continue;    // old messages keep their buttons, disabled
        let label = el.getAttribute('aria-label') || '';
        if (!label && input?.labels?.[0]) label = input.labels[0].innerText;
        if (!label && el.id) { const l = document.querySelector(`label[for="${el.id}"]`) as HTMLElement | null; if (l) label = l.innerText; }
        if (!label) label = (el.innerText || (el as HTMLInputElement).placeholder || '').trim();
        label = label.replace(/\s+/g, ' ').trim().slice(0, 100);
        if (!label || chrome.test(label)) continue;
        n++;
        target.setAttribute('data-qa-id', String(n));
        const v = input || tag === 'textarea' ? (el as HTMLInputElement).value : undefined;
        out.push({ id: n, role, label, inDialog: !!el.closest('[role=dialog]'),
          checked: !!(input?.checked) || el.getAttribute('aria-checked') === 'true' || el.getAttribute('aria-selected') === 'true',
          value: v === undefined ? undefined : /\d{6}/.test(v) ? '••••••' : v });
      }
      return out;
    }, CHROME.source).catch(() => [] as Control[]);
    this.controls = list;
    return list;
  }

  private control(id: unknown): { c: Control; el: ReturnType<Page['locator']> } {
    const c = this.controls.find(x => x.id === Number(id));
    if (!c) throw new Error(`there is no control #${id} on screen now`);
    return { c, el: this.chat.page.locator(`[data-qa-id="${c.id}"]`).first() };
  }

  // ------------------------------------------------------------ doing it

  private async perform(name: string, a: Record<string, any>): Promise<string | void> {
    const page = this.chat.page;
    switch (name) {
      case 'click': {
        const { c, el } = this.control(a.id);
        assertAllowed({ tap: c.label }, this.chat.allow);
        await el.scrollIntoViewIfNeeded().catch(() => {});
        const clicked = await el.click({ timeout: 4000 }).then(() => true, () => false)
          // covered by its label or a decoration: click the label, as a person would
          || await el.evaluate(n => { const l = (n as HTMLInputElement).labels?.[0] ?? n.closest('label'); if (l) { (l as HTMLElement).click(); return true; } return false; })
            .catch(() => false)
          || await el.click({ force: true, timeout: 4000 }).then(() => true, () => false);
        if (!clicked) throw new Error(`could not click [${c.label}]: something covers it`);
        this.chat.lastAction = `clicked [${c.label}]`;
        await settle(this.chat.root(), c.inDialog ? 1500 : 4000);
        return;
      }
      case 'type': {
        const { c, el } = this.control(a.id);
        const text = String(a.text ?? '');
        assertAllowed({ fillLabel: c.label, type: text }, this.chat.allow);
        if (/\d{8,}/.test(text.replace(/[\s-]/g, '')) && !/booking|reference/i.test(c.label))
          throw new SafetyStopError('forbidden-action', 'refused to type a long number (card or bank details)');
        await typeInto(el, text);
        this.chat.lastAction = `typed "${text}" into ${c.label}`;
        return;
      }
      case 'choose_option': {
        // a type-ahead field (role=combobox, "Start typing a country"): type, then pick the matching suggestion
        const { c, el } = this.control(a.id);
        const want = String(a.option ?? '').trim();
        if (!want) throw new Error('choose_option needs the option text');
        assertAllowed({ fillLabel: c.label, type: want }, this.chat.allow);
        await el.click({ timeout: 4000 }).catch(() => {});
        await el.fill('').catch(() => {});
        await typeInto(el, want);
        const exact = new RegExp(`^\\s*(?:[A-Z]{2}\\s+)?${want.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\s*$`, 'i');
        const options = page.locator('[role=option]').filter({ visible: true });
        await options.first().waitFor({ state: 'visible', timeout: 15_000 }).catch(() => {});
        const best = options.filter({ hasText: exact }).first();
        const pick = await best.isVisible().catch(() => false) ? best : options.filter({ hasText: new RegExp(want, 'i') }).first();
        if (await pick.isVisible().catch(() => false)) await pick.click({ timeout: 4000 });
        else { await el.press('ArrowDown').catch(() => {}); await el.press('Enter').catch(() => {}); }
        await page.waitForTimeout(800);
        const now = (await el.inputValue().catch(() => '')).trim();
        if (!new RegExp(want, 'i').test(now)) throw new Error(`"${want}" was not taken by [${c.label}] (field shows "${now}")`);
        this.chat.lastAction = `chose "${now}" in ${c.label}`;
        return `chose "${now}" -- now click the form's Submit once`;
      }
      case 'send_message': return this.chat.say(String(a.text ?? ''));
      case 'complete_persona': return this.persona();
      case 'get_email_code': return this.emailCode();
      case 'upload_files': {
        const files = RECEIPTS.map(f => path.resolve(ROOT, f)).filter(f => fs.existsSync(f));
        const input = page.locator('[role=dialog] input[type=file], #ac-chat-widget-container input[type=file]').last();
        await input.setInputFiles(files, { timeout: 10_000 });
        this.chat.lastAction = `attached ${files.map(f => path.basename(f)).join(', ')}`;
        await page.waitForTimeout(3000);
        return `attached ${files.length} file(s); wait for "View receipt" before Submit`;
      }
      case 'scroll':
        await this.chat.root().evaluate((r, up) => {
          for (const el of Array.from(r.querySelectorAll<HTMLElement>('*')))
            if (/(auto|scroll)/.test(getComputedStyle(el).overflowY) && el.scrollHeight > el.clientHeight) el.scrollBy(0, up ? -500 : 500);
        }, a.direction === 'up');
        return;
      case 'wait':
        await page.waitForTimeout(Math.max(2, Math.min(20, Number(a.seconds) || 5)) * 1000);
        return;
      default: throw new Error(`unknown action ${name}`);
    }
  }

  /**
   * Wait until the assistant has said something new (a bot message beyond `botsBefore`) and the chat has gone
   * quiet, or until `ms` passes. Returns whether a reply came. Never clicks or types: it only waits, so a slow
   * answer is never taken for a missed click.
   */
  private async waitForReply(botsBefore: number, ms: number): Promise<boolean> {
    const end = Date.now() + ms;
    while (Date.now() < end) {
      const msgs = await this.chat.messages().catch(() => this.messages);
      if (msgs.filter(m => m.who === 'bot').length > botsBefore) {
        await settle(this.chat.root(), 4000, 60_000).catch(() => {});
        this.messages = await this.chat.messages().catch(() => msgs);
        return true;
      }
      if (this.decisions.length) {
        this.currentStep = `waiting for the assistant (${Math.round((Date.now() - end + ms) / 1000)} s)`;
        await this.live().catch(() => {});
      }
      await this.chat.page.waitForTimeout(3000);
    }
    return false;
  }

  /**
   * The code tool does the whole step. The broker (getOtp) taps Email itself, right after it lists the inbox,
   * so the code it reads is the one this tap sent: here we only wait until the assistant shows that choice
   * and it can be pressed (INT can take a while to render it), never tap it ourselves.
   */
  private async emailCode(): Promise<string> {
    const root = this.chat.root();
    const email = root.getByRole('button', { name: /^\s*(E-?mail|Courriel)\b/i }).filter({ visible: true }).last();
    const ready = await expect(email).toBeEnabled({ timeout: REPLY_WAIT_MS }).then(() => true, () => false);
    if (!ready) {
      const field = root.getByLabel(/Verification code|Code de vérification/i).filter({ visible: true }).last();
      throw new Error(await field.isVisible().catch(() => false)
        ? 'a code was already requested in this chat (the Email choice is used); this run cannot read that code'
        : 'the assistant has not offered to send a code by email yet: wait for it');
    }
    await settle(root, 2000, 20_000).catch(() => {});
    await this.verify();
    return 'code entered and verified';
  }

  /**
   * Identity check (Persona), the INT way: click "Verify my identity" (or "Get verified"), wait for the
   * withpersona.com link the assistant posts (valid 30 minutes), open it in a new tab, close it again, then tell
   * the assistant "done" in the chat (on INT that is the skip). Every step has a hard time limit.
   */
  private async persona(): Promise<string> {
    const page = this.chat.page;
    const root = this.chat.root();
    const linkHref = async (): Promise<string | undefined> =>
      (await root.locator('a[href*="withpersona.com"]').last().getAttribute('href', { timeout: 2000 }).catch(() => null))
      || ((await root.innerText({ timeout: 5000 }).catch(() => '')).match(/https:\/\/withpersona\.com\/\S+/g) || []).pop();
    let href = await linkHref();
    if (!href) {
      // French "Vérifier mon identité"
      const btn = root.getByRole('button', { name: /get verified|verify my identity|v[ée]rifi/i }).filter({ visible: true }).last();
      await btn.click({ timeout: 15_000 });
      this.chat.lastAction = `clicked [${(await btn.innerText({ timeout: 2000 }).catch(() => 'Verify my identity')).trim()}]`;
      const end = Date.now() + REPLY_WAIT_MS;
      while (!href && Date.now() < end) {
        await page.waitForTimeout(3000);
        href = await linkHref();
        // older builds open Persona in a tab of their own instead of posting a link
        const other = page.context().pages().find(p => p !== page && /withpersona/i.test(p.url()));
        if (!href && other) href = other.url();
      }
      if (!href) throw new Error(`no Persona link from the assistant within ${Math.round(REPLY_WAIT_MS / 1000)} s`);
    }
    this.r.notes.push(`Persona link: ${href.replace(/code=[^&\s]+/, 'code=…')}`);
    // open the link the way a customer clicks it, look at it, close it
    const tab = page.context().pages().find(p => p !== page && /withpersona/i.test(p.url())) ?? await page.context().newPage();
    let seen = '';
    try {
      if (!/withpersona/i.test(tab.url())) await tab.goto(href, { timeout: 45_000, waitUntil: 'domcontentloaded' }).catch(() => {});
      await tab.waitForTimeout(4000);
      await tab.screenshot({ path: path.join(this.dir, 'screenshots', `run${this.r.run}_persona.png`), timeout: 15_000 }).catch(() => {});
      seen = (await tab.innerText('body', { timeout: 5000 }).catch(() => '')).replace(/\s+/g, ' ').slice(0, 160);
      // INT: pressing the page's submit ("Consent and Continue") is enough, Persona passes the check by itself
      const go = tab.getByRole('button', { name: /consent and continue|continue|submit|accepter et continuer|continuer/i }).filter({ visible: true }).first();
      if (await go.isVisible({ timeout: 5000 }).catch(() => false)) {
        await go.click({ timeout: 10_000 }).catch(() => {});
        await tab.waitForTimeout(5000);
        await tab.screenshot({ path: path.join(this.dir, 'screenshots', `run${this.r.run}_persona_after.png`), timeout: 15_000 }).catch(() => {});
        seen += ` → after submit: ${(await tab.innerText('body', { timeout: 5000 }).catch(() => '')).replace(/\s+/g, ' ').slice(0, 160)}`;
      }
    } finally {
      await tab.close().catch(() => {});
      await page.bringToFront().catch(() => {});
    }
    this.r.notes.push(`Persona page said: "${seen}"`);
    // back in the chat: tell the assistant the check is done
    await this.chat.say('done');
    this.chat.lastAction = 'opened the Persona link, closed it and told the assistant "done"';
    return this.chat.lastAction;
  }

  // ------------------------------------------------------------ checkpoints (Jira test)

  /**
   * Each expected bot line/alert/option of the Jira test, matched to what the assistant actually said, in
   * order. Meaning must match; the test's sample data (names, PNR, flight number, dates, masked contacts)
   * differs because the booking is seeded, but amounts and outcomes must match. The judge quotes the
   * assistant and the quote is checked against the transcript.
   */
  private async judgeCheckpoints(): Promise<void> {
    const cps = this.item.checkpoints || [];
    if (!cps.length) return;
    const msgs = this.messages.map((m, i) => ({ i, m })).filter(x => x.m.who !== 'you' && (x.m.text || x.m.buttons.length));
    const transcript = msgs.map(x => `[${x.i}] ${x.m.who === 'bot' ? 'ASSISTANT' : 'WIDGET'}${x.m.layout !== 'plain' ? ` (${x.m.layout} box)` : ''}: `
      + `${x.m.text.replace(/\s+/g, ' ').slice(0, 600)}${x.m.buttons.length ? ` {buttons: ${x.m.buttons.join(' | ')}}` : ''}${x.m.form.length ? ` {form: ${x.m.form.join(', ')}}` : ''}`).join('\n');
    const consent = this.chat.consent ? `[consent] PRE-CHAT CONSENT SCREEN (shown before the chat opens): ${this.chat.consent.replace(/\s+/g, ' ').slice(0, 800)}\n` : '';
    const list = cps.map((c, n) => `${n + 1}. (${c.kind}${c.requirement ? ', ' + c.requirement : ''}) ${String(c.text || '').slice(0, 300)}`).join('\n');
    this.currentStep = 'checking the test\'s bot checkpoints';
    await this.live();
    let items: { n: number; status: string; message: number | null; quote: string; reason: string }[] = [];
    try {
      const res = await bedrock().send(new ConverseCommand({
        modelId: MODEL,
        system: [{ text: 'You check a chat transcript against a test\'s expected assistant lines, in order. For each expected item: pass = the assistant (or widget) shows the same meaning/element (wording may differ; the test\'s sample names, booking reference, flight number, dates and masked email/phone may differ because the booking is seeded; amounts, currencies, outcomes and option labels must match); fail = the assistant reached that point but said/showed something different (give the difference); not_reached = the chat never got there. quote must be copied exactly from the matched message.' }],
        messages: [{ role: 'user', content: [{ text: `Expected items:\n${list}\n\nTranscript (numbered messages):\n${consent}${transcript}` }] }],
        toolConfig: {
          tools: [{ toolSpec: { name: 'results', description: 'One result per expected item.', inputSchema: { json: { type: 'object', required: ['items'], properties: {
            items: { type: 'array', items: { type: 'object', required: ['n', 'status', 'reason'], properties: {
              n: { type: 'number' }, status: { type: 'string', enum: ['pass', 'fail', 'not_reached'] },
              message: { type: 'number' }, quote: { type: 'string' }, reason: { type: 'string' } } } } } } as any } } } as Tool],
          toolChoice: { tool: { name: 'results' } },
        },
        inferenceConfig: { maxTokens: 6000, temperature: 0 },
      }));
      const use = (res.output?.message?.content ?? []).find(b => 'toolUse' in b && b.toolUse) as ContentBlock.ToolUseMember | undefined;
      items = ((use?.toolUse.input as any)?.items ?? []);
    } catch (e: any) {
      this.r.notes.push(`checkpoint judge unavailable: ${String(e?.message ?? e).slice(0, 160)}`);
      return;
    }
    const norm = (t: string) => t.normalize('NFKD').toLowerCase().replace(/[\u2018\u2019\u201c\u201d'"`]/g, '')
      .replace(/[^a-z0-9$.%]+/g, ' ').replace(/\s+/g, ' ').trim();
    const said = (m: Message) => norm([m.text, ...m.buttons, ...m.form].join(' '));
    const results = cps.map((c, n) => {
      const it = items.find(x => x.n === n + 1) || { status: 'not_reached', message: null, quote: '', reason: 'no result returned' } as any;
      const q = norm(it.quote || '').slice(0, 120);
      const msg = it.message != null ? this.messages[it.message] : undefined;
      const hit = q ? (msg && said(msg).includes(q) ? msg : this.messages.find(m => m.who !== 'you' && said(m).includes(q))
        ?? (this.chat.consent && norm(this.chat.consent).includes(q) ? ({} as Message) : undefined)) : undefined;
      if (hit && it.message == null) it.message = this.messages.indexOf(hit as Message);
      const quoted = !!hit;
      const status = it.status === 'pass' && !quoted ? 'unverified' : it.status;
      return { n: n + 1, requirement: c.requirement || null, kind: c.kind, expected: c.text, line: c.line, status,
               message: it.message ?? null, quote: it.quote || '', reason: it.reason || '' };
    });
    (this.r as any).checkpoints = results;
    for (const x of results) {
      if (x.status === 'pass' && x.requirement && !this.r.stepsSeen.includes(x.requirement)) this.r.stepsSeen.push(x.requirement);
      if (x.status === 'fail' || x.status === 'not_reached') {
        await this.fail({ step: `${x.requirement || 'checkpoint'} #${x.n} (feature line ${x.line ?? '?'})`,
          expected: String(x.expected || '').slice(0, 300),
          got: x.status === 'not_reached' ? `not reached — ${x.reason}` : `${x.reason}${x.quote ? ` — assistant: "${x.quote.slice(0, 200)}"` : ''}`,
          kind: x.status === 'not_reached' ? 'flow' : 'wording', severity: x.status === 'not_reached' ? 'High' : 'Medium' });
      }
    }
    const c = (k: string) => results.filter(x => x.status === k).length;
    this.r.notes.push(`checkpoints: ${c('pass')} pass, ${c('fail')} fail, ${c('not_reached')} not reached, ${c('unverified')} unverified (quote not found) of ${results.length}`);
  }

  // ------------------------------------------------------------ deciding

  private async decide(sys: string, turn: number): Promise<{ name: string; input: unknown; thought?: string }> {
    this.messages = await this.chat.messages().catch(() => this.messages);
    const controls = await this.readControls();
    const root = this.chat.root();
    await root.evaluate(r => {        // newest message in view, as a person would have it
      for (const el of Array.from(r.querySelectorAll<HTMLElement>('*')))
        if (/(auto|scroll)/.test(getComputedStyle(el).overflowY)) el.scrollTop = el.scrollHeight;
    }).catch(() => {});
    const shot = await root.locator(':scope > div').first()
      .screenshot({ type: 'jpeg', quality: 60, timeout: 10_000, mask: [this.chat.page.locator('input[aria-label*="Verification" i]')] })
      .catch(() => undefined);
    const recent = this.decisions.slice(-6).map(d => `turn ${d.turn}: ${d.action} ${d.args && Object.keys(d.args as object).length ? JSON.stringify(d.args) : ''} -> ${d.outcome ?? ''}`).join('\n');
    const list = controls.map(c => `#${c.id} ${c.role} "${c.label}"${c.checked ? ' (selected)' : ''}${c.value ? ` value="${c.value}"` : ''}${c.inDialog ? ' [in pop-up]' : ''}`).join('\n');
    const text = [
      `Turn ${turn} of ${this.maxTurns}.`,
      'Chat so far (latest last):', transcriptText(this.messages) || '(empty)',
      `Controls on the page now:\n${list || '(none besides the message box)'}`,
      recent ? `Your previous actions and what happened:\n${recent}` : '',
      'Look at the screenshot and choose the next single action.',
    ].filter(Boolean).join('\n\n');
    this.currentStep = `turn ${turn}: looking at the screen`;
    await this.live();
    const content: ContentBlock[] = [{ text }];
    if (shot) content.unshift({ image: { format: 'jpeg', source: { bytes: new Uint8Array(shot) } } } as ContentBlock);
    const res = await bedrock().send(new ConverseCommand({
      modelId: MODEL,
      system: [{ text: sys }],
      messages: [{ role: 'user', content }],
      toolConfig: { tools: TOOLS, toolChoice: { any: {} } },
      inferenceConfig: { maxTokens: 800, temperature: 0.3 },
    }));
    const blocks = (res.output?.message?.content ?? []) as ContentBlock[];
    const said = blocks.map(b => ('text' in b ? b.text : '')).filter(Boolean).join(' ').trim();
    const use = blocks.find(b => 'toolUse' in b && b.toolUse) as ContentBlock.ToolUseMember | undefined;
    if (!use) return { name: 'wait', input: { seconds: 3 }, thought: said || 'no action returned' };
    const { why, ...input } = (use.toolUse.input ?? {}) as Record<string, unknown>;
    return { name: use.toolUse.name!, input, thought: String(why ?? '') || said || undefined };
  }

  // ------------------------------------------------------------ judging

  /**
   * Compare the conversation with the case's expected outcome. The judge must quote the assistant, and the
   * quote is checked against the transcript: a verdict resting on words the assistant never wrote is
   * discarded. "unclear" is no evidence, never a fail.
   */
  private async judgeExpected(): Promise<void> {
    if (!this.item.expect) return;
    const bot = this.messages.filter(m => m.who === 'bot');
    if (!bot.length) return;
    this.currentStep = 'judging against the expected outcome';
    await this.live();
    let v: { verdict: string; quote: string; reason: string } | undefined;
    try {
      const res = await bedrock().send(new ConverseCommand({
        modelId: MODEL,
        system: [{ text: 'You grade an airline chat assistant against a test case. Judge only what the ASSISTANT said. ' +
          'match = the assistant reached the expected step/outcome (same meaning, wording may differ); mismatch = it clearly went ' +
          'another way or gave a different outcome; unclear = the conversation ended before the assistant addressed it. ' +
          'quote must be copied exactly from one ASSISTANT message.' }],
        messages: [{ role: 'user', content: [{ text: `Test case: ${this.item.title ?? ''}\nExpected: ${this.item.expect}\n\nConversation:\n${transcriptText(this.messages, 60)}` }] }],
        toolConfig: {
          tools: [{ toolSpec: { name: 'verdict', description: 'The verdict.', inputSchema: { json: { type: 'object', required: ['verdict', 'quote', 'reason'],
            properties: { verdict: { type: 'string', enum: ['match', 'mismatch', 'unclear'] }, quote: { type: 'string' }, reason: { type: 'string' } } } as any } } } as Tool],
          toolChoice: { tool: { name: 'verdict' } },
        },
        inferenceConfig: { maxTokens: 600, temperature: 0 },
      }));
      const use = (res.output?.message?.content ?? []).find(b => 'toolUse' in b && b.toolUse) as ContentBlock.ToolUseMember | undefined;
      v = use?.toolUse.input as typeof v;
    } catch (e: any) {
      this.r.notes.push(`judge unavailable: ${String(e?.message ?? e).slice(0, 160)}`);
      return;
    }
    if (!v) return;
    const norm = (t: string) => t.replace(/\s+/g, ' ').trim().toLowerCase();
    const quoted = !!v.quote && bot.some(m => norm(m.text).includes(norm(v!.quote).slice(0, 200)));
    if (v.verdict !== 'unclear' && !quoted) {
      this.r.notes.push(`judge verdict "${v.verdict}" discarded: its quote is not in the transcript`);
      v = { ...v, verdict: 'unclear' };
    }
    this.r.notes.push(`expected outcome: ${v.verdict} — ${v.reason}${quoted ? ` (assistant: "${v.quote.slice(0, 200)}")` : ''}`);
    if (v.verdict === 'match') this.r.stepsSeen.push('expected outcome');
    if (v.verdict === 'mismatch')
      await this.fail({ step: 'expected outcome', expected: this.item.expect, got: `${v.reason} — assistant: "${v.quote}"`, kind: 'flow' });
    if (v.verdict === 'unclear') this.unclear = true;
  }

  private unclear = false;

  protected override async finish(): Promise<void> {
    if (!this.r.result.startsWith('blocked')) {
      await this.judgeCheckpoints().catch(e => this.r.notes.push(`checkpoint judge error: ${String(e?.message ?? e).slice(0, 160)}`));
      await this.judgeExpected().catch(() => {});
    }
    await super.finish();
    if (this.unclear && this.r.result === 'pass') {
      // no evidence either way is not a pass: say so instead of reporting green
      this.r.result = 'blocked (expected outcome not reached in the chat)';
      this.write();
    }
  }

  override async execute() {
    const r = await super.execute();
    r.stepsExpected = [...new Set([...r.stepsSeen, ...STOPS.filter(s => r.endedAt_step.startsWith(s.board)).map(s => s.board)])];
    return r;
  }
}
