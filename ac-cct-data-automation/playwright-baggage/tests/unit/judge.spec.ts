import { test, expect } from '@playwright/test';
import { genericDefects, judge, knownFor, loadKnownIssues } from '../../src/judge';
import type { Message } from '../../src/transcript';

let n = 0;
const bot = (text: string, extra: Partial<Message> = {}): Message => ({
  index: n++, who: 'bot', text, layout: 'plain', boxes: [], buttons: [], chips: [], form: [], links: [], rawUrls: [], ...extra,
});

test('meaning, not wording: any_of alternatives, case-insensitive', () => {
  const w = [bot('Has your BAG been delivered to you yet?', { buttons: ['Yes, it was delivered!', "No, I still haven't received it!"] })];
  expect(judge({ step: 'S5', any_of: ['been delivered'], buttons: ['Yes, it was delivered!'] }, w).ok).toBe(true);
  expect(judge({ step: 'S5', any_of: ['was it returned'] }, w).problems[0].kind).toBe('flow');
});

test('layout is strict: plain vs green alert', () => {
  const ok = [bot('Thank you, your submission was successful.', { layout: 'success', boxes: [{ kind: 'success', text: 'Thank you, your submission was successful.' }] })];
  expect(judge({ step: 'S20', text: 'submission was successful', layout: 'success' }, ok).ok).toBe(true);
  const plain = [bot('Thank you, your submission was successful.')];
  const v = judge({ step: 'S20', text: 'submission was successful', layout: 'success' }, plain);
  expect(v.ok).toBe(false);
  expect(v.problems[0]).toEqual({ kind: 'layout', what: 'layout plain, expected success' });
  expect(v.got).toMatch(/^plain "Thank you/);
});

test('buttons, form fields and box are strict', () => {
  const w = [bot('Before you begin: please list the items in your bag.', {
    boxes: [{ kind: 'info', text: 'Before you begin' }], buttons: ["Yes, let's start"], form: ['Country*'] })];
  const v = judge({ step: 'S2', any_of: ['list the items'], box: 'Before you begin', box_kind: 'info', buttons: ["Yes, let's start", 'No, not now'], form: ['Country'] }, w);
  expect(v.problems.map(p => p.what)).toEqual(['button [No, not now] missing']);
});

test('order: green alert must come BEFORE the receipts message', () => {
  const success = bot('Thank you, your submission was successful.', { layout: 'success' });
  const receipts = bot('Please upload your receipts as proof of ownership.');
  expect(judge({ step: 'S20', text: 'successful', before: 'proof of ownership' }, [success, receipts]).ok).toBe(true);
  const r2 = bot('Please upload your receipts as proof of ownership.');
  const s2 = bot('Thank you, your submission was successful.', { layout: 'success' });
  expect(judge({ step: 'S20', text: 'successful', before: 'proof of ownership' }, [r2, s2]).ok).toBe(false);
});

test('absent: a message that must not show', () => {
  const w = [bot('Reminder: your claim will be assessed by an automated system.')];
  const v = judge({ step: 'tracking.no-notice', absent: ['claim will be assessed'] }, w);
  expect(v.ok).toBe(false);
  expect(judge({ step: 'x', absent: ['claim will be assessed'] }, [bot('Your bag is on its way.')]).ok).toBe(true);
});

test('the customer\'s own words are never judged as the bot', () => {
  const you: Message = { ...bot('my bag has been delivered'), who: 'you' };
  expect(judge({ step: 'S5', any_of: ['been delivered'] }, [you]).ok).toBe(false);
});

test('generic defects: raw URL and error text', () => {
  const d = genericDefects([bot('See https://example.com', { rawUrls: ['https://example.com'] }), bot('Something went wrong, please try again')]);
  expect(d.map(x => x.kind)).toEqual(['layout', 'error']);
});

test('known issues tag only what they match', () => {
  const issues = loadKnownIssues();
  expect(issues.length).toBeGreaterThan(5);
  expect(knownFor({ step: 'BAG-08.S3 [check: life event]', got: 'plain "ok"', expected: 'empathy' }, issues, ['I-12'])).toBe('I-12');
  expect(knownFor({ step: 'BAG-03c.S5', got: 'plain "?"', expected: 'delivered' }, issues, ['I-12'])).toBeNull();
  expect(knownFor({ step: 'BAG-06.S16.link', got: 'plain "Montreal" — link ~ /Montreal/ missing', expected: 'any of /Montreal/; …' }, issues)).toBe('I-11');
});
