import { useState } from 'react';
import { api, Env, ENVS, Job } from '../api';
import { Badge, Confirm, Empty, ErrorBox, Link, Loading, Modal, useLoad, useToast, when, go } from '../ui';

interface RunRow {
  label: string; updated: string; kind: 'run' | 'build'; bookings?: number; agree?: number; disagree?: number;
  not_judged?: number; engine?: string; release?: number; records?: number; manifests?: number;
}

export function RunsPage({ env: envParam }: { env?: string }) {
  const env = (ENVS.includes(envParam as Env) ? envParam : 'int') as Env;
  const { data, error, reload } = useLoad(() => api.get<{ runs: RunRow[]; trash: string[]; seeded: number }>(`/api/runs/${env}`), [env]);
  const [del, setDel] = useState<string | null>(null);
  const [filter, setFilter] = useState('');
  const toast = useToast();
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;
  const rows = data.runs.filter(r => !filter || r.label.toLowerCase().includes(filter.toLowerCase()));

  return (
    <div className="page">
      <div className="page-head">
        <h1>Runs</h1>
        <div className="tabs inline-tabs">{ENVS.map(e => <button key={e} className={e === env ? 'on' : ''} onClick={() => go(`/runs/${e}`)}>{e.toUpperCase()}</button>)}</div>
      </div>
      <p className="muted">{data.seeded} case(s) have a booking in {env}. A run holds the engine's documents per booking; a build holds what was published.</p>
      <input className="search" placeholder="Filter runs" value={filter} onChange={e => setFilter(e.target.value)} />
      {rows.length ? (
        <div className="table-wrap">
          <table>
            <thead><tr><th>Run</th><th>Kind</th><th>Updated</th><th className="num">Bookings</th><th className="num">Agree</th><th className="num">Disagree</th><th className="num">Not judged</th><th>Engine</th><th /></tr></thead>
            <tbody>
              {rows.map(r => (
                <tr key={r.label} className="click" onClick={() => go(`/runs/${env}/${r.label}`)}>
                  <td><b>{r.label}</b></td>
                  <td><Badge kind={r.kind === 'build' ? 'muted' : 'info'}>{r.kind}</Badge></td>
                  <td>{when(r.updated)}</td>
                  <td className="num">{r.bookings ?? r.records ?? ''}</td>
                  <td className="num">{r.agree ?? ''}</td>
                  <td className="num">{r.disagree ? <span className="err-text">{r.disagree}</span> : r.disagree ?? ''}</td>
                  <td className="num">{r.not_judged ?? ''}</td>
                  <td>{r.engine ? `${r.engine} ${r.release ?? ''}` : ''}</td>
                  <td onClick={e => e.stopPropagation()}><button className="ghost danger-text" onClick={() => setDel(r.label)}>Delete</button></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : <Empty>No runs in {env}.</Empty>}

      {data.trash.length > 0 && (
        <section className="card">
          <h2>Deleted runs</h2>
          {data.trash.map(t => (
            <div key={t} className="row between line"><span>{t}</span>
              <button onClick={async () => { try { await api.post(`/api/runs/${env}/restore`, { file: t }); toast('Restored'); reload(); } catch (e: any) { toast(e.message, 'err'); } }}>Restore</button>
            </div>
          ))}
        </section>
      )}
      {del && <Confirm title={`Delete run ${del}`} action="Delete" danger onClose={() => setDel(null)}
        body={<p>Move the record to <code>runs/{env}/_trash</code>. The bookings stay in {env}; only this machine forgets the run, so <i>skip already seeded</i> stops counting its cases unless the seeded-history index lists them.</p>}
        onConfirm={async () => { try { await api.del(`/api/runs/${env}/${del}`); toast(`Deleted ${del}`); reload(); } catch (e: any) { toast(e.message, 'err'); } }} />}
    </div>
  );
}

interface RunDetail {
  label: string; env: Env; summary: any;
  cases: { case: string; locator: string; pnrId: string; flight: string; route: string; agrees: boolean | null; disagreements: string[]; file: string }[];
  batches: { path: string; bookings: number; rows: { id: string; pnrId: string; locator: string }[] }[];
}

export function RunView({ env, label }: { env: string; label: string }) {
  const { data, error } = useLoad(() => api.get<RunDetail>(`/api/runs/${env}/${label}`), [env, label]);
  const [dialog, setDialog] = useState<'judge' | 'gate' | null>(null);
  const [doc, setDoc] = useState<{ name: string; body: unknown } | null>(null);
  const [filter, setFilter] = useState<'all' | 'agree' | 'disagree' | 'unjudged'>('all');
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;
  const s = data.summary || {};
  const cases = data.cases.filter(c => filter === 'all' || (filter === 'agree' ? c.agrees === true : filter === 'disagree' ? c.agrees === false && c.disagreements.length : c.agrees == null || (c.agrees === false && !c.disagreements.length)));

  return (
    <div className="page">
      <div className="crumbs"><Link to={`/runs/${env}`}>Runs {env.toUpperCase()}</Link> / {label}</div>
      <div className="page-head">
        <h1>{label}</h1>
        <div className="row">
          {data.cases.length > 0 && <button onClick={() => setDialog('judge')}>Re-judge</button>}
          {data.batches.length > 0 && <button onClick={() => setDialog('gate')}>Gate (read and judge)</button>}
        </div>
      </div>
      {s.bookings != null && (
        <div className="stats">
          <div className="stat"><span>{s.bookings}</span>bookings</div>
          <div className="stat ok"><span>{s.agree}</span>agree</div>
          <div className="stat err"><span>{s.disagree}</span>disagree</div>
          <div className="stat"><span>{s.not_judged}</span>not judged</div>
        </div>
      )}
      {s.engine && <p className="muted small">Engine {s.engine} release {s.release} · written {when(s.written_at)}</p>}

      {data.cases.length > 0 && (
        <section className="card">
          <div className="row between wrap">
            <h2>Bookings</h2>
            <div className="tabs inline-tabs">{(['all', 'agree', 'disagree', 'unjudged'] as const).map(f => <button key={f} className={f === filter ? 'on' : ''} onClick={() => setFilter(f)}>{f}</button>)}</div>
          </div>
          <div className="table-wrap">
            <table>
              <thead><tr><th>Case</th><th>Locator</th><th>Flight</th><th>Route</th><th>Verdict</th><th>Disagreements</th></tr></thead>
              <tbody>
                {cases.map(c => (
                  <tr key={c.file} className="click" onClick={async () => setDoc({ name: c.file, body: await api.get(`/api/runs/${env}/${label}/files/${c.file}`) })}>
                    <td><Link to={`/case/${c.case}`}><b>{c.case}</b></Link></td><td className="mono">{c.locator}</td><td>{c.flight}</td><td>{c.route}</td>
                    <td>{c.agrees === true ? <Badge kind="ok">agrees</Badge> : c.agrees === false && c.disagreements.length ? <Badge kind="err">disagrees</Badge> : <Badge kind="muted">not judged</Badge>}</td>
                    <td className="small">{c.disagreements.join(', ')}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}

      {data.batches.map(b => (
        <section key={b.path} className="card">
          <h2>Batch {b.path.split('/').slice(-1)[0]} <span className="muted small">{b.bookings} booking(s) · {b.path}</span></h2>
          <div className="table-wrap"><table>
            <thead><tr><th>Case</th><th>PNR id</th><th>Locator</th></tr></thead>
            <tbody>{b.rows.map(r => <tr key={r.pnrId || r.id}><td><Link to={`/case/${String(r.id).split('#')[0]}`}>{r.id}</Link></td><td className="mono">{r.pnrId}</td><td className="mono">{r.locator}</td></tr>)}</tbody>
          </table></div>
        </section>
      ))}
      {!data.cases.length && !data.batches.length && <Empty>This run folder holds no booking records or manifests.</Empty>}

      {dialog === 'judge' && <JudgeDialog env={env as Env} run={label} onClose={() => setDialog(null)} />}
      {dialog === 'gate' && <GateDialog env={env as Env} batches={data.batches.map(b => b.path)} onClose={() => setDialog(null)} />}
      {doc && <Modal title={doc.name} wide onClose={() => setDoc(null)}><pre className="log tall">{JSON.stringify(doc.body, null, 1)}</pre></Modal>}
    </div>
  );
}

function JudgeDialog({ env, run, onClose }: { env: Env; run: string; onClose: () => void }) {
  const flows = useLoad(() => api.get<{ id: string }[]>('/api/flows'), []);
  const [flow, setFlow] = useState('fd');
  const [write, setWrite] = useState(false);
  const toast = useToast();
  return (
    <Modal title={`Re-judge ${run}`} onClose={onClose}>
      <p className="muted">Re-applies the current comparator to the stored engine documents. Nothing is read from the engine again.</p>
      <label className="field">Flow policy<select value={flow} onChange={e => setFlow(e.target.value)}>{(flows.data || []).map(f => <option key={f.id}>{f.id}</option>)}</select></label>
      <label className="inline"><input type="checkbox" checked={write} onChange={e => setWrite(e.target.checked)} /> Write the new checks onto the records</label>
      <div className="row end">
        <button className="ghost" onClick={onClose}>Cancel</button>
        <button className="primary" onClick={async () => { try { const j = await api.post<Job>('/api/jobs/judge', { run, env, flow, write }); go(`/jobs/${j.id}`); } catch (e: any) { toast(e.message, 'err'); } }}>Re-judge</button>
      </div>
    </Modal>
  );
}

function GateDialog({ env, batches, onClose }: { env: Env; batches: string[]; onClose: () => void }) {
  const flows = useLoad(() => api.get<{ id: string }[]>('/api/flows'), []);
  const [batch, setBatch] = useState(batches[0]);
  const [flow, setFlow] = useState('fd');
  const [label, setLabel] = useState(`gate-${new Date().toISOString().slice(5, 16).replace(/[-:T]/g, '')}`);
  const toast = useToast();
  return (
    <Modal title="Gate a published batch" onClose={onClose}>
      <p className="muted">Reads and judges bookings that are already published, without publishing again. Needs access to {env}.</p>
      <label className="field">Batch<select value={batch} onChange={e => setBatch(e.target.value)}>{batches.map(b => <option key={b}>{b}</option>)}</select></label>
      <div className="grid3">
        <label className="field">Flow<select value={flow} onChange={e => setFlow(e.target.value)}>{(flows.data || []).map(f => <option key={f.id}>{f.id}</option>)}</select></label>
        <label className="field">Store as run<input value={label} onChange={e => setLabel(e.target.value)} /></label>
      </div>
      <div className="row end">
        <button className="ghost" onClick={onClose}>Cancel</button>
        <button className="primary" onClick={async () => { try { const j = await api.post<Job>('/api/jobs/gate', { batch, label, env, flow }); go(`/jobs/${j.id}`); } catch (e: any) { toast(e.message, 'err'); } }}>Gate</button>
      </div>
    </Modal>
  );
}
