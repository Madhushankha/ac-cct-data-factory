import { useEffect, useMemo, useRef, useState } from 'react';
import { api, Env, ENVS, JiraDoc, SetInfo } from '../api';
import { Badge, Confirm, ErrorBox, Link, Loading, Modal, Prompt, useLoad, useToast, go, download } from '../ui';

type Raw = Record<string, any>;

interface CaseResponse {
  id: string; set: string; raw: Raw; problems: string[]; history: string[];
  jira: JiraDoc | null; seeded: Record<Env, { pnrId: string; locator: string; run: string } | null>;
}

// The editable shape of a spec. Anything else in the file (rebooking, vouchers, bags, ttUi...) is
// kept as it is and can be edited on the JSON tab.
type Col = { key: string; label: string; type?: 'num' | 'bool' | 'text'; width?: string; options?: string[] };
const PAX: Col[] = [
  { key: 'firstName', label: 'First name' }, { key: 'lastName', label: 'Last name' },
  { key: 'type', label: 'Type', options: ['ADT', 'CHD', 'INF', 'YTH'] }, { key: 'residence', label: 'Residence', width: '5em' },
  { key: 'dob', label: 'Date of birth' }, { key: 'aeroplanNumber', label: 'Aeroplan #' },
  { key: 'aeroplanTier', label: 'Tier' }, { key: 'employee', label: 'Employee', type: 'bool' },
];
const SEG: Col[] = [
  { key: 'seg', label: 'Seg', type: 'num', width: '4em' }, { key: 'bound', label: 'Bound', type: 'num', width: '4em' },
  { key: 'carrier', label: 'Carrier', width: '4em' }, { key: 'number', label: 'Flight', width: '5em' },
  { key: 'origin', label: 'From', width: '4em' }, { key: 'destination', label: 'To', width: '4em' },
  { key: 'depLocal', label: 'Dep', width: '5em' }, { key: 'arrLocal', label: 'Arr', width: '5em' },
  { key: 'dayOffset', label: '+Day', type: 'num', width: '4em' }, { key: 'cabin', label: 'Cabin', width: '4em' },
  { key: 'bookingClass', label: 'Class', width: '4em' }, { key: 'status', label: 'Status', width: '4em' },
];
const OUT: Col[] = [
  { key: 'seg', label: 'Seg', type: 'num', width: '4em' },
  { key: 'kind', label: 'What happened', options: ['delay', 'cancel', 'divert', 'none'] },
  { key: 'arrDelayMin', label: 'Arr delay (min)', type: 'num' }, { key: 'depDelayMin', label: 'Dep delay (min)', type: 'num' },
  { key: 'delayCode', label: 'Delay code' }, { key: 'cancelCode', label: 'Cancel code' },
  { key: 'noticeHours', label: 'Notice (h)', type: 'num' }, { key: 'divertTo', label: 'Divert to', width: '5em' },
];
const EXPECT: Col[] = [
  { key: 'regime', label: 'Regime', options: ['APPR', 'EU', 'UK', 'US', 'NONE'] },
  { key: 'eligibility', label: 'Eligibility', options: ['ELIGIBLE', 'NOT_ELIGIBLE', 'PENDING'] },
  { key: 'systemCode', label: 'System code' }, { key: 'amount', label: 'Amount', type: 'num' },
  { key: 'currency', label: 'Currency', options: ['CAD', 'EUR', 'GBP', 'USD'] }, { key: 'delayBand', label: 'Delay band' },
  { key: 'delayMin', label: 'Delay (min)', type: 'num' },
  { key: 'control', label: 'Control', options: ['CONTROLLABLE', 'UNCONTROLLABLE', 'SAFETY'] }, { key: 'cause', label: 'Cause code' },
];

const TEMPLATE = (family: string): Raw => ({
  id: '', family, summary: '',
  passengers: [{ firstName: 'TEST', lastName: 'PASSENGER', type: 'ADT', aeroplanNumber: null, aeroplanTier: null, residence: 'CA', employee: false }],
  segments: [{ seg: 1, bound: 1, carrier: 'AC', number: '', origin: '', destination: '', depLocal: '', arrLocal: '', dayOffset: 0, cabin: 'Y', bookingClass: 'Y', status: 'HK' }],
  flightDaysAgo: 10,
  outcomes: [{ seg: 1, kind: 'delay', arrDelayMin: null, depDelayMin: null, delayCode: null, cancelCode: null, noticeHours: null, divertTo: null }],
  rebooking: [], scheduleChanges: [], paxEvents: [], vouchers: [], bags: [],
  expect: { regime: null, eligibility: null, systemCode: null, amount: null, currency: null, delayBand: null, delayMin: null, control: null, cause: null },
});

export function CaseEditor({ id, query }: { id: string; query: URLSearchParams }) {
  const isNew = id === 'new';
  const toast = useToast();
  const loaded = useLoad(() => isNew ? Promise.resolve(null) : api.get<CaseResponse>(`/api/cases/${encodeURIComponent(id)}`), [id]);
  const sets = useLoad(() => api.get<{ sets: SetInfo[] }>('/api/sets'), []);
  const [raw, setRaw] = useState<Raw | null>(null);
  const [setName, setSetName] = useState(query.get('set') || '');
  const [tab, setTab] = useState<'form' | 'json' | 'jira'>('form');
  const [json, setJson] = useState('');
  const [jsonErr, setJsonErr] = useState('');
  const [problems, setProblems] = useState<string[]>([]);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState('');
  const [dirty, setDirty] = useState(false);
  const [dialog, setDialog] = useState<string | null>(null);

  useEffect(() => {
    if (isNew) {
      const flow = (query.get('set') || 'fd').split('/')[0];
      const fam = { fd: 'FD', soc: 'SOC', baggage: 'BAG', anc: 'ANC' }[flow] || flow.toUpperCase();
      const start = TEMPLATE(fam);
      setRaw(start); setJson(JSON.stringify(start, null, 1)); setDirty(false);
    } else if (loaded.data) {
      setRaw(loaded.data.raw); setJson(JSON.stringify(loaded.data.raw, null, 1));
      setSetName(loaded.data.set); setProblems(loaded.data.problems); setDirty(false);
    }
  }, [loaded.data, isNew]);  // eslint-disable-line react-hooks/exhaustive-deps

  // the flow's own check, as the person types
  const timer = useRef<number>();
  useEffect(() => {
    if (!raw || !setName) return;
    window.clearTimeout(timer.current);
    timer.current = window.setTimeout(() => {
      api.post<{ problems: string[] }>('/api/validate', { raw, set: setName }).then(r => setProblems(r.problems)).catch(() => {});
    }, 500);
  }, [raw, setName]);

  useEffect(() => {
    const warn = (e: BeforeUnloadEvent) => { if (dirty) { e.preventDefault(); e.returnValue = ''; } };
    window.addEventListener('beforeunload', warn);
    return () => window.removeEventListener('beforeunload', warn);
  }, [dirty]);

  const update = (next: Raw) => { setRaw(next); setJson(JSON.stringify(next, null, 1)); setJsonErr(''); setDirty(true); };
  const set = (key: string, value: any) => raw && update({ ...raw, [key]: value });

  const fromJson = (text: string) => {
    setJson(text); setDirty(true);
    try { const parsed = JSON.parse(text); if (typeof parsed !== 'object' || Array.isArray(parsed)) throw new Error('must be one JSON object'); setRaw(parsed); setJsonErr(''); }
    catch (e: any) { setJsonErr(e.message); }
  };

  const save = async () => {
    if (!raw || jsonErr) return;
    setSaving(true); setErr('');
    try {
      if (isNew) {
        if (!setName) throw new Error('Choose a set first');
        const r = await api.post<{ id: string }>(`/api/sets/${setName}/cases`, { raw });
        toast(`Created ${r.id}`); setDirty(false); go(`/case/${r.id}`);
      } else {
        const r = await api.put<{ id: string }>(`/api/cases/${encodeURIComponent(id)}`, { raw });
        toast(`Saved ${r.id}`); setDirty(false);
        if (r.id !== id) go(`/case/${r.id}`); else loaded.reload();
      }
    } catch (e: any) { setErr(e.message); } finally { setSaving(false); }
  };

  const bookings = Array.isArray(raw?.bookings);
  const data = loaded.data;
  const title = isNew ? 'New case' : id;

  if (loaded.error) return <div className="page"><ErrorBox error={loaded.error} /></div>;
  if (!raw) return <Loading />;

  return (
    <div className="page">
      <div className="crumbs"><Link to="/sets">Sets</Link> / {setName ? <Link to={`/sets/${setName}`}>{setName}</Link> : 'new'} / {title}</div>
      <div className="page-head">
        <h1>{title} {dirty && <Badge kind="warn">unsaved</Badge>}</h1>
        <div className="row wrap">
          {!isNew && <button onClick={() => go(`/seed?set=${setName}&only=${id}`)}>Seed this case</button>}
          {!isNew && <button onClick={() => setDialog('clone')}>Clone</button>}
          {!isNew && <button onClick={() => setDialog('move')}>Move</button>}
          {!isNew && <button onClick={() => download(`${id}.json`, raw)}>Download</button>}
          {!isNew && <button className="ghost danger-text" onClick={() => setDialog('delete')}>Delete</button>}
          <button className="primary" disabled={saving || !!jsonErr || !dirty && !isNew} onClick={save}>{saving ? 'Saving…' : isNew ? 'Create case' : 'Save'}</button>
        </div>
      </div>

      {isNew && (
        <label className="field narrow">Set
          <select value={setName} onChange={e => setSetName(e.target.value)}>
            <option value="">Choose…</option>
            {(sets.data?.sets || []).map(s => <option key={s.name}>{s.name}</option>)}
          </select>
        </label>
      )}

      <ErrorBox error={err} />
      {problems.length > 0
        ? <div className="note warn"><b>The {setName.split('/')[0]} flow would not run this case as it is:</b><ul>{problems.map(p => <li key={p}>{p}</li>)}</ul></div>
        : setName && <div className="note ok">The {setName.split('/')[0]} flow can run this case.</div>}

      {data && (
        <div className="row wrap seeded">
          {ENVS.map(e => data.seeded[e]
            ? <span key={e}><Badge kind="ok">{e}</Badge> {data.seeded[e]!.locator} <span className="muted small">({data.seeded[e]!.run})</span></span>
            : <span key={e}><Badge kind="muted">{e}</Badge> <span className="muted small">not seeded</span></span>)}
        </div>
      )}

      <div className="tabs">
        <button className={tab === 'form' ? 'on' : ''} onClick={() => setTab('form')}>Form</button>
        <button className={tab === 'json' ? 'on' : ''} onClick={() => setTab('json')}>JSON {jsonErr && <Badge kind="err">invalid</Badge>}</button>
        <button className={tab === 'jira' ? 'on' : ''} onClick={() => setTab('jira')}>Jira {data?.jira ? <span className="muted small">{data.jira.key}</span> : null}</button>
        {data && data.history.length > 0 && <button onClick={() => setDialog('history')}>History ({data.history.length})</button>}
      </div>

      {tab === 'form' && (bookings
        ? <div className="note">This spec holds {raw.bookings.length} bookings in one file. Edit it on the JSON tab.</div>
        : (
          <div className="form">
            <div className="grid3">
              <label className="field">Case id<input value={raw.id || ''} onChange={e => set('id', e.target.value)} placeholder="FD_TC_400" /></label>
              <label className="field">Family<input value={raw.family || ''} onChange={e => set('family', e.target.value)} /></label>
              <label className="field">Flight days ago<input type="number" value={raw.flightDaysAgo ?? ''} onChange={e => set('flightDaysAgo', e.target.value === '' ? null : Number(e.target.value))} /></label>
            </div>
            <label className="field">Summary<textarea rows={2} value={raw.summary || ''} onChange={e => set('summary', e.target.value)} /></label>
            <Rows title="Passengers" cols={PAX} rows={raw.passengers || []} onChange={v => set('passengers', v)}
              blank={{ firstName: '', lastName: '', type: 'ADT', aeroplanNumber: null, aeroplanTier: null, residence: 'CA', employee: false }} />
            <Rows title="Segments" cols={SEG} rows={raw.segments || []} onChange={v => set('segments', v)}
              blank={{ seg: (raw.segments?.length || 0) + 1, bound: 1, carrier: 'AC', number: '', origin: '', destination: '', depLocal: '', arrLocal: '', dayOffset: 0, cabin: 'Y', bookingClass: 'Y', status: 'HK' }} />
            <Rows title="What happened (outcomes)" cols={OUT} rows={raw.outcomes || []} onChange={v => set('outcomes', v)}
              blank={{ seg: 1, kind: 'delay', arrDelayMin: null, depDelayMin: null, delayCode: null, cancelCode: null, noticeHours: null, divertTo: null }} />
            <section className="card">
              <h2>Expected answer</h2>
              <div className="grid3">
                {EXPECT.map(c => (
                  <label key={c.key} className="field">{c.label}
                    <Cell col={c} value={(raw.expect || {})[c.key]} onChange={v => set('expect', { ...(raw.expect || {}), [c.key]: v })} />
                  </label>
                ))}
              </div>
              <OtherKeys raw={raw.expect || {}} known={EXPECT.map(c => c.key)} />
            </section>
            <OtherKeys raw={raw} known={['id', 'family', 'summary', 'flightDaysAgo', 'passengers', 'segments', 'outcomes', 'expect']} top />
          </div>
        ))}

      {tab === 'json' && (
        <div>
          <textarea className="code tall" spellCheck={false} value={json} onChange={e => fromJson(e.target.value)} />
          {jsonErr && <ErrorBox error={`JSON: ${jsonErr}`} />}
        </div>
      )}

      {tab === 'jira' && <JiraPanel doc={data?.jira || null} />}

      {dialog === 'clone' && (
        <ClonePrompt id={id} sets={sets.data?.sets || []} current={setName} onClose={() => setDialog(null)}
          onDone={nid => { toast(`Cloned to ${nid}`); go(`/case/${nid}`); }} />
      )}
      {dialog === 'move' && (
        <MovePrompt id={id} sets={sets.data?.sets || []} current={setName} onClose={() => setDialog(null)}
          onDone={s => { toast(`Moved to ${s}`); loaded.reload(); }} />
      )}
      {dialog === 'delete' && <Confirm title={`Delete ${id}`} action="Delete" danger
        body={<p>Move this case to <code>{setName}/_superseded</code>. It stops being seeded and can be restored from the set page. Bookings already published are not affected.</p>}
        onClose={() => setDialog(null)}
        onConfirm={async () => { try { await api.del(`/api/cases/${encodeURIComponent(id)}`); toast(`Deleted ${id}`); setDirty(false); go(`/sets/${setName}`); } catch (e: any) { toast(e.message, 'err'); } }} />}
      {dialog === 'history' && data && (
        <Modal title={`Saved versions of ${id}`} onClose={() => setDialog(null)}>
          <p className="muted small">Each save keeps the previous text. Reverting saves the current text as a version too.</p>
          {data.history.map(v => (
            <div key={v} className="row between line">
              <span>{v.split('--')[1]?.replace('.json', '')}</span>
              <button onClick={async () => {
                try { await api.post(`/api/cases/${encodeURIComponent(id)}/revert`, { version: v }); toast('Reverted'); setDialog(null); loaded.reload(); }
                catch (e: any) { toast(e.message, 'err'); }
              }}>Revert to this</button>
            </div>
          ))}
        </Modal>
      )}
    </div>
  );
}

function Rows({ title, cols, rows, onChange, blank }: { title: string; cols: Col[]; rows: Raw[]; onChange: (r: Raw[]) => void; blank: Raw }) {
  const extra = useMemo(() => rows.some(r => Object.keys(r).some(k => !cols.find(c => c.key === k))), [rows, cols]);
  return (
    <section className="card">
      <div className="row between"><h2>{title}</h2><button onClick={() => onChange([...rows, { ...blank }])}>Add</button></div>
      {rows.length ? (
        <div className="table-wrap">
          <table className="edit">
            <thead><tr>{cols.map(c => <th key={c.key}>{c.label}</th>)}<th /></tr></thead>
            <tbody>
              {rows.map((r, i) => (
                <tr key={i}>
                  {cols.map(c => (
                    <td key={c.key} style={{ minWidth: c.width }}>
                      <Cell col={c} value={r[c.key]} onChange={v => onChange(rows.map((x, j) => j === i ? { ...x, [c.key]: v } : x))} />
                    </td>
                  ))}
                  <td className="actions">
                    <button className="ghost" title="Copy row" onClick={() => onChange([...rows.slice(0, i + 1), { ...r }, ...rows.slice(i + 1)])}>⧉</button>
                    <button className="ghost danger-text" title="Remove row" onClick={() => onChange(rows.filter((_, j) => j !== i))}>✕</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : <div className="muted">None.</div>}
      {extra && <div className="muted small">Some rows carry more fields than shown here; they are kept, and the JSON tab shows them.</div>}
    </section>
  );
}

function Cell({ col, value, onChange }: { col: Col; value: any; onChange: (v: any) => void }) {
  if (col.type === 'bool') return <input type="checkbox" checked={!!value} onChange={e => onChange(e.target.checked)} />;
  if (col.type === 'num') return <input type="number" value={value ?? ''} onChange={e => onChange(e.target.value === '' ? null : Number(e.target.value))} />;
  const listId = col.options ? `opt-${col.key}` : undefined;
  return (
    <>
      <input list={listId} value={value ?? ''} onChange={e => onChange(e.target.value === '' ? null : e.target.value)} />
      {col.options && <datalist id={listId}>{col.options.map(o => <option key={o} value={o} />)}</datalist>}
    </>
  );
}

function OtherKeys({ raw, known, top }: { raw: Raw; known: string[]; top?: boolean }) {
  const rest = Object.keys(raw).filter(k => !known.includes(k));
  if (!rest.length) return null;
  const summary = rest.map(k => {
    const v = raw[k];
    const n = Array.isArray(v) ? `${v.length} item${v.length === 1 ? '' : 's'}` : v === null ? 'empty' : typeof v === 'object' ? 'set' : String(v).slice(0, 30);
    return `${k}: ${n}`;
  });
  return <div className={`muted small ${top ? 'card' : ''}`}>{top ? 'Also in this spec (edit on the JSON tab): ' : 'More fields: '}{summary.join(' · ')}</div>;
}

function JiraPanel({ doc }: { doc: JiraDoc | null }) {
  if (!doc) return <div className="note">No Jira test is linked to this case id. The Jira page lists coverage gaps per set.</div>;
  return (
    <section className="card">
      <div className="row between">
        <h2>{doc.title}</h2>
        <a href={doc.url} target="_blank" rel="noreferrer">{doc.key} ↗</a>
      </div>
      <p className="muted small">Status {doc.status} · synced {doc.synced_at?.slice(0, 10)}{doc.damaged_characters ? ` · ${doc.damaged_characters} character(s) arrived damaged from Jira` : ''}</p>
      <h3>Goal</h3>
      <p className="pre">{doc.goal || doc.description}</p>
      {doc.prerequisite_items?.length > 0 && (<><h3>Prerequisites</h3><ul>{doc.prerequisite_items.map((p, i) => <li key={i}>{p}</li>)}</ul></>)}
    </section>
  );
}

function ClonePrompt({ id, sets, current, onClose, onDone }: { id: string; sets: SetInfo[]; current: string; onClose: () => void; onDone: (id: string) => void }) {
  const [target, setTarget] = useState(current);
  const toast = useToast();
  return (
    <Prompt title={`Clone ${id}`} label="New case id" initial={`${id}_COPY`} action="Clone" onClose={onClose}
      onSubmit={async v => { try { const r = await api.post<{ id: string }>(`/api/cases/${encodeURIComponent(id)}/clone`, { newId: v, set: target }); onDone(r.id); } catch (e: any) { toast(e.message, 'err'); throw e; } }}>
      <label className="field">Into set<select value={target} onChange={e => setTarget(e.target.value)}>{sets.map(s => <option key={s.name}>{s.name}</option>)}</select></label>
    </Prompt>
  );
}

function MovePrompt({ id, sets, current, onClose, onDone }: { id: string; sets: SetInfo[]; current: string; onClose: () => void; onDone: (s: string) => void }) {
  const [target, setTarget] = useState('');
  const toast = useToast();
  return (
    <Modal title={`Move ${id}`} onClose={onClose}>
      <label className="field">To set
        <select value={target} onChange={e => setTarget(e.target.value)}>
          <option value="">Choose…</option>
          {sets.filter(s => s.name !== current).map(s => <option key={s.name}>{s.name}</option>)}
        </select>
      </label>
      <div className="row end">
        <button className="ghost" onClick={onClose}>Cancel</button>
        <button className="primary" disabled={!target} onClick={async () => {
          try { const r = await api.post<{ set: string }>(`/api/cases/${encodeURIComponent(id)}/move`, { set: target }); onClose(); onDone(r.set); }
          catch (e: any) { toast(e.message, 'err'); }
        }}>Move</button>
      </div>
    </Modal>
  );
}
