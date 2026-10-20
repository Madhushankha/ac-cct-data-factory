// One place that talks to the Python server. Every call throws an Error carrying the server's own
// message, so a refusal ("FD_TC_118 already exists in fd/uat/automation") reaches the person as is.

export type Env = 'int' | 'crt' | 'bat';
export const ENVS: Env[] = ['int', 'crt', 'bat'];

export interface SetInfo {
  name: string; flow: string; phase: string; purpose: string; label: string; flowLabel: string;
  count: number; state: 'runnable' | 'blocked' | 'empty'; needs: string[]; deleted: number;
}
export interface CaseRow {
  id: string; family?: string; summary?: string; passengers?: number; segments?: number;
  flights?: string; bookings?: number; regime?: string; eligibility?: string; systemCode?: string;
  amount?: number; currency?: string; loyalty?: boolean; error?: string; file?: string;
  set?: string; seeded?: { pnrId: string; locator: string; run: string } | null;
}
export interface Job {
  id: string; kind: string; title: string; status: 'running' | 'ok' | 'findings' | 'failed' | 'cancelled';
  started: string; ended: string | null; exitCode: number | null; publishes: boolean; command: string;
  params: Record<string, unknown>;
}
export interface JiraDoc {
  case_id: string; key: string; status: string; url: string; title: string; goal: string;
  description: string; prerequisite_items: string[]; synced_at: string; damaged_characters: number;
}

async function call<T>(method: string, url: string, body?: unknown): Promise<T> {
  const res = await fetch(url, {
    method,
    headers: body === undefined ? undefined : { 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await res.text();
  let data: any = null;
  try { data = text ? JSON.parse(text) : null; } catch { data = text; }
  if (!res.ok) {
    const detail = data?.detail;
    const msg = typeof detail === 'string' ? detail
      : Array.isArray(detail) ? detail.map((d: any) => `${(d.loc || []).slice(1).join('.')}: ${d.msg}`).join('; ')
      : `${res.status} ${res.statusText}`;
    throw new Error(msg);
  }
  return data as T;
}

export const api = {
  get: <T,>(url: string) => call<T>('GET', url),
  post: <T,>(url: string, body: unknown = {}) => call<T>('POST', url, body),
  put: <T,>(url: string, body: unknown) => call<T>('PUT', url, body),
  del: <T,>(url: string) => call<T>('DELETE', url),
};

export const setUrl = (name: string) => `/api/sets/${name}`;
export const enc = encodeURIComponent;
