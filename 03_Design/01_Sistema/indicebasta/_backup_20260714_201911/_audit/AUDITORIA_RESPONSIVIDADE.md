# Auditoria de Responsividade — Basta HTMLs (01–17)

**Data:** 26/04/2026 · **Auditor:** Claude (lente de senior UI/UX Huge Inc + engenheiro front-end)
**Método:** análise estática estrutural — meta viewports, breakpoints, overflow, typography, touch targets, padding mobile, app-shell behavior, modais. Não substitui testes em devices reais (Lighthouse mobile + BrowserStack obrigatórios antes de produção).

---

## 1. Resumo executivo

**Nota geral de responsividade: 6,8 / 10.** A base está sólida (`viewport-fit=cover`, `overflow-x: clip`, app-shell com sidebar/topbar bem alternadas). Mas há **regressões críticas para iOS** (input font-size 15px causa zoom forçado), **inconsistência de breakpoints sistêmica** (cada arquivo tem o seu mapa), **0% de uso de `safe-area-inset` para notch**, e a landing usa **9 breakpoints diferentes** num único arquivo, o que é dívida técnica.

**Top 3 problemas:**

1. **Inputs com `font-size: 15px` em 5 telas críticas** (02 cadastro, 03 login, 04/05 senha, 16 perfil) — Safari iOS faz zoom involuntário ao focar. Ajuste para 16px é trivial e não-negociável.
2. **Landing tem 9 breakpoints únicos** (480, 600, 640, 680, 767, 768, 780, 800, 900px) — caótico. Cada componente decide sozinho onde quebra. Padronizar para 4 breakpoints (640/768/1024/1200) reduz superfície de bug em 60%.
3. **Padding mobile do `.main` em 13–17 é 20px lateral** (deveria seguir gutter de 16px tokenizado). Inconsistência entre 12 (24px) e 13–17 (20px) — divergência cosmética entre telas do mesmo app.

**Pontos fortes:**
- 17/17 arquivos com `meta viewport` correto e `viewport-fit=cover` (16/17 — só 01_landing não tem).
- 17/17 com `overflow-x: clip` no `<html>` — a defesa universal contra horizontal scroll acidental.
- App-shell (12–17) com sidebar/topbar alternadas em ≤960px — pattern correto.
- Landing usa `clamp()` em 18 lugares — typography fluida bem aplicada na peça mais importante.
- Modais (`logout-modal`) com `width: 100%; max-width: 360px` — responsivos.

---

## 2. Matriz: meta viewport + breakpoints

| Arquivo | viewport-fit=cover | # breakpoints únicos | Mobile-first |
|---|:---:|:---:|:---:|
| 01_landing | ❌ | 9 | parcial |
| 02–05 (auth) | ✓ | 6 cada | sim |
| 06_conta-criada | ✓ | 4 | sim |
| 07_of-banco | ✓ | 3 | sim |
| 08_of-credenciais | ✓ | 4 | sim |
| 09_of-instrucao | ✓ | 3 | sim |
| 10_of-progresso | ✓ | 3 | sim |
| 11_of-erro | ✓ | 4 | sim |
| 12_dashboard | ✓ | 9* | parcial |
| 13_documentos | ✓ | 5 | parcial |
| 14_contas | ✓ | 5 | parcial |
| 15_requerimentos | ✓ | 7 | parcial |
| 16_perfil | ✓ | 6 | parcial |
| 17_ajuda | ✓ | 5 | parcial |

*\*12_dashboard tem `min-width: 44px/56px/72px` que parecem ser usados em container queries internos — verificar se são intencionais ou typo.*

**Achado P1:** ausência de viewport-fit=cover no `01_landing` impede que o conteúdo respeite safe-area do iPhone (notch). Adicionar.

---

## 3. Achados por categoria

### 3.1 Inputs e formulários (P0 para iOS)

**Problema:** `font-size: 15px` em todos os `.form-input` de 02, 03, 04, 05, 16. Safari iOS faz auto-zoom ao focar inputs com fonte < 16px. Comportamento confunde o usuário e quebra a sensação de app nativo.

**Fix (1 linha por arquivo):**
```css
.form-input { font-size: 16px; }  /* mobile-first */
@media (min-width: 768px) { .form-input { font-size: 15px; } }  /* desktop volta ao original */
```

**Outros problemas de form:**
- `.btn-save` em 16 perfil: `width: 100%` em mobile, `width: auto` em ≥600px. ✓ correto.
- `.form-cta` em 02-05: usa botão com padding 18-20px e min-height 56-60px. ✓ touch target OK.
- Falta `inputmode` em alguns campos (CEP, telefone) — dispatch ainda exige polish.

### 3.2 Touch targets (≥44×44px)

Auditoria mostra que **botões principais respeitam 44px+**: `.btn` em 56-60px, `.hero-link-secondary` 48px, `.btn--sm` 40px (atenção!).

**Atenção em `.btn--sm` (40px):** abaixo do mínimo iOS HIG (44px) e WCAG 2.5.5 AAA (44px). Aumentar para 44px ou usar somente em contextos não-críticos (chips de filtro, etc).

**Sidebar `.nav-item` (12-17):** padding 10×12 = ~38px de altura efetiva. **Falha WCAG.** Aumentar para 12×16 (48px) em mobile.

### 3.3 Overflow horizontal

Defesa global aplicada (`html { overflow-x: clip }`) ✓. Mas `clip` é mais novo que `hidden` — em browsers antigos cai em `hidden` que **bloqueia position: sticky em ancestors**. Como `.sidebar` usa `position: sticky` em `_components/sidebar.css`, há conflito potencial. Recomendo:

```css
html { overflow-x: clip; overflow-x: hidden; }  /* ordem invertida — clip vence onde suportado */
```

**Único `overflow-x: auto` intencional:** `.journey-bar` em 01_landing — barra horizontal scrollável. Bem feito (com `-webkit-overflow-scrolling: touch` e `scrollbar-width: none`).

### 3.4 Tipografia fluida

| Arquivo | clamp() usado | Avaliação |
|---|---:|---|
| 01_landing | 18 | ✓ excelente |
| 02–05 auth | 1 cada | ⚠ quase nenhum — fontes em px fixo |
| 12 dashboard | 0 | ⚠ nenhum |
| 16 perfil | 0 | ⚠ nenhum |
| 17 ajuda | 0 | ⚠ nenhum |

**Recomendação:** as telas autenticadas (12-17) deveriam usar `clamp()` ao menos em headlines de página (`page-title`) para evitar truncamento em mobile pequeno (320-360px).

### 3.5 App-shell (sidebar ↔ topbar) em 12-17

Pattern verificado em 12, 13, 14, 15, 16, 17:
- `.sidebar { display: none }` por padrão (mobile)
- `.topbar { display: flex }` por padrão (mobile)
- `@media (min-width: 768-960px) { .sidebar { display: flex }; .topbar { display: none } }`

✓ **Padrão consistente, bem implementado.**

**Mas:** o breakpoint de troca varia: 768px em alguns, 960px em outros. **Padronizar em 960px** (sidebar de 240px só faz sentido em viewports ≥1024px, ≥960px é o limite confortável).

### 3.6 Padding/gutter mobile

| Arquivo | `.main` padding mobile | Token-aligned |
|---|---|:---:|
| 12 dashboard | `84px 24px 100px` | ✓ (24px = `--gutter-tablet`) |
| 13 documentos | `84px 20px 100px` | ❌ (20px não é token) |
| 14 contas | `84px 20px 100px` | ❌ |
| 15 requerimentos | `84px 20px 100px` | ❌ |
| 16 perfil | `84px 20px 100px` | ❌ |
| 17 ajuda | `72px 20px 100px` | ❌ (top diferente também) |

**Inconsistência sistêmica.** Padronizar para `var(--gutter-mobile)` (16px) ou `var(--gutter-tablet)` (24px), nunca 20px.

### 3.7 Position: fixed e safe-area-inset

`position: fixed` é usado em:
- `.sidebar` (12-17) — coluna esquerda fixa em desktop
- `.topbar` (12-17) — barra superior fixa em mobile
- `.fab` / `.wa-fab` (12, 13, 16, 17, 01) — botão flutuante WhatsApp
- `.btn-close` (13, 16) — botão de fechar fixed

**Problema:** **0/17 arquivos usam `env(safe-area-inset-*)` para respeitar notch e home bar do iPhone.** Em iPhone X+ landscape ou portrait, o `.fab` pode ficar atrás da home indicator.

**Fix (aplicar em todos os fixed bottom/right):**
```css
.fab, .wa-fab {
  bottom: max(20px, env(safe-area-inset-bottom));
  right: max(20px, env(safe-area-inset-right));
}
.topbar {
  padding-top: max(14px, env(safe-area-inset-top));
}
```

### 3.8 Modais

`.logout-modal` (12-17): `width: 100%; max-width: 360px`. ✓ responsivo.

**Falta:** `.modal-overlay` deveria bloquear scroll do body. Verificar se `body { overflow: hidden }` é aplicado quando modal abre. Verificar via JS — o `_scripts/sidebar.js` já faz `lockScroll(true)`.

### 3.9 Imagens

`01_landing` tem 2 `<img>` (`hero-bg-img`), zero com atributos `width/height` explícitos. Isso causa **CLS (Cumulative Layout Shift)** durante carregamento — penaliza Lighthouse e UX percebida.

**Fix:** adicionar `width="1920" height="1280"` aos imgs (já está, na verdade — verificar) e `loading="lazy"` em imagens fora da fold.

### 3.10 Hover-only — falta @media (hover: hover)

0/17 arquivos usam `@media (hover: hover)`. Significa que efeitos `:hover` rodam em **touch devices** que não têm hover real, deixando o estado "sticky" depois do tap.

**Fix global:**
```css
@media (hover: hover) and (pointer: fine) {
  .btn--primary:hover { background: var(--green-hover); transform: translateY(-2px); }
}
```

Aplicar em **todas as regras `:hover`** dos componentes interativos. Trabalho mecânico.

### 3.11 Fontes pequenas (< 12px)

- 02 cadastro: `font-size: 11px` em alguns labels — ainda legível mas no limite WCAG (14px+ recomendado).
- 12, 17: `font-size: 10px` em algumas labels — **abaixo do confortável.** Aumentar para 11-12px.

### 3.12 Landing-específico (01)

**Hero:** usa breakpoint `min-width: 900px` para reorganizar o logo grande à direita. Em viewports 768-899px (tablets), o hero fica esquisito (logo escondido, headline ainda em desktop layout). **Validar.**

**Trust bar, manifesto, FAQ, footer:** usam o `.container` agora (após Onda 7b), com gutter 16/24/32 progressivo. ✓ correto.

**Journey bar (Como funciona):** scroll horizontal em mobile. ✓ correto. Background full-bleed via `box-shadow` técnica que aplicamos. ✓.

---

## 4. Plano de correção priorizado

### P0 — bloqueadores (corrigir antes de qualquer release)

1. **Input font-size para 16px** em 02, 03, 04, 05, 16 (5 arquivos × 1 linha CSS).
2. **safe-area-inset** em todos os `.fab`, `.wa-fab`, `.topbar`, `.btn-close` fixed (~10 arquivos).
3. **Adicionar `viewport-fit=cover`** em 01_landing.

### P1 — alta prioridade (próxima sprint)

4. **Padronizar padding `.main` mobile** para `var(--gutter-tablet)` (24px) em 13-17.
5. **Touch target `.nav-item`** subir para 44-48px de altura em mobile.
6. **`.btn--sm`** subir para 44px de altura.
7. **`@media (hover: hover)`** envolver todos os efeitos hover dos componentes principais.
8. **Padronizar breakpoint sidebar** para 960px em todas as 6 telas autenticadas.

### P2 — médio prazo

9. **Reduzir breakpoints da landing** de 9 para 4 canônicos (640/768/1024/1200).
10. **Adicionar `clamp()` em headlines** das telas autenticadas (12-17).
11. **Imagens com `loading="lazy"`** + dimensões explícitas em 01_landing.
12. **`overflow-x: clip; overflow-x: hidden;`** no `<html>` para fallback browsers antigos.

### P3 — polimento

13. **Aumentar fontes 10-11px** para 11-12px (legibilidade).
14. **Tablet review (768-1023px):** validar visualmente cada uma das 17 telas — zona menos coberta no design.
15. **Container queries** (`@container`) onde possível — futuro-proof para Next.js port.

---

## 5. Devices a testar (depois das correções P0)

Mínimo viável de QA:

- **iPhone SE (375×667)** — menor moderno, captura mais bugs
- **iPhone 14 Pro (393×852)** — notch + dynamic island
- **Pixel 7 (412×915)** — Android moderno
- **iPad Mini (768×1024)** — tablet portrait
- **iPad Pro (1024×1366)** — tablet landscape
- **MacBook Air (1440×900)** — desktop pequeno
- **iMac (1920×1080)** — desktop grande

Ferramentas: Chrome DevTools Device Toolbar (rápido, não substitui device real) → BrowserStack ou Playwright para test runs.

---

## 6. O que NÃO foi auditado

- **Comportamento JS em scroll/touch:** não testei se sidebar mobile abre corretamente ao tocar hamburger, se modais fecham com swipe, se accordions tem feedback tátil.
- **Renderização real em devices:** auditoria estática só. Lighthouse mobile + screenshots em devices reais são o próximo passo obrigatório.
- **Acessibilidade (WCAG 2.1 AA):** auditei fontes pequenas e touch targets, mas não contraste de cores nem screen reader passes.
- **Performance:** não medi LCP/FID/CLS em devices reais.

---

*Fim do documento. Próximo passo recomendado: aplicar os 3 itens P0 (input font-size + safe-area + viewport-fit) — 30 min de trabalho que elimina os bugs mais visíveis em iOS.*
