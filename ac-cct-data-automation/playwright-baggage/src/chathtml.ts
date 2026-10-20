// The chat itself, kept as a page you can scroll: the widget's live DOM and its CSS, frozen into a
// standalone HTML file (chat/run<n>.html). Opened in a chat-sized frame it looks and scrolls like the
// real Ask AC window, history and all -- no screenshot stitching.
//
// styled-components inserts its rules through the CSSOM, so the <style> tags are empty: the rules are
// read from document.styleSheets instead. Scripts and inline handlers are dropped, typed values are
// written into the markup (so forms show what was entered), and a six-digit code is masked.
import fs from 'node:fs';
import path from 'node:path';
import type { Page } from '@playwright/test';

export async function saveChatHtml(page: Page, file: string): Promise<boolean> {
  try {
    const snap = await page.evaluate(() => {
      const css: string[] = [];
      for (const sheet of Array.from(document.styleSheets)) {
        try { for (const rule of Array.from(sheet.cssRules)) css.push(rule.cssText); } catch { /* cross-origin sheet */ }
      }
      const root = document.querySelector('#ac-chat-widget-container');
      if (!root) return null;
      // carry typed values into the markup before cloning
      for (const el of Array.from(root.querySelectorAll<HTMLInputElement | HTMLTextAreaElement>('input,textarea'))) {
        const v = /^\s*\d{6}\s*$/.test(el.value) ? '••••••' : el.value;
        if (el instanceof HTMLTextAreaElement) el.textContent = v; else el.setAttribute('value', v);
        if ((el as HTMLInputElement).checked) el.setAttribute('checked', '');
      }
      const clone = root.cloneNode(true) as HTMLElement;
      clone.querySelectorAll('script,iframe,object,embed').forEach(n => n.remove());
      for (const el of Array.from(clone.querySelectorAll('*'))) {
        for (const a of Array.from(el.attributes)) if (/^on/i.test(a.name)) el.removeAttribute(a.name);
        if (el.children.length === 0 && /^\s*\d{6}\s*$/.test(el.textContent || '')) el.textContent = '••••••';
      }
      return { css: css.join('\n'), body: clone.outerHTML, base: location.href };
    });
    if (!snap) return false;
    const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<base href="${snap.base.replace(/"/g, '&quot;')}">
<title>Ask AC chat</title>
<style>${snap.css.replace(/<\/style/gi, '<\\/style')}</style>
<style>
  /* the widget floats in the corner of a page; here it fills the frame */
  html, body { margin: 0; height: 100%; background: #fff; }
  #ac-chat-widget-container { position: static !important; inset: auto !important; width: 100% !important; height: 100% !important; }
  #ac-chat-widget-container > div { position: relative !important; inset: auto !important; width: 100% !important; height: 100% !important;
    max-width: none !important; max-height: none !important; transform: none !important; border-radius: 0 !important; box-shadow: none !important; }
</style></head>
<body>${snap.body}
<script>
  // open at the newest message, as the real widget does
  for (const el of document.querySelectorAll('*')) {
    const s = getComputedStyle(el);
    if (/(auto|scroll)/.test(s.overflowY) && el.scrollHeight > el.clientHeight) el.scrollTop = el.scrollHeight;
  }
</script>
</body></html>`;
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(`${file}.tmp`, html);
    fs.renameSync(`${file}.tmp`, file);
    return true;
  } catch {
    return false;
  }
}
