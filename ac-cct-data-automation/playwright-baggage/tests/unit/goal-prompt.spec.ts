import { test, expect } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';
import { botSilence, pickReceipts, receiptsFor, scripted, scrollStuck, shown, transcriptText } from '../../src/goal';

test('a SOC case uploads a night stranded, a baggage case its clothing and toiletries', () => {
  expect(receiptsFor('SOC_UAT_046').map(f => path.basename(f)))
    .toEqual(['hotel-receipt.pdf', 'meals-receipt.pdf', 'taxi-receipt.pdf', 'essentials-receipt.pdf']);
  expect(receiptsFor('BAG_PO_001').map(f => path.basename(f))).toEqual(['clothing-receipt.pdf', 'toiletries-receipt.pdf']);
  expect(receiptsFor(undefined)).toEqual(receiptsFor('BAG_PO_001'));
  // the SOC files exist and carry SOC_UAT_046's CAD amounts
  const root = path.resolve(__dirname, '..', '..');
  const amounts = receiptsFor('SOC_UAT_046').map(f => fs.readFileSync(path.join(root, f), 'latin1').match(/Total CAD ([\d.]+)/)?.[1]);
  expect(amounts).toEqual(['185.00', '52.00', '60.00', '28.00']);
});

const booking = { first: 'Isabella', last: 'Ostcastav', pnr: 'ZZTZUF' };
const item = {
  pnr: 'ZZTZUF', title: 'EU – Eligible – No Travel Incomplete – Flight Cancelled', jiraKey: 'CHAI-31961',
  script: [
    { type: 'click', value: 'English' },
    { type: 'say', value: 'I was on a connecting flight… Can I get reimbursed?' },
    { type: 'provide', value: 'Isabella Ostcastav' },
    { type: 'provide', value: 'ZZTZUF' },
    { type: 'otp' },
  ],
};

test('the assistant leads: steps are facts to answer with, not text to type in order', () => {
  const p = scripted(item, booking);
  expect(p).toContain('THE ASSISTANT LEADS');
  expect(p).toContain('Never type a name, booking reference or other detail into the chat unless the assistant has just asked');
  expect(p).not.toMatch(/IN ORDER, one per turn/);
  expect(p).not.toMatch(/Do not skip, add or reorder/);
  // what SOC_UAT_046 got wrong: name and PNR are "when asked", not messages to send
  expect(p).toContain('when asked, give: "Isabella Ostcastav"');
  expect(p).toContain('when asked, give: "ZZTZUF"');
  expect(p).toContain('say (free text, when the assistant is waiting for you to type)');
});

test('a bot that answers with information instead of a claim is steered, not waited on', () => {
  const p = scripted(item, booking);
  expect(p).toContain('If the assistant does not start the claim');
  expect(p).toContain("I'd like to file a claim to be reimbursed for my expenses");
});

test('one receipt by default, a photo before a PDF folio; all on request', () => {
  const files = ['r/046_1_hotel_YYZ.pdf', 'r/046_2_meal_YYZ.jpg', 'r/046_3_transport_YYZ.jpg'];
  expect(pickReceipts(files, '1')).toEqual(['r/046_2_meal_YYZ.jpg']);
  expect(pickReceipts(files, 'all')).toEqual(['r/046_2_meal_YYZ.jpg', 'r/046_3_transport_YYZ.jpg', 'r/046_1_hotel_YYZ.pdf']);
  expect(pickReceipts(files, '2')).toHaveLength(2);
});

test('a silent assistant stops the run instead of 48 waits', () => {
  const t0 = Date.parse('2026-10-20T15:30:00Z');
  const at = (min: number) => new Date(t0 + min * 60_000).toISOString();
  const waits = [{ action: 'send_message', at: at(0) }, ...[1, 2, 3, 4, 5, 6, 7].map(m => ({ action: 'wait', at: at(m) }))];
  const msgs = [{ who: 'bot' }, { who: 'you' }];
  expect(botSilence(waits, msgs, t0 + 8 * 60_000)).toBe(7 * 60_000);       // silent since the first wait
  expect(botSilence([...waits, { action: 'click', at: at(8) }], msgs, t0 + 9 * 60_000)).toBe(0);  // the customer acted
  expect(botSilence([{ action: 'send_message', at: at(0) }], msgs, t0 + 60_000)).toBe(0);
});

test('two scrolls in a row means stop scrolling', () => {
  expect(scrollStuck([{ action: 'send_message' }, { action: 'scroll' }])).toBe(false);
  expect(scrollStuck([{ action: 'scroll' }, { action: 'scroll' }])).toBe(true);
  expect(scrollStuck([{ action: 'scroll' }, { action: 'scroll' }, { action: 'click' }])).toBe(false);
});

test('the customer and the judge both see what an alert box says', () => {
  const alert = { who: 'bot', text: '', layout: 'plain', boxes: [{ kind: 'success', text: 'Claim submission successful!' }],
                  buttons: [], form: [], links: [], chips: [], index: 0 } as any;
  expect(shown(alert)).toBe('Claim submission successful!');
  expect(transcriptText([alert])).toContain('Claim submission successful!');
  // a box repeating the text is not shown twice
  expect(shown({ text: 'Your identity has been verified.', boxes: [{ kind: 'success', text: 'Your identity has been verified.' }] } as any))
    .toBe('Your identity has been verified.');
});
