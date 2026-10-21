import { useState } from 'react';
import { api } from './api';
import { useInterval, useLoad, useToast } from './ui';

interface AwsState { signedIn: boolean; waiting?: boolean; profile: string; since?: string }

/**
 * "Waiting for AWS sign-in": shown whenever the int-cce session has expired, or a job is paused on it.
 * The button starts `aws sso login` on this machine; the browser opens and the person approves it there.
 */
export function AwsBanner() {
  const s = useLoad(() => api.get<AwsState>('/api/aws'), []);
  const [started, setStarted] = useState(false);
  const toast = useToast();
  useInterval(() => s.reload(), s.data && (!s.data.signedIn || s.data.waiting) ? 10_000 : 120_000);
  if (!s.data || (s.data.signedIn && !s.data.waiting)) return null;
  return (
    <div className="note warn row between wrap">
      <span><b>{s.data.waiting ? 'Waiting for AWS sign-in' : 'AWS sign-in has expired'}</b> — profile <code>{s.data.profile}</code>.
        {' '}{started ? 'A browser tab opened on this PC: approve it there.' : 'Seeding, the automation and S3 need it.'}</span>
      <button className="primary" onClick={async () => {
        try { await api.post('/api/aws/signin', {}); setStarted(true); toast('Sign-in opened in the browser'); } catch (e: any) { toast(e.message, 'err'); }
      }}>Sign in</button>
    </div>
  );
}
