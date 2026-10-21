// Which CDP browser each Playwright worker drives. One Moli `serve` per worker keeps chats apart and
// lets a crashed browser take down one chat, not fifteen.
//
//   CDP_URL=http://127.0.0.1:9222                    every worker shares one endpoint (as before)
//   CDP_URLS=http://127.0.0.1:9222,http://127.0.0.1:9223
//   CDP_PORTS=9222-9236                               http://127.0.0.1:<port>, one per worker
//
// Worker n takes endpoint n (mod the list); if that one does not answer it tries the next ones in
// order. It never falls back to launching Chromium here: on a PC sized for Moli that is what crashes it.

export function cdpEndpoints(e: NodeJS.ProcessEnv = process.env): string[] {
  if (e.CDP_URLS) return e.CDP_URLS.split(',').map(s => s.trim()).filter(Boolean);
  if (e.CDP_PORTS) {
    const host = e.CDP_HOST || '127.0.0.1';
    const out: string[] = [];
    for (const part of e.CDP_PORTS.split(',').map(s => s.trim()).filter(Boolean)) {
      const m = part.match(/^(\d+)(?:-(\d+))?$/);
      if (!m) throw new Error(`CDP_PORTS: "${part}" is not a port or a range like 9222-9236`);
      const a = Number(m[1]), b = Number(m[2] ?? m[1]);
      if (b < a || b - a > 200) throw new Error(`CDP_PORTS: bad range ${part}`);
      for (let p = a; p <= b; p++) out.push(`http://${host}:${p}`);
    }
    return out;
  }
  return e.CDP_URL ? [e.CDP_URL] : [];
}

/** The order a worker tries endpoints in: its own first, then the rest round the list. */
export function endpointOrder(list: string[], workerIndex: number): string[] {
  if (!list.length) return [];
  const start = ((workerIndex % list.length) + list.length) % list.length;
  return [...list.slice(start), ...list.slice(0, start)];
}
