// ──────────────────────────────────────────────────────────────────────────
// export_feeds.js
// Captura os 35 Feeds (1080×1350) do html_portabilidade.html
// e organiza em 7 pastas carrossel_01 ... carrossel_07 (5 feeds cada).
//
// Como rodar (no terminal do Mac, dentro desta pasta):
//   node export_feeds.js
// (puppeteer já foi instalado pelo export_stories.js)
//
// Saída: ./exports_feeds/carrossel_01/feed_01.png ... feed_35.png
// ──────────────────────────────────────────────────────────────────────────

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const HTML_FILE = path.resolve(__dirname, 'html_portabilidade.html');
const OUTPUT_ROOT = path.resolve(__dirname, 'exports_feeds');
const TOTAL = 35;

// Devicepixel ratio 1 → PNG sai exatamente em 1080×1350 (asset nativo de Feed).
const DPR = 1;

(async () => {
  console.log('Lançando Chromium headless...');
  const browser = await puppeteer.launch({
    headless: 'new',
    defaultViewport: { width: 1080, height: 1350, deviceScaleFactor: DPR },
  });

  for (let n = 1; n <= TOTAL; n++) {
    const nStr = String(n).padStart(2, '0');
    const carrossel = String(Math.ceil(n / 5)).padStart(2, '0');
    const outDir = path.join(OUTPUT_ROOT, `carrossel_${carrossel}`);
    fs.mkdirSync(outDir, { recursive: true });
    const outFile = path.join(outDir, `feed_${nStr}.png`);

    const page = await browser.newPage();
    await page.setViewport({ width: 1080, height: 1350, deviceScaleFactor: DPR });

    const url = `file://${HTML_FILE}?export=${n}`;
    await page.goto(url, { waitUntil: 'networkidle0', timeout: 60000 });

    // Garante que TODAS as fontes (Plus Jakarta Sans, 5 pesos) terminaram de carregar
    await page.evaluate(async () => { await document.fonts.ready; });

    // Pequena folga para renderização final (sombras, gradientes, layout)
    await new Promise(r => setTimeout(r, 250));

    await page.screenshot({
      path: outFile,
      clip: { x: 0, y: 0, width: 1080, height: 1350 },
      omitBackground: false,
    });

    console.log(`✓ Feed ${nStr} → carrossel_${carrossel}/feed_${nStr}.png`);
    await page.close();
  }

  await browser.close();
  console.log(`\nPronto. 35 PNGs em ${OUTPUT_ROOT}`);
})().catch(err => {
  console.error('Erro durante export:', err);
  process.exit(1);
});
