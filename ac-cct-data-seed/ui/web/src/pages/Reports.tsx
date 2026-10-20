import { useState } from 'react';
import { api } from '../api';
import { Confirm, Empty, ErrorBox, Loading, useLoad, useToast, when } from '../ui';

interface Report { path: string; env: string; set: string; version: number; updated: string; files: string[]; fileCount: number }

export function ReportsPage() {
  const { data, error, reload } = useLoad(() => api.get<Report[]>('/api/reports'), []);
  const [del, setDel] = useState<string | null>(null);
  const toast = useToast();
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;
  return (
    <div className="page">
      <div className="page-head"><h1>Reports</h1></div>
      <p className="muted">Seed reports, one folder per set and version: <code>reports/&lt;env&gt;/&lt;set&gt;/v&lt;n&gt;</code>. The highest version is current.</p>
      {data.length ? data.map(r => (
        <section key={r.path} className="card">
          <div className="row between wrap">
            <h2>{r.env.toUpperCase()} · {r.set} · v{r.version}</h2>
            <span className="row"><span className="muted small">{when(r.updated)} · {r.fileCount} file(s)</span>
              <button className="ghost danger-text" onClick={() => setDel(r.path)}>Delete</button></span>
          </div>
          <div className="files">
            {r.files.filter(f => /\.(html|md|json|csv|txt)$/i.test(f)).slice(0, 40).map(f => (
              <a key={f} href={`/api/reports/file/${r.path}/${f}`} target="_blank" rel="noreferrer">{f}</a>
            ))}
          </div>
        </section>
      )) : <Empty>No reports.</Empty>}
      {del && <Confirm title={`Delete report ${del}`} action="Delete" danger onClose={() => setDel(null)}
        body={<p>Move this report version to a <code>_trash</code> folder beside it.</p>}
        onConfirm={async () => { try { await api.del(`/api/reports/${del}`); toast('Deleted'); reload(); } catch (e: any) { toast(e.message, 'err'); } }} />}
    </div>
  );
}
