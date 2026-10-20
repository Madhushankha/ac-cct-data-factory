import { useState } from 'react';
import { api, SetInfo } from '../api';
import { Badge, Confirm, Empty, ErrorBox, Link, Loading, Modal, STATUS_KIND, useLoad, useToast, go } from '../ui';

interface SetsResponse { sets: SetInfo[]; archived: { id: string; flow: string; phase: string; folder: string; count: number }[] }

export function SetsPage() {
  const { data, error, reload } = useLoad(() => api.get<SetsResponse>('/api/sets'), []);
  const flows = useLoad(() => api.get<{ id: string; label: string }[]>('/api/flows'), []);
  const [creating, setCreating] = useState(false);
  const [restoring, setRestoring] = useState<string | null>(null);
  const [q, setQ] = useState('');
  const [hits, setHits] = useState<any[] | null>(null);
  const toast = useToast();

  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;

  const search = async (text: string) => {
    setQ(text);
    if (text.trim().length < 2) { setHits(null); return; }
    try { setHits(await api.get(`/api/search?q=${encodeURIComponent(text)}`)); } catch { setHits([]); }
  };

  return (
    <div className="page">
      <div className="page-head">
        <h1>Sets &amp; cases</h1>
        <button className="primary" onClick={() => setCreating(true)}>New set</button>
      </div>
      <input className="search" placeholder="Find a case by id or summary across every set…" value={q} onChange={e => search(e.target.value)} />
      {hits && (
        <section className="card">
          <h2>{hits.length} match{hits.length === 1 ? '' : 'es'}</h2>
          {hits.map(h => (
            <Link key={h.id} to={`/case/${h.id}`} className="job-line">
              <b>{h.id}</b><span className="muted">{h.set}</span><span className="clip">{h.summary}</span>
            </Link>
          ))}
        </section>
      )}
      <div className="table-wrap">
        <table>
          <thead><tr><th>Set</th><th>Flow</th><th>Phase</th><th>Purpose</th><th className="num">Cases</th><th>State</th><th className="num">Deleted</th></tr></thead>
          <tbody>
            {data.sets.map(s => (
              <tr key={s.name} className="click" onClick={() => go(`/sets/${s.name}`)}>
                <td><b>{s.name}</b></td><td>{s.flowLabel}</td><td>{s.phase}</td><td>{s.purpose}</td>
                <td className="num">{s.count}</td>
                <td><Badge kind={STATUS_KIND[s.state]}>{s.state}</Badge>{s.state === 'blocked' && <div className="muted small clip" title={s.needs.join('\n')}>{s.needs[0]}</div>}</td>
                <td className="num">{s.deleted || ''}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {data.archived.length > 0 && (
        <section className="card">
          <h2>Archived sets</h2>
          {data.archived.map(a => (
            <div key={a.id} className="row between line">
              <span>{a.flow}/{a.phase}/<b>{a.folder}</b> <span className="muted">{a.count} cases</span></span>
              <button onClick={() => setRestoring(a.id)}>Restore</button>
            </div>
          ))}
        </section>
      )}

      {creating && <NewSetDialog flows={flows.data || []} onClose={() => setCreating(false)}
        onDone={name => { toast(`Created ${name}`); go(`/sets/${name}`); }} />}
      {restoring && <Confirm title="Restore set" action="Restore" body={<p>Put <b>{restoring}</b> back as a set?</p>}
        onClose={() => setRestoring(null)}
        onConfirm={async () => {
          try { const r = await api.post<{ name: string }>('/api/sets/restore', { id: restoring }); toast(`Restored ${r.name}`); reload(); }
          catch (e: any) { toast(e.message, 'err'); }
        }} />}
      {!data.sets.length && <Empty>No sets yet. Create one to start adding cases.</Empty>}
    </div>
  );
}

function NewSetDialog({ flows, onClose, onDone }: { flows: { id: string; label: string }[]; onClose: () => void; onDone: (n: string) => void }) {
  const [flow, setFlow] = useState(flows[0]?.id || 'fd');
  const [phase, setPhase] = useState('uat');
  const [purpose, setPurpose] = useState('automation');
  const [err, setErr] = useState('');
  return (
    <Modal title="New set" onClose={onClose}>
      <p className="muted">A set is a folder: <code>spec/&lt;flow&gt;/&lt;phase&gt;/&lt;purpose&gt;</code>. Nothing else registers it.</p>
      <div className="grid3">
        <label className="field">Flow<select value={flow} onChange={e => setFlow(e.target.value)}>{flows.map(f => <option key={f.id} value={f.id}>{f.id} ({f.label})</option>)}</select></label>
        <label className="field">Phase<input list="phases" value={phase} onChange={e => setPhase(e.target.value)} /><datalist id="phases"><option value="uat" /><option value="sit" /><option value="bat" /></datalist></label>
        <label className="field">Purpose<input list="purposes" value={purpose} onChange={e => setPurpose(e.target.value)} /><datalist id="purposes"><option value="automation" /><option value="po" /></datalist></label>
      </div>
      <ErrorBox error={err} />
      <div className="row end">
        <button className="ghost" onClick={onClose}>Cancel</button>
        <button className="primary" onClick={async () => {
          try { const r = await api.post<{ name: string }>('/api/sets', { flow, phase, purpose }); onClose(); onDone(r.name); }
          catch (e: any) { setErr(e.message); }
        }}>Create</button>
      </div>
    </Modal>
  );
}
