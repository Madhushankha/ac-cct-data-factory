import { api, Job, SetInfo } from '../api';
import { Badge, ErrorBox, Link, Loading, SET_STATE_TEXT, STATUS_KIND, STATUS_TEXT, useInterval, useLoad, useToast, when, go } from '../ui';

interface Overview {
  root: string; sets: SetInfo[];
  flows: { id: string; label: string; sections: string[]; ready: boolean; needs: string[] }[];
  totals: { sets: number; cases: number; runnable: number };
  running: Job[]; recentJobs: Job[]; pools: number;
}

export function Dashboard() {
  const { data, error, reload } = useLoad(() => api.get<Overview>('/api/overview'), []);
  const toast = useToast();
  useInterval(reload, data?.running.length ? 3000 : null);
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;

  const byFlow: Record<string, SetInfo[]> = {};
  data.sets.forEach(s => { (byFlow[s.flow] ||= []).push(s); });

  const run = async (url: string) => {
    try { const j = await api.post<Job>(url, url.includes('doctor') ? { env: 'int' } : {}); go(`/jobs/${j.id}`); }
    catch (e: any) { toast(e.message, 'err'); }
  };

  return (
    <div className="page">
      <div className="page-head">
        <h1>Dashboard</h1>
        <div className="row">
          <button onClick={() => run('/api/jobs/doctor')}>Check environment</button>
          <button onClick={() => run('/api/jobs/tests')}>Run offline tests</button>
          <button className="primary" onClick={() => go('/seed')}>Seed a set</button>
        </div>
      </div>

      <div className="stats">
        <div className="stat"><span>{data.totals.cases}</span>cases</div>
        <div className="stat"><span>{data.totals.sets}</span>sets</div>
        <div className="stat"><span>{data.totals.runnable}</span>runnable sets</div>
        <div className="stat"><span>{data.pools}</span>pools for automation</div>
      </div>

      {data.running.length > 0 && (
        <section className="card">
          <h2>Running now</h2>
          {data.running.map(j => <JobLine key={j.id} job={j} />)}
        </section>
      )}

      <section className="card">
        <h2>Flows and sets</h2>
        <div className="flows">
          {data.flows.map(f => (
            <div key={f.id} className="flow">
              <div className="flow-head">
                <b>{f.label}</b> <span className="muted">{f.id}</span>
                <Badge kind={f.ready ? 'ok' : 'warn'}>{f.ready ? 'claims a verdict' : 'seeds, no verdict yet'}</Badge>
              </div>
              {(byFlow[f.id] || []).map(s => (
                <Link key={s.name} to={`/sets/${s.name}`} className="set-line">
                  <span>{s.phase.toUpperCase()} {s.purpose}</span>
                  <span className="muted">{s.count} cases</span>
                  <Badge kind={STATUS_KIND[s.state]}>{SET_STATE_TEXT[s.state] || s.state}</Badge>
                </Link>
              ))}
              {!byFlow[f.id] && <div className="muted small">no sets yet</div>}
              {!f.ready && <div className="muted small" title={f.needs.join('\n')}>needs: {f.needs[0]}</div>}
            </div>
          ))}
        </div>
      </section>

      <section className="card">
        <div className="row between"><h2>Recent jobs</h2><Link to="/jobs">All jobs</Link></div>
        {data.recentJobs.length ? data.recentJobs.map(j => <JobLine key={j.id} job={j} />)
          : <div className="muted">No jobs yet. Plans, seeds, gates and re-judges show up here.</div>}
      </section>
      <p className="muted small">Project: {data.root}</p>
    </div>
  );
}

export function JobLine({ job }: { job: Job }) {
  return (
    <Link to={`/jobs/${job.id}`} className="job-line">
      <Badge kind={STATUS_KIND[job.status]}>{STATUS_TEXT[job.status]}</Badge>
      <span>{job.title}</span>
      {job.publishes && <Badge kind="err">publishes</Badge>}
      <span className="muted">{when(job.started)}</span>
    </Link>
  );
}
