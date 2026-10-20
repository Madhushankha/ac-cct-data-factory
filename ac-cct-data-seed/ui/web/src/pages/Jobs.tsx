import { useEffect, useRef, useState } from 'react';
import { api, Job } from '../api';
import { Badge, Confirm, Empty, ErrorBox, Link, Loading, STATUS_KIND, STATUS_TEXT, useInterval, useLoad, useToast, when, go } from '../ui';

export function JobsPage() {
  const { data, error, reload } = useLoad(() => api.get<Job[]>('/api/jobs'), []);
  useInterval(reload, data?.some(j => j.status === 'running') ? 3000 : null);
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;
  return (
    <div className="page">
      <div className="page-head"><h1>Jobs</h1></div>
      {data.length ? (
        <div className="table-wrap">
          <table>
            <thead><tr><th>Status</th><th>Job</th><th>Started</th><th>Ended</th><th>Command</th></tr></thead>
            <tbody>
              {data.map(j => (
                <tr key={j.id} className="click" onClick={() => go(`/jobs/${j.id}`)}>
                  <td><Badge kind={STATUS_KIND[j.status]}>{STATUS_TEXT[j.status]}</Badge></td>
                  <td><b>{j.title}</b> {j.publishes && <Badge kind="err">publishes</Badge>}</td>
                  <td>{when(j.started)}</td><td>{when(j.ended)}</td>
                  <td className="clip mono small">{j.command}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : <Empty>No jobs yet.</Empty>}
    </div>
  );
}

export function JobView({ id }: { id: string }) {
  const [job, setJob] = useState<Job | null>(null);
  const [log, setLog] = useState('');
  const [err, setErr] = useState('');
  const [stop, setStop] = useState(false);
  const offset = useRef(0);
  const box = useRef<HTMLPreElement>(null);
  const follow = useRef(true);
  const toast = useToast();

  const poll = async () => {
    try {
      const r = await api.get<Job & { log: string; offset: number }>(`/api/jobs/${id}?offset=${offset.current}`);
      offset.current = r.offset;
      setJob(r);
      if (r.log) setLog(l => l + r.log);
    } catch (e: any) { setErr(e.message); }
  };
  useEffect(() => { offset.current = 0; setLog(''); poll(); }, [id]); // eslint-disable-line
  useInterval(poll, job?.status === 'running' ? 1500 : null);
  useEffect(() => { if (follow.current && box.current) box.current.scrollTop = box.current.scrollHeight; }, [log]);

  if (err) return <div className="page"><ErrorBox error={err} /></div>;
  if (!job) return <Loading />;
  const summary = log.match(/summary: (.+)/)?.[1];
  const runLabel = (job.params?.label as string) || summary?.match(/runs[\\/](\w+)[\\/]([^\\/]+)[\\/]_summary/)?.[2];

  return (
    <div className="page">
      <div className="crumbs"><Link to="/jobs">Jobs</Link> / {job.title}</div>
      <div className="page-head">
        <h1>{job.title} <Badge kind={STATUS_KIND[job.status]}>{STATUS_TEXT[job.status]}</Badge></h1>
        <div className="row">
          {job.status === 'running' && <button className="danger" onClick={() => setStop(true)}>Stop</button>}
          {job.kind === 'seed' && runLabel && job.status !== 'running' && <button onClick={() => go(`/runs/${job.params.env}/${runLabel}`)}>Open the run</button>}
          {job.status !== 'running' && <button className="ghost" onClick={async () => { await api.del(`/api/jobs/${id}`); toast('Removed'); go('/jobs'); }}>Remove</button>}
        </div>
      </div>
      <p className="muted small mono">{job.command}</p>
      <p className="muted small">Started {when(job.started)}{job.ended ? ` · ended ${when(job.ended)}` : ''}{job.exitCode != null ? ` · exit code ${job.exitCode}` : ''}</p>
      {job.status === 'findings' && <div className="note warn">The command finished and some cases disagree with what the engine answered. The output below names them.</div>}
      <pre ref={box} className="log" onScroll={e => { const t = e.currentTarget; follow.current = t.scrollTop + t.clientHeight >= t.scrollHeight - 30; }}>{log || ' '}</pre>
      {stop && <Confirm title="Stop this job" action="Stop" danger onClose={() => setStop(false)}
        body={<p>Stop the process now. Anything it already published stays published; a run can be finished later with Gate on the Runs page.</p>}
        onConfirm={async () => { await api.post(`/api/jobs/${id}/cancel`); poll(); }} />}
    </div>
  );
}
