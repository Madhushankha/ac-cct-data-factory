import { test, expect } from '@playwright/test';
import { caseMails, caseNumberFrom, checkDashboard, chosenAmount, words, type Verification } from '../../src/verify';

const V: Verification = {
  caseNumber: 'CCD-1017990-NOFE0U',
  sections: [
    { section: 'case', items: [
      { id: 'CP105', present: true, value: { currentStatusCode: 'closed', eligibilityStatusCode: 'not_eligible' } },
      { id: 'CP110', present: null, value: { manualEntry: {} } },
    ] },
    { section: 'eligibilityAndCompensation', items: [
      { id: 'CP132', present: true, value: { type: 'cash', amount: '400.00', issuedCurrency: 'CAD' } },
      { id: 'CP136', present: true, value: { eligibilityStatusCode: 'eligible', regimeCode: 'APPR' } },
    ] },
    { section: 'records', items: [{ id: 'CP153', present: false, value: { count: 0 } }] },
  ],
};

test('the case number is the last one the assistant quoted, never the customer', () => {
  expect(caseNumberFrom([
    { who: 'bot', text: 'Your earlier case CCD-1000001-AAAA11 is closed.' },
    { who: 'you', text: 'what about CCD-9999999-ZZZZ99' },
    { who: 'bot', text: 'Your claim was submitted. Case number: CCD-1017990-NOFE0U.' },
    { who: 'you', text: 'thanks' },
  ])).toBe('CCD-1017990-NOFE0U');
  expect(caseNumberFrom([{ who: 'bot', text: 'no case here' }])).toBeUndefined();
});

test('labels and stored codes meet halfway', () => {
  expect(words('Closed → Not Eligible')).toEqual(['closed', 'not', 'eligible']);
  expect(words({ s: 'not_eligible' })).toEqual(expect.arrayContaining(['not', 'eligible']));
});

test('each mapped dashboard row is checked against the API item it maps to', () => {
  const r = checkDashboard([
    { jiraCheckpoint: 'CP081', api: 'CP105', check: 'And the Status is "Closed → Not Eligible"', expected: 'Closed → Not Eligible' },
    { jiraCheckpoint: 'CP090', api: 'CP136', check: 'And the regime is APPR', expected: 'EU261' },
    { jiraCheckpoint: 'CP091', api: 'CP132', check: 'And the compensation is set' },
    { jiraCheckpoint: 'CP092', api: 'CP153', check: 'And the receipts are attached' },
    { jiraCheckpoint: 'CP093', api: 'CP110', check: 'And no banners are displayed' },
    { jiraCheckpoint: 'CP094', api: 'CP199', check: 'And something new' },
    { jiraCheckpoint: 'CP095', api: null, check: 'And the moon is full' },
    { jiraCheckpoint: 'CP096', api: 'CP108', check: 'And the SLA countdown', manual: true },
  ], V);
  expect(r.map(x => [x.jiraCheckpoint, x.status])).toEqual([
    ['CP081', 'pass'],      // every expected word is in the stored codes
    ['CP090', 'review'],    // present, but the value does not say EU261: a person decides, not a regex
    ['CP091', 'pass'],      // nothing expected beyond presence
    ['CP092', 'fail'],      // the API says absent
    ['CP093', 'ui'],        // decided in the UI: not checkable from the API
    ['CP094', 'missing'],   // the plan maps to an item the API does not have
    ['CP095', 'unmapped'],
    ['CP096', 'manual'],
  ]);
});

test('the chosen amount comes from CP132', () => {
  expect(chosenAmount(V)).toBe('400.00');
  expect(chosenAmount({ sections: [] })).toBeUndefined();
});

test('a shared inbox only counts mail that quotes the case; an own inbox counts all of it', () => {
  const mails = [
    { id: '1', subject: 'Your claim CCD-1017990-NOFE0U', body: 'You will receive $400.00 by Interac for CCD-1017990-NOFE0U.' },
    { id: '2', subject: 'Your verification code', body: 'IDRIS, use the code below: 123456' },
    { id: '3', subject: 'Another claim', body: 'Case CCD-1000001-AAAA11: $50.00' },
  ];
  const shared = caseMails(mails, 'CCD-1017990-NOFE0U', { ownInbox: false, amount: '400.00' });
  expect(shared.map(m => [m.id, m.quotesCase, m.amountFound])).toEqual([['1', true, true]]);
  const own = caseMails(mails.slice(0, 2), 'CCD-1017990-NOFE0U', { ownInbox: true, amount: '400.00' });
  expect(own.map(m => [m.id, m.quotesCase, m.amountFound])).toEqual([['1', true, true], ['2', false, false]]);
});
