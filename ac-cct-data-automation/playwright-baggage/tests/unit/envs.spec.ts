import { test, expect } from '@playwright/test';
import { ENVS, envName, envSettings } from '../../src/envs';
import { dashboardSource } from '../../src/verify';

test('ENV picks the row; older variables still imply it', () => {
  expect(envName({})).toBe('int');
  expect(envName({ ENV: 'BAT' })).toBe('bat');
  expect(envName({ CHAT_URL: 'bat' })).toBe('bat');
  expect(envName({ DASHBOARD_ENV: 'bat' })).toBe('bat');
  expect(() => envName({ ENV: 'prod' })).toThrow(/int or bat/);
});

test('BAT: uat2 behind basic auth named by .env keys, its own dashboard key read as bat-sso, Done-button IDV', () => {
  const bat = envSettings({ ENV: 'bat' });
  expect(bat.chatUrl).toBe('https://uat2.aircanada.com/home/ca/en/aco/trips');
  expect(bat.basicAuth).toEqual({ user: 'UAT2_USER', pass: 'UAT2_PASS' });
  expect(bat.idv).toBe('link-then-done-button');
  expect(dashboardSource('bat')).toEqual({
    url: 'https://claims-dashboard-service.ac-cct-bat.cloud.aircanada.com',
    secret: 'cct-case-mgmt-bat/app-secrets', profile: 'bat-sso' });
  expect(bat.upload.envPath).toBe('bat');
});

test('INT keeps its own host, secret and profile', () => {
  expect(dashboardSource('int')).toEqual({
    url: 'https://claims-dashboard-service.ac-cct-int.cloud.aircanada.com', secret: 'cct-int-secrets', profile: 'int-cce' });
  expect(ENVS.int.basicAuth).toBeUndefined();
  expect(ENVS.int.idv).toBe('link-then-type');
});

test('no secret values in the settings, only names', () => {
  const text = JSON.stringify(ENVS);
  expect(text).not.toMatch(/password|apikey|x-api-key/i);
});
