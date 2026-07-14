# Relatório de Execução — Onda 8: Excelência Mobile

**Data:** 26/04/2026 · **Escopo:** Ondas 8a → 8d completas
**Insumo:** `AUDITORIA_RESPONSIVIDADE.md` + `PLANO_MOBILE_EXCELENCIA.md`
**Status:** Concluído com 100% dos critérios DoD verdes
**Princípios:** UX mobile prioritário · zero alteração de texto · reversível via baseline

---

## 1. O que mudou (em resumo)

### Onda 8a — Fixes P0 iOS (zero risco)
- **Inputs com `font-size: 16px`** em mobile (em 02, 03, 04, 05, 16). Em desktop ≥768px volta a 13px (`--fs-sm`). **Elimina o auto-zoom do Safari iOS** ao focar campos.
- **`safe-area-inset` aplicada** em todos os elementos `position: fixed` (`.fab`, `.wa-fab`, `.topbar`) em **17/17 arquivos**. WhatsApp FAB e topbar agora respeitam notch e home indicator do iPhone.
- **`viewport-fit=cover` adicionado em `01_landing`** (faltava). Agora 17/17 telas têm.
- `_components/form.css` é a fonte canônica: `font-size: 16px` mobile, `13px` desktop.

### Onda 8b — Touch targets + hover-only (risco baixo)
- **`.btn--sm`**: min-height 40px → **44px** + padding 10px → 12px. Atende WCAG 2.5.5 e iOS HIG.
- **`.nav-item`** em 12-17: padding `10px 12px` → **`14px 16px`** (~48px de altura). Touch target generoso para sidebar mobile.
- **Hover-guard global** em 12-17: `@media (hover: none) and (pointer: coarse) { *:hover { transform: none !important; box-shadow: none !important; } }`. Em devices touch, estados `:hover` não ficam mais "stuck" depois do tap.
- **`clamp()` em headlines** das telas autenticadas: `.page-title` (24px) virou `clamp(22px, 5vw, 32px)`. Greeting do dashboard `clamp(28px, 6vw, 40px)`. Fontes escalam suavemente em viewports de 320 a 1920px.

### Onda 8c — Padding/breakpoints padronizados (risco médio)
- **`.main` mobile padding** em 13-17: `20px` → **`24px`** (= `--gutter-tablet`). Alinha com 12_dashboard.
- **`.topbar` padding lateral**: `20px` → **`24px`**. Alinha com `.main`.
- **Resultado:** todas as 6 telas autenticadas têm gutter mobile idêntico — 24px lateral, consistente edge-to-content.

### Onda 8d — Polish + validação (zero risco)
- **`overflow-x` no `<html>`**: `hidden` (fallback) + `clip` (modern). Defesa universal contra horizontal scroll em browsers antigos sem perder a vantagem do `clip` (que não bloqueia `position: sticky`).
- **`@media (prefers-reduced-motion)`** elevado para o `_foundation/reset.css` — agora aplica universalmente em qualquer arquivo que carrega Foundation. Atende a11y para usuários sensíveis a movimento.
- **Smoke test estrutural:** 17/17 arquivos íntegros pós-mudanças.

---

## 2. Verificações automatizadas (DoD)

| # | Critério | Verificação | Status |
|---|---|---|:---:|
| 1 | Inputs ≥16px (anti zoom iOS) | grep regex em 5 arquivos | ✓ 5/5 |
| 2 | `env(safe-area-inset)` em fixed elements | 17 arquivos com matches | ✓ 17/17 |
| 3 | `viewport-fit=cover` | meta viewport | ✓ 17/17 |
| 4 | `.btn--sm` ≥44px | min-height token | ✓ |
| 5 | `.nav-item` mobile ≥48px | padding 14px 16px | ✓ 6/6 |
| 6 | Hover-guard `(hover: none)` | media query inserted | ✓ 6/6 |
| 7 | `.main` padding 24px mobile | regex padding | ✓ 6/6 |
| 8 | `clamp()` em headlines app | grep clamp | ✓ 12, 13, 14, 15, 16, 17 |
| 9 | Smoke test estrutural | DOCTYPE/body/html | ✓ 17/17 |
| 10 | `prefers-reduced-motion` | reset.css | ✓ universal |

---

## 3. Resultado quantitativo

| Métrica | Antes Onda 7 | Pós Onda 8 |
|---|---:|---:|
| Bytes totais (17 arquivos) | 604.224 | **599.887** |
| Δ vs baseline original | — | **−4.337 bytes (−0,72%)** |
| Tokens órfãos | 0 | **0** |
| Telas com `<h1>` | 17 | **17** |
| Telas com Foundation | 17 | **17** |
| Telas com `viewport-fit=cover` | 16 | **17** |
| Telas com `safe-area-inset` | 0 | **17** |
| Telas com hover-guard touch | 0 | **6** (autenticadas) |
| Inputs anti-zoom iOS | 0/5 | **5/5** |
| Touch target `.btn--sm` | 40px | **44px** |
| Touch target `.nav-item` mobile | 38px | **48px** |
| Headlines com `clamp()` (app) | 0 | **9 ocorrências em 6 telas** |

---

## 4. Cobertura de devices (após Onda 8)

| Device | Score esperado |
|---|---|
| iPhone SE (375×667) | ✓ Sem auto-zoom, fontes legíveis, FAB safe-area |
| iPhone 14 Pro (393×852, notch) | ✓ Topbar respeita notch top, FAB respeita home indicator |
| Pixel 7 (412×915) | ✓ Touch targets generosos, hover não fica stuck |
| Galaxy A54 (360×780) | ✓ `.nav-item` 48px confortável para polegar |
| iPad Mini (768×1024) | ✓ Sidebar aparece em 768px (revisar Onda 8c+) |
| iPad Pro (1024×1366) | ✓ Layout desktop completo, gutter 32px |
| MacBook Air (1440×900) | ✓ Container 1200px centered |

---

## 5. O que NÃO foi feito (consciente, com motivo)

- **Reduzir os 9 breakpoints da landing para 4 canônicos:** alto risco de regressão visual em viewports intermediárias (768-899px). Requer screenshot diff manual em cada breakpoint. **Backlog para Onda 9.**
- **Padronizar breakpoint sidebar/topbar para 960px único:** alguns arquivos estão em 768, 900, 960. Mudança de breakpoint pode quebrar tablets. **Backlog para Onda 9.**
- **`@media (hover: hover)` em CSS local de cada arquivo (em vez do hover-guard global):** o hover-guard global é mais simples e elimina o problema. Refatorar todos os `:hover` individuais é trabalho de dezenas de horas com pouco ganho marginal.
- **Imagens com `loading="lazy"` na landing:** os 2 `<img>` do hero estão acima da fold e não devem ter lazy. Imagens decorativas estariam abaixo, mas o `01_landing` não usa imagens decorativas — só backgrounds CSS. **Não-aplicável.**
- **Aumentar fontes de 10-11px para 11-12px:** trabalho cosmético; arquivos têm copy compacto e essas fontes são labels secundárias. **Backlog para Onda 9.**

---

## 6. Próximos passos recomendados

1. **Validação em devices reais.** O melhor que CSS estático pode oferecer está feito. Agora precisa ir para iPhone real, Android real, iPad real. Use BrowserStack ou Playwright + screenshot diff contra `_audit/baseline/`.
2. **Lighthouse Mobile.** Rodar em cada uma das 17 telas. Meta: Performance ≥85, Accessibility ≥95, Best Practices ≥95.
3. **Onda 9 (opcional, baseado em feedback de devices reais):**
   - Padronizar breakpoints da landing
   - Padronizar breakpoint sidebar/topbar
   - Polir fontes muito pequenas
   - Adicionar `loading="lazy"` em imagens de seções abaixo da fold (se forem adicionadas)

---

## 7. Reversão (se necessário)

Tudo aplicado pelas Ondas 8a-8d é incremental e reversível:

```bash
# Reverter Onda 8 inteira (volta ao estado pós Onda 7)
cp _audit/baseline/*.html .
# E re-aplicar apenas Ondas 1-7 (scripts em outputs/)
python3 outputs/apply_foundation.py
python3 outputs/cleanup_local_root.py
python3 outputs/promote_h1.py
python3 outputs/apply_grid_logo.py
```

Os scripts `outputs/onda8a_p0_ios.py`, `onda8b_touch.py`, `onda8c_padding.py` são idempotentes — rodar de novo não causa duplicação.

---

*Onda 8 fecha o ciclo de excelência mobile. Próximo passo: validação em devices reais.*
