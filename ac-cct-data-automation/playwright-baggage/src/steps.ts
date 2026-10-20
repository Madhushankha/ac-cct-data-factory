// Step library (guide section 6) and the run that executes one scenario.
import fs from 'node:fs';
import path from 'node:path';
import { expect, type Page, type TestInfo } from '@playwright/test';
import { ChatPage, escapeRe, settle, typeInto } from './chat';
import { ROOT, runDir, ensureDir } from './config';
import { claimBooking, releaseBooking, NoBooking, type PickedBooking } from './bookings';
import { detect, SafetyStopError, STOPS, type StopKind } from './guards';
import { describe, expectedText, genericDefects, judge, knownFor, loadKnownIssues, severityOf, type Expect, type Failure, type Kind, type Severity } from './judge';
import { getOtp, OtpBudgetExceeded, OtpNotSent, OtpUnavailable } from './otp';
import { stepKind, type ContentsSpec, type Scenario, type Step } from './scenario';
import { fullChatShot } from './shots';
import type { Message } from './transcript';
import { slim, writeLive, type Decision } from './live';

export type Result = 'pass' | 'fail' | `known (${string})` | `blocked (${string})`;

export interface RunResult {
  run: number;
  id: string;
  caseId?: string;
  title: string;
  file?: string;
  booking: string;
  pool?: string;
  passenger?: string;
  sessionId?: string;
  startedAt: string;
  endedAt?: string;
  noticeSeen?: boolean;
  otpCodes: number;
  stepsSeen: string[];
  stepsExpected: string[];
  endedAt_step: string;
  result: Result;
  failures: Failure[];
  notes: string[];
  screenshots: string[];
}

export class Blocked extends Error {}
export class EndRun extends Error {}

/** Labels of the buttons the widget shows (guide 4.2). */
const L = {
  noticeYes: 'Yes', noticeNo: 'No',
  submit: 'Submit',
  journeyYes: 'Yes, that one', journeyNo: 'No, a different one',
  delivered: 'Yes, it was delivered!', notDelivered: "No, I still haven't received it!",
  selectDate: 'Select a date', prevMonth: 'Previous month',
  ready: "Yes, let's start", notReady: 'No, not now',
  contents: 'Baggage contents',
  confirm: 'I confirm', change: 'Something needs changing',
  upload: 'Upload receipts', viewReceipt: 'View receipt',
};

export class Run {
  chat: ChatPage;
  booking?: PickedBooking;
  r: RunResult;
  /** index of the first message produced by the current action */
  protected windowStart = 0;
  protected failureSeq = 0;
  protected reported = new Set<string>();
  protected issues = loadKnownIssues();
  protected runKey: string;
  protected dir = runDir();
  protected claimConfirmed = false;
  protected messages: Message[] = [];

  constructor(page: Page, public s: Scenario, private testInfo?: TestInfo) {
    this.chat = new ChatPage(page);
    this.chat.allow = s.allow ?? [];
    this.runKey = `${path.basename(this.dir)}:${s.run}`;
    this.r = {
      run: s.run ?? 0, id: s.id, caseId: s.caseId, title: s.title, file: s.file, booking: '—', startedAt: new Date().toISOString(),
      otpCodes: 0, stepsSeen: [], notes: [], screenshots: [], failures: [], endedAt_step: '', result: 'pass',
      stepsExpected: s.steps.flatMap(st => 'expect' in st ? [st.expect.step] : 'stop' in st && st.stop !== 'end' ? [boardOf(st.stop)] : []),
    };
  }

  protected get tag(): string { return `run${this.r.run}_${this.booking?.pnr ?? 'NOBOOKING'}`; }

  // ------------------------------------------------------------ lifecycle

  async execute(): Promise<RunResult> {
    try {
      if (this.s.booking) {
        this.booking = await claimBooking(this.s.booking, this.runKey);
        this.r.booking = this.booking.pnr;
        this.r.pool = this.booking.pool;
        this.r.passenger = `${this.booking.first} ${this.booking.last}`;
      }
      await this.start();
      for (let i = 0; i < this.s.steps.length; i++) await this.step(this.s.steps[i], i);
      if (!this.r.endedAt_step) this.r.endedAt_step = this.r.stepsSeen[this.r.stepsSeen.length - 1] ?? 'end of scenario';
    } catch (e: any) {
      if (e instanceof EndRun) { /* recorded already */ }
      else if (e instanceof Blocked || e instanceof NoBooking) this.block(e.message);
      else if (e instanceof OtpNotSent || e instanceof OtpUnavailable || e instanceof OtpBudgetExceeded) this.block(`OTP: ${e.message}`);
      else await this.fail({ step: this.currentStep, expected: 'the step to complete', got: `harness error: ${short(e)}`, kind: 'error', severity: 'High' });
    } finally {
      await this.finish();
    }
    return this.r;
  }

  protected currentStep = 'start';

  protected async start(): Promise<void> {
    this.currentStep = 'open chat';
    await this.chat.open(this.s.lang ?? 'English');
    this.r.sessionId = await this.chat.sessionId();
    await this.live();
    await this.action('first message', () => this.chat.say(this.s.first_message));
  }

  protected async finish(): Promise<void> {
    this.r.endedAt = new Date().toISOString();
    this.messages = await this.chat.messages().catch(() => this.messages);
    this.r.sessionId = (await this.chat.sessionId().catch(() => undefined)) ?? this.r.sessionId;
    const shots = await this.shot(`${this.tag}.png`).catch(() => []);
    this.r.screenshots.unshift(...shots);
    if (!this.r.result.startsWith('blocked')) {
      const open = this.r.failures.filter(f => !f.known);
      if (open.length) this.r.result = 'fail';
      else if (this.r.failures.length) this.r.result = `known (${[...new Set(this.r.failures.map(f => f.known))].join(', ')})`;
      else this.r.result = 'pass';
    }
    for (const f of this.r.failures) f.sessionId ??= this.r.sessionId;
    await this.live('finished');
    this.write();
    if (this.booking) {
      await releaseBooking(this.booking.pnr, this.runKey, {
        used: this.r.otpCodes > 0, lastEnd: this.r.endedAt_step, claimConfirmed: this.claimConfirmed,
      }).catch(() => {});
    }
  }

  protected write(): void {
    const t = ensureDir(path.join(this.dir, 'transcripts'));
    fs.writeFileSync(path.join(t, `run${this.r.run}.json`), JSON.stringify({
      ...this.r, scenario: this.s.id, booking: this.r.booking, messages: this.messages,
    }, null, 2));
    const res = ensureDir(path.join(this.dir, 'results'));
    fs.writeFileSync(path.join(res, `run${this.r.run}.json`), JSON.stringify(this.r, null, 2));
  }

  protected async shot(name: string): Promise<string[]> {
    const file = path.join(ensureDir(path.join(this.dir, 'screenshots')), name.replace(/[^\w.-]+/g, '_'));
    const files = await fullChatShot(this.chat.page, file);
    for (const f of files) await this.testInfo?.attach(path.basename(f), { path: f, contentType: 'image/png' }).catch(() => {});
    return files.map(f => path.relative(this.dir, f).replace(/\\/g, '/'));
  }

  protected block(reason: string): void {
    this.r.result = `blocked (${reason.slice(0, 160)})`;
    this.r.endedAt_step ||= this.currentStep;
  }

  /** goal runs: the goal and the agent's decisions, shown in the live view */
  protected goal?: string;
  protected decisions: Decision[] = [];

  protected async live(state: 'running' | 'finished' = 'running'): Promise<void> {
    await writeLive(this.dir, this.chat.page, {
      run: this.r.run, id: this.r.id, title: this.r.title, booking: this.booking?.pnr, sessionId: this.r.sessionId,
      state, step: this.currentStep, lastAction: this.chat.lastAction, goal: this.goal,
      decisions: this.decisions.length ? this.decisions : undefined, messages: slim(this.messages),
    }, state === 'running');
  }

  // ------------------------------------------------------------ failures

  protected async fail(f: { step: string; expected: string; got: string; kind: Kind; severity?: Severity; optional?: boolean }): Promise<void> {
    const key = `${f.step}|${f.expected}|${f.got}`;
    if (this.reported.has(key)) return;
    this.reported.add(key);
    if (f.optional) { this.r.notes.push(`${f.step}: ${f.expected} — got ${f.got}`); return; }
    const failure: Failure = {
      id: 0, run: this.r.run, sessionId: this.r.sessionId, step: f.step, expected: f.expected, got: f.got,
      before: this.chat.lastAction, kind: f.kind, severity: severityOf(f.kind, f.severity), known: null,
    };
    failure.known = knownFor(failure, this.issues, this.s.known);
    failure.id = ++this.failureSeq;
    const shots = await this.shot(`${this.tag}_fail_${f.step}.png`).catch(() => []);
    failure.screenshot = shots[0];
    this.r.screenshots.push(...shots);
    this.r.failures.push(failure);
    this.r.endedAt_step = f.step;
  }

  // ------------------------------------------------------------ action wrapper

  /** Run an action, then read the new messages: generic defects and safety stops. */
  protected async action(label: string, fn: () => Promise<void>, nextIndex?: number): Promise<void> {
    this.currentStep = label;
    const before = await this.chat.messages().catch(() => [] as Message[]);
    this.windowStart = before.length;
    try {
      await fn();
    } catch (e: any) {
      if (e instanceof SafetyStopError) {
        await this.fail({ step: label, expected: 'scenario stays inside the safety rules', got: e.message, kind: 'flow' });
        throw new EndRun();
      }
      if (e instanceof Blocked || e instanceof OtpNotSent || e instanceof OtpUnavailable || e instanceof OtpBudgetExceeded) throw e;
      await this.fail({ step: label, expected: `could ${label}`, got: `${short(e)}; last bot message: ${describe(this.lastBot())}`, kind: 'flow' });
      throw new EndRun();
    }
    this.messages = await this.chat.messages().catch(() => this.messages);
    const fresh = this.messages.slice(this.windowStart);
    for (const d of genericDefects(fresh)) await this.fail({ step: label, expected: 'no raw URLs or error text', got: `${d.what}: ${describe(d.m)}`, kind: d.kind });
    await this.live();
    await this.checkStops(fresh, nextIndex);
  }

  protected lastBot(): Message | undefined { return [...this.messages].reverse().find(m => m.who === 'bot'); }

  protected async checkStops(fresh: Message[], nextIndex?: number): Promise<void> {
    const hit = detect(fresh).filter(s => !this.chat.allow.includes(s.kind));
    if (!hit.length) return;
    // a stop is fine when the scenario's next action is that stop (expects in between are still judged)
    const rest = nextIndex === undefined ? [] : this.s.steps.slice(nextIndex);
    const nextAction = rest.find(st => stepKind(st) !== 'expect');
    if (nextAction && 'stop' in nextAction && hit.some(h => h.kind === nextAction.stop)) return;
    const h = hit[0];
    await this.fail({
      step: `${h.board} (safety stop: ${h.kind})`, expected: nextAction ? `the scenario's next step (${stepKind(nextAction)})` : 'no safety stop',
      got: describe(fresh.filter(m => m.who === 'bot').pop()), kind: 'flow',
    });
    this.r.endedAt_step = `${h.board} safety stop`;
    throw new EndRun();
  }

  // ------------------------------------------------------------ steps

  protected async step(st: Step, i: number): Promise<void> {
    const k = stepKind(st);
    const v: any = (st as any)[k];
    const next = i + 1;
    switch (k) {
      case 'notice': return this.action('automated-decision notice', () => this.notice(v), next);
      case 'identify': return this.action('identity form', () => this.identify(v === true ? {} : v), next);
      case 'verify': return this.action('verification code', () => this.verify(), next);
      case 'journey': return this.action('journey', () => this.journey(v), next);
      case 'delivery': return this.action('delivery answer', () => this.delivery(v), next);
      case 'readiness': return this.action('readiness', () => this.chat.tap(v === 'yes' ? L.ready : L.notReady), next);
      case 'contents': return this.action('contents', () => this.contents(v), next);
      case 'confirm': return this.action('summary confirm', () => this.confirm(v), next);
      case 'upload': return this.action('receipt upload', () => this.upload(v), next);
      case 'say': return this.action(`say "${String(v).slice(0, 40)}"`, () => this.chat.say(v), next);
      case 'tap': return this.action(`tap [${v}]`, () => this.chat.tap(v), next);
      case 'choose': return this.action(`choose ${v.join(', ')}`, async () => {
        for (const o of v) await this.chat.choose(o);
        if ((st as any).submit !== false) await this.chat.tap(L.submit);
      }, next);
      case 'wait': await this.chat.page.waitForTimeout(Number(v) * 1000); return;
      case 'expect': return this.expectStep(v as Expect);
      case 'stop': return this.stop(v);
    }
  }

  protected async notice(v: 'yes' | 'no' | 'skip'): Promise<void> {
    const seen = await this.chat.waitForText(/claim will be assessed|automated|Reminder/i, 30_000);
    this.r.noticeSeen = seen;
    if (!seen || v === 'skip') return;
    await this.chat.tap(v === 'yes' ? L.noticeYes : L.noticeNo);
  }

  protected async identify(o: { first?: string; last?: string; pnr?: string }): Promise<void> {
    const b = this.booking;
    const first = o.first ?? b?.first, last = o.last ?? b?.last, pnr = o.pnr ?? b?.pnr;
    if (!first || !last || !pnr) throw new Blocked('no booking for the identity form');
    const root = this.chat.root();
    await expect(root.getByLabel(/First name/i).filter({ visible: true }).last()).toBeVisible({ timeout: 90_000 });
    await this.chat.fill(/First name/i, first);
    await this.chat.fill(/Last name/i, last);
    await this.chat.fill(/Booking reference/i, pnr);
    await this.chat.tap(L.submit, { settle: false });
    this.chat.lastAction = `submitted the identity form (${first} ${last}, ${pnr})`;
    const channel = this.chat.btn(/^(Email|Courriel)/);
    await expect(channel).toBeVisible({ timeout: 90_000 });
    // the masked contact proves which booking (and which environment's data) the bot found
    this.r.notes.push(`OTP channel offered: ${(await channel.innerText().catch(() => '')).trim()}`);
    await settle(root, 2000);
  }

  protected async verify(): Promise<void> {
    const b = this.booking;
    if (!b) throw new Blocked('verify needs a booking');
    const code = await getOtp(this.chat, { firstName: b.first, booking: b.pnr, provider: b.otp });
    this.r.otpCodes++;
    const field = this.chat.root().getByLabel(/Verification code|Code de vérification/i).filter({ visible: true }).last();
    await expect(field).toBeVisible({ timeout: 60_000 });
    await typeInto(field, code);
    await this.chat.tap(L.submit, { settle: false });
    this.chat.lastAction = 'entered the verification code';
    const ok = /You're verified|You are verified|vérifié/i;
    const bad = /doesn't match|didn't match|does not match|ne correspond pas/i;
    await expect(this.chat.root()).toContainText(new RegExp(`${ok.source}|${bad.source}`, 'i'), { timeout: 60_000 });
    await settle(this.chat.root(), 3000);
    const msgs = await this.chat.messages();
    const last = msgs.slice(this.windowStart).filter(m => m.who === 'bot').map(m => m.text).join('\n');
    // Guide 5.5: a wrong code is not retried at once (it uses a try and the daily budget)
    if (bad.test(last) && !ok.test(last)) throw new Blocked('OTP: code did not match');
  }

  protected async journey(v: 'one' | 'no' | { match: string }): Promise<void> {
    if (v === 'one') await this.chat.tap(L.journeyYes);
    else if (v === 'no') await this.chat.tap(L.journeyNo);
    else {
      const root = this.chat.root();
      const re = new RegExp(escapeRe(v.match), 'i');
      // claim road: checkbox list + Submit; tracking road: one button per journey
      const listed = await root.getByText(/Choose one or more options/i).last().isVisible().catch(() => false);
      if (listed) { await this.chat.choose(re); await this.chat.tap(L.submit); }
      else await this.chat.tap(re);
    }
    // Duplicate claim: the booking already finished a claim (GenUC-13/14)
    const msgs = await this.chat.messages();
    if (msgs.slice(this.windowStart).some(m => /already submitted a claim/i.test(m.text))) {
      this.claimConfirmed = true;
      if (!this.s.known?.includes('duplicate-claim') && !this.s.steps.some(s => 'expect' in s && /GenUC-1[34]/.test(s.expect.step)))
        throw new Blocked('booking already used');
    }
  }

  protected async delivery(v: 'yes' | 'no' | { answer: 'yes'; date: string }): Promise<void> {
    if (v === 'no') return this.chat.tap(L.notDelivered);
    await this.chat.tap(L.delivered);
    if (typeof v !== 'object') return;
    await this.chat.tap(L.selectDate, { settle: false });
    const label = dayLabel(v.date);
    const root = this.chat.root();
    const day = () => root.getByRole('button', { name: label, exact: true }).filter({ visible: true }).last();
    for (let i = 0; i < 12 && !(await day().count()); i++) {
      await root.getByRole('button', { name: L.prevMonth }).filter({ visible: true }).last().click();
    }
    await day().click();
    await this.chat.tap(L.submit);
    this.chat.lastAction = `picked the delivery date ${v.date}`;
  }

  protected async contents(c: ContentsSpec): Promise<void> {
    const root = this.chat.root();
    const items = c.items ?? [{ item: c.item!, qty: c.qty, amount: c.amount! }];
    await expect(root.getByText(/Choose one or more options/i).last()).toBeVisible({ timeout: 90_000 });
    for (const cat of [c.category].flat()) await this.chat.choose(cat);
    await this.chat.tap(L.submit);
    await this.chat.waitForText(/Canadian dollars|dollars canadiens/i, 90_000);
    if (c.cad === false) { await this.chat.tap('No'); await this.chat.say(c.currency!); }
    else await this.chat.tap('Yes');
    await expect(root.getByText(/Choose one or more options/i).last()).toBeVisible({ timeout: 90_000 });
    for (const it of items) await this.chat.choose(new RegExp(`^${escapeRe(it.item)}$`, 'i'));
    await this.chat.tap(L.submit);
    // quantities: one Increase per unit (the picker starts at 0; ⚠️ check on a new widget build)
    const firstInc = root.getByRole('button', { name: `Increase ${items[0].item}` }).filter({ visible: true }).last();
    await expect(firstInc).toBeVisible({ timeout: 90_000 });
    for (const it of items) {
      const inc = root.getByRole('button', { name: `Increase ${it.item}` }).filter({ visible: true }).last();
      for (let q = 0; q < (it.qty ?? 1); q++) await inc.click();
    }
    await this.chat.tap(L.submit);
    await this.chat.tap(L.contents, { settle: false });
    const dlg = this.chat.dialog();
    await expect(dlg).toBeVisible({ timeout: 60_000 });
    const amounts = dlg.getByLabel(/^Amount in /i);
    await expect(amounts.first()).toBeVisible();
    const n = await amounts.count();
    for (let i = 0; i < items.length && i < n; i++) await typeInto(amounts.nth(i), String(items[i].amount));
    await dlg.getByRole('button', { name: L.submit, exact: true }).last().click();
    this.chat.lastAction = `entered contents ${items.map(i => `${i.qty ?? 1}× ${i.item} ${i.amount}`).join(', ')}${c.cad === false ? ` ${c.currency}` : ' CAD'}`;
    await expect(this.chat.btn(L.confirm)).toBeVisible({ timeout: 90_000 });
    await settle(root, 3000);
  }

  protected async confirm(v: true | 'change'): Promise<void> {
    await this.chat.tap(v === 'change' ? L.change : L.confirm);
    const msgs = await this.chat.messages();
    if (msgs.slice(this.windowStart).some(m => /submission was successful/i.test(m.text) || m.boxes.some(b => /submission was successful/i.test(b.text))))
      this.claimConfirmed = true;
  }

  protected async upload(files: string[]): Promise<void> {
    const abs = files.map(f => path.resolve(ROOT, f));
    for (const f of abs) if (!fs.existsSync(f)) throw new Blocked(`receipt file missing: ${f}`);
    await this.chat.tap(L.upload, { settle: false });
    const dlg = this.chat.dialog();
    await expect(dlg).toBeVisible({ timeout: 60_000 });
    await dlg.locator('input[type=file]').setInputFiles(abs);
    // the first Submit while a file is still uploading does nothing: wait for one "View receipt" per file
    await expect(dlg.getByText(L.viewReceipt)).toHaveCount(abs.length, { timeout: 120_000 }).catch(async () => {
      await expect(dlg.getByText(L.viewReceipt).first()).toBeVisible({ timeout: 60_000 });
    });
    await dlg.getByRole('button', { name: L.submit, exact: true }).last().click();
    await expect(dlg).toBeHidden({ timeout: 30_000 }).catch(async () => {
      await dlg.getByRole('button', { name: L.submit, exact: true }).last().click();
    });
    this.chat.lastAction = `uploaded ${files.map(f => path.basename(f)).join(', ')}`;
    await settle(this.chat.root());
  }

  protected async expectStep(e: Expect): Promise<void> {
    this.currentStep = e.step;
    const pattern = e.text ?? e.any_of?.join('|') ?? e.all_of?.[0];
    if (pattern) await this.chat.waitForText(new RegExp(pattern, 'i'), (e.timeout ?? 60) * 1000);
    this.messages = await this.chat.messages().catch(() => this.messages);
    const window = this.messages.slice(this.windowStart);
    const v = judge(e, window, this.messages);
    if (v.ok) { this.r.stepsSeen.push(e.step); return; }
    const kind = v.problems[0].kind;
    await this.fail({
      step: e.board ? `${e.step} ${e.board}` : e.step, expected: expectedText(e),
      got: `${v.got} — ${v.problems.map(p => p.what).join('; ')}`, kind, severity: e.severity, optional: e.optional,
    });
    // a missing meaning means the bot took another road: later steps would only cascade
    if (kind === 'flow' && !e.optional) throw new EndRun();
  }

  protected async stop(kind: StopKind | 'end'): Promise<void> {
    if (kind === 'end') { this.r.endedAt_step ||= 'end of scenario'; throw new EndRun(); }
    const rule = STOPS.find(s => s.kind === kind)!;
    const shown = await expect.poll(async () => {
      this.messages = await this.chat.messages();
      return detect(this.messages.slice(this.windowStart)).some(s => s.kind === kind);
    }, { timeout: 60_000 }).toBe(true).then(() => true, () => false);
    if (!shown) {
      await this.fail({ step: `${rule.board} (stop: ${kind})`, expected: `the ${rule.board} safety stop`, got: describe(this.lastBot()), kind: 'flow' });
    } else {
      this.r.stepsSeen.push(rule.board);
      this.r.endedAt_step = `${rule.board} (stopped: never ${rule.never})`;
    }
    throw new EndRun();
  }
}

function boardOf(kind: StopKind): string { return STOPS.find(s => s.kind === kind)?.board ?? kind; }

/** Calendar day aria-label, e.g. "Thu, Oct 1, 2026" (en, UTC — as the widget renders it). */
export function dayLabel(iso: string): string {
  return new Date(`${iso}T12:00:00Z`).toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
}

function short(e: any): string {
  return String(e?.message ?? e).split('\n').filter(l => l.trim() && !/^\s*at /.test(l)).slice(0, 2).join(' ').replace(/\u001b\[\d+m/g, '').slice(0, 300);
}
