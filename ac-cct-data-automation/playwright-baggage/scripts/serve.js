// Static server for the Ask AC host page. The widget script does not run from file://, and
// `python3 -m http.server` is not on every Windows machine, so this is plain Node with no deps.
//   node scripts/serve.js [dir] [port]      (defaults: CHAT_DIR, resolved in src/external.ts, port 8765)
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(process.argv[2] || process.env.CHAT_DIR || path.join(__dirname, '..', '..', '..', 'public-qa-chat', 'public'));
const port = Number(process.argv[3] || process.env.CHAT_PORT || 8765);

const TYPES = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.css': 'text/css; charset=utf-8',
  '.json': 'application/json', '.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg', '.gif': 'image/gif', '.ico': 'image/x-icon', '.woff': 'font/woff', '.woff2': 'font/woff2',
  '.md': 'text/markdown; charset=utf-8',
};

if (!fs.existsSync(path.join(root, 'index.html'))) {
  console.error(`[serve] no index.html in ${root} (set CHAT_DIR)`);
  process.exit(1);
}

http.createServer((req, res) => {
  let rel = decodeURIComponent((req.url || '/').split('?')[0]);
  if (rel.endsWith('/')) rel += 'index.html';
  const file = path.normalize(path.join(root, rel));
  if (!file.startsWith(root)) { res.writeHead(403).end(); return; }
  fs.readFile(file, (err, buf) => {
    if (err) { res.writeHead(404).end('not found'); return; }
    res.writeHead(200, { 'Content-Type': TYPES[path.extname(file).toLowerCase()] || 'application/octet-stream', 'Cache-Control': 'no-store' });
    res.end(buf);
  });
}).listen(port, '127.0.0.1', () => console.log(`[serve] ${root} -> http://localhost:${port}/index.html`));
