// Claim evidence without the chat: the Claims Dashboard verification and the case's e-mails, for chats whose own
// evidence was lost. Usage: npx tsx scripts/claim-evidence.ts <env> <outDir> <CASE_ID>=<CCD>@<inbox> ...
import fs from 'fs';
import path from 'path';
import { fetchVerification, readCaseMail } from '../src/verify';

(async () => {
  const [env, out, ...pairs] = process.argv.slice(2);
  for (const p of pairs) {
    const [caseId, rest] = p.split('='); const [ccd, inbox] = rest.split('@');
    const dir = path.join(out, caseId); fs.mkdirSync(dir, { recursive: true });
    const ver = await fetchVerification(ccd, env, 30_000).catch((e: Error) => ({ error: e.message }));
    const mail = await readCaseMail({ provider: 'mailinator', inbox, own: true } as any, ccd, Date.now() - 6 * 3600_000, 5_000);
    const mails = mail.mails.filter(m => m.body.includes(ccd));
    fs.writeFileSync(path.join(dir, 'dashboard-verification.json'), JSON.stringify(ver, null, 2));
    fs.writeFileSync(path.join(dir, 'claim-emails.json'), JSON.stringify(mails, null, 2));
    console.log(caseId, ccd, 'dashboard:', 'error' in ver ? ver.error : 'ok', '| e-mails quoting the case:', mails.length);
  }
})();
