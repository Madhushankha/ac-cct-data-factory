import { useMemo, useState } from 'react';
import { api, enc } from '../api';
import { Badge, Confirm, Empty, ErrorBox, Loading, useLoad, useToast, when } from '../ui';

interface Report {
  path: string; env: string; set: string; flow: string; phase: string; purpose: string;
  version: number; updated: string; files: string[]; fileCount: number;
}
interface JiraTest {
  case_id: string; key: string; url: string; status: string; priority: string; title: string;
  summary: string; goal: string; description: string; prerequisite_items: string[]; labels: string[];
  gherkin: string; execution: string; executionUrl: string; synced_at: string; damaged_characters: number;
}

const SHOWN = /\.(html|md|json|csv|txt)$/i;
// `int-fd_uat_automation-v4-2026-10-19-lahiru-seeded.html` -> `seeded`
const kindOf = (f: string) => (f.split('/').pop() || f).replace(/\.[^.]+$/, '').split('-').pop() || 'other';
const uniq = (xs: string[]) => [...new Set(xs)].sort();

export function ReportsPage() {
  const { data, error, reload } = useLoad(() => api.get<Report[]>('/api/reports'), []);
  const [del, setDel] = useState<string | null>(null);
  const [env, setEnv] = useState('');
  const [flow, setFlow] = useState('');
  const [phase, setPhase] = useState('');
  const [purpose, setPurpose] = useState('');
  const [kind, setKind] = useState('');
  const [latest, setLatest] = useState(false);
  const [q, setQ] = useState('');
  const [jiraOpen, setJiraOpen] = useState<string | null>(null);
  const toast = useToast();

  const opts = useMemo(() => {
    const rs = data || [];
    return { env: uniq(rs.map(r => r.env)), flow: uniq(rs.map(r => r.flow)), phase: uniq(rs.map(r => r.phase)),
             purpose: uniq(rs.map(r => r.purpose)), kind: uniq(rs.flatMap(r => r.files.filter(f => SHOWN.test(f)).map(kindOf))) };
  }, [data]);

  const shown = useMemo(() => {
    const rs = (data || []).filter(r => (!env || r.env === env) && (!flow || r.flow === flow) && (!phase || r.phase === phase)
      && (!purpose || r.purpose === purpose) && (!kind || r.files.some(f => SHOWN.test(f) && kindOf(f) === kind))
      && (!q || `${r.path} ${r.files.join(' ')}`.toLowerCase().includes(q.toLowerCase())));
    if (!latest) return rs;
    const top = new Map<string, number>();
    rs.forEach(r => top.set(`${r.env}/${r.set}`, Math.max(top.get(`${r.env}/${r.set}`) ?? 0, r.version)));
    return rs.filter(r => r.version === top.get(`${r.env}/${r.set}`));
  }, [data, env, flow, phase, purpose, kind, latest, q]);

  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;
  const filtered = env || flow || phase || purpose || kind || latest || q;
  const pick = (label: string, value: string, set: (v: string) => void, values: string[]) => (
    <label className="field"><span>{label}</span>
      <select value={value} onChange={e => set(e.target.value)}>
        <option value="">All</option>
        {values.map(v => <option key={v} value={v}>{label === 'Environment' ? v.toUpperCase() : v}</option>)}
      </select>
    </label>
  );

  return (
    <div className="page">
      <div className="page-head"><h1>Reports</h1></div>
      <p className="muted">Seed reports, one folder per set and version: <code>reports/&lt;env&gt;/&lt;set&gt;/v&lt;n&gt;</code>. The highest version is current.</p>
      <section className="card">
        <div className="grid3">
          {pick('Environment', env, setEnv, opts.env)}
          {pick('Flow', flow, setFlow, opts.flow)}
          {pick('Phase', phase, setPhase, opts.phase)}
          {pick('Purpose', purpose, setPurpose, opts.purpose)}
          {pick('Report type', kind, setKind, opts.kind)}
          <label className="field"><span>Search</span>
            <input placeholder="path or file name" value={q} onChange={e => setQ(e.target.value)} /></label>
        </div>
        <div className="row between wrap">
          <label className="inline"><input type="checkbox" checked={latest} onChange={e => setLatest(e.target.checked)} /> Latest version only</label>
          <span className="row"><span className="muted small">{shown.length} of {data.length} report(s)</span>
            {filtered && <button className="ghost" onClick={() => { setEnv(''); setFlow(''); setPhase(''); setPurpose(''); setKind(''); setLatest(false); setQ(''); }}>Clear filters</button>}</span>
        </div>
      </section>
      {shown.length ? shown.map(r => (
        <section key={r.path} className="card">
          <div className="row between wrap">
            <h2>{r.env.toUpperCase()} · {r.set} · v{r.version}</h2>
            <span className="row"><span className="muted small">{when(r.updated)} · {r.fileCount} file(s)</span>
              <a href={`/api/reports/zip/${r.path}`} download><button>Download all (.zip)</button></a>
              <button onClick={() => setJiraOpen(jiraOpen === r.path ? null : r.path)}>{jiraOpen === r.path ? 'Hide Jira tests' : 'Jira tests'}</button>
              <button className="ghost danger-text" onClick={() => setDel(r.path)}>Delete</button></span>
          </div>
          <div className="files">
            {r.files.filter(f => SHOWN.test(f) && (!kind || kindOf(f) === kind)).slice(0, 40).map(f => (
              <span key={f} className="inline">
                <a href={`/api/reports/file/${r.path}/${f}`} target="_blank" rel="noreferrer">{f}</a>
                <a href={`/api/reports/file/${r.path}/${f}?download=1`} download title={`Download ${f}`}>⬇</a>
              </span>
            ))}
          </div>
          {jiraOpen === r.path && <JiraTests set={r.set} />}
        </section>
      )) : <Empty>{data.length ? 'No reports match these filters.' : 'No reports.'}</Empty>}
      {del && <Confirm title={`Delete report ${del}`} action="Delete" danger onClose={() => setDel(null)}
        body={<p>Move this report version to a <code>_trash</code> folder beside it.</p>}
        onConfirm={async () => { try { await api.del(`/api/reports/${del}`); toast('Deleted'); reload(); } catch (e: any) { toast(e.message, 'err'); } }} />}
    </div>
  );
}

/** The set's synced Xray tests: description, prerequisites, Cucumber steps and Jira links per case. */
function JiraTests({ set }: { set: string }) {
  const { data, error } = useLoad(() => api.get<JiraTest[]>(`/api/jira/tests?set=${enc(set)}`), [set]);
  const [q, setQ] = useState('');
  const [status, setStatus] = useState('');
  const [open, setOpen] = useState<string | null>(null);
  if (error) return <ErrorBox error={error} />;
  if (!data) return <Loading />;
  if (!data.length) return <div className="note">No Jira tests are synced for <code>{set}</code> (looked in <code>jira/{set}/</code>).</div>;
  const needle = q.toLowerCase();
  const rows = data.filter(t => (!status || t.status === status) && (!needle ||
    [t.case_id, t.key, t.title, t.summary, t.description, t.gherkin, t.execution].join(' ').toLowerCase().includes(needle)));
  return (
    <div>
      <h3>Jira tests for {set}</h3>
      <div className="row wrap toolbar">
        <input className="search grow" placeholder="Search case id, key, description or steps" value={q} onChange={e => setQ(e.target.value)} />
        <select style={{ width: 'auto' }} value={status} onChange={e => setStatus(e.target.value)}>
          <option value="">Any status</option>
          {uniq(data.map(t => t.status).filter(Boolean)).map(s => <option key={s}>{s}</option>)}
        </select>
        <span className="muted small">{rows.length} of {data.length}</span>
      </div>
      <div className="table-wrap">
        <table>
          <thead><tr><th>Case</th><th>Title</th><th>Status</th><th>Jira test</th><th>Execution</th></tr></thead>
          <tbody>
            {rows.map(t => {
              const id = t.key + t.case_id;
              return [
                <tr key={id} className="click" onClick={() => setOpen(open === id ? null : id)}>
                  <td><b>{t.case_id}</b></td>
                  <td className="wide-col">{t.title || t.summary}</td>
                  <td>{t.status && <Badge kind="muted">{t.status}</Badge>}</td>
                  <td><a href={t.url} target="_blank" rel="noreferrer" onClick={e => e.stopPropagation()}>{t.key} ↗</a></td>
                  <td>{t.execution ? <a href={t.executionUrl} target="_blank" rel="noreferrer" onClick={e => e.stopPropagation()}>{t.execution} ↗</a> : <span className="muted">—</span>}</td>
                </tr>,
                open === id && (
                  <tr key={id + ':detail'}><td colSpan={5}><TestDetail t={t} /></td></tr>
                ),
              ];
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function TestDetail({ t }: { t: JiraTest }) {
  return (
    <div>
      <div className="row wrap">
        <a href={t.url} target="_blank" rel="noreferrer">Open {t.key} in Jira ↗</a>
        {t.execution && <a href={t.executionUrl} target="_blank" rel="noreferrer">Open execution {t.execution} ↗</a>}
        {t.priority && <Badge kind="info">{t.priority}</Badge>}
        {t.labels.map(l => <Badge key={l} kind="muted">{l}</Badge>)}
        <span className="muted small">synced {when(t.synced_at)}</span>
        {t.damaged_characters > 0 && <span className="muted small" title="Replacement characters that are already in Jira's stored text">{t.damaged_characters} damaged character(s) from Jira</span>}
      </div>
      {t.summary && <><h3>Summary</h3><div>{t.summary}</div></>}
      <h3>Description</h3>
      {/* the prerequisites are listed below one by one, so only show the goal above them */}
      <div className="pre">{(t.prerequisite_items.length ? t.goal : '') || t.description || <span className="muted">No description.</span>}</div>
      {t.prerequisite_items.length > 0 && <><h3>Prerequisites</h3>
        {/* the items carry Jira's own bullets and dashes, so the list adds none */}
        <ul style={{ listStyle: 'none', paddingLeft: 0 }}>{t.prerequisite_items.map((p, i) => <li key={i}>{p}</li>)}</ul></>}
      <h3>Cucumber steps</h3>
      {t.gherkin ? <div className="log">{t.gherkin}</div> : <p className="muted">No test.feature synced for this test.</p>}
    </div>
  );
}
