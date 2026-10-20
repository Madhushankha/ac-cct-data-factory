import { test, expect } from '@playwright/test';
import { bodyText, extractCode, firstNameMatches } from '../../src/otp';

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
