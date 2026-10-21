// Per-environment settings, in one place. ENV=int|bat picks a row; the older single-purpose variables
// (CHAT_URL, DASHBOARD_ENV, DASHBOARD_URL, DASHBOARD_SECRET_ID, DASHBOARD_PROFILE, MAILINATOR_PROFILE,
// UPLOAD_PROFILE, REPORT_BUCKET) still win where they are set. No secrets here: only the NAMES of the
// .env variables and secrets that hold them.
//
// No imports on purpose: config.ts reads this before anything else exists.

export type EnvName = 'int' | 'bat';

/**
 * TASK_ROLE=1: running inside AWS (an ECS task), where credentials come from the task's own role, not from
 * the laptop's SSO profiles. Every `--profile` flag and fromIni() is dropped then.
 */
export const TASK_ROLE = process.env.TASK_ROLE === '1';
/** `--profile <p>` on a laptop, nothing inside AWS. */
export function profileArgs(profile: string): string[] { return TASK_ROLE ? [] : ['--profile', profile]; }

export interface EnvSettings {
  name: EnvName;
  /** the chat page the AI customer opens */
  chatUrl: string;
  /** .env variable names for the page's HTTP Basic auth, where it has one */
  basicAuth?: { user: string; pass: string };
  /** AWS SSO profile for this env's own account (seeding, the dashboard key) */
  awsProfile: string;
  /** Claims Dashboard testing API host, and the secret that holds its TESTING_CASE_INFO_API_KEY */
  dashboard: { url: string; secret: string; profile: string };
  /** Mailinator: the private domain the seeded inboxes use, and the profile that reads the API token */
  mailinator: { domain: string; profile: string };
  /** report upload: bucket and the env segment of runs/<env>/<flow>/<suite>/<run-id>/ */
  upload: { bucket: string; profile: string; envPath: string };
  /**
   * The identity check (Persona). INT: open the link, close it, say "done" (the INT skip).
   * BAT: click Verify, open the link, close it, then click the chat's Done button (it passes by itself).
   */
  idv: 'link-then-type' | 'link-then-done-button';
}

export const ENVS: Record<EnvName, EnvSettings> = {
  int: {
    name: 'int',
    chatUrl: 'https://cct-chat.ac-cct-int.cloud.aircanada.com/',
    awsProfile: 'int-cce',
    dashboard: { url: 'https://claims-dashboard-service.ac-cct-int.cloud.aircanada.com', secret: 'cct-int-secrets', profile: 'int-cce' },
    mailinator: { domain: 'ae-qa1-aircanada.mailinator.com', profile: 'int-cce' },
    upload: { bucket: 'cct-qa-artifacts-int', profile: 'int-cce', envPath: 'int' },
    idv: 'link-then-type',
  },
  bat: {
    name: 'bat',
    chatUrl: 'https://uat2.aircanada.com/home/ca/en/aco/trips',
    basicAuth: { user: 'UAT2_USER', pass: 'UAT2_PASS' },
    awsProfile: 'bat-sso',
    // BAT's key lives in BAT's own account; reading it as int-cce fails
    dashboard: { url: 'https://claims-dashboard-service.ac-cct-bat.cloud.aircanada.com', secret: 'cct-case-mgmt-bat/app-secrets', profile: 'bat-sso' },
    // the Mailinator token and the report viewer's bucket are INT's for every env
    mailinator: { domain: 'ae-qa1-aircanada.mailinator.com', profile: 'int-cce' },
    upload: { bucket: 'cct-qa-artifacts-int', profile: 'int-cce', envPath: 'bat' },
    idv: 'link-then-done-button',
  },
};

/** ENV, else what an older variable implies (CHAT_URL=bat, DASHBOARD_ENV=bat), else int. */
export function envName(e: NodeJS.ProcessEnv = process.env): EnvName {
  const v = (e.ENV || (e.CHAT_URL === 'bat' ? 'bat' : '') || e.DASHBOARD_ENV || 'int').toLowerCase();
  if (v !== 'int' && v !== 'bat') throw new Error(`ENV=${v}: expected int or bat`);
  return v;
}

export function envSettings(e: NodeJS.ProcessEnv = process.env): EnvSettings {
  return ENVS[envName(e)];
}
