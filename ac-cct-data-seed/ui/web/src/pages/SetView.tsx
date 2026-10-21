import { useMemo, useRef, useState } from 'react';
import { api, CaseRow, Env, ENVS, Identity, IDENTITY_FIELDS, SetInfo } from '../api';
import { Badge, Confirm, download, Empty, ErrorBox, Link, Loading, Modal, Prompt, SET_STATE_TEXT, STATUS_KIND, useLoad, useToast, go } from '../ui';

export function SetView({ name }: { name: string }) {
  const [env, setEnv] = useState<Env>('int');
  const sets = useLoad(() => api.get<{ sets: SetInfo[] }>('/api/sets'), [name]);
  const { data, error, reload } = useLoad(() => api.get<{ cases: CaseRow[] }>(`/api/sets/${name}/cases?env=${env}`), [name, env]);
  const deleted = useLoad(() => api.get<CaseRow[]>(`/api/sets/${name}/deleted`), [name]);
  const [filter, setFilter] = useState('');
  const [picked, setPicked] = useState<Set<string>>(new Set());
  const [dialog, setDialog] = useState<string | null>(null);
  const [target, setTarget] = useState<string>('');
  const toast = useToast();
  const info = sets.data?.sets.find(s => s.name === name);

  const rows = useMemo(() => {
    const f = filter.toLowerCase();
    return (data?.cases || []).filter(c => !f || c.id.toLowerCase().includes(f) || (c.summary || '').toLowerCase().includes(f)
      || (c.systemCode || '').toLowerCase().includes(f) || (c.regime || '').toLowerCase().includes(f));
  }, [data, filter]);

  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;

  const all = rows.length > 0 && rows.every(r => picked.has(r.id));
  const toggle = (id: string) => setPicked(p => { const n = new Set(p); n.has(id) ? n.delete(id) : n.add(id); return n; });
  const chosen = [...picked];
  const seededCount = data.cases.filter(c => c.seeded).length;

  const bulk = async (fn: (id: string) => Promise<unknown>, verb: string) => {
    let ok = 0; const errs: string[] = [];
    for (const id of chosen) { try { await fn(id); ok++; } catch (e: any) { errs.push(`${id}: ${e.message}`); } }
    toast(`${verb} ${ok} case(s)` + (errs.length ? `; ${errs.length} failed` : ''), errs.length ? 'err' : 'ok');
    if (errs.length) console.warn(errs);
    setPicked(new Set()); reload(); deleted.reload(); sets.reload();
  };

  return (
    <div className="page">
      <div className="crumbs"><Link to="/sets">Sets</Link> / {name}</div>
      <div className="page-head">
        <h1>{info?.label || name} {info && <Badge kind={STATUS_KIND[info.state]}>{SET_STATE_TEXT[info.state] || info.state}</Badge>}</h1>
        <div className="row wrap">
          <button className="primary" onClick={() => go(`/case/new?set=${name}`)}>New case</button>
          <button onClick={() => setDialog('import')}>Import JSON</button>
          <button onClick={async () => download(`${name.replace(/\//g, '-')}.json`, await api.get(`/api/sets/${name}/export`))}>Export</button>
          <button onClick={() => go(`/seed?set=${name}`)}>Seed this set</button>
          <button className="ghost" onClick={() => setDialog('rename')}>Rename</button>
          <button className="ghost danger-text" onClick={() => setDialog('archive')}>Archive set</button>
        </div>
      </div>
      {info?.state === 'no-verdict' && <div className="note warn">This set seeds bookings, but the flow cannot claim a verdict on them yet. It still needs:
        <ul>{info.needs.map(n => <li key={n}>{n}</li>)}</ul></div>}
      {info?.state === 'blocked' && <div className="note warn">This set cannot be seeded until the flow has:
        <ul>{info.blocks.map(n => <li key={n}>{n}</li>)}</ul>
        {info.needs.length > info.blocks.length && <>Before it can claim a verdict it also needs:
          <ul>{info.needs.filter(n => !info.blocks.includes(n)).map(n => <li key={n}>{n}</li>)}</ul></>}</div>}

      <IdentityCard set={name} />

      <div className="row wrap toolbar">
        <input className="search" placeholder="Filter by id, summary, regime or system code" value={filter} onChange={e => setFilter(e.target.value)} />
        <label className="inline">Seeded in
          <select value={env} onChange={e => setEnv(e.target.value as Env)}>{ENVS.map(e => <option key={e}>{e}</option>)}</select>
        </label>
        <span className="muted">{seededCount} of {data.cases.length} have a booking in {env}</span>
      </div>

      {chosen.length > 0 && (
        <div className="bulk">
          <b>{chosen.length} selected</b>
          <button onClick={() => go(`/seed?set=${name}&only=${chosen.join(',')}`)}>Seed these</button>
          <button onClick={() => setDialog('move')}>Move to set…</button>
          <button className="danger" onClick={() => setDialog('bulk-delete')}>Delete</button>
          <button className="ghost" onClick={() => setPicked(new Set())}>Clear</button>
        </div>
      )}

      {rows.length ? (
        <div className="table-wrap">
          <table>
            <thead><tr>
              <th><input type="checkbox" checked={all} onChange={() => setPicked(all ? new Set() : new Set(rows.map(r => r.id)))} aria-label="Select all" /></th>
              <th>Case</th><th>Summary</th><th>Flights</th><th>Regime</th><th>Expect</th><th>System code</th><th className="num">Amount</th><th>{env.toUpperCase()}</th>
            </tr></thead>
            <tbody>
              {rows.map(c => (
                <tr key={c.id} className="click" onClick={() => go(`/case/${c.id}`)}>
                  <td onClick={e => e.stopPropagation()}><input type="checkbox" checked={picked.has(c.id)} onChange={() => toggle(c.id)} aria-label={`Select ${c.id}`} /></td>
                  <td><b>{c.id}</b>{c.bookings && c.bookings > 1 ? <span className="muted small"> ×{c.bookings}</span> : null}{c.loyalty && <Badge kind="info">wallet</Badge>}</td>
                  <td className="clip wide-col" title={c.summary}>{c.error ? <span className="err-text">{c.error}</span> : c.summary}</td>
                  <td>{c.flights}</td><td>{c.regime}</td>
                  <td>{c.eligibility && <Badge kind={c.eligibility === 'ELIGIBLE' ? 'ok' : 'muted'}>{c.eligibility}</Badge>}</td>
                  <td>{c.systemCode}</td>
                  <td className="num">{c.amount != null ? `${c.amount} ${c.currency || ''}` : ''}</td>
                  <td>{c.seeded ? <span title={`${c.seeded.pnrId} in ${c.seeded.run}`}>{c.seeded.locator}</span> : <span className="muted">—</span>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : <Empty>{data.cases.length ? 'No case matches the filter.' : 'This set has no cases yet. Add one, or import a JSON file.'}</Empty>}

      {(deleted.data?.length || 0) > 0 && (
        <section className="card">
          <h2>Deleted cases ({deleted.data!.length})</h2>
          <p className="muted small">Kept in <code>{name}/_superseded</code>, which is never seeded. Restore puts a case back.</p>
          {deleted.data!.map(d => (
            <div key={d.file} className="row between line">
              <span><b>{d.id}</b> <span className="muted clip">{d.summary}</span></span>
              <button onClick={async () => {
                try { await api.post(`/api/sets/${name}/restore`, { file: d.file }); toast(`Restored ${d.id}`); reload(); deleted.reload(); }
                catch (e: any) { toast(e.message, 'err'); }
              }}>Restore</button>
            </div>
          ))}
        </section>
      )}

      {dialog === 'import' && <ImportDialog set={name} onClose={() => setDialog(null)} onDone={() => { reload(); sets.reload(); }} />}
      {dialog === 'rename' && info && <Prompt title="Rename set" label={`New purpose for ${info.flow}/${info.phase}/`} initial={info.purpose} action="Rename"
        onClose={() => setDialog(null)}
        onSubmit={async v => { try { const r = await api.post<{ name: string }>(`/api/sets/${name}/rename`, { purpose: v }); toast(`Renamed to ${r.name}`); go(`/sets/${r.name}`); } catch (e: any) { toast(e.message, 'err'); } }} />}
      {dialog === 'archive' && <Confirm title="Archive set" action="Archive" danger typeToConfirm={info?.purpose || 'archive'}
        body={<p>Move <b>{name}</b> and its {data.cases.length} case(s) to <code>spec-attic/archived/</code>, outside the spec tree. It stops being a set and is never seeded, and it can be restored from the Sets page.</p>}
        onClose={() => setDialog(null)}
        onConfirm={async () => { try { await api.del(`/api/sets/${name}`); toast(`Archived ${name}`); go('/sets'); } catch (e: any) { toast(e.message, 'err'); } }} />}
      {dialog === 'bulk-delete' && <Confirm title="Delete cases" action={`Delete ${chosen.length}`} danger
        body={<p>Move {chosen.length} case(s) to this set's <code>_superseded/</code> folder. They stop being seeded and can be restored below. Bookings already published are not affected.</p>}
        onClose={() => setDialog(null)} onConfirm={() => bulk(id => api.del(`/api/cases/${id}`), 'Deleted')} />}
      {dialog === 'move' && (
        <Modal title={`Move ${chosen.length} case(s)`} onClose={() => setDialog(null)}>
          <label className="field">To set
            <select value={target} onChange={e => setTarget(e.target.value)}>
              <option value="">Choose…</option>
              {(sets.data?.sets || []).filter(s => s.name !== name).map(s => <option key={s.name}>{s.name}</option>)}
            </select>
          </label>
          <div className="row end">
            <button className="ghost" onClick={() => setDialog(null)}>Cancel</button>
            <button className="primary" disabled={!target} onClick={async () => { setDialog(null); await bulk(id => api.post(`/api/cases/${id}/move`, { set: target }), 'Moved'); }}>Move</button>
          </div>
        </Modal>
      )}
    </div>
  );
}

/** The contact details and name this set is seeded with unless the Seed form says otherwise. */
function IdentityCard({ set }: { set: string }) {
  const saved = useLoad(() => api.get<Identity>(`/api/sets/${set}/identity`), [set]);
  const [open, setOpen] = useState(false);
  const [f, setF] = useState<Identity | null>(null);
  const [err, setErr] = useState('');
  const toast = useToast();
  const value = f || saved.data;
  const summary = saved.data && IDENTITY_FIELDS.filter(([k]) => saved.data![k]).map(([k]) => saved.data![k]).join(' · ');
  return (
    <section className="card">
      <div className="row between wrap">
        <button className="ghost" onClick={() => setOpen(o => !o)}>{open ? '▾' : '▸'} Customer identity for this set</button>
        <span className="muted small">{summary || 'none saved: the Seed form uses its own defaults'}</span>
      </div>
      {open && value && (
        <>
          <p className="muted small">Saved in <code>spec-attic/identities.json</code> and filled into the Seed form when this set is chosen. Leave a field blank to use the default.</p>
          <div className="grid3">
            {IDENTITY_FIELDS.map(([k, label]) => (
              <label key={k} className="field">{label}
                <input value={value[k]} placeholder={k === 'dob' ? 'YYYY-MM-DD' : ''} onChange={e => setF({ ...value, [k]: e.target.value })} /></label>
            ))}
          </div>
          <ErrorBox error={err} />
          <div className="row end">
            <button className="ghost" disabled={!f} onClick={() => { setF(null); setErr(''); }}>Undo changes</button>
            <button className="primary" disabled={!f} onClick={async () => {
              try { await api.put(`/api/sets/${set}/identity`, f); setF(null); setErr(''); saved.reload(); toast('Identity saved'); }
              catch (e: any) { setErr(e.message); }
            }}>Save identity</button>
          </div>
        </>
      )}
    </section>
  );
}

function ImportDialog({ set, onClose, onDone }: { set: string; onClose: () => void; onDone: () => void }) {
  const [items, setItems] = useState<unknown[]>([]);
  const [names, setNames] = useState<string[]>([]);
  const [text, setText] = useState('');
  const [overwrite, setOverwrite] = useState(false);
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);
  const input = useRef<HTMLInputElement>(null);
  const toast = useToast();

  const readFiles = async (files: FileList | null) => {
    if (!files) return;
    const out: unknown[] = []; const ns: string[] = [];
    for (const f of Array.from(files)) {
      try { out.push(JSON.parse(await f.text())); ns.push(f.name); }
      catch { setErr(`${f.name} is not valid JSON`); return; }
    }
    setErr(''); setItems(out); setNames(ns);
  };

  const submit = async () => {
    let payload = items;
    if (!payload.length && text.trim()) {
      try { payload = [JSON.parse(text)]; } catch { setErr('The pasted text is not valid JSON'); return; }
    }
    if (!payload.length) { setErr('Choose files or paste JSON first'); return; }
    setBusy(true);
    try {
      const r = await api.post<{ imported: string[] }>(`/api/sets/${set}/import`, { items: payload, overwrite });
      toast(`Imported ${r.imported.length} case(s)`); onDone(); onClose();
    } catch (e: any) { setErr(e.message); } finally { setBusy(false); }
  };

  return (
    <Modal title={`Import into ${set}`} onClose={onClose} wide>
      <p className="muted">Spec JSON files, one case each or a list of cases per file. Every case is checked first: if any is refused, nothing is written.</p>
      <div className="row">
        <button onClick={() => input.current?.click()}>Choose files…</button>
        <input ref={input} type="file" accept=".json,application/json" multiple hidden onChange={e => readFiles(e.target.files)} />
        <span className="muted">{names.length ? `${names.length} file(s): ${names.slice(0, 4).join(', ')}${names.length > 4 ? '…' : ''}` : 'or paste below'}</span>
      </div>
      <textarea className="code" rows={10} placeholder='{"id": "FD_TC_400", "family": "FD", ...}' value={text} onChange={e => setText(e.target.value)} disabled={items.length > 0} />
      <label className="inline"><input type="checkbox" checked={overwrite} onChange={e => setOverwrite(e.target.checked)} /> Replace cases with the same id in this set (the old text is kept in history)</label>
      <ErrorBox error={err} />
      <div className="row end">
        <button className="ghost" onClick={onClose}>Cancel</button>
        <button className="primary" disabled={busy} onClick={submit}>{busy ? 'Importing…' : 'Import'}</button>
      </div>
    </Modal>
  );
}
