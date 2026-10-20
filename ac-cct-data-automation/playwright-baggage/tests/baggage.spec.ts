// One test per scenario in scenarios/*.yaml, or one per item of a run plan.
// Each test = its own browser context = its own chat session.
//   SCENARIO=run2,smoke-open     run only these scenario ids
//   RUN_PLAN=<file.json>         [{ "scenario": "lost-no-expenses", "pnr": "FYO4TS", "caseId": "BAG_SIT_SD_03_19" }, ...]
//                                one chat per item, each bound to that exact booking (agentic-qa "by seeded case")
import fs from 'node:fs';
import { test, expect } from './fixtures/cdp';   // plain @playwright/test unless CDP_URL is set
import { loadScenarios, validateScenario, type Scenario } from '../src/scenario';
import { Run } from '../src/steps';
import { saveVideo } from '../src/video';

interface PlanItem { scenario: string; pnr: string; caseId?: string; pool?: string }

function planned(all: Scenario[]): Scenario[] {
  const plan = JSON.parse(fs.readFileSync(process.env.RUN_PLAN!, 'utf8')) as PlanItem[];
  const byId = new Map(all.map(s => [s.id, s]));
  return plan.map((item, i) => {
    const s = byId.get(item.scenario);
    if (!s) throw new Error(`run plan item ${i + 1}: no scenario "${item.scenario}"`);
    return {
      ...s, run: i + 1, caseId: item.caseId,
      title: `${s.title} · ${item.caseId ?? ''} ${item.pnr}`.trim(),
      booking: { pnr: item.pnr, ...(item.pool ? { pool: item.pool } : {}) },
    };
  });
}

const only = (process.env.SCENARIO || '').split(',').map(s => s.trim()).filter(Boolean);
const all = loadScenarios();
const scenarios = process.env.RUN_PLAN ? planned(all) : all.filter(s => !only.length || only.includes(s.id));

for (const s of scenarios) {
  const tags = (s.tags ?? []).map(t => `@${t}`).join(' ');
  test(`run${s.run} ${s.id}: ${s.title} ${tags}`.trim(), async ({ page }, testInfo) => {
    const problems = validateScenario(s);
    expect(problems, `scenario ${s.file} is unsafe or malformed`).toEqual([]);

    const r = await new Run(page, s, testInfo).execute();
    await saveVideo(page, r.run, testInfo);
    testInfo.annotations.push(
      { type: 'result', description: r.result },
      { type: 'booking', description: r.booking },
      { type: 'session', description: r.sessionId ?? '—' },
      { type: 'ended at', description: r.endedAt_step },
    );
    // a blocked run (no booking, OTP problem, booking already used) stays visible in the report, labelled
    if (r.result.startsWith('blocked')) return;
    const open = r.failures.filter(f => !f.known);
    expect(open.map(f => `#${f.id} ${f.step}: expected ${f.expected} — got ${f.got}`), r.result).toEqual([]);
  });
}
