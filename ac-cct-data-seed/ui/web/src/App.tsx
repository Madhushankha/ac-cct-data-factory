import { useState } from 'react';
import { Dashboard } from './pages/Dashboard';
import { SetsPage } from './pages/Sets';
import { SetView } from './pages/SetView';
import { CaseEditor } from './pages/CaseEditor';
import { SeedPage } from './pages/Seed';
import { JobsPage, JobView } from './pages/Jobs';
import { RunsPage, RunView } from './pages/Runs';
import { PoolsPage, PoolView } from './pages/Pools';
import { ReportsPage } from './pages/Reports';
import { JiraPage } from './pages/Jira';
import { ActivityPage } from './pages/Activity';
import { LivePage } from './pages/Live';
import { AwsBanner } from './aws';
import { useRoute } from './ui';

const NAV: [string, string][] = [
  ['', 'Dashboard'], ['sets', 'Sets & cases'], ['seed', 'Seed'], ['jobs', 'Jobs'], ['runs', 'Runs'],
  ['pools', 'Pools'], ['live', 'Live automation'], ['reports', 'Reports'], ['jira', 'Jira'], ['activity', 'Activity'],
];

export function App() {
  const [parts, query] = useRoute();
  const [menu, setMenu] = useState(false);
  const top = parts[0] || '';
  const section = top === 'case' ? 'sets' : top;

  let page;
  switch (top) {
    case '': page = <Dashboard />; break;
    case 'sets': page = parts.length >= 4 ? <SetView name={parts.slice(1, 4).join('/')} /> : <SetsPage />; break;
    case 'case': page = <CaseEditor id={parts[1]} query={query} />; break;
    case 'seed': page = <SeedPage query={query} />; break;
    case 'jobs': page = parts[1] ? <JobView id={parts[1]} /> : <JobsPage />; break;
    case 'runs': page = parts[2] ? <RunView env={parts[1]} label={parts[2]} /> : <RunsPage env={parts[1]} />; break;
    case 'pools': page = parts[1] ? <PoolView file={parts[1]} /> : <PoolsPage />; break;
    case 'reports': page = <ReportsPage />; break;
    case 'jira': page = <JiraPage query={query} />; break;
    case 'activity': page = <ActivityPage />; break;
    case 'live': page = <LivePage run={parts[1]} n={parts[2]} />; break;
    default: page = <div className="page"><h1>Not found</h1></div>;
  }

  return (
    <div className="shell">
      <header className="topbar">
        <button className="ghost menu-btn" onClick={() => setMenu(m => !m)} aria-label="Menu">☰</button>
        <a className="brand" href="#/">CCT Data Seed</a>
        <span className="sub">ac-cct-data-factory</span>
      </header>
      <nav className={`side ${menu ? 'open' : ''}`} onClick={() => setMenu(false)}>
        {NAV.map(([path, label]) => (
          <a key={path} href={`#/${path}`} className={section === path ? 'active' : ''}>{label}</a>
        ))}
      </nav>
      <main><div style={{ padding: '0 24px' }}><AwsBanner /></div>{page}</main>
    </div>
  );
}
