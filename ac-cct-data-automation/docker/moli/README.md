# Moli in Docker

One Moli headless browser per parallel chat, each capped at 512 MB / 0.5 CPU, ports 127.0.0.1:9222-9246.

## Set up (once)

`moli-linux.tar.gz` is Moli **v1.1.18** for Linux x86_64 from
https://github.com/lexmount/moli/releases/tag/v1.1.18, checked against GitHub's published
sha256 `59715fbdb2b016bb9136e1edb59a2a195c0f98459fd06739e17edc62da6a48b1`.

    docker build -t cct-qa/moli:1.1.18 .

## Start / stop / scale

    docker compose up -d                       # all 25 (moli01..moli25 on 9222..9246)
    docker compose up -d moli01 moli02 moli03  # just three
    docker compose down                        # stop and remove them
    docker stats --no-stream | grep moli       # memory per browser

The suite connects with `CDP_PORTS=9222-9246` (one browser per worker; see `playwright-baggage/src/cdp-endpoints.ts`).

## Known limits (2026-10-21)

- **Sites behind HTTP Basic auth (uat2 / BAT) do not load.** Moli does not answer the auth challenge, and request
  interception (`page.route`, Playwright's `httpCredentials`) hangs.
- **Playwright's actionability checks fail on Moli:** `click()` waits for visibility that Moli does not report, and
  `innerText` of buttons comes back empty. A DOM `el.click()` works. The chat harness needs a Moli-aware click/read
  path before full chats run on it.
- The INT chat page itself renders fully (screenshot works, greeting arrives).
