// Keep each chat's screen recording next to its transcript: <run>/videos/run<n>.webm.
// Playwright finishes writing the video only when the page closes, so this closes the page first.
import fs from 'node:fs';
import path from 'node:path';
import type { Page, TestInfo } from '@playwright/test';
import { runDir } from './config';

export async function saveVideo(page: Page, run: number, testInfo?: TestInfo): Promise<string | undefined> {
  const video = page.video();
  if (!video) return undefined;
  try {
    await page.close();
    const dir = path.join(runDir(), 'videos');
    fs.mkdirSync(dir, { recursive: true });
    const file = path.join(dir, `run${run}.webm`);
    await video.saveAs(file);
    await testInfo?.attach(`run${run}.webm`, { path: file, contentType: 'video/webm' }).catch(() => {});
    return file;
  } catch {
    return undefined;
  }
}
