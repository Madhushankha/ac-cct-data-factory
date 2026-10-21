import { useEffect, useState } from 'react';
import { api, enc } from '../api';
import { Badge, Empty, ErrorBox, Loading, useInterval, useLoad, when, go } from '../ui';

interface ChatRow {
  n: string; title?: string; booking?: string; state?: string; step?: string; updatedAt?: string; result?: string | null;
  caseId?: string | null; caseNumber?: string | null; pass?: number; fail?: number;
}
interface RunRow {
  run: string; updated: string; running: boolean; chats: ChatRow[]; planned?: number | null; cases?: string[]; flow?: string;
  /** what `npm run evidence` wrote: run<n>.html per test, index.html, evidence.zip */
  evidence?: string[];
}

/** One word per chat for the monitor and the filter. */
const statusOf = (c: ChatRow) => c.state === 'running' ? 'running' : c.state === 'stopped' ? 'stopped'
  : !c.result ? 'finished' : c.result === 'pass' ? 'passed' : c.result.startsWith('blocked') ? 'blocked' : c.result.startsWith('known') ? 'known' : 'failed';
interface Decision { turn: number; at: string; thought?: string; action: string; args?: unknown; outcome?: string }
interface LiveChat {
  run: number; title: string; booking?: string; state: string; step: string; goal?: string; updatedAt: string;
  screenshot?: string; decisions?: Decision[]; messages: { who: string; text: string; buttons?: string[] }[];
  final: { result: string; failures: { step: string; expected: string; got: string }[]; notes: string[]; caseNumber?: string;
           checkpoints?: { n: number; status: string; expected: string; quote: string }[];
           dashboard?: { jiraCheckpoint?: string; api?: string; status: string; check: string }[] } | null;
  files: string[];
}

const fileUrl = (run: string, rel: string, bust = '') => `/api/live/${enc(run)}/file/${rel}${bust ? `?t=${bust}` : ''}`;
const resultKind = (r?: string | null) => !r ? 'muted' : r === 'pass' ? 'ok' : r.startsWith('blocked') || r.startsWith('known') ? 'warn' : 'err';

/** The automation suite's chats as they happen: the screen, the conversation and the AI's decisions. */
export function LivePage({ run, n }: { run?: string; n?: string }) {
  const runs = useLoad(() => api.get<RunRow[]>('/api/live'), []);
  const [flow, setFlow] = useState('');
  const [status, setStatus] = useState('');
  const [q, setQ] = useState('');
  const [open, setOpen] = useState<string | null>(n ?? null);
  useInterval(() => runs.reload(), runs.data?.some(r => r.running) ? 5_000 : 15_000);
  useEffect(() => { if (n) setOpen(n); }, [n]);
  if (runs.error) return <div className="page"><ErrorBox error={runs.error} /></div>;
  if (!runs.data) return <Loading />;
  const visibleRuns = runs.data.filter(r => !flow || r.flow === flow);
  const pickRun = run || visibleRuns.find(r => r.running)?.run || visibleRuns[0]?.run;
  const current = runs.data.find(r => r.run === pickRun);
  const chats = (current?.chats || []).map(c => ({ ...c, caseId: c.caseId || current?.cases?.[Number(c.n) - 1] || null }));
  const shown = chats.filter(c => (!status || statusOf(c) === status)
    && (!q || `${c.caseId} ${c.booking} ${c.title} ${c.caseNumber}`.toLowerCase().includes(q.toLowerCase())));
  const count = (s: string) => chats.filter(c => statusOf(c) === s).length;
  const queued = Math.max(0, (current?.planned ?? 0) - chats.length);
  const done = chats.filter(c => c.state !== 'running').length;
  const total = current?.planned || chats.length;
  return (
    <div className="page">
      <div className="page-head"><h1>Live automation</h1><span className="muted small">refreshes every few seconds</span></div>
      <p className="muted">Chats run by the Playwright suite (<code>ac-cct-data-automation/playwright-baggage/out</code>). Typed one-time codes are masked.</p>
      {!runs.data.length && <Empty>No automation runs yet.</Empty>}
      <section className="card">
        <div className="grid3">
          <label className="field">Run
            <select value={pickRun} onChange={e => go(`/live/${e.target.value}`)}>
              {visibleRuns.map(r => <option key={r.run} value={r.run}>{r.running ? '● ' : ''}{r.run}</option>)}
            </select>
          </label>
          <label className="field">Flow
            <select value={flow} onChange={e => setFlow(e.target.value)}>
              <option value="">All</option>{['fd', 'soc', 'baggage', 'anc'].map(f => <option key={f}>{f}</option>)}
            </select>
          </label>
          <label className="field">Status
            <select value={status} onChange={e => setStatus(e.target.value)}>
              <option value="">All</option>{['running', 'passed', 'failed', 'blocked', 'known', 'stopped'].map(s => <option key={s}>{s}</option>)}
            </select>
          </label>
          <label className="field">Search <input placeholder="case id, PNR, CCD number, title" value={q} onChange={e => setQ(e.target.value)} /></label>
        </div>
      </section>
      {current && (
        <div className="stats">
          <div className="stat"><span>{done}/{total}</span>done</div>
          <div className="stat"><span>{count('running')}</span>running</div>
          <div className="stat"><span>{queued}</span>queued</div>
          <div className="stat ok"><span>{count('passed')}</span>passed</div>
          <div className="stat err"><span>{count('failed')}</span>failed</div>
          <div className="stat"><span>{count('blocked') + count('stopped')}</span>blocked / stopped</div>
        </div>
      )}
      {current && (
        <div className="row wrap toolbar">
          {current.evidence?.includes('index.html') && <a href={fileUrl(current.run, 'evidence/index.html')} target="_blank" rel="noreferrer"><button>Run summary</button></a>}
          {current.evidence?.includes('evidence.zip') && <a href={`${fileUrl(current.run, 'evidence/evidence.zip')}?download=1`}><button className="primary">Download all reports (.zip)</button></a>}
          {!current.evidence?.length && <span className="muted small">No HTML reports yet: run <code>npm run evidence -- out/{current.run}</code> in playwright-baggage.</span>}
        </div>
      )}
      {current && total > 0 && (
        <div style={{ height: 8, background: 'var(--muted-bg)', borderRadius: 4, overflow: 'hidden', margin: '-4px 0 12px' }}>
          <div style={{ width: `${(100 * done) / total}%`, height: '100%', background: 'var(--ok)' }} />
        </div>
      )}
      {current && !chats.length && <Empty>No chat has started in this run yet (preflight first){queued ? `; ${queued} queued` : ''}.</Empty>}
      {shown.map(c => (
        <section key={c.n} className="card" style={{ padding: 0 }}>
          <div className="row between wrap click" style={{ padding: '10px 14px', cursor: 'pointer' }} onClick={() => setOpen(open === c.n ? null : c.n)}>
            <span className="row wrap">
              <b>{open === c.n ? '▾' : '▸'} {c.caseId ?? `run${c.n}`}</b>
              <Badge kind={c.state === 'running' ? 'info' : resultKind(c.result)}>{statusOf(c)}</Badge>
              <span className="muted small">{c.booking}{c.caseNumber ? ` · ${c.caseNumber}` : ''}</span>
            </span>
            <span className="row">
              <span className="muted small">{c.state === 'running' ? c.step : `${c.pass ?? 0} pass · ${c.fail ?? 0} fail`} · {when(c.updatedAt)}</span>
              {current?.evidence?.includes(`run${c.n}.html`) && <a href={`${fileUrl(current.run, `evidence/run${c.n}.html`)}?download=1`} onClick={e => e.stopPropagation()}><button className="ghost">Report ⬇</button></a>}
            </span>
          </div>
          {open === c.n && current && <div style={{ padding: '0 14px 14px' }}><ChatView run={current.run} n={c.n} /></div>}
        </section>
      ))}
    </div>
  );
}

function ChatView({ run, n }: { run: string; n: string }) {
  const { data, error, reload } = useLoad(() => api.get<LiveChat>(`/api/live/${enc(run)}/${n}`), [run, n]);
  const [bust, setBust] = useState(String(Date.now()));
  const live = data?.state === 'running';
  useInterval(() => { reload(); setBust(String(Date.now())); }, live ? 3000 : null);
  useEffect(() => setBust(String(Date.now())), [data?.updatedAt]);
  if (error) return <ErrorBox error={error} />;
  if (!data) return <Loading />;
  const f = data.final;
  const video = data.files.find(x => x.endsWith('.webm'));
  const chatHtml = data.files.find(x => x.startsWith('chat/') && x.endsWith('.html'));
  const steps = data.files.filter(x => /_step\d+\.png$/.test(x));
  const cps = f?.checkpoints || [];
  const count = (s: string) => cps.filter(c => c.status === s).length;
  return (
    <>
      <section className="card">
        <div className="row between wrap">
          <h2>{data.title}</h2>
          <span className="row">
            <Badge kind={live ? 'info' : resultKind(f?.result)}>{live ? 'running' : f?.result ?? data.state}</Badge>
            <span className="muted small">updated {when(data.updatedAt)}</span>
          </span>
        </div>
        <div className="muted small">Booking {data.booking} · now: {data.step}{f?.caseNumber ? ` · case ${f.caseNumber}` : ''}</div>
        {f && (
          <div className="note">
            {cps.length > 0 && <div>Jira checkpoints: <b>{count('pass')}</b> pass, <b>{count('fail')}</b> fail, <b>{count('not_reached')}</b> not reached, <b>{count('unverified')}</b> unverified, of {cps.length}</div>}
            {f.failures.length > 0 && <ul>{f.failures.slice(0, 12).map((x, i) => <li key={i}><b>{x.step}</b>: {x.got}</li>)}</ul>}
            {f.notes.filter(x => /^(dashboard|mail|checkpoints|expected outcome)/.test(x)).map((x, i) => <div key={i} className="small">{x}</div>)}
          </div>
        )}
      </section>
      <div className="grid3" style={{ gridTemplateColumns: 'minmax(280px, 1fr) minmax(280px, 1fr)' }}>
        <section className="card">
          <h3>Screen</h3>
          {data.screenshot ? <a href={fileUrl(run, data.screenshot, bust)} target="_blank" rel="noreferrer">
            <img src={fileUrl(run, data.screenshot, bust)} alt="the chat as the customer sees it" style={{ width: '100%', border: '1px solid var(--line)', borderRadius: 6 }} /></a>
            : <p className="muted">No screenshot yet.</p>}
          <div className="files small">
            {chatHtml && <a href={fileUrl(run, chatHtml)} target="_blank" rel="noreferrer">Full chat (scrollable)</a>}
            {video && <a href={fileUrl(run, video)} target="_blank" rel="noreferrer">Video</a>}
            {steps.length > 0 && <span className="muted">{steps.length} step screenshot(s)</span>}
          </div>
        </section>
        <section className="card">
          <h3>AI decisions ({data.decisions?.length ?? 0})</h3>
          <div className="log" style={{ maxHeight: 420 }}>
            {(data.decisions || []).slice().reverse().map(d => `#${d.turn} ${d.action}${d.outcome && d.outcome !== 'ok' ? ` [${d.outcome}]` : ''}\n   ${d.thought ?? ''}`).join('\n\n') || 'none yet'}
          </div>
        </section>
      </div>
      <section className="card">
        <h3>Conversation ({data.messages.length})</h3>
        <div className="log" style={{ maxHeight: 520 }}>
          {data.messages.filter(m => m.text?.trim() || m.buttons?.length).map(m =>
            `${m.who === 'you' ? 'CUSTOMER' : m.who === 'bot' ? 'ASSISTANT' : 'WIDGET'}: ${m.text?.trim() ?? ''}${m.buttons?.length ? `\n   [${m.buttons.join(' | ')}]` : ''}`).join('\n\n')}
        </div>
      </section>
      {steps.length > 0 && (
        <section className="card">
          <h3>Step by step</h3>
          <div className="row wrap">
            {steps.map(s => <a key={s} href={fileUrl(run, s)} target="_blank" rel="noreferrer">
              <img src={fileUrl(run, s)} alt={s} style={{ width: 160, border: '1px solid var(--line)', borderRadius: 4 }} /></a>)}
          </div>
        </section>
      )}
    </>
  );
}
