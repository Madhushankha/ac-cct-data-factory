import { test, expect } from '@playwright/test';
import { cdpEndpoints, endpointOrder } from '../../src/cdp-endpoints';

test('one endpoint, a list, or a port range', () => {
  expect(cdpEndpoints({})).toEqual([]);
  expect(cdpEndpoints({ CDP_URL: 'http://127.0.0.1:9222' })).toEqual(['http://127.0.0.1:9222']);
  expect(cdpEndpoints({ CDP_URLS: 'http://a:1, http://b:2' })).toEqual(['http://a:1', 'http://b:2']);
  expect(cdpEndpoints({ CDP_PORTS: '9222-9224' })).toEqual(['http://127.0.0.1:9222', 'http://127.0.0.1:9223', 'http://127.0.0.1:9224']);
  expect(cdpEndpoints({ CDP_PORTS: '9222,9300', CDP_HOST: 'moli' })).toEqual(['http://moli:9222', 'http://moli:9300']);
  expect(() => cdpEndpoints({ CDP_PORTS: '9230-9222' })).toThrow(/bad range/);
});

test('each worker starts on its own browser and falls through to the others', () => {
  const l = ['a', 'b', 'c'];
  expect(endpointOrder(l, 0)).toEqual(['a', 'b', 'c']);
  expect(endpointOrder(l, 1)).toEqual(['b', 'c', 'a']);
  expect(endpointOrder(l, 4)).toEqual(['b', 'c', 'a']);   // more workers than browsers: they share
  expect(endpointOrder([], 3)).toEqual([]);
});
