// Seed report HTML -> a booking pool in data/bookings.yaml.
//   npm run import-seed -- <seed-report.html> [more.html] [--name toula-v72]
// A bare filename is looked up in AQA_SEED_REPORTS (see src/external.ts).
//
// Reads the "<name> baggage test bookings (vNN)" pages: passenger, the address the code goes to, and every
// row of the per-card tables (booking, flights, what it tests, bag file, case id) plus the "All bookings"
// flags. Each booking gets state tags the scenarios pick by (open, delivered, closed, no-ahl, two-bags,
// two-journeys, partner, waiting, outside-21, duplicate, cap-spent). The OTP provider follows the address:
// a *.mailinator.com contact -> mailinator (automatic); anything else -> manual (a person drops the code).
import fs from 'node:fs';
import path from 'node:path';
import YAML from 'yaml';
import { BOOKINGS_FILE, type Booking, type Pool } from '../src/bookings';
import { SEED_REPORTS } from '../src/external';

const strip = (s: string) => s.replace(/<[^>]+>/g, ' ').replace(/&rarr;/g, '→').replace(/&mdash;/g, '—').replace(/&amp;/g, '&')
  .replace(/&[a-z]+;/g, ' ').replace(/\s+/g, ' ').trim();

export function tagsFor(pick: string, what: string, tagText: string[], note: string): string[] {
  const t = new Set<string>();
  const p = pick.toLowerCase();
  if (/\bopen\b/.test(p)) t.add('open');
  if (/\bdelivered\b/.test(p) && !/never delivered|not delivered|undelivered|neither delivered/.test(p)) t.add('delivered');
  // a bag still not back 21+ days after arrival counts as lost (the contents road)
  const days = Number(p.match(/(\d+) days since arrival/)?.[1] ?? NaN);
  if (/counts as lost/i.test(what) || (/\bopen\b/.test(p) && days >= 21)) t.add('lost');
  if (/\bopen\b/.test(p) && days < 21) t.add('recent');
  if (/closed/.test(p)) t.add('closed');
  if (/no ahl/.test(p)) t.add('no-ahl');
  if (/two bags|two ahl|and yvrac|ahls?\b.*\band\b/.test(p)) t.add('two-bags');
  if (/islastcarrierac = false/.test(p)) t.add('partner');
  if (/cap/.test(what.toLowerCase()) && /consumed|spent/.test(what.toLowerCase() + p)) t.add('cap-spent');
  if (/duplicate/.test(what.toLowerCase())) t.add('duplicate');
  if (/still inside/i.test(note)) t.add('waiting');
  for (const x of tagText) {
    const k = x.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
    if (k) t.add(k === '2-journeys' ? 'two-journeys' : k === '2-bags' ? 'two-bags' : k);
  }
  return [...t].sort();
}

export function parseSeedReport(html: string, file = ''): { name: string; pool: Pool } {
  const text = strip(html.replace(/<style[\s\S]*?<\/style>|<script[\s\S]*?<\/script>/gi, ' '));
  const dataset = html.match(/baggage-[a-z]+-[a-z]+-v\d+/)?.[0];
  const passenger = text.match(/Passenger\s+([A-Z][A-Z' -]+?)\s+Date of birth/)?.[1]?.trim() ?? '';
  const email = text.match(/Code sent to\s+([\w.+-]+@[\w.-]+\.\w+)/i)?.[1];
  const [first, ...rest] = passenger.split(/\s+/);
  const titleCase = (s: string) => s.toLowerCase().replace(/\b\w/g, c => c.toUpperCase());

  const bookings = new Map<string, Booking>();
  for (const sec of html.matchAll(/<section id="(bag\d+)"[\s\S]*?<\/section>/gi)) {
    const card = sec[1].toUpperCase().replace(/^BAG(\d+)/, 'BAG-$1');
    for (const tr of sec[0].matchAll(/<tr>([\s\S]*?)<\/tr>/gi)) {
      const row = tr[1];
      const pnr = row.match(/<div class="pnr">\s*([A-Z0-9]{6})\s*</)?.[1];
      if (!pnr) continue;
      const legs = [...row.matchAll(/<div class="leg( delayed)?">([\s\S]*?)<\/div>\s*<div class="muted small">([\d-]+)<\/div>/gi)];
      const delayed = legs.find(l => l[1]) ?? legs[legs.length - 1];
      const what = strip(row.match(/<div class="what">([\s\S]*?)<\/div>/)?.[1] ?? '');
      const tagText = [...row.matchAll(/<span class="tag[^"]*">([\s\S]*?)<\/span>/gi)].map(m => strip(m[1]));
      const note = strip(row.match(/<div class="note">([\s\S]*?)<\/div>/)?.[1] ?? '');
      const pick = strip(row.match(/<td class="pick">([\s\S]*?)<\/td>/)?.[1] ?? '');
      const tech = strip(row.match(/<td class="tech"><div>([\s\S]*?)<\/div>/)?.[1] ?? '');
      // older reports (v24-v26) name each booking: <div class="login"><span class="k">First</span> Maya</div>
      const rowFirst = strip(row.match(/<span class="k">First<\/span>([\s\S]*?)<\/div>/)?.[1] ?? '');
      const rowLast = strip(row.match(/<span class="k">Last<\/span>([\s\S]*?)<\/div>/)?.[1] ?? '');
      bookings.set(pnr, {
        pnr, ...(rowFirst ? { first: rowFirst } : {}), ...(rowLast ? { last: rowLast } : {}),
        tags: tagsFor(pick, what, tagText, note),
        flight: delayed ? strip(delayed[2]).replace(/\s*delayed\s*$/, '').split(' ')[0] : undefined,
        landed: delayed?.[3], card, caseId: tech || undefined,
        note: [what, pick, note].filter(Boolean).join(' | '),
      });
    }
  }
  // "All bookings" flags: Within 21 days / AC last carrier / Wait elapsed
  for (const tr of html.matchAll(/<tr><td><span class="pnr sm">([A-Z0-9]{6})<\/span><\/td><td class="tech">[^<]*<\/td><td>[^<]*<\/td>((?:<td class="c">[\s\S]*?<\/td>){5})<\/tr>/gi)) {
    const b = bookings.get(tr[1]);
    if (!b) continue;
    const cells = [...tr[2].matchAll(/<td class="c">([\s\S]*?)<\/td>/g)].map(m => strip(m[1]));
    const tags = new Set(b.tags);
    if (cells[2] === 'No') tags.add('outside-21');
    if (cells[3] === 'No') tags.add('partner');
    if (/waiting/i.test(cells[4] ?? '')) tags.add('waiting');
    if (Number(cells[1]) > 1) tags.add('two-journeys');
    b.tags = [...tags].sort();
  }

  const version = dataset?.match(/v\d+$/)?.[0] ?? 'v?';
  const who = path.basename(file).split('-')[0] || 'seed';
  const otp = email && /mailinator\.com$/i.test(email)
    ? { provider: 'mailinator' as const, domain: email.split('@')[1], inbox: email.split('@')[0] }
    : { provider: 'manual' as const, sentTo: email };
  const names = first ? { first: titleCase(first), last: titleCase(rest.join(' ')) } : {};
  const pool: Pool = { dataset, source: path.basename(file), otp, ...names, bookings: [...bookings.values()] };
  return { name: `${who}-${version}`, pool };
}

/** Keep the hand-written comment header of bookings.yaml, rewrite the pools in block style. */
function main(): void {
  const args = process.argv.slice(2);
  const nameAt = args.indexOf('--name');
  const forced = nameAt >= 0 ? args.splice(nameAt, 2)[1] : undefined;
  if (!args.length) { console.error('usage: npm run import-seed -- <seed-report.html> [...] [--name <pool>]'); process.exit(1); }
  const src = fs.existsSync(BOOKINGS_FILE) ? fs.readFileSync(BOOKINGS_FILE, 'utf8') : '';
  const header = src.split(/\r?\n/).filter((l, i, a) => a.slice(0, i + 1).every(x => x.startsWith('#') || !x.trim())).join('\n');
  const pools: Record<string, Pool> = (src && YAML.parse(src)?.pools) || {};
  for (const given of args) {
    // a bare filename comes from the seed-report folder, so the command does not depend on where
    // it is run from; a path with a separator is used as given
    const f = /[\/]/.test(given) ? given : path.join(SEED_REPORTS, given);
    if (!fs.existsSync(f)) {
      console.error(`no such seed report: ${f}${/[\/]/.test(given) ? '' : ' (set AQA_SEED_REPORTS)'}`);
      process.exit(1);
    }
    const { name, pool } = parseSeedReport(fs.readFileSync(f, 'utf8'), f);
    const key = args.length === 1 && forced ? forced : name;
    pools[key] = pool;
    const who = pool.first ? `${pool.first} ${pool.last}` : 'names per booking';
    console.log(`${key}: ${pool.bookings.length} bookings, ${who}, otp=${pool.otp.provider}${'sentTo' in pool.otp && pool.otp.sentTo ? ` (${pool.otp.sentTo})` : ''}`);
  }
  const body = YAML.stringify({ pools }, { lineWidth: 0 });
  fs.writeFileSync(BOOKINGS_FILE, `${header ? header + '\n' : ''}${body}`);
  console.log(`-> ${BOOKINGS_FILE}`);
}

if (require.main === module) main();
