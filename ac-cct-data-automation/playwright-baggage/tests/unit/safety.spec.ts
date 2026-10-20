// Guide section 14: "No run ever passes a safety stop: a unit check walks every scenario's steps."
import { test, expect } from '@playwright/test';
import { assertAllowed, detect, SafetyStopError } from '../../src/guards';
import { loadScenarios, validateScenario, type Scenario } from '../../src/scenario';

for (const s of loadScenarios()) {
  test(`scenario ${s.file} is safe and well-formed`, () => {
    expect(validateScenario(s)).toEqual([]);
  });
}

test('every non-smoke scenario ends at an explicit stop', () => {
  for (const s of loadScenarios()) {
    const last = s.steps.filter(st => !('expect' in st)).pop();
    expect(last && 'stop' in last, `${s.file} must end with a stop step`).toBe(true);
  }
});

test('the walk catches a scenario that taps "Yes, proceed"', () => {
  const bad: Scenario = { id: 'x', title: 'x', first_message: 'hi', steps: [{ tap: 'Yes, proceed' }, { stop: 'end' }] };
  expect(validateScenario(bad).join()).toMatch(/forbidden "Yes, proceed"/);
});

test('the walk catches actions after a stop and third-party answers', () => {
  const bad: Scenario = { id: 'x', title: 'x', first_message: 'hi', steps: [{ stop: 'payout-country' }, { say: 'Canada' }] };
  expect(validateScenario(bad).join()).toMatch(/after stop/);
  const tp: Scenario = { id: 'y', title: 'y', first_message: 'hi', steps: [{ tap: 'Claims company' }] };
  expect(validateScenario(tp).join()).toMatch(/third-party/);
});

test('runtime guard refuses forbidden actions', () => {
  expect(() => assertAllowed({ tap: 'Yes, proceed' })).toThrow(SafetyStopError);
  expect(() => assertAllowed({ fillLabel: 'Country*' })).toThrow(/payout Country/);
  expect(() => assertAllowed({ fillLabel: 'Email address*' })).toThrow(/manual-review/);
  expect(() => assertAllowed({ fillLabel: 'Account number' })).toThrow(/bank/);
  expect(() => assertAllowed({ tap: 'Travel agency' })).toThrow(/third-party/);
  expect(() => assertAllowed({ tap: "Yes, let's start" })).not.toThrow();
  expect(() => assertAllowed({ fillLabel: 'Country*' }, ['payout-country'])).not.toThrow();
});

test('stops are recognised from text, buttons and form fields', () => {
  const m = (text: string, buttons: string[] = [], form: string[] = []) => ({ who: 'bot' as const, text, buttons, form });
  expect(detect([m('Great. In which country will it be deposited?', [], ['Country*'])]).map(s => s.kind)).toEqual(['payout-country']);
  expect(detect([m('Ready to pay?', ['Yes, proceed', 'No'])]).map(s => s.kind)).toEqual(['payment-proceed']);
  expect(detect([m('What email address should we use?', [], ['Email address*'])]).map(s => s.kind)).toEqual(['manual-review']);
  expect(detect([m('What is your relationship to the passenger?', ['Claims company', 'Travel agency'])]).map(s => s.kind)).toEqual(['third-party']);
  expect(detect([m('Has your bag been delivered?', ['Yes, it was delivered!'])])).toEqual([]);
  // the customer's own words never trigger a stop
  expect(detect([{ who: 'you', text: 'in which country will it be deposited', buttons: [], form: [] }])).toEqual([]);
});
