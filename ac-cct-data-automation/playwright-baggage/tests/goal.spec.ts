// Goal chats (project "goal"): one AI-driven chat per item of GOAL_PLAN.
//   GOAL_PLAN=<file.json>   [{ "pnr": "FYO4TS", "goal": "Claim for the lost contents; stop at the payout question", "maxTurns": 30 }]
import fs from 'node:fs';
import { test, expect } from './fixtures/cdp';   // plain @playwright/test unless CDP_URL is set
import { GoalRun, type GoalItem } from '../src/goal';
import { saveVideo } from '../src/video';

const plan: GoalItem[] = process.env.GOAL_PLAN ? JSON.parse(fs.readFileSync(process.env.GOAL_PLAN, 'utf8')) : [];

test.describe('goal chats', () => {
  // each chat is its own booking: run them side by side (the OTP broker still hands out one code at a time)
  test.describe.configure({ mode: 'parallel' });
  test.skip(!plan.length, 'no GOAL_PLAN');
  plan.forEach((item, i) => {
    test(`run${i + 1} ${item.caseId ?? 'goal'} ${item.pnr}: ${item.title ?? item.goal ?? 'AI customer'}`.slice(0, 200), async ({ page }, testInfo) => {
      // a Jira FD claim waits minutes for some replies (payout country, Persona): give the chat room to finish
      test.setTimeout(Number(process.env.GOAL_TIMEOUT_MS || 45 * 60_000));
      const r = await new GoalRun(page, item, i + 1, testInfo).execute();
      await saveVideo(page, r.run, testInfo);
      testInfo.annotations.push({ type: 'result', description: r.result }, { type: 'booking', description: r.booking },
        { type: 'session', description: r.sessionId ?? '—' }, { type: 'ended at', description: r.endedAt_step });
      // a blocked chat (no evidence either way) stays visible in the report, labelled, rather than hidden as skipped
      if (r.result.startsWith('blocked')) return;
      expect(r.failures.filter(f => !f.known).map(f => `#${f.id} ${f.step}: ${f.got}`), r.result).toEqual([]);
    });
  });
});
