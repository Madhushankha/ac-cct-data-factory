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
import { BedrockRuntimeClient, ConverseCommand, type ContentBlock, type ConverseCommandOutput, type Tool } from '@aws-sdk/client-bedrock-runtime';
import { NodeHttpHandler } from '@smithy/node-http-handler';
import { fromIni } from '@aws-sdk/credential-providers';
import { TASK_ROLE } from './envs';
import { settle, typeInto } from './chat';
import { ENV, PERSONA_DONE, ROOT, ensureDir } from './config';
import { assertAllowed, detect, SafetyStopError, STOPS, UPLOAD_BUTTON, type StopKind } from './guards';
import { codeSince } from './otp';
import { describe, genericDefects } from './judge';
import type { Scenario } from './scenario';
import { EndRun, Run } from './steps';
import type { Message } from './transcript';
import { caseMails, caseNumberFrom, checkDashboard, chosenAmount, fetchVerification, readCaseMail,
         type DashboardCheck, type EmailCheck } from './verify';

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
  /** the test's Claims Dashboard rows, mapped to the testing API's item ids; checked after the chat */
  dashboard?: DashboardCheck[];
  /** the test's e-mail rows; any present means the case must have mail quoting its case number */
  emails?: EmailCheck[];
  /** this case's own receipts (ac-cct-data-seed tools/soc_receipts.py), paths relative to this project */
  receipts?: { file: string; category?: string; total?: number | string; currency?: string }[];
}

export interface ScriptStep { type: string; value?: string; line?: number; reason?: string; after_line?: number }
export interface Checkpoint { kind?: string; text?: string; line?: number; requirement?: string | null }

interface Control { id: number; role: string; label: string; checked?: boolean; value?: string; inDialog: boolean }

const DEFAULT_GOAL = 'Play out this test case as the customer until the assistant gives its answer for it ' +
  '(a decision, an eligibility outcome, a hand-off, or the next form it needs), then call finish.';
const MODEL = process.env.GOAL_MODEL_ID || 'global.anthropic.claude-sonnet-4-6';
const REGION = process.env.AGENT_REGION || 'ca-central-1';
const PROFILE = process.env.BEDROCK_PROFILE || process.env.AWS_PROFILE || 'int-cce';
/** Test receipts per flow: baggage claims clothing and toiletries; standards of care a night stranded
 *  (hotel, meals, taxi, essentials -- SOC_UAT_046's amounts). Written by scripts/make-receipts.js. */
const RECEIPTS: Record<string, string[]> = {
  baggage: ['receipts/clothing-receipt.pdf', 'receipts/toiletries-receipt.pdf'],
  soc: ['receipts/soc/hotel-receipt.pdf', 'receipts/soc/meals-receipt.pdf', 'receipts/soc/taxi-receipt.pdf',
        'receipts/soc/essentials-receipt.pdf'],
};

/**
 * How many of a case's receipts go up, by request ONE for now (RECEIPTS_MAX=all, or a number, for more).
 * Photos first: the meal or taxi JPG is the kind the reference pack shows the reader accepting most
 * reliably, ahead of a PDF folio.
 */
export function pickReceipts(files: string[], max = process.env.RECEIPTS_MAX ?? '1'): string[] {
  const ordered = [...files].sort((a, b) => Number(/\.pdf$/i.test(a)) - Number(/\.pdf$/i.test(b)));
  return max === 'all' ? ordered : ordered.slice(0, Math.max(1, Number(max) || 1));
}

/** Which receipts a case uploads, from its case id (SOC_UAT_046 -> soc); baggage's are the default. */
export function receiptsFor(caseId?: string): string[] {
  return /^soc[_-]/i.test(caseId ?? '') ? RECEIPTS.soc : RECEIPTS.baggage;
}
const MAX_ERRORS_IN_A_ROW = 3;
/** INT can take 2-3 minutes to answer after a submit (e.g. the payout country): wait this long for a reply */
const REPLY_WAIT_MS = Number(process.env.REPLY_WAIT_MS || 240_000);
/** widget chrome the customer never needs */
const CHROME = /^(helpful|not helpful|minimize( chat)?|full screen|exit full screen|download( transcript)?|close chat|new message|dismiss)$/i;

let client: BedrockRuntimeClient | undefined;
function bedrock(): BedrockRuntimeClient {
  // adaptive retry: backs off on Bedrock throttling when many chats run at once
  // a call that never answers is cut at 2 minutes and retried: a hung socket held chats at "looking at the
  // screen" until the 45-minute test limit (209 run, 2026-10-22)
  client ??= new BedrockRuntimeClient({ region: REGION, credentials: TASK_ROLE ? undefined : fromIni({ profile: PROFILE }),
    maxAttempts: 8, retryMode: 'adaptive',
    requestHandler: new NodeHttpHandler({ connectionTimeout: 10_000, requestTimeout: 120_000 }) });
  return client;
}

/**
 * One Converse call with a hard limit on the whole call (credentials, the adaptive retry's own waits and
 * the request), tried 3 times. The socket timeout alone did not stop chats freezing at turn 1 "looking at
 * the screen" for 30+ minutes (rerun of 42, 2026-10-22).
 */
async function converse(cmd: ConverseCommand, limitMs = 180_000): Promise<ConverseCommandOutput> {
  let last: unknown;
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      return await bedrock().send(cmd, { abortSignal: AbortSignal.timeout(limitMs) });
    } catch (e) { last = e; }
  }
  throw last;
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
  ['complete_persona', 'Identity verification (Persona), the whole step: clicks "Verify my identity" (or "Get verified"), opens the withpersona.com link the assistant gives, closes it, then clicks the "Done" button in the chat (or types "done" where there is none). Use it once when the assistant asks to verify identity; do not click those buttons yourself.', {}, []],
  ['upload_files', 'The whole receipt step: opens the "Upload receipts" pop-up if needed, attaches this case\'s receipts, waits for them and clicks the pop-up\'s Submit. Use it once when the assistant asks for receipts; do not click "Upload receipts" yourself.', {}, []],
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

/**
 * A Jira test played as a customer would: the assistant leads, the test's customer steps are what the
 * customer KNOWS and WANTS. The first version told the model to perform the steps "IN ORDER, do not skip",
 * and on SOC_UAT_046 that made it type the passenger name and the PNR into the chat right after the bot
 * had answered with general information and "Is there anything else I can help with?" -- answers to
 * questions nobody asked -- then scroll fourteen times waiting for a form that was never coming.
 */
export function scripted(item: GoalItem, b: { first: string; last: string; pnr: string }): string {
  const sample = item.sample || {};
  const steps = (item.script || []).map((st, i) => {
    const v = st.value ?? '';
    const what = st.type === 'assumed' ? `whatever the assistant offers here (the test only says: ${st.reason || 'the bot asks'})`
      : st.type === 'otp' ? 'the verification code: use get_email_code when the assistant asks where to send it (the test\'s code is an example)'
      : st.type === 'say' ? `say (free text, when the assistant is waiting for you to type): "${v}"`
      : st.type === 'click' && /get verified/i.test(v) ? 'identity verification: complete_persona when the assistant asks for it'
      : st.type === 'provide' ? `when asked, give: "${v}"`
      : `when offered, choose: "${v}"`;
    return `${i + 1}. ${what}${i === 0 && /english/i.test(v) ? '  (ALREADY DONE: the chat opens in English)' : ''}`;
  }).join('\n');
  return [
    'You are a QA tester executing a Jira/Xray Cucumber test in the "Ask AC" web chat, operating the browser like a person: you see a screenshot and a numbered list of the controls on the page, and you act with one tool call per turn.',
    item.title ? `Test: ${item.jiraKey ? item.jiraKey + ' ' : ''}${item.title}` : '',
    item.goal ? `What the test is about: ${item.goal}` : '',
    'THE ASSISTANT LEADS. Each turn, first work out what the assistant is asking for RIGHT NOW (a question, a form, buttons, a pop-up) and answer exactly that, taking the answer from the customer steps below. The steps are the facts this customer knows and the choices they make, listed in the order the test expects; use them when they fit what is being asked, not as text to type in order. Never type a name, booking reference or other detail into the chat unless the assistant has just asked for it in the chat; when it shows a form, fill the form. Only send a scripted message ("say") when the assistant is waiting for free text from you and that message is what this customer would say next. If the assistant asks something the steps do not cover, give the plainest answer that keeps the test\'s flow going, and say so in why.',
    'If the assistant does not start the claim: when it answers with general information, a link, or "is there anything else I can help with" instead of starting the claim the test is about (no claim notice, no identification form), steer it in plain words, once or twice -- e.g. "I\'d like to file a claim to be reimbursed for my expenses" for meals/hotel/transport (standards of care), "I\'d like to claim compensation for my delayed/cancelled flight" for a disruption, "I\'d like to file a claim for my baggage" for bags -- and say in why that the test\'s own wording did not start the claim.',
    'Track the steps: by the end, every step should have been used where the assistant asked for it. A step the assistant never asks for is not forced in.',
    `The test's sample data is replaced by the seeded booking: name "${sample.name || ''}" -> "${b.first} ${b.last}" (first name ${b.first}), booking reference "${sample.pnr || ''}" -> "${b.pnr}". A masked email/phone option in the script means: pick the Email option on screen.`,
    'Forms: type each value into its own field (first name, last name, booking reference), then click that form\'s Submit.',
    'This test submits its claim on INT: you DO answer the payout country, choose the payout option and confirm/submit exactly as scripted. Never type bank account, card or IBAN numbers.',
    'Customer steps:', steps,
    'The assistant can take 2-3 minutes to answer after a submit (for example after the payout country). The harness already waits for its reply after each click or message; if the screen still shows the same question, use wait -- NEVER repeat a click or re-submit an answer that was already given.',
    'Dropdowns and type-ahead fields (role combobox, e.g. Country): use choose_option once, then click the form\'s Submit once.',
    'Identity check: use complete_persona once. If the assistant still says the verification is incomplete after a second complete_persona, stop and call finish with cannot_reach (the result did not reach the chat); never loop on it.',
    'Options you can see but cannot click: if the screenshot shows answer chips (e.g. "Yes" / "No", "My own trip") that are not in the controls list, do not click the message box or scroll looking for them: type the option text itself with send_message (e.g. "Yes"). Never click or scroll more than twice in a row without the chat changing.',
    'Do not finish while scripted steps remain: after the claim is submitted, wait for the assistant to ask if there is anything else, answer as the script says (usually No) and wait for its closing message.',
    'Call finish with goal_reached once the claim has gone as far as the steps describe and the assistant has closed, or cannot_reach only after steering has failed and the claim the test is about can no longer be started or continued.',
    'Scrolling: at most twice in a row. If nothing new appears, act instead (answer, use a control, or steer).',
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

export function transcriptText(messages: Message[], tail = 16): string {
  return messages.slice(-tail).map(m => {
    const who = m.who === 'you' ? 'CUSTOMER' : m.who === 'bot' ? `ASSISTANT${m.layout !== 'plain' ? ` [${m.layout} box]` : ''}` : 'WIDGET';
    // an alert-only message keeps its words in its box: without shown() the customer never saw it either
    return `${who}: ${shown(m).replace(/\s+/g, ' ').slice(0, 700)}`;
  }).filter(l => !/^WIDGET: $/.test(l)).join('\n');
}

/** How long the assistant may stay silent while the customer only waits or scrolls, before the run stops. */
export const SILENCE_LIMIT_MS = Number(process.env.SILENCE_LIMIT_MS || 6 * 60_000);

/**
 * Milliseconds since the assistant last said anything new, counted only across trailing turns in which
 * the customer did nothing that asks for an answer (wait/scroll). Zero as soon as the customer acts.
 */
export function botSilence(decisions: { action: string; at?: string }[], messages: { who: string }[], now = Date.now()): number {
  let i = decisions.length - 1;
  while (i >= 0 && /^(wait|scroll)$/.test(decisions[i].action)) i--;
  const idle = decisions.slice(i + 1);
  if (!idle.length || !idle[0].at) return 0;
  // the transcript has no reliable timestamps, so the span of idle turns is the measure; a new bot message
  // since the idle span began would have made the model act rather than wait again
  return messages.length && messages[messages.length - 1].who === 'you' || idle.length >= 2 ? now - Date.parse(idle[0].at) : 0;
}

/** Two scrolls in a row: the agent is looking for something that is not coming, and must act instead. */
export function scrollStuck(decisions: { action: string }[]): boolean {
  const last = decisions.slice(-2);
  return last.length === 2 && last.every(d => d.action === 'scroll');
}

/**
 * Everything a message shows: its text, and its alert boxes. An alert-only message ("Claim submission
 * successful!", "payment details cannot be changed") has EMPTY text -- the words live in the box -- so a
 * judge reading `text` alone reported both as never shown when the chat had displayed them.
 */
export function shown(m: Pick<Message, 'text' | 'boxes'>): string {
  const t = (m.text || '').trim();
  const boxes = (m.boxes || []).map(b => b.text.trim()).filter(b => b && !t.includes(b));
  return [t, ...boxes].filter(Boolean).join(' ');
}

export interface CheckpointResult {
  n: number; requirement: string | null; kind?: string; expected?: string; line?: number;
  status: 'pass' | 'fail' | 'not_reached' | 'unverified'; message: number | null; quote: string; reason: string;
}

export function checkpointNote(results: CheckpointResult[]): string {
  const c = (k: string) => results.filter(x => x.status === k).length;
  return `checkpoints: ${c('pass')} pass, ${c('fail')} fail, ${c('not_reached')} not reached, ${c('unverified')} unverified (quote not found) of ${results.length}`;
}

/**
 * Each expected bot line/alert/option of the Jira test, matched to what the assistant actually showed, in
 * order, by the model; then every quote it gives is looked up in the transcript, and a pass whose quote is
 * not there becomes "unverified". Used after a chat, and by scripts/rejudge.ts on a saved transcript.
 */
export async function judgeTranscript(cps: Checkpoint[], messages: Message[], consent?: string)
  : Promise<{ results: CheckpointResult[] } | { error: string }> {
  const msgs = messages.map((m, i) => ({ i, m })).filter(x => x.m.who !== 'you' && (shown(x.m) || x.m.buttons.length));
  const transcript = msgs.map(x => {
    const box = (x.m.boxes || []).map(b => b.kind).find(k => k && k !== 'plain');
    const layout = x.m.layout !== 'plain' ? x.m.layout : box;
    return `[${x.i}] ${x.m.who === 'bot' ? 'ASSISTANT' : 'WIDGET'}${layout ? ` (${layout} box)` : ''}: `
      + `${shown(x.m).replace(/\s+/g, ' ').slice(0, 600)}${x.m.buttons.length ? ` {buttons: ${x.m.buttons.join(' | ')}}` : ''}`
      + `${x.m.form.length ? ` {form: ${x.m.form.join(', ')}}` : ''}`;
  }).join('\n');
  const pre = consent ? `[consent] PRE-CHAT CONSENT SCREEN (shown before the chat opens): ${consent.replace(/\s+/g, ' ').slice(0, 800)}\n` : '';
  const list = cps.map((c, n) => `${n + 1}. (${c.kind}${c.requirement ? ', ' + c.requirement : ''}) ${String(c.text || '').slice(0, 300)}`).join('\n');
  let items: { n: number; status: string; message: number | null; quote: string; reason: string }[] = [];
  try {
    const res = await converse(new ConverseCommand({
      modelId: MODEL,
      system: [{ text: 'You check a chat transcript against a test\'s expected assistant lines, in order. For each expected item: pass = the assistant (or widget) shows the same meaning/element (wording may differ; the test\'s sample names, booking reference, flight number, dates and masked email/phone may differ because the booking is seeded; amounts, currencies, outcomes and option labels must match; an alert/success/info box counts as shown); fail = the assistant reached that point but said/showed something different (give the difference); not_reached = the chat never got there. quote must be copied exactly from the matched message.' }],
      messages: [{ role: 'user', content: [{ text: `Expected items:\n${list}\n\nTranscript (numbered messages):\n${pre}${transcript}` }] }],
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
    return { error: String(e?.message ?? e).slice(0, 160) };
  }
  return { results: verifyQuotes(cps, items, messages, consent) };
}

/** The judge's verdicts, each pass held to a quote that really is in the transcript (text or alert box). */
export function verifyQuotes(cps: Checkpoint[], items: { n: number; status: string; message: number | null; quote?: string; reason?: string }[],
                             messages: Message[], consent?: string): CheckpointResult[] {
  const norm = (t: string) => t.normalize('NFKD').toLowerCase().replace(/[‘’“”'"`]/g, '')
    .replace(/[^a-z0-9$.%]+/g, ' ').replace(/\s+/g, ' ').trim();
  const said = (m: Message) => norm([shown(m), ...m.buttons, ...m.form].join(' '));
  return cps.map((c, n) => {
    const it = items.find(x => x.n === n + 1) || { status: 'not_reached', message: null, quote: '', reason: 'no result returned' } as any;
    const q = norm(it.quote || '').slice(0, 120);
    const msg = it.message != null ? messages[it.message] : undefined;
    const hit = q ? (msg && said(msg).includes(q) ? msg : messages.find(m => m.who !== 'you' && said(m).includes(q))
      ?? (consent && norm(consent).includes(q) ? ({} as Message) : undefined)) : undefined;
    let message = it.message ?? null;
    if (hit && message == null) message = messages.indexOf(hit as Message);
    const status = (it.status === 'pass' && !hit ? 'unverified' : it.status) as CheckpointResult['status'];
    return { n: n + 1, requirement: c.requirement || null, kind: c.kind, expected: c.text, line: c.line, status,
             message, quote: it.quote || '', reason: it.reason || '' };
  });
}

export class GoalRun extends Run {
  /** worker slots that already waited their stagger (only a worker's first chat waits) */
  static staggered = new Set<number>();
  /** this worker's parallel slot, for the staggered start */
  private slot = 0;
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
    this.slot = testInfo?.parallelIndex ?? 0;
    this.item = item;
    this.goal = [item.title, item.brief, item.goal].filter(Boolean).join(' — ') || DEFAULT_GOAL;
    this.maxTurns = Math.max(3, Math.min(90, item.maxTurns ?? (item.script?.length ? Math.max(40, item.script.length * 4) : 40)));
    this.chat.allow = item.allow ?? [];
  }

  /** Run.execute calls start() and then walks steps (none here): the whole conversation lives in start(). */
  protected override async start(): Promise<void> {
    this.currentStep = 'open chat';
    // stagger the starts: 20 parallel chats opening uat2 in the same second left 13 with no chat at all
    // (cloud rerun, 2026-10-21). Each worker waits STAGGER_MS x its slot before its first chat.
    const slot = this.slot;
    if (!GoalRun.staggered.has(slot)) {
      GoalRun.staggered.add(slot);
      const ms = Number(process.env.STAGGER_MS ?? 5000) * slot;
      if (ms > 0) await this.chat.page.waitForTimeout(Math.min(ms, 180_000));
    }
    // and one retry: a chat that does not open the first time usually does the second
    try { await this.chat.open(this.s.lang ?? 'English', { requireGreeting: false }); }
    catch (e: any) {
      this.r.notes.push(`chat did not open on the first try (${String(e?.message ?? e).split('\n')[0].slice(0, 120)}); retrying once`);
      await this.chat.open(this.s.lang ?? 'English', { requireGreeting: false });
    }
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
        const clicked = this.controls.find(c => c.id === Number((decided.input as any)?.id));
        // a button that only opens a pop-up (Upload receipts) gets no assistant reply: do not wait for one
        const sends = /^(send_message|get_email_code|complete_persona|upload_files)$/.test(decided.name)
          || (decided.name === 'click' && /^(button|link)$/.test(clicked?.role ?? '') && !UPLOAD_BUTTON.test(clicked?.label ?? ''));
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
      // the assistant has gone quiet: waiting longer only burns the turn budget (SOC_UAT_046 run 3 waited
      // 48 turns after "we had a small disruption on our end"). Stop and say so: a bot finding, not a pass.
      const silentFor = botSilence(this.decisions, this.messages);
      if (silentFor >= SILENCE_LIMIT_MS) {
        this.outcome = 'errors';
        this.r.endedAt_step = 'assistant stopped answering';
        await this.fail({ step: `turn ${turn}`, expected: 'the assistant answers the customer',
          got: `no new assistant message for ${Math.round(silentFor / 60_000)} min; last reply: ${describe(this.lastBot())}`, kind: 'flow', severity: 'High' });
        return;
      }
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

  /**
   * The whole receipt step, as the scripted runs do it: open the "Upload receipts" pop-up when it is not
   * open yet, attach the files, wait for one "View receipt" per file (a Submit while a file is still
   * uploading does nothing), Submit, and wait for the pop-up to close. The file input only exists inside
   * the pop-up: SOC_UAT_046's first stable run attached to nothing and timed out, then clicked the button
   * and sat four minutes waiting for a reply a pop-up never sends.
   */
  private async uploadReceipts(files: string[]): Promise<string> {
    const dlg = this.chat.dialog();
    if (!(await dlg.locator('input[type=file]').count().catch(() => 0))) {
      await this.chat.root().getByRole('button', { name: UPLOAD_BUTTON }).last().click({ timeout: 15_000 });
      await dlg.waitFor({ state: 'visible', timeout: 60_000 });
    }
    await dlg.locator('input[type=file]').first().setInputFiles(files, { timeout: 30_000 });
    const view = dlg.getByText(/View receipt|Voir le reçu/i);
    await expect(view).toHaveCount(files.length, { timeout: 120_000 })
      .catch(() => expect(view.first()).toBeVisible({ timeout: 60_000 }));
    const submit = dlg.getByRole('button', { name: /^(Submit|Soumettre)$/i }).last();
    await submit.click({ timeout: 15_000 });
    await expect(dlg).toBeHidden({ timeout: 30_000 }).catch(() => submit.click().catch(() => {}));
    this.chat.lastAction = `uploaded ${files.map(f => path.basename(f)).join(', ')}`;
    return `uploaded and submitted ${files.length} receipt(s): ${files.map(f => path.basename(f)).join(', ')}`;
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
      // some widget builds draw quick replies ("Yes" / "No", "Email: …") as plain elements with a click handler
      // and no button role: count a leaf with a pointer cursor as a button too, or the AI sees them and cannot act
      const chipLike = (sc: Element) => Array.from(sc.querySelectorAll<HTMLElement>('span,div,li')).filter(e =>
        getComputedStyle(e).cursor === 'pointer' && !e.closest(sel) && !e.querySelector(sel) && (e.innerText || '').trim().length > 0 && (e.innerText || '').length < 120);
      for (const sc of scopes) for (const el of [...Array.from(sc.querySelectorAll<HTMLElement>(sel)), ...chipLike(sc)]) {
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
        // "Email" as the place to send the verification code is the code step, which the code tool does
        // whole (request, read, type, submit); a bare click sends a code nothing then reads
        // (a button on one page, a radio/option on the new INT page: any control labelled Email counts)
        if (/^\s*(E-?mail|Courriel)\b/i.test(c.label) && !c.inDialog && !/textbox|combobox/.test(c.role)) return this.emailCode();
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
        // long numbers the test itself asks for (an existing case, an IATA or ticket number) are not card details
        if (/\d{8,}/.test(text.replace(/[\s-]/g, '')) && !/booking|reference|case|iata|ticket/i.test(c.label))
          throw new SafetyStopError('forbidden-action', 'refused to type a long number (card or bank details)');
        // a made-up code ("123456") only burns attempts: codes come from the inbox via get_email_code (FD_TC_002, 2026-10-22)
        if (/verification code|code de vérification|one-time code/i.test(c.label)
            || (/^\s*\d{6}\s*$/.test(text) && !/iata|ticket|flight|booking|reference|case|aeroplan|phone/i.test(c.label)))
          throw new Error('never type a verification code yourself: use get_email_code, which reads the real code from the inbox');
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
      case 'send_message':
        if (/^\s*\d{6}\s*$/.test(String(a.text ?? '')))
          throw new Error('never send a verification code yourself: use get_email_code, which reads the real code from the inbox');
        return this.chat.say(String(a.text ?? ''));
      case 'complete_persona': return this.persona();
      case 'get_email_code': return this.emailCode();
      case 'upload_files': {
        // the case's own receipts when its plan names them; the flow's generic test receipts otherwise
        const own = (this.item.receipts ?? []).map(r => r.file);
        const files = (own.length ? own : receiptsFor(this.item.caseId)).map(f => path.resolve(ROOT, f)).filter(f => fs.existsSync(f));
        if (!files.length) throw new Error(`no test receipts for ${this.item.caseId ?? 'this case'}: run node scripts/make-receipts.js`);
        return this.uploadReceipts(pickReceipts(files));
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
    // a button on most builds; a plain "Email: la***@…" chip on others (BAT, 50-chat run 2026-10-21)
    const email = root.getByRole('button', { name: /^\s*(E-?mail|Courriel)\b/i })
      .or(root.getByText(/^\s*(E-?mail|Courriel)\s*:\s*\S+@/i)).filter({ visible: true }).last();
    // already sent ("I've just sent a 6-digit verification code"): read it now, don't wait four minutes for
    // an Email choice that is no longer the next step (SOC_UAT_046, new INT page, turn 4)
    const sentAlready = /sent a 6-digit verification code|what'?s the code|code de vérification à 6 chiffres/i.test(this.lastBot()?.text ?? '');
    // BAT lists the contacts as plain text ("• Email: LA***3@…  Where would you like to receive the code?") with
    // nothing to press: answer "Email" in the chat, then read the code from the booking's own inbox (FD_TC_002, 2026-10-22)
    const offeredAsText = !sentAlready
      && /where would you like to receive the code|où (souhaitez|voulez)-vous recevoir le code/i.test(this.lastBot()?.text ?? '')
      && !(await root.getByRole('button', { name: /^\s*(E-?mail|Courriel)\b/i }).filter({ visible: true }).count().catch(() => 0));
    if (offeredAsText) {
      if (!(this.booking?.otp.provider === 'mailinator' && this.booking.otp.own))
        throw new Error('the code would go to a shared inbox; this run cannot tell which code is its own');
      const asked = Date.now();
      await this.chat.say('Email');
      const field = root.getByLabel(/Verification code|Code de vérification/i).filter({ visible: true }).last();
      await expect(field.or(root.getByText(/sent (a|you a) 6-digit|what'?s the code|enter (it|the code)|entrez le code/i))
        .first()).toBeVisible({ timeout: REPLY_WAIT_MS });
      const code = await codeSince(this.booking.otp, asked - 5000);
      this.r.otpCodes++;
      if (await field.isVisible().catch(() => false)) {
        await typeInto(field, code);
        await this.chat.tap(/^(Submit|Soumettre)$/, { settle: false });
      } else await this.chat.say(code);
      await expect(root).toContainText(/You're verified|You are verified|verification was successful|successfully verified|vérifié|doesn't match|did not match|ne correspond pas/i, { timeout: 60_000 });
      return 'answered "Email" in the chat, code read from the booking\'s own inbox and entered';
    }
    const ready =!sentAlready && await expect(email).toBeEnabled({ timeout: REPLY_WAIT_MS }).then(() => true, () => false);
    if (!ready) {
      const field = root.getByLabel(/Verification code|Code de vérification/i).filter({ visible: true }).last();
      // the new INT page has no code field: the assistant says "What's the code?" and takes it as a chat message
      const asked = /sent a 6-digit verification code|what'?s the code|enter (it|the code)|entrez le code/i.test(this.lastBot()?.text ?? '');
      const hasField = await field.isVisible().catch(() => false);
      if (!hasField && !asked) throw new Error('the assistant has not offered to send a code by email yet: wait for it');
      if (!hasField) {
        if (!(this.booking?.otp.provider === 'mailinator' && this.booking.otp.own))
          throw new Error('the code was sent already and goes to a shared inbox; this run cannot tell which code is its own');
        const code = await codeSince(this.booking.otp, Date.parse(this.r.startedAt));
        this.r.otpCodes++;
        await this.chat.say(code);
        await expect(root).toContainText(/You're verified|You are verified|verification was successful|successfully verified|vérifié|doesn't match|did not match|ne correspond pas/i, { timeout: 60_000 });
        return 'code read from the booking\'s own inbox and sent in the chat';
      }
      // the code was requested already (the customer pressed "Email" itself): with an inbox of its own the
      // booking's newest code since the chat began is that one (SOC_UAT_046, new URL, turn 7)
      if (!(this.booking?.otp.provider === 'mailinator' && this.booking.otp.own))
        throw new Error('a code was already requested in this chat (the Email choice is used); this run cannot read that code');
      const code = await codeSince(this.booking.otp, Date.parse(this.r.startedAt));
      this.r.otpCodes++;
      await typeInto(field, code);
      await this.chat.tap(/^(Submit|Soumettre)$/, { settle: false });
      await expect(root).toContainText(/You're verified|You are verified|verification was successful|successfully verified|vérifié|doesn't match|did not match|ne correspond pas/i, { timeout: 60_000 });
      return 'code (already requested) read from the booking\'s own inbox and entered';
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
    if (PERSONA_DONE) {
      // BAT (uat2), by request 2026-10-21: once the link has come, do not open Persona -- pressing its consent
      // button starts a real verification that never completes. Close any tab the click opened, then "done".
      for (const p of page.context().pages()) if (p !== page && /withpersona/i.test(p.url())) await p.close().catch(() => {});
      await page.bringToFront().catch(() => {});
      const doneBtn = root.getByRole('button', { name: /^(done|termin[ée])$/i }).filter({ visible: true }).last();
      if (await doneBtn.waitFor({ state: 'visible', timeout: 15_000 }).then(() => true, () => false)) await doneBtn.click({ timeout: 10_000 });
      else await this.chat.say('done');
      this.chat.lastAction = 'clicked Verify, waited for the link, then "done" (Persona not opened)';
      return this.chat.lastAction;
    }
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
    // back in the chat: press its "Done" button where it offers one (BAT, by request 2026-10-21), else type it
    const done = root.getByRole('button', { name: /^(done|termin[ée])$/i }).filter({ visible: true }).last();
    if (await done.waitFor({ state: 'visible', timeout: PERSONA_DONE ? 15_000 : 3000 }).then(() => true, () => false)) {
      await done.click({ timeout: 10_000 });
      this.chat.lastAction = 'opened the Persona link, closed it and clicked [Done]';
    } else {
      await this.chat.say('done');
      this.chat.lastAction = 'opened the Persona link, closed it and told the assistant "done"';
    }
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
    // nothing to judge: a chat that never opened has no transcript, and judging 30-odd checkpoints against
    // nothing hung until the 45-minute test limit (13 chats, cloud rerun 2026-10-21)
    if (!this.messages.length) { this.r.notes.push('checkpoints not judged: the chat has no messages (it did not open)'); return; }
    this.currentStep = 'checking the test\'s bot checkpoints';
    await this.live();
    const out = await judgeTranscript(cps, this.messages, this.chat.consent);
    if ('error' in out) { this.r.notes.push(`checkpoint judge unavailable: ${out.error}`); return; }
    const results = out.results;
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
    this.r.notes.push(checkpointNote(results));
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
      scrollStuck(this.decisions)
        ? 'You have scrolled twice in a row and nothing new appeared: do NOT scroll again. Answer the assistant\'s last message, use a control from the list, or steer the chat (see "If the assistant does not start the claim").'
        : '',
      'Look at the screenshot and choose the next single action: first answer what the assistant is asking NOW.',
    ].filter(Boolean).join('\n\n');
    this.currentStep = `turn ${turn}: looking at the screen`;
    await this.live();
    const content: ContentBlock[] = [{ text }];
    if (shot) content.unshift({ image: { format: 'jpeg', source: { bytes: new Uint8Array(shot) } } } as ContentBlock);
    const res = await converse(new ConverseCommand({
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
      const res = await converse(new ConverseCommand({
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

  /**
   * The systems behind the chat: the Claims Dashboard's testing API for the case the chat opened, and the
   * case's mail. Evidence files go to dashboard/ and emails/ in the run folder; a dashboard item the API says
   * is absent, a mapped item it does not have, or a test that expects mail with none quoting the case, fails.
   * POST_CHECKS=0 skips all of it.
   */
  private async postChecks(): Promise<void> {
    if (process.env.POST_CHECKS === '0') return;
    const caseNumber = caseNumberFrom(this.messages);
    (this.r as any).caseNumber = caseNumber ?? null;
    if (!caseNumber) {
      if (this.item.dashboard?.length || this.item.emails?.length)
        this.r.notes.push('post-chat checks skipped: the chat never quoted a case number (CCD-…)');
      return;
    }
    this.currentStep = `checking case ${caseNumber} on the dashboard and in the mail`;
    await this.live();
    const env = process.env.DASHBOARD_ENV || ENV.name;
    let amount: string | undefined;
    if (this.item.dashboard?.length) {
      try {
        const v = await fetchVerification(caseNumber, env);
        fs.writeFileSync(path.join(ensureDir(path.join(this.dir, 'dashboard')), `run${this.r.run}.json`), JSON.stringify(v, null, 2));
        amount = chosenAmount(v);
        const results = checkDashboard(this.item.dashboard, v);
        (this.r as any).dashboard = results;
        for (const x of results.filter(x => x.status === 'fail' || x.status === 'missing'))
          await this.fail({ step: `dashboard ${x.api} (${x.jiraCheckpoint ?? 'jira'})`, expected: x.expected || x.check,
            got: x.status === 'missing' ? 'the testing API has no such item' : `absent on the dashboard: ${x.value ?? ''}`, kind: 'data' });
        const n = (s: string) => results.filter(x => x.status === s).length;
        this.r.notes.push(`dashboard ${caseNumber}: ${n('pass')} pass, ${n('review')} to review, ${n('fail')} fail, ${n('missing')} missing, `
          + `${n('ui')} UI-derived, ${n('manual')} manual, ${n('unmapped')} unmapped`);
      } catch (e: any) {
        this.r.notes.push(`dashboard check unavailable: ${String(e?.message ?? e).slice(0, 200)}`);
      }
    }
    if (this.booking) {
      try {
        const { ownInbox, mails } = await readCaseMail(this.booking.otp, caseNumber, Date.parse(this.r.startedAt));
        const seen = caseMails(mails, caseNumber, { ownInbox, amount });
        fs.writeFileSync(path.join(ensureDir(path.join(this.dir, 'emails')), `run${this.r.run}.json`), JSON.stringify(seen, null, 2));
        (this.r as any).emails = seen;
        const quoting = seen.filter(m => m.quotesCase);
        this.r.notes.push(`mail for ${caseNumber}: ${seen.length} message(s), ${quoting.length} quote the case number`
          + (amount ? `, ${seen.filter(m => m.amountFound).length} carry ${amount}` : ''));
        if (this.item.emails?.length && !quoting.length)
          await this.fail({ step: 'case e-mail', expected: `an e-mail quoting ${caseNumber}`, got: `none in ${ownInbox ? 'the booking\'s own' : 'the shared'} inbox`, kind: 'data' });
      } catch (e: any) {
        this.r.notes.push(`mail check unavailable: ${String(e?.message ?? e).slice(0, 200)}`);
      }
    }
  }

  protected override async finish(): Promise<void> {
    if (!this.r.result.startsWith('blocked')) {
      await this.judgeCheckpoints().catch(e => this.r.notes.push(`checkpoint judge error: ${String(e?.message ?? e).slice(0, 160)}`));
      await this.judgeExpected().catch(() => {});
      await this.postChecks().catch(e => this.r.notes.push(`post-chat checks error: ${String(e?.message ?? e).slice(0, 160)}`));
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
