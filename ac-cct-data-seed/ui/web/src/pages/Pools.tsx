import { useState } from 'react';
import { api } from '../api';
import { Badge, Confirm, Empty, ErrorBox, Link, Loading, useLoad, useToast, when, go } from '../ui';

interface PoolRow { file: string; name?: string; updated: string; dataset?: string; seededAt?: string; bookings?: number; error?: string }

export function PoolsPage() {
  const { data, error, reload } = useLoad(() => api.get<{ dir: string; pools: PoolRow[]; trash: string[] }>('/api/pools'), []);
  const [del, setDel] = useState<string | null>(null);
  const toast = useToast();
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;
  return (
    <div className="page">
      <div className="page-head"><h1>Pools</h1></div>
      <p className="muted">A pool is the hand-off to automation: the bookings a seed produced, tagged by state. The Playwright suite picks from every pool in <code>{data.dir}</code>.</p>
      {data.pools.length ? (
        <div className="table-wrap">
          <table>
            <thead><tr><th>Pool</th><th>Dataset</th><th className="num">Bookings</th><th>Seeded</th><th>File</th><th /></tr></thead>
            <tbody>
              {data.pools.map(p => (
                <tr key={`${p.file}-${p.name}`} className="click" onClick={() => go(`/pools/${p.file}`)}>
                  <td><b>{p.name || p.file}</b>{p.error && <div className="err-text small">{p.error}</div>}</td>
                  <td>{p.dataset}</td><td className="num">{p.bookings}</td><td>{when(p.seededAt || p.updated)}</td>
                  <td className="muted small">{p.file}</td>
                  <td onClick={e => e.stopPropagation()}><button className="ghost danger-text" onClick={() => setDel(p.file)}>Delete</button></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : <Empty>No pools yet. Seed with "Hand the bookings to automation" ticked to write one.</Empty>}
      {data.trash.length > 0 && (
        <section className="card">
          <h2>Deleted pools</h2>
          {data.trash.map(t => (
            <div key={t} className="row between line"><span>{t}</span>
              <button onClick={async () => { try { await api.post('/api/pools/restore', { file: t }); toast('Restored'); reload(); } catch (e: any) { toast(e.message, 'err'); } }}>Restore</button>
            </div>
          ))}
        </section>
      )}
      {del && <Confirm title={`Delete pool ${del}`} action="Delete" danger onClose={() => setDel(null)}
        body={<p>Move the file to <code>data/pools/_trash</code>. Automation stops picking these bookings; the bookings themselves stay in the environment.</p>}
        onConfirm={async () => { try { await api.del(`/api/pools/${del}`); toast(`Deleted ${del}`); reload(); } catch (e: any) { toast(e.message, 'err'); } }} />}
    </div>
  );
}

export function PoolView({ file }: { file: string }) {
  const { data, error } = useLoad(() => api.get<{ file: string; pools: { name: string; dataset: string; seededAt: string; bookings: any[] }[] }>(`/api/pools/${file}`), [file]);
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;
  return (
    <div className="page">
      <div className="crumbs"><Link to="/pools">Pools</Link> / {file}</div>
      {data.pools.map(p => (
        <section key={p.name} className="card">
          <h2>{p.name} <span className="muted small">{p.dataset} · seeded {when(p.seededAt)}</span></h2>
          <p className="muted small">{p.bookings.filter(b => b.used).length} of {p.bookings.length} already used by automation runs.</p>
          <div className="table-wrap"><table>
            <thead><tr><th>Locator</th><th>Name</th><th>Case</th><th>Flight</th><th>Date</th><th>Tags</th><th>Used</th></tr></thead>
            <tbody>{p.bookings.map((b, i) => (
              <tr key={i}>
                <td className="mono">{b.pnr}</td><td>{[b.first, b.last].filter(Boolean).join(' ')}</td>
                <td>{b.caseId && <Link to={`/case/${b.caseId}`}>{b.caseId}</Link>}</td><td>{b.flight}</td><td>{b.landed}</td>
                <td>{(b.tags || []).map((t: string) => <Badge key={t} kind="muted">{t}</Badge>)}</td>
                <td>{b.used ? <Badge kind="warn">used</Badge> : ''}</td>
              </tr>
            ))}</tbody>
          </table></div>
        </section>
      ))}
    </div>
  );
}
