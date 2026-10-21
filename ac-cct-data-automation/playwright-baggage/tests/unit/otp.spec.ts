import { test, expect } from '@playwright/test';
import { bodyText, extractCode, firstNameMatches, needsQueue } from '../../src/otp';
import { full } from '../../src/bookings';

test('a shared inbox queues for its code; a booking\'s own inbox does not', () => {
  expect(needsQueue({ provider: 'mailinator', domain: 'd', inbox: 'lahiru' })).toBe(true);
  expect(needsQueue({ provider: 'mailinator', domain: 'd', inbox: 'bag-po-001-x', own: true })).toBe(false);
  expect(needsQueue({ provider: 'manual' })).toBe(true);
});

test('a booking\'s own otp wins over the pool\'s, and a booking without one keeps the pool\'s', () => {
  const pool = { otp: { provider: 'mailinator' as const, inbox: 'lahiru' }, bookings: [] };
  const own = { provider: 'mailinator' as const, inbox: 'bag-po-001-x', own: true };
  expect(full('p', pool, { pnr: 'AAA111', otp: own }).otp).toEqual(own);
  expect(full('p', pool, { pnr: 'BBB222' }).otp).toEqual(pool.otp);
});

const EN = {
  parts: [{ body: `<html><head><style>.a{color:#005078} .b{background:#123456}</style></head>
    <body><p style="color:#005078">IDRIS, use the code below to continue your Ask AC chat verification:&nbsp;<b>482913</b></p>
    <p>Ref 1234567 · colour #654321</p></body></html>` }],
};
const FR = {
  parts: [{ body: `<div style="color:#005078">Bonjour Toula, utilisez le code ci-dessous pour poursuivre la vérification de votre clavardage Demandez à AC : 731905</div>` }],
};

test('reads the six digits after "verification", never a CSS colour', () => {
  const t = bodyText(EN);
  expect(t).not.toContain('005078');           // style blocks stripped
  expect(extractCode(t)).toBe('482913');
});

test('a bare \\d{6} would have picked the colour: the guard regex does not', () => {
  const raw = EN.parts[0].body;
  expect(raw.match(/\d{6}/)?.[0]).toBe('005078');
  expect(extractCode(bodyText(EN))).toBe('482913');
});

test('English greeting must name the passenger', () => {
  const t = bodyText(EN);
  expect(firstNameMatches(t, 'idris')).toBe(true);
  expect(firstNameMatches(t, 'TOULA')).toBe(false);
});

test('French email: name anywhere, digits after vérification', () => {
  const t = bodyText(FR);
  expect(extractCode(t)).toBe('731905');
  expect(firstNameMatches(t, 'Toula')).toBe(true);
  expect(firstNameMatches(t, 'Idris')).toBe(false);
});

test('no code -> undefined (seven digits are not a code)', () => {
  expect(extractCode('verification: 1234567')).toBeUndefined();
  expect(extractCode('hello')).toBeUndefined();
});
