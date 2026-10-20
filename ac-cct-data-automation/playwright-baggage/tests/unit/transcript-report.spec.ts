import fs from 'node:fs';
import path from 'node:path';
import { test, expect } from '@playwright/test';
import { layoutOf, splitInnerText, toMessages } from '../../src/transcript';
import { renderReport } from '../../scripts/report';
import { parseSeedReport } from '../../scripts/import-seed';
import { SEED_REPORTS, seedReport } from '../../src/external';
import { dayLabel, type RunResult } from '../../src/steps';

const UUID = '980ad42a-91d7-431f-8579-defd4759757a';

test('rows -> messages: header, session id and chrome stripped, layout from the alert colour', () => {
  const msgs = toMessages([
    { text: `Ask AC\n02:45 PM\nGood afternoon!\nHow can I help you today?\n${UUID}`, hasUuid: true, alerts: [], buttons: ['Helpful', 'Not helpful'], chips: ['Ask AC', '02:45 PM'], form: [], links: [] },
    { text: 'English\nFrançais', hasUuid: true, alerts: [], buttons: [], chips: ['English', 'Français'], form: [], links: [] },
    { text: 'You\n02:46 PM\nMy bag is lost', hasUuid: false, alerts: [], buttons: [], chips: [], form: [], links: [] },
    { text: `Ask AC\n02:47 PM\nThank you, your submission was successful.\n${UUID}`, hasUuid: true,
      alerts: [{ bg: 'rgb(223, 240, 219)', text: 'Thank you, your submission was successful.' }], buttons: ['Upload receipts', 'Helpful'], chips: [], form: [], links: [] },
  ]);
  expect(msgs[0]).toMatchObject({ who: 'bot', time: '02:45 PM', text: 'Good afternoon!\nHow can I help you today?', layout: 'plain', buttons: [] });
  expect(msgs[1]).toMatchObject({ who: 'widget', text: '', chips: ['English', 'Français'] });
  expect(msgs[2]).toMatchObject({ who: 'you', text: 'My bag is lost' });
  expect(msgs[3]).toMatchObject({ layout: 'success', buttons: ['Upload receipts'] });
});

test('alert colours', () => {
  expect(layoutOf('rgb(207, 230, 252)')).toBe('info');
  expect(layoutOf('rgb(255, 247, 204)')).toBe('warning');
  expect(layoutOf('rgb(223, 240, 219)')).toBe('success');
});

test('innerText fallback splits on the "Ask AC / You + time" headers', () => {
  const parts = splitInnerText(`Ask AC\n02:44 PM\nHi there!\n${UUID}\nYou\n02:45 PM\nmy bag\nAsk AC\n02:45 PM\nSorry to hear that.`);
  expect(parts).toEqual([
    { who: 'bot', time: '02:44 PM', text: 'Hi there!' },
    { who: 'you', time: '02:45 PM', text: 'my bag' },
    { who: 'bot', time: '02:45 PM', text: 'Sorry to hear that.' },
  ]);
});

test('calendar day label matches the widget ("Thu, Oct 1, 2026")', () => {
  expect(dayLabel('2026-10-01')).toBe('Thu, Oct 1, 2026');
});

test('report.md has the guide 11.2 layout', () => {
  const r: RunResult = {
    run: 4, id: 'item-over-300', title: 'Item over 300', booking: 'VMOGAP', pool: 'v77', sessionId: 'aedca5aa-0000',
    startedAt: '2026-10-07T20:00:00Z', endedAt: '2026-10-07T20:09:00Z', otpCodes: 1, stepsSeen: ['GenUC-08', 'BAG-06.S20'],
    stepsExpected: ['BAG-06.S20', 'GenUC-27'], endedAt_step: 'BAG-06.S22', result: 'fail', notes: [],
    screenshots: ['screenshots/run4_VMOGAP.png'],
    failures: [{ id: 1, run: 4, sessionId: 'aedca5aa-0000', step: 'BAG-06.S22 → GenUC-27', expected: 'GenUC-27 first question',
      got: 'plain "I\'m sorry | we weren\'t able"', before: 'typed `I don\'t have the receipt`', kind: 'error', severity: 'High', known: null }],
  };
  const md = renderReport([r], { name: 'v77 all paths', workers: 5 });
  expect(md).toContain('# Baggage v77 all paths');
  expect(md).toContain('## Table 1: one row per run');
  expect(md).toContain('## Table 2: one row per failed step (the fix list)');
  expect(md).toContain('## Summary');
  expect(md).toContain('![](screenshots/run4_VMOGAP.png)');
  expect(md).toContain("I'm sorry \\| we weren't able");      // pipes escaped inside table cells
  expect(md).toContain('Board steps not reached: GenUC-27');
  expect(md).toMatch(/0 pass \/ 1 fail \/ 0 known \/ 0 blocked/);
});

const SEED = seedReport('toula-v72-bag-sit-test-bookings.html');
test('seed importer reads a real seed report', () => {
  // skip only when the seed-report FOLDER is absent, which means this machine does not have the
  // data. A missing file inside a folder that exists is a real failure: this test silently skipped
  // for a while because the path walked out of the project and landed one directory short.
  test.skip(!fs.existsSync(SEED_REPORTS), `no seed reports at ${SEED_REPORTS} (set AQA_SEED_REPORTS)`);
  const { name, pool } = parseSeedReport(fs.readFileSync(SEED, 'utf8'), SEED);
  expect(name).toBe('toula-v72');
  expect(pool).toMatchObject({ dataset: 'baggage-sit-int-v72', first: 'Toula', last: 'Voulgaris', otp: { provider: 'manual' } });
  expect(pool.bookings).toHaveLength(55);
  const by = Object.fromEntries(pool.bookings.map(b => [b.pnr, b]));
  expect(by.GCIHNK.tags).toContain('closed');
  expect(by.GCIHNK.tags).not.toContain('delivered');      // "Bag never delivered"
  expect(by.K0WX16.tags).toContain('delivered');
  expect(by.E2G6I2.tags).toEqual(expect.arrayContaining(['partner', 'waiting']));
  expect(by.UR5WW0.tags).toContain('lost');
});
