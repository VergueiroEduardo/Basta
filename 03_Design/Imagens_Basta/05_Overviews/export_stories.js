// ──────────────────────────────────────────────────────────────────────────
// export_stories.js
// Captura os 35 Stories (1080×1920) do html_portabilidade_stories.html
// e organiza em 7 pastas carrossel_01 ... carrossel_07 (5 stories cada).
//
// Como rodar (no terminal do Mac, dentro desta pasta):
//   npm install puppeteer
//   node export_stories.js
//
// Saída: ./exports_stories/carrossel_01/story_01.png ... story_35.png
// ──────────────────────────────────────────────────────────────────────────

const puppeteer = require('puppeteer');
const path = require('path');
const fs = require('fs');

const HTML_FILE = path.resolve(__dirname, 'html_portabilidade_stories.html');
const OUTPUT_ROOT = path.resolve(__dirname, 'exports_stories');
const TOTAL = 35;

// Devicepixel ratio 1 → PNG sai exatamente em 1080×1920 (asset nativo de Story).
// Se quiser 2x (3240×3840) para retina, troque para 2.
const DPR = 1;

(async () => {
  console.log('Lançando Chromium headless...');
  const browser = await puppeteer.launch({
    headless: 'new',
    defaultViewport: { width: 1080, height: 1920, deviceScaleFactor: DPR },
  });

  for (let n = 1; n <= TOTAL; n++) {
    const nStr = String(n).padStart(2, '0');
    const carrossel = String(Math.ceil(n / 5)).padStart(2, '0');
    const outDir = path.join(OUTPUT_ROOT, `carrossel_${carrossel}`);
    fs.mkdirSync(outDir, { recursive: true });
    const outFile = path.join(outDir, `story_${nStr}.png`);

    const page = await browser.newPage();
    await page.setViewport({ width: 1080, height: 1920, deviceScaleFactor: DPR });

    const url = `file://${HTML_FILE}?export=${n}`;
    await page.goto(url, { waitUntil: 'networkidle0', timeout: 60000 });

    // Garante que TODAS as fontes (Plus Jakarta Sans, 5 pesos) terminaram de carregar
    await page.evaluate(async () => { await document.fonts.ready; });

    // Pequena folga para renderização final (sombras, gradientes, layout)
    await new Promise(r => setTimeout(r, 250));

    await page.screenshot({
      path: outFile,
      clip: { x: 0, y: 0, width: 1080, height: 1920 },
      omitBackground: false,
    });

    console.log(`✓ Story ${nStr} → carrossel_${carrossel}/story_${nStr}.png`);
    await page.close();
  }

  await browser.close();
  console.log(`\nPronto. 35 PNGs em ${OUTPUT_ROOT}`);
})().catch(err => {
  console.error('Erro durante export:', err);
  process.exit(1);
});
