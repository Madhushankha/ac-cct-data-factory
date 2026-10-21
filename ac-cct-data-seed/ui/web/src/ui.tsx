import { createContext, ReactNode, useCallback, useContext, useEffect, useRef, useState } from 'react';

// ---------------------------------------------------------------- routing (hash based, no deps)

export function useRoute(): [string[], URLSearchParams] {
  const read = () => {
    const h = window.location.hash.replace(/^#\/?/, '');
    const [path, query = ''] = h.split('?');
    return [path.split('/').filter(Boolean).map(decodeURIComponent), new URLSearchParams(query)] as [string[], URLSearchParams];
  };
  const [route, setRoute] = useState(read);
  useEffect(() => {
    const on = () => setRoute(read());
    window.addEventListener('hashchange', on);
    return () => window.removeEventListener('hashchange', on);
  }, []);
  return route;
}

export const go = (path: string) => { window.location.hash = path.startsWith('#') ? path : `#${path}`; };

export function Link({ to, children, className }: { to: string; children: ReactNode; className?: string }) {
  return <a href={`#${to}`} className={className}>{children}</a>;
}

// ---------------------------------------------------------------- data loading

export function useLoad<T>(load: () => Promise<T>, deps: unknown[]): {
  data: T | undefined; error: string; loading: boolean; reload: () => void;
} {
  const [data, setData] = useState<T>();
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);
  const [tick, setTick] = useState(0);
  useEffect(() => {
    let live = true;
    setLoading(true);
    load().then(d => { if (live) { setData(d); setError(''); } })
      .catch(e => { if (live) setError(String(e.message || e)); })
      .finally(() => { if (live) setLoading(false); });
    return () => { live = false; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, tick]);
  return { data, error, loading, reload: useCallback(() => setTick(t => t + 1), []) };
}

export function useInterval(fn: () => void, ms: number | null) {
  const saved = useRef(fn);
  saved.current = fn;
  useEffect(() => {
    if (ms === null) return;
    const id = setInterval(() => saved.current(), ms);
    return () => clearInterval(id);
  }, [ms]);
}

// ---------------------------------------------------------------- toasts

type Toast = { id: number; text: string; kind: 'ok' | 'err' };
const ToastCtx = createContext<(text: string, kind?: 'ok' | 'err') => void>(() => {});
export const useToast = () => useContext(ToastCtx);

export function ToastHost({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<Toast[]>([]);
  const push = useCallback((text: string, kind: 'ok' | 'err' = 'ok') => {
    const id = Date.now() + Math.random();
    setToasts(t => [...t, { id, text, kind }]);
    setTimeout(() => setToasts(t => t.filter(x => x.id !== id)), kind === 'err' ? 9000 : 4000);
  }, []);
  return (
    <ToastCtx.Provider value={push}>
      {children}
      <div className="toasts">
        {toasts.map(t => <div key={t.id} className={`toast ${t.kind}`} onClick={() => setToasts(x => x.filter(y => y.id !== t.id))}>{t.text}</div>)}
      </div>
    </ToastCtx.Provider>
  );
}

// ---------------------------------------------------------------- dialogs

export function Modal({ title, onClose, children, wide }: { title: string; onClose: () => void; children: ReactNode; wide?: boolean }) {
  useEffect(() => {
    const on = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', on);
    return () => window.removeEventListener('keydown', on);
  }, [onClose]);
  return (
    <div className="backdrop" onMouseDown={e => { if (e.target === e.currentTarget) onClose(); }}>
      <div className={`modal ${wide ? 'wide' : ''}`} role="dialog" aria-label={title}>
        <div className="modal-head"><h3>{title}</h3><button className="ghost" onClick={onClose} aria-label="Close">✕</button></div>
        {children}
      </div>
    </div>
  );
}

/** A yes/no question that can require typing a word before the danger button unlocks. */
export function Confirm({ title, body, action, danger, typeToConfirm, onConfirm, onClose }: {
  title: string; body: ReactNode; action: string; danger?: boolean; typeToConfirm?: string;
  onConfirm: () => Promise<void> | void; onClose: () => void;
}) {
  const [typed, setTyped] = useState('');
  const [busy, setBusy] = useState(false);
  const ok = !typeToConfirm || typed.trim().toLowerCase() === typeToConfirm.toLowerCase();
  return (
    <Modal title={title} onClose={onClose}>
      <div className="modal-body">{body}</div>
      {typeToConfirm && (
        <label className="field">Type <b>{typeToConfirm}</b> to confirm
          <input autoFocus value={typed} onChange={e => setTyped(e.target.value)} />
        </label>
      )}
      <div className="row end">
        <button className="ghost" onClick={onClose}>Cancel</button>
        <button className={danger ? 'danger' : 'primary'} disabled={!ok || busy}
          onClick={async () => { setBusy(true); try { await onConfirm(); onClose(); } finally { setBusy(false); } }}>
          {busy ? 'Working…' : action}
        </button>
      </div>
    </Modal>
  );
}

export function Prompt({ title, label, initial = '', action, onSubmit, onClose, children }: {
  title: string; label: string; initial?: string; action: string;
  onSubmit: (value: string) => Promise<void> | void; onClose: () => void; children?: ReactNode;
}) {
  const [value, setValue] = useState(initial);
  const [busy, setBusy] = useState(false);
  return (
    <Modal title={title} onClose={onClose}>
      <form onSubmit={async e => { e.preventDefault(); setBusy(true); try { await onSubmit(value.trim()); onClose(); } catch { /* the caller has said why; keep the dialog open */ } finally { setBusy(false); } }}>
        <label className="field">{label}<input autoFocus value={value} onChange={e => setValue(e.target.value)} /></label>
        {children}
        <div className="row end">
          <button type="button" className="ghost" onClick={onClose}>Cancel</button>
          <button className="primary" disabled={!value.trim() || busy}>{busy ? 'Working…' : action}</button>
        </div>
      </form>
    </Modal>
  );
}

// ---------------------------------------------------------------- small pieces

export function Badge({ kind, children }: { kind: string; children: ReactNode }) {
  return <span className={`badge ${kind}`}>{children}</span>;
}

export const STATUS_KIND: Record<string, string> = {
  runnable: 'ok', 'no-verdict': 'warn', blocked: 'err', empty: 'muted', running: 'info', ok: 'ok', findings: 'warn',
  failed: 'err', cancelled: 'muted',
};
/** A set's state as a person reads it. "no-verdict" sets seed; only "blocked" ones cannot. */
export const SET_STATE_TEXT: Record<string, string> = {
  runnable: 'runnable', 'no-verdict': 'seeds, no verdict', blocked: 'blocked', empty: 'empty',
};
export const STATUS_TEXT: Record<string, string> = {
  running: 'running', ok: 'finished', findings: 'finished, some disagree', failed: 'failed', cancelled: 'stopped',
};

export function Empty({ children }: { children: ReactNode }) {
  return <div className="empty">{children}</div>;
}

export function ErrorBox({ error }: { error: string }) {
  return error ? <div className="error-box">{error}</div> : null;
}

export function Loading() {
  return <div className="loading">Loading…</div>;
}

export function when(iso?: string | null) {
  if (!iso) return '';
  const d = new Date(iso);
  return isNaN(+d) ? iso : d.toLocaleString(undefined, { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
}

export function download(name: string, data: unknown) {
  const blob = new Blob([JSON.stringify(data, null, 1)], { type: 'application/json' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = name;
  a.click();
  URL.revokeObjectURL(a.href);
}
