// Hand a code to a run waiting on the manual OTP provider, or list who is waiting.
//   npm run otp                    list pending requests
//   npm run otp -- WESDIF 123456   deliver the code for booking WESDIF
import fs from 'node:fs';
import path from 'node:path';
import { STATE_DIR, ensureDir } from '../src/config';

const [pnr, code] = process.argv.slice(2);
const req = path.join(STATE_DIR, 'otp-requests');
if (!pnr) {
  const files = fs.existsSync(req) ? fs.readdirSync(req) : [];
  if (!files.length) console.log('no run is waiting for a code');
  for (const f of files) process.stdout.write(fs.readFileSync(path.join(req, f), 'utf8'));
  process.exit(0);
}
if (!/^\d{6}$/.test(code ?? '')) { console.error('usage: npm run otp -- <PNR> <6-digit code>'); process.exit(1); }
fs.writeFileSync(path.join(ensureDir(path.join(STATE_DIR, 'otp-inbox')), `${pnr.toUpperCase()}.txt`), code);
console.log(`code for ${pnr.toUpperCase()} delivered`);
