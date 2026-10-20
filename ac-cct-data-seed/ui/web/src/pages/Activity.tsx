import { api } from '../api';
import { Empty, ErrorBox, Loading, useLoad, when } from '../ui';

export function ActivityPage() {
  const { data, error } = useLoad(() => api.get<Record<string, any>[]>('/api/audit'), []);
  if (error) return <div className="page"><ErrorBox error={error} /></div>;
  if (!data) return <Loading />;
  return (
    <div className="page">
      <div className="page-head"><h1>Activity</h1></div>
      <p className="muted">Every change made through this UI, newest first, from <code>ui/audit.log</code>.</p>
      {data.length ? (
        <div className="table-wrap"><table>
          <thead><tr><th>When</th><th>Who</th><th>What</th><th>Detail</th></tr></thead>
          <tbody>{data.map((a, i) => {
            const { at, user, action, ...rest } = a;
            return <tr key={i}><td>{when(at)}</td><td>{user}</td><td><b>{action}</b></td>
              <td className="small mono">{Object.entries(rest).map(([k, v]) => `${k}=${Array.isArray(v) ? v.join(',') : v}`).join('  ')}</td></tr>;
          })}</tbody>
        </table></div>
      ) : <Empty>Nothing changed through the UI yet.</Empty>}
    </div>
  );
}
