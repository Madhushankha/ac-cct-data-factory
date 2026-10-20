import { useState } from 'react';
import { api, JiraDoc, Job } from '../api';
import { Badge, ErrorBox, Link, Loading, useLoad, useToast, go } from '../ui';

interface Coverage { set: string; specs: number; docs: number; aligned: boolean; missingDocs: string[]; missingSpecs: string[]; duplicates: string[] }

export function JiraPage({ query }: { query: URLSearchParams }) {
  const { data, error } = useLoad(() => api.get<Coverage[]>('/api/jira/coverage'), []);
  const [q, setQ] = useState(query.get('q') || '');
  const [hits, setHits] = useState<JiraDoc[] | null>(null);
  const [open, setOpen] = useState<string | null>(null);
  const toast = useToast();
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;

  return (
    <div className="page">
      <div className="page-head">
        <h1>Jira</h1>
        <button onClick={async () => { try { const j = await api.post<Job>('/api/jobs/jira-audit', {}); go(`/jobs/${j.id}`); } catch (e: any) { toast(e.message, 'err'); } }}>Run loyalty audit</button>
      </div>
      <p className="muted">The Xray tests synced into <code>jira/</code>, matched to specs by case id. Both directions are gaps: a spec with no test, and a test nobody can seed.</p>
      <form className="row" onSubmit={async e => { e.preventDefault(); if (q.trim()) setHits(await api.get(`/api/jira/search?q=${encodeURIComponent(q)}`)); }}>
        <input className="search" placeholder='Search what the tests say, e.g. "frozen" or "sister city"' value={q} onChange={e => setQ(e.target.value)} />
        <button>Search</button>
      </form>
      {hits && (
        <section className="card">
          <h2>{hits.length} test(s) mention “{q}”</h2>
          {hits.map(d => (
            <div key={d.key + d.case_id} className="row between line">
              <span><Link to={`/case/${d.case_id}`}><b>{d.case_id}</b></Link> <span className="clip">{d.title}</span></span>
              <a href={d.url} target="_blank" rel="noreferrer">{d.key} ↗</a>
            </div>
          ))}
        </section>
      )}
      <div className="table-wrap">
        <table>
          <thead><tr><th>Set</th><th className="num">Specs</th><th className="num">Jira tests</th><th>Aligned</th><th className="num">Spec, no test</th><th className="num">Test, no spec</th></tr></thead>
          <tbody>
            {data.map(c => (
              <tr key={c.set} className="click" onClick={() => setOpen(open === c.set ? null : c.set)}>
                <td><b>{c.set}</b></td><td className="num">{c.specs}</td><td className="num">{c.docs}</td>
                <td>{c.aligned ? <Badge kind="ok">aligned</Badge> : <Badge kind="warn">gaps</Badge>}</td>
                <td className="num">{c.missingDocs.length || ''}</td><td className="num">{c.missingSpecs.length || ''}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {open && (() => {
        const c = data.find(x => x.set === open)!;
        return (
          <section className="card">
            <h2>{c.set}</h2>
            {c.missingDocs.length > 0 && <><h3>Specs with no Jira test ({c.missingDocs.length})</h3><div className="files">{c.missingDocs.map(i => <Link key={i} to={`/case/${i}`}>{i}</Link>)}</div></>}
            {c.missingSpecs.length > 0 && <><h3>Jira tests with no spec ({c.missingSpecs.length})</h3><div className="files">{c.missingSpecs.map(i => <span key={i}>{i}</span>)}</div>
              <p className="muted small">Create a spec with the same case id to make a test seedable.</p></>}
            {c.duplicates.length > 0 && <><h3>Duplicate test ids</h3><div className="files">{c.duplicates.map(i => <span key={i}>{i}</span>)}</div></>}
            {c.aligned && <p className="muted">Every spec has a test and every test has a spec.</p>}
          </section>
        );
      })()}
    </div>
  );
}
