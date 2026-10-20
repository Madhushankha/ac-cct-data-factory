import { useEffect, useState } from 'react';
import { api, Env, ENVS, Job, SetInfo } from '../api';
import { Badge, Confirm, ErrorBox, Link, Loading, STATUS_KIND, useLoad, useToast, go } from '../ui';

interface Form {
  set: string; env: Env; limit: number; only: string; part: string; skipSeeded: boolean; label: string; runDay: string;
  readBatch: number; batchSize: number; settle: number; email: string; phone: string; firstName: string; lastName: string;
  dob: string; wallet: boolean; pool: boolean; uniqueName: boolean;
}

const START: Form = {
  set: '', env: 'int', limit: 0, only: '', part: '', skipSeeded: true, label: '', runDay: '', readBatch: 100,
  batchSize: 0, settle: 90, email: '', phone: '', firstName: '', lastName: '', dob: '', wallet: false, pool: true, uniqueName: false,
};

export function SeedPage({ query }: { query: URLSearchParams }) {
  const sets = useLoad(() => api.get<{ sets: SetInfo[] }>('/api/sets'), []);
  const [f, setF] = useState<Form>(() => ({ ...START, set: query.get('set') || '', only: query.get('only') || '' }));
  const [confirm, setConfirm] = useState(false);
  const [err, setErr] = useState('');
  const [advanced, setAdvanced] = useState(false);
  const toast = useToast();
  useEffect(() => { setF(x => ({ ...x, set: query.get('set') || x.set, only: query.get('only') ?? x.only })); }, [query.toString()]); // eslint-disable-line

  if (sets.error) return <div className="page"><ErrorBox error={sets.error} /></div>;
  if (!sets.data) return <Loading />;
  const info = sets.data.sets.find(s => s.name === f.set);
  const put = <K extends keyof Form>(k: K, v: Form[K]) => setF(x => ({ ...x, [k]: v }));
  const only = f.only.split(/[\s,]+/).filter(Boolean);
  const count = only.length || (f.limit ? Math.min(f.limit, info?.count || 0) : info?.count || 0);

  const body = (go_: boolean, confirmText = '') => ({
    ...f, only, go: go_, confirm: confirmText,
    limit: Number(f.limit) || 0, readBatch: Number(f.readBatch) || 100, batchSize: Number(f.batchSize) || 0, settle: Number(f.settle) || 0,
  });

  const start = async (kind: 'plan' | 'dry' | 'go', confirmText = '') => {
    setErr('');
    if (!f.set) { setErr('Choose a set'); return; }
    try {
      const j = kind === 'plan'
        ? await api.post<Job>('/api/jobs/plan', { set: f.set, env: f.env, limit: Number(f.limit) || 0, only, part: f.part, skipSeeded: f.skipSeeded, label: f.label, runDay: f.runDay, readBatch: Number(f.readBatch) || 100 })
        : await api.post<Job>('/api/jobs/seed', body(kind === 'go', confirmText));
      toast(`Started: ${j.title}`); go(`/jobs/${j.id}`);
    } catch (e: any) { setErr(e.message); }
  };

  return (
    <div className="page">
      <div className="page-head"><h1>Seed</h1></div>
      <p className="muted">Runs <code>python -m cli plan</code> or <code>seed</code> with these options. A plan and a dry run send nothing. Publishing writes bookings to the environment's topics, which other services read.</p>

      <section className="card">
        <div className="grid3">
          <label className="field">Set
            <select value={f.set} onChange={e => put('set', e.target.value)}>
              <option value="">Choose…</option>
              {sets.data.sets.map(s => <option key={s.name} value={s.name} disabled={!s.count}>{s.name} ({s.count}){s.state === 'blocked' ? ' · no verdict' : ''}</option>)}
            </select>
          </label>
          <label className="field">Environment
            <select value={f.env} onChange={e => put('env', e.target.value as Env)}>{ENVS.map(e => <option key={e}>{e}</option>)}</select>
          </label>
          <label className="field">Run label <input placeholder="default: set + time" value={f.label} onChange={e => put('label', e.target.value)} /></label>
        </div>
        {info && <div className="row wrap"><Badge kind={STATUS_KIND[info.state]}>{info.state}</Badge>{info.state === 'blocked' && <span className="muted small">{info.needs[0]}</span>} <Link to={`/sets/${info.name}`}>Pick cases in the set</Link></div>}
        <label className="field">Only these case ids (comma or space separated; empty means the whole set)
          <textarea rows={2} value={f.only} onChange={e => put('only', e.target.value)} placeholder="FD_TC_001, FD_TC_118" />
        </label>
        <div className="grid3">
          <label className="field">First N cases <input type="number" min={0} value={f.limit} onChange={e => put('limit', Number(e.target.value))} /></label>
          <label className="field">Part (e.g. 2/3) <input value={f.part} onChange={e => put('part', e.target.value)} /></label>
          <label className="field">Run day <input type="date" value={f.runDay} onChange={e => put('runDay', e.target.value)} /></label>
        </div>
        <div className="checks">
          <label className="inline"><input type="checkbox" checked={f.skipSeeded} onChange={e => put('skipSeeded', e.target.checked)} /> Skip cases that already have a booking in {f.env}</label>
          <label className="inline"><input type="checkbox" checked={f.pool} onChange={e => put('pool', e.target.checked)} /> Hand the bookings to automation as a pool</label>
          <label className="inline"><input type="checkbox" checked={f.wallet} onChange={e => put('wallet', e.target.checked)} /> Mint an AC Wallet / Aeroplan member where a case asks (needs the int-cce AWS profile)</label>
          <label className="inline"><input type="checkbox" checked={f.uniqueName} onChange={e => put('uniqueName', e.target.checked)} /> Give each case its own surname</label>
        </div>
      </section>

      <section className="card">
        <button className="ghost" onClick={() => setAdvanced(a => !a)}>{advanced ? '▾' : '▸'} Customer identity and tuning</button>
        {advanced && (
          <>
            <div className="grid3">
              <label className="field">Contact e-mail <input value={f.email} onChange={e => put('email', e.target.value)} /></label>
              <label className="field">Contact phone <input value={f.phone} onChange={e => put('phone', e.target.value)} /></label>
              <label className="field">Date of birth <input placeholder="YYYY-MM-DD" value={f.dob} onChange={e => put('dob', e.target.value)} /></label>
              <label className="field">First name (every passenger) <input value={f.firstName} onChange={e => put('firstName', e.target.value)} /></label>
              <label className="field">Last name (every passenger) <input value={f.lastName} onChange={e => put('lastName', e.target.value)} /></label>
            </div>
            <div className="grid3">
              <label className="field">Batch size (0 = all at once) <input type="number" min={0} value={f.batchSize} onChange={e => put('batchSize', Number(e.target.value))} /></label>
              <label className="field">Settle seconds <input type="number" min={0} value={f.settle} onChange={e => put('settle', Number(e.target.value))} /></label>
              <label className="field">Bookings per read <input type="number" min={1} value={f.readBatch} onChange={e => put('readBatch', Number(e.target.value))} /></label>
            </div>
          </>
        )}
      </section>

      <ErrorBox error={err} />
      <div className="row wrap sticky-actions">
        <span className="muted">{f.set ? `${count} case(s) from ${f.set} on ${f.env}` : 'Choose a set'}</span>
        <span className="grow" />
        <button onClick={() => start('plan')} disabled={!f.set}>Plan (build only)</button>
        <button onClick={() => start('dry')} disabled={!f.set}>Dry run</button>
        <button className="danger" onClick={() => setConfirm(true)} disabled={!f.set}>Seed and publish…</button>
      </div>

      {confirm && (
        <Confirm title={`Publish to ${f.env.toUpperCase()}`} action="Publish" danger typeToConfirm={f.env}
          body={<>
            <p>This builds and publishes <b>{count}</b> booking(s) from <b>{f.set}</b> to <b>{f.env}</b>, then reads and judges what the engine answers.</p>
            <p>Published bookings cannot be taken back from here.{!f.skipSeeded && ' Cases that already have a booking will get a second one.'}</p>
          </>}
          onClose={() => setConfirm(false)} onConfirm={() => start('go', f.env)} />
      )}
    </div>
  );
}
