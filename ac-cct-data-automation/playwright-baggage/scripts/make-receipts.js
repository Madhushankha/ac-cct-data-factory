// Writes two small one-page PDF receipts into receipts/ (placeholders until the real receipt packs,
// e.g. TestData/<date>/Receipts-bagv77/, are copied in). Dated after the seed sets' arrivals.
const fs = require('node:fs');
const path = require('node:path');
function pdf(lines) {
  const text = lines.map((l, i) => `BT /F1 14 Tf 60 ${740 - i * 22} Td (${l.replace(/[()\\]/g, '\\$&')}) Tj ET`).join('\n');
  const objs = [
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>',
    `<< /Length ${Buffer.byteLength(text)} >>\nstream\n${text}\nendstream`,
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
  ];
  let out = '%PDF-1.4\n'; const offs = [];
  objs.forEach((o, i) => { offs.push(Buffer.byteLength(out)); out += `${i + 1} 0 obj\n${o}\nendobj\n`; });
  const xref = Buffer.byteLength(out);
  out += `xref\n0 ${objs.length + 1}\n0000000000 65535 f \n` + offs.map(o => `${String(o).padStart(10, '0')} 00000 n \n`).join('');
  out += `trailer\n<< /Size ${objs.length + 1} /Root 1 0 R >>\nstartxref\n${xref}\n%%EOF\n`;
  return out;
}
const dir = path.join(__dirname, '..', 'receipts');
fs.mkdirSync(dir, { recursive: true });
fs.writeFileSync(path.join(dir, 'toiletries-receipt.pdf'), pdf(['TEST RECEIPT - QA ONLY', 'Pharmacy YYZ Terminal 1', 'Date: 2026-10-05', 'Toothbrush 6.99', 'Toothpaste 5.49', 'Deodorant 8.99', 'Total CAD 21.47']));
fs.writeFileSync(path.join(dir, 'clothing-receipt.pdf'), pdf(['TEST RECEIPT - QA ONLY', 'Clothing store Toronto', 'Date: 2026-10-05', 'Shirt 80.00', 'Total CAD 80.00']));
console.log('receipts/ written');
