import zlib from 'node:zlib';
import { test, expect } from '@playwright/test';
import { countCheckpoints, crc32, maskOtp, renderIndex, renderMessage, renderTest, summarize, zip, type EvidenceData } from '../../src/evidence';

const PNG = 'data:image/png;base64,iVBORw0KGgo=';

const DATA: EvidenceData = {
  run: 1, runName: 'fd-tc-001', title: 'Travel Completed | Delay', caseId: 'FD_TC_001', jiraKey: 'CHAI-31393',
  booking: 'ZZCROD', passenger: 'Catherine Q', caseNumber: 'CCD-1018800-7QLGJC', result: 'fail',
  startedAt: '2026-10-20T11:29:49.331Z', endedAt: '2026-10-20T11:39:37.478Z',
  messages: [
    { index: 0, who: 'bot', time: '05:00 PM', text: 'Which language?', layout: 'plain', boxes: [], buttons: ['English', 'Français'], chips: [], form: [], links: [] },
    { index: 1, who: 'you', time: '05:01 PM', text: '358978', layout: 'plain' },
    { index: 2, who: 'you', text: 'my code is 123456 thanks', layout: 'plain' },
    { index: 3, who: 'bot', text: '<script>alert("x")</script><img src=x onerror=alert(1)>', layout: 'plain' },
    { index: 4, who: 'widget', text: 'Chat ended', layout: 'plain' },
    { index: 5, who: 'bot', text: '', layout: 'plain', boxes: [{ kind: 'success', text: 'Claim submitted' }] },
    { index: 6, who: 'bot', text: 'Name', layout: 'plain', form: ['First name*', 'Last name*'],
      links: [{ text: 'Privacy Notice', href: 'https://www.aircanada.com/privacy' }] },
  ],
  checkpoints: [
    { n: 1, status: 'pass', expected: 'Hello', quote: 'Hi there', message: 0, line: 2 },
    { n: 2, status: 'fail', expected: 'How many people?', reason: 'skipped', line: 43 },
    { n: 3, status: 'fail', expected: 'x' },
    { n: 4, status: 'not_reached', expected: 'y' },
    { n: 5, status: 'unverified', expected: 'z' },
  ],
  skipped: [{ jiraCheckpoint: 'CP140', kind: 'dashboard', check: 'IDV result', reason: 'IDV not automated' }],
  dashboard: [
    { jiraCheckpoint: 'CP103', api: 'CP103', check: 'topic', expected: 'Delay', status: 'pass', value: '{"a":1}' },
    { jiraCheckpoint: 'CP104', api: 'CP103', check: 'edit', status: 'manual' },
    { jiraCheckpoint: 'CP130', api: 'CP130', check: 'amount', expected: '400', status: 'fail', value: '300' },
  ],
  verification: { caseNumber: 'CCD-1018800-7QLGJC', sections: [] },
  emails: [
    { id: 'a', subject: 'Your Air Canada verification code', quotesCase: false, amountFound: false, snippet: 'use the code below: 358978 for security' },
    { id: 'b', subject: 'Payment details CCD-1018800-7QLGJC', quotesCase: true, amountFound: true, snippet: 'amount 400.00' },
  ],
  failures: [{ id: 1, run: 1, step: 'GenUC-05 #9', expected: 'a', got: 'b', before: 'typed `654321`', kind: 'wording', severity: 'Medium', known: null }],
  failureShots: { '1': 'k1' },
  decisions: [{ turn: 1, at: '', action: 'type', args: { id: 1, text: '777888' }, thought: 'enter the code', outcome: 'ok' }],
  notes: ['note <b>bold</b>'],
  screens: [{ key: 'k1', label: 'Step 1' }, { key: 'k2', label: 'Step 2' }],
  images: { k1: PNG, k2: PNG },
};

test('a typed six-digit code is masked, alone or inside a sentence; amounts are not', () => {
  expect(maskOtp('358978')).toBe('••••••');
  expect(maskOtp(' 123456 ')).toBe('••••••');
  expect(maskOtp('my code is 123456 thanks')).toBe('my code is •••••• thanks');
  expect(maskOtp('400.00 CAD, phone 1234567890')).toBe('400.00 CAD, phone 1234567890');
  const html = renderTest(DATA);
  for (const code of ['358978', '123456', '654321', '777888']) expect(html).not.toContain(code);
  expect(html).toContain('••••••');
});

test('bubbles carry their role: customer right, assistant left, widget centred', () => {
  expect(renderMessage(DATA.messages[0], 0)).toMatch(/^<div class="msg bot" id="m0">/);
  expect(renderMessage(DATA.messages[1], 1)).toMatch(/^<div class="msg you" id="m1">/);
  expect(renderMessage(DATA.messages[4], 4)).toMatch(/^<div class="msg widget" id="m4">/);
  // an options-only widget row sits on the assistant's side
  expect(renderMessage({ who: 'widget', text: '', chips: ['Yes', 'No'] }, 9)).toContain('class="msg bot opts"');
  // an alert box is styled by its layout
  expect(renderMessage(DATA.messages[5], 5)).toContain('<div class="box success">Claim submitted</div>');
  // a box that repeats the message text is shown once
  const dup = renderMessage({ who: 'bot', text: 'Note:\nno changes', layout: 'info', boxes: [{ kind: 'info', text: 'Note: no changes' }] }, 7);
  expect(dup.match(/class="box info"/g)!.length).toBe(1);
});

test('buttons, chips and form fields are rendered under the bubble', () => {
  const m = renderMessage(DATA.messages[0], 0);
  expect(m).toContain('<span class="chip btn">English</span>');
  expect(m).toContain('<span class="chip btn">Français</span>');
  const f = renderMessage(DATA.messages[6], 6);
  expect(f).toContain('<li>First name*</li>');
  expect(f).toContain('<li>Last name*</li>');
  expect(f).toContain('Privacy Notice');
});

test('checkpoint counts in the page and the index row', () => {
  expect(countCheckpoints(DATA.checkpoints)).toEqual({ pass: 1, fail: 2, not_reached: 1, unverified: 1, total: 5 });
  const html = renderTest(DATA);
  expect(html).toContain('1 pass · 2 fail · 1 not reached · 1 unverified of 5');
  expect(html).toContain('data-f="not_reached">not reached (1)');
  expect(html.match(/<tr data-s="fail">/g)!.length).toBe(3);   // 2 checkpoints + 1 dashboard row
  const row = summarize(DATA);
  expect(row.checkpoints.fail).toBe(2);
  expect(row.dashboard).toMatchObject({ pass: 1, fail: 1, manual: 1 });
  expect(row.emailOk).toBe(true);
  const index = renderIndex([row, { ...row, run: 2, file: 'run2.html', result: 'pass' }], { name: 'fd' });
  expect(index).toContain('href="run1.html"');
  expect(index).toContain('href="run2.html"');
  expect(index).toContain('<th>2 / 4 / 2</th>');
  expect(index).toContain('data-f="pass">pass (1)');
});

test('bot text is escaped: no script injection', () => {
  const html = renderTest(DATA);
  expect(html).not.toContain('<script>alert');
  expect(html).not.toContain('<img src=x');
  expect(html).toContain('&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;');
  expect(html).toContain('note &lt;b&gt;bold&lt;/b&gt;');
  // only the page's own script block
  expect(html.match(/<script>/g)!.length).toBe(1);
});

test('self-contained: no external resource, no video', () => {
  const html = renderTest(DATA);
  expect(html).not.toMatch(/(src|href)\s*=\s*["']?\s*(https?:)?\/\//i);
  expect(html).not.toMatch(/url\(\s*["']?(https?:)?\/\//i);
  expect(html).not.toMatch(/@import/i);
  expect(html).not.toMatch(/\.webm/i);
  expect(html).not.toMatch(/<(video|iframe|link)\b/i);
  // each picture embedded once, copies point at it
  expect(html.split(PNG).length - 1).toBe(2);
  expect(html).toContain('data-same="k1"');
  const index = renderIndex([summarize(DATA)]);
  expect(index).not.toMatch(/(src|href)\s*=\s*["']?\s*(https?:)?\/\//i);
});

test('zip: a valid archive whose entries inflate back', () => {
  const a = Buffer.from('<html>'.repeat(200));
  const b = Buffer.from('x');
  const z = zip([{ name: 'index.html', data: a }, { name: 'run1.html', data: b }]);
  expect(z.readUInt32LE(0)).toBe(0x04034b50);
  expect(z.readUInt32LE(z.length - 22)).toBe(0x06054b50);
  expect(z.readUInt16LE(z.length - 22 + 10)).toBe(2);
  // first entry: deflated, crc matches
  expect(z.readUInt16LE(8)).toBe(8);
  const size = z.readUInt32LE(18), nameLen = z.readUInt16LE(26);
  expect(z.toString('utf8', 30, 30 + nameLen)).toBe('index.html');
  expect(zlib.inflateRawSync(z.subarray(30 + nameLen, 30 + nameLen + size)).equals(a)).toBe(true);
  expect(z.readUInt32LE(14)).toBe(crc32(a));
  expect(crc32(Buffer.from('123456789'))).toBe(0xcbf43926);
});

test('with the chat as seen, the text transcript is not repeated and ↗ chat lands on the screenshot', () => {
  const lean: EvidenceData = { ...DATA, screens: [], chatShots: ['k1'] };
  const html = renderTest(lean);
  expect(html).toContain('<section id="seen"><h2>Chat (as seen)');
  expect(html).not.toContain('Chat transcript');
  expect(html).not.toContain('id="m0"');
  expect(html).toContain('href="#seen">↗ chat</a>');
  expect(html).not.toContain('href="#m0"');
  // no chat screenshot: the transcript is the only chat evidence, so it stays, links and all
  const bare = renderTest({ ...DATA, screens: [], chatShots: [] });
  expect(bare).toContain('Chat transcript');
  expect(bare).toContain('href="#m0">↗ chat</a>');
});
