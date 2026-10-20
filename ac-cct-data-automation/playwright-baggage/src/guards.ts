// Safety stops (guide section 2). Two layers:
//  1. detect(): after every action the runner looks at the latest bot messages; a stop that is showing
//     ends the run unless the scenario explicitly allows that stop.
//  2. assertAllowed(): every click and every typed text goes through here, so a forbidden action throws
//     even if a scenario (or a bug in a step) asks for it.
import type { Message } from './transcript';

export type StopKind = 'payout-country' | 'payment-proceed' | 'manual-review' | 'third-party' | 'receipt-upload';

export interface StopRule {
  kind: StopKind;
  board: string;
  /** recognise it from the bot's text, buttons or form fields */
  match: (m: Pick<Message, 'text' | 'buttons' | 'form'>) => boolean;
  never: string;
}

const has = (list: string[], re: RegExp) => list.some(x => re.test(x));

export const STOPS: StopRule[] = [
  {
    kind: 'payout-country', board: 'GenUC-16a',
    match: m => /in which country will it be deposited|dans quel pays/i.test(m.text) || has(m.form, /^Country\*?$|^Pays\*?$/i),
    never: 'answer the payout country or enter bank details',
  },
  {
    kind: 'payment-proceed', board: 'GenUC-16',
    match: m => has(m.buttons, /^Yes, proceed$|^Oui, continuer$/i),
    never: 'tap "Yes, proceed"',
  },
  {
    kind: 'manual-review', board: 'GenUC-27',
    match: m => /what email address/i.test(m.text) || has(m.form, /^Email address\*?$/i),
    never: 'fill or submit the manual-review email form',
  },
  {
    kind: 'third-party', board: 'GenUC-23',
    match: m => /relationship to the passenger/i.test(m.text) || has(m.buttons, /^Claims company$|^Travel agency$|^A parent, guardian/i),
    never: 'answer the third-party relationship question',
  },
];

/** The receipt upload is not a hard stop, but only scenario-named files may be uploaded. */
export const UPLOAD_BUTTON = /^Upload receipts$|^Téléverser/i;

/**
 * Buttons that must never be tapped, whatever the scenario says.
 *
 * `Yes, proceed` confirms a real payout instruction, so it is refused even to a scenario that
 * names `payment-proceed` in its `allow` list -- an unattended run over 264 bookings must not be
 * able to issue payments by writing one line of YAML.
 *
 * ALLOW_PAYMENT_PROCEED=1 lifts it for one run, for the end-to-end case where the point IS the
 * payment: the claim is submitted, the confirmation email is read and the Claims Dashboard
 * verification API is asked whether the case holds the right money. It is an environment
 * variable, not a scenario field, so it is a decision made per run by the person starting it.
 */
export const FORBIDDEN_TAPS: RegExp[] =
  process.env.ALLOW_PAYMENT_PROCEED === '1' ? [] : [/^Yes, proceed$/i, /^Oui, continuer$/i];
/** Third-party answers are never given. */
export const FORBIDDEN_THIRD_PARTY = /^(Claims company|Travel agency|A parent, guardian)/i;

export class SafetyStopError extends Error {
  constructor(public kind: StopKind | 'forbidden-action', message: string) { super(message); }
}

/** Which stops are visible in these messages (normally: the bot messages since the last action). */
export function detect(messages: Pick<Message, 'who' | 'text' | 'buttons' | 'form'>[]): StopRule[] {
  const bot = messages.filter(m => m.who !== 'you');
  return STOPS.filter(s => bot.some(m => s.match(m)));
}

/** Throw on an action the suite must never take. `allow` = stops the scenario explicitly opts into. */
export function assertAllowed(action: { tap?: string; type?: string; fillLabel?: string }, allow: StopKind[] = []): void {
  // FD automation tests submit their claim on INT on purpose: a run that allows 'payment-proceed' may
  // confirm the payout. Bank/card details stay refused below whatever is allowed.
  if (action.tap && FORBIDDEN_TAPS.some(r => r.test(action.tap!.trim())) && !allow.includes('payment-proceed'))
    throw new SafetyStopError('forbidden-action', `refused to tap "${action.tap}" (GenUC-16: never proceed with a payment)`);
  if (action.tap && FORBIDDEN_THIRD_PARTY.test(action.tap.trim()) && !allow.includes('third-party'))
    throw new SafetyStopError('forbidden-action', `refused to answer the third-party question with "${action.tap}" (GenUC-23)`);
  if (action.fillLabel && /^(Country|Pays)\*?$/i.test(action.fillLabel) && !allow.includes('payout-country'))
    throw new SafetyStopError('forbidden-action', 'refused to fill the payout Country form (GenUC-16a)');
  if (action.fillLabel && /^Email address\*?$/i.test(action.fillLabel) && !allow.includes('manual-review'))
    throw new SafetyStopError('forbidden-action', 'refused to fill the manual-review email form (GenUC-27)');
  if (action.fillLabel && /iban|account number|transit|institution|routing|swift|bank/i.test(action.fillLabel))
    throw new SafetyStopError('forbidden-action', `refused to enter bank details ("${action.fillLabel}")`);
}
