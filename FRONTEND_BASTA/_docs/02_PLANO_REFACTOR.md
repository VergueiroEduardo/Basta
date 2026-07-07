# Plano de Refactor — Basta HTMLs (01–17)

**Autor:** Claude (engenheiro front-end + UX/UI sr. estilo Huge Inc)
**Insumo:** `auditoria_basta_html.md` (25/04/2026)
**Stack-alvo final:** Next.js 14 + React + Tailwind + Supabase + Vercel
**Stack do refactor (esta fase):** HTML estático + CSS modular + JS vanilla mínimo
**Princípio:** os 17 HTMLs são **a especificação executável** que vai virar React. Quanto mais limpos saírem desta fase, menos débito vai para a port. Cada decisão aqui é uma decisão arquitetural do produto.

---

## 0. Princípios não-negociáveis

Antes de qualquer linha trocada, estes 7 princípios governam tudo:

1. **DS é fonte da verdade.** Se um valor não está em `tokens.css`, não existe. Se um componente não está em `components.css`, é exceção justificada — exceção tem comentário com motivo.
2. **Semântica vence cosmética.** `<button>` para ação, `<a>` para navegação, `<form>` para qualquer agrupamento de input. Sem `<div onclick>`. Sem `tabindex` em elemento que já é nativo focável.
3. **Toda tela tem 1 `<h1>`.** Sem exceção. A hierarquia de heading é a espinha dorsal da tela para screen readers e SEO.
4. **Microcopy é UI.** Erros de espaço grudado, capitalização inconsistente e "Sua Conta" pseudo-corporativo são bugs com a mesma severidade de um botão quebrado.
5. **Estilo de classe único.** BEM duplo-traço (`btn btn--primary`). Sem `btn-primary`, sem `btnPrimary`, sem `btn_primary`. Find-and-replace agressivo no início.
6. **Componentização ainda em HTML.** Header, sidebar, logo, modal de logout: extrair para parciais carregadas via include do build (ou via fetch + `<template>` para rodar localmente). Quando virar React, vira `import` direto.
7. **A11y testada, não assumida.** Cada tela passa por axe-core no fim de cada onda. Score < 95 bloqueia merge.

---

## 1. Estratégia em 6 ondas

```
Onda 0 — Baseline & instrumentação ………………… 0,5 dia
Onda 1 — Foundation (tokens, primitives, partials) … 2 dias
Onda 2 — Auth funnel (02–06) ……………………………… 1,5 dia
Onda 3 — Open Finance (07–11) …………………………… 2 dias
Onda 4 — App shell + Dashboard (12) ………………… 1 dia
Onda 5 — App screens (13–17) ………………………………… 2 dias
Onda 6 — Landing (01) ………………………………………………… 1 dia
─────────────────────────────────────────────────────
TOTAL .................................. ~10 dias-pessoa
```

**Ordem é deliberada:**
- Foundation primeiro porque tudo depende dela.
- Auth antes de OF porque é mais simples (forma de aquecimento) e valida o pattern.
- OF antes do app porque é o ponto de maior abandono no funil — corrigir bug de microcopy "conexãointerrompida" cedo é receita.
- Dashboard antes das demais autenticadas porque define o app-shell que as 5 outras herdarão.
- Landing por último porque é o arquivo mais autônomo e o de menor risco se quebrar (não está no funil de conversão autenticado).

---

## 2. Onda 0 — Baseline & instrumentação

**Objetivo:** congelar o que existe, instalar o ambiente de medição.

| # | Ação | Output |
|---|---|---|
| 0.1 | `git checkout -b refactor/basta-html-v2`, commit baseline | Branch criada |
| 0.2 | Rodar Lighthouse + axe-core em cada um dos 17 arquivos. Salvar JSON em `01_Sistema/_audit/baseline/` | Baseline numérico |
| 0.3 | Tirar screenshot full-page de cada arquivo em desktop (1440px) e mobile (390px). Salvar em `_audit/baseline-screens/` | Baseline visual |
| 0.4 | Criar `_audit/diff-budget.md`: total LOC atual = 13.342, target pós-refactor = ~9.000. Total CSS atual = 8.214, target = ~3.500. | Métrica de sucesso |
| 0.5 | Instalar localmente: `npx http-server` (servir os HTMLs), `axe-cli`, `pa11y-ci` | Ambiente |

**Definition of Done:** branch criada, baseline arquivado, métricas-alvo escritas. Sem código tocado ainda.

---

## 3. Onda 1 — Foundation

**Objetivo:** parar de redefinir DS dentro de cada arquivo. Criar a infraestrutura compartilhada.

### 3.1 Estrutura de pastas alvo

```
01_Sistema/
  _foundation/
    tokens.css            ← derivado direto do basta-design-system.html
    reset.css             ← reset minimalista
    typography.css        ← classes utilitárias de tipografia (display-1, body-l, label-xs)
    layout.css            ← .container, .stack, .grid-2, .grid-3
  _components/
    btn.css               ← btn + variants
    card.css
    form.css              ← form-group, form-label, form-input, form-select
    badge.css
    modal.css
    accordion.css
    sidebar.css           ← sidebar autenticado
    topbar.css            ← topbar mobile autenticado
    bank-card.css         ← bank-card + mapa de cores institucionais
    custom-select.css     ← acessível com role="listbox"
    progress.css          ← progress-card, progress-circle, progress-bar
  _partials/
    logo-symbol.html      ← <svg><symbol id="logo-basta">…</symbol></svg>
    sidebar.html          ← <aside class="sidebar">…</aside>
    topbar.html           ← <div class="topbar">…</div>
    logout-modal.html
    head-meta.html        ← <meta>s padrão (charset, viewport, theme-color, fonts)
  _scripts/
    accordion.js          ← keyboard support universal
    custom-select.js
    form-validation.js
    masks.js              ← CPF, CEP, telefone, moeda BRL
  01_basta-landing.html
  02_basta-cadastro.html
  …
```

**Decisão arquitetural:** parciais HTML são incluídas via build script (Node + cheerio) ou via `fetch()` + template no client. Recomendo **build script** (`scripts/build-includes.js`) para que o output final seja HTML puro, deployável estaticamente — exatamente o que vai pra Vercel.

### 3.2 `tokens.css` — extrato canônico do DS

Copiar o `:root` de `basta-design-system.html` (linhas 17–93) **integralmente**. Adicionar tokens que aparecem na auditoria mas faltam no DS:

```css
/* tokens.css — extends basta-design-system.html :root */
:root {
  /* … todos os tokens do DS, sem cortes … */

  /* Adições documentadas (origem: auditoria) */
  --gray-100:        #F4F4F4;   /* fundo neutro suave (usado em 11, 12, 13, 17) */
  --green-hover:     #389d3e;   /* hover do --green */

  /* WhatsApp (canal de produto) */
  --wa:              #25D366;
  --wa-hover:        #1DA851;

  /* Cores institucionais de bancos — lookup, não tokens de tema */
  --bank-bb:         #003882;
  --bank-itau:       #EC0000;
  --bank-bradesco:   #CC092F;
  --bank-nubank:     #820AD1;   /* corrige drift #8A05BE → #820AD1 */
  --bank-santander:  #EC0000;
  --bank-caixa:      #005CA9;
  --bank-inter:      #FF7A00;
}
```

### 3.3 `_partials/logo-symbol.html`

Extrai o SVG do logo de uma vez. Cada arquivo passa a ter:

```html
<!-- topo do <body>, antes de qualquer outro conteúdo -->
<!--#include file="_partials/logo-symbol.html" -->

<!-- onde o logo aparecer -->
<svg class="logo" aria-label="Basta." role="img">
  <use href="#logo-basta"/>
</svg>
```

**Ganho:** ~1.230 LOC de SVG duplicado eliminadas.

### 3.4 Padronização de naming (find & replace global)

| De | Para | Onde |
|---|---|---|
| `--f:` | `--font-family:` | todos |
| `--t:` | `--transition:` | todos |
| `--ease:` | `--ease-out:` | todos |
| `class="btn btn-primary"` | `class="btn btn--primary"` | 02–09 |
| `class="btn-logout-confirm"` | `class="btn btn--primary"` | 12–17 |
| `class="btn-logout-cancel"` | `class="btn btn--ghost"` | 12–17 |
| `class="btn-wa"` | `class="btn btn--wa"` | 17 |
| `class="btn--retry"` | `class="btn btn--primary" data-action="retry"` | 11 |

**Ferramenta:** `sd` (sed moderno) ou `find` + `xargs sed`. Commit por substituição para facilitar revert.

### 3.5 Definition of Done (Onda 1)

- [ ] `_foundation/tokens.css` criado, importado por **todos** os 17 arquivos no `<head>`.
- [ ] `_foundation/reset.css` extraído (eliminado de cada `<style>` interno).
- [ ] `_components/btn.css` criado com 6 variants (`primary`, `ghost`, `outline-black`, `outline-white`, `error`, `wa`).
- [ ] `_partials/logo-symbol.html` incluído em todos os arquivos onde o logo aparece.
- [ ] `_partials/head-meta.html` padronizado: charset, viewport, fonts (preconnect + display=swap), theme-color decidido por contexto (claro para 01, escuro para 02–17).
- [ ] Naming de botão unificado em todos os arquivos.
- [ ] Lighthouse ≥ baseline em todas as 17 telas (não regredir). axe-core sem novos erros.
- [ ] LOC total cai de 13.342 para ≤ 11.000.

---

## 4. Onda 2 — Auth funnel (02–06)

**Objetivo:** o caminho cadastro → criada deve ser a **prova-de-conceito** do novo padrão. Quem entra aqui depois sabe o que esperar nas próximas ondas.

### 4.1 Refactors específicos

**Todos os arquivos da onda:**
- Importar `tokens.css`, `reset.css`, `typography.css`, `form.css`, `btn.css` no `<head>`.
- Remover o `<style>` inline (deve sobrar < 50 linhas de estilo realmente local).
- Promover `<h2>` de tela para `<h1>`.
- Garantir `<main>` único envolvendo o conteúdo.

**`02_basta-cadastro.html`:**
- Trocar "Crie Sua Conta." por "**Criar conta.**" (sentence-case, modo verbal direto — alinha com o resto).
- `--error` → remover redefinição local; herdar do tokens.
- `<button>` "mostrar senha" e "limpar CEP": adicionar `type="button"` explícito.
- Implementar máscara via `_scripts/masks.js`: CPF (`000.000.000-00`), CEP (`00000-000`), data (`DD/MM/AAAA`), telefone (`(00) 00000-0000`).
- Lookup de CEP: documentar como TODO no JS (a integração com ViaCEP entra na port React).
- Substituir `<a class="btn">` (se houver) por `<button>`.

**`03_basta-login.html`:**
- Promover `<h2>` para `<h1>`.
- "Esqueci minha senha" mantém-se `<a>` (é navegação).
- Adicionar `aria-label` no botão de mostrar senha.
- Estado de erro de credencial: criar `<p class="form-error" role="alert" hidden>` injetado por JS no submit fail.

**`04_basta-recuperar-senha.html` e `05_basta-redefinir-senha.html`:**
- Mesmo padrão. Em 04, os 2 estados ("solicitar link" / "link enviado") devem ter rotas diferentes na versão React; aqui mantém toggle JS mas com `aria-live="polite"` no container que troca.
- Em 05, todos os botões com `type=` explícito (atualmente só 1 dos 3 tem).

**`06_basta-conta-criada.html`:**
- **Bug crítico de microcopy:** corrigir "Conta criada**com** sucesso." → adicionar espaço entre `<span>`s ou unificar em `<h1>Conta criada<br>com sucesso.</h1>`.
- Adicionar `<main>` (atualmente só `<div>`s).
- Auto-redirect para dashboard após N segundos (com `aria-live` anunciando contagem regressiva).
- Adicionar `<meta name="robots" content="noindex">` (tela autenticada).

### 4.2 Definition of Done (Onda 2)

- [ ] 5 arquivos passam axe-core com 0 erros.
- [ ] 5 arquivos têm `<h1>` único.
- [ ] 5 arquivos têm `<main>`.
- [ ] Todos os formulários estão dentro de `<form>` com `<label for=>` em todos os inputs.
- [ ] Todos os `<button>` têm `type=` explícito.
- [ ] Microcopy de 06 corrigido — captura de tela enviada para Eduardo aprovar antes do merge.
- [ ] CSS local de cada arquivo ≤ 80 linhas (overrides justificados).

---

## 5. Onda 3 — Open Finance (07–11)

**Objetivo:** este é o trecho do funil onde dinheiro é perdido. A jornada precisa ser irrepreensível — visual, semântica e copy.

### 5.1 Refactors específicos

**Pattern compartilhado para 07–11:**
- Importar `bank-card.css` e `progress.css` da Foundation.
- Adicionar `<h1>` em todas as 5 (atualmente nenhuma tem).
- Adicionar `<main>` em todas.
- Trocar todo `<div onclick>` por `<button>` semântico.
- Centralizar cores de banco em `var(--bank-nubank)` etc.

**`07_basta-of-selecao-banco.html`:**
- 6 inline `style=` — eliminar todos. Usar `data-bank="nubank"` + `style="--bank-color: var(--bank-nubank)"` para colorir dinamicamente.
- Lista de bancos: marcar como `<ul role="list">` + `<li>` + `<button class="bank-card">`.
- Adicionar busca/filtro client-side (input + filter JS) — não esperar para o React. UX wins agora.

**`08_basta-of-credenciais.html`:**
- Esclarecer no markup que é **redirecionamento ao banco**, não captura de credenciais. Adicionar `<h1>Você será redirecionado ao Nubank</h1>` e `<p>` explicativo. (Compliance OF: a Basta nunca vê credenciais.)
- Substituir `confirm-box__btn--cancel/confirm` por `btn btn--ghost` / `btn btn--primary`.

**`09_basta-of-instrucao-banco.html`:**
- Reusar `step-item` do DS para os passos.
- Substituir `#FEF2F2` (alerta suave) por uma tonalidade derivada: `background: color-mix(in srgb, var(--error) 8%, white);`

**`10_basta-of-progresso.html`:**
- `progress-circle` vai para `_components/progress.css`.
- `<a class="btn">` "Voltar ao dashboard" vira `<a class="link link--inline">` (não é botão, é navegação) ou `<button>` se for ação.

**`11_basta-of-erro.html`:**
- **Bug crítico de microcopy:** corrigir "conexão**interrompida**." (falta espaço).
- "Tentar novamente" vira `<button type="button" data-action="retry">` (não `<a>`).
- Mensagem de erro `aria-live="assertive"`.
- Adicionar fallback: link para WhatsApp da Basta como segunda opção.

### 5.2 Definition of Done (Onda 3)

- [ ] 5 arquivos passam axe-core com 0 erros.
- [ ] Microcopy de 11 corrigido. Captura aprovada.
- [ ] 0 `<div onclick>` nos 5 arquivos.
- [ ] Cores de banco lendo de `--bank-*` (nenhum `#820AD1` literal).
- [ ] Caminho 07 → 08 → 09 → 10 → (sucesso ou 11) testado manualmente clicando-se com teclado (Tab / Enter / Space).

---

## 6. Onda 4 — App shell + Dashboard (12)

**Objetivo:** o app-shell extraído na Foundation passa do plano para a prática. Esta tela define como as 5 seguintes vão se comportar.

### 6.1 Refactors específicos

**`12_basta-dashboard.html`:**
- Substituir o `<aside class="sidebar">` literal pelo `<!--#include file="_partials/sidebar.html" -->`.
- Substituir o `<div class="topbar">` pelo `<!--#include file="_partials/topbar.html" -->`.
- Substituir o `<dialog class="logout-modal">` pelo `<!--#include file="_partials/logout-modal.html" -->`.
- 924 linhas de CSS local devem cair para ≤ 200 linhas (apenas overrides reais do dashboard).
- Validar token de sidebar (`--sidebar-w`) está em `tokens.css`.
- Padronizar todos os `<button>` da sidebar com `aria-current="page"` na página ativa.

### 6.2 Validação especial — sidebar/topbar como contrato

A partir desta onda, **qualquer mudança de sidebar/topbar é mudança de contrato**. Documentar:

```
_partials/sidebar.html — CONTRATO

Slots disponíveis:
  - data-active="resumo|documentos|contas|requerimentos|perfil|ajuda"
    define qual link tem aria-current

Tokens consumidos:
  - --sidebar-w
  - --black, --white, --gray-300

JS necessário:
  - _scripts/sidebar.js (toggle mobile)
```

### 6.3 Definition of Done (Onda 4)

- [ ] 12_dashboard.html ≤ 700 linhas (atual: 1.317).
- [ ] CSS local ≤ 200 linhas (atual: 924).
- [ ] Sidebar e topbar lendo de partial, não duplicadas no arquivo.
- [ ] axe-core 0 erros.
- [ ] Lighthouse ≥ baseline.

---

## 7. Onda 5 — App screens (13–17)

**Objetivo:** replicar o pattern do dashboard nas 5 telas autenticadas restantes. Cada uma deve ter no máximo 2 commits: um para extrair sidebar/topbar, outro para limpezas locais.

### 7.1 Refactors específicos

**Para todas (13, 14, 15, 16, 17):**
- Substituir sidebar e topbar pelos partials.
- Adicionar `data-active="…"` no include para ativar o link correto.
- Substituir logout modal pelo partial.
- Importar `tokens.css` + componentes da Foundation.

**`13_basta-documentos.html`:**
- `acc__header` e `sub-acc__header` migram para `_components/accordion.css`.
- Validar handler Enter/Space em `_scripts/accordion.js`.
- 60 KB → meta de 28 KB.

**`14_basta-contas-bancarias.html`:**
- 8 `<div onclick>` viram `<button>`.
- Cores de banco lendo de `--bank-*`.
- Corrige drift `#8A05BE` → `#820AD1`.

**`15_basta-requerimentos.html`:**
- Custom selects migram para `_components/custom-select.css` + `_scripts/custom-select.js` com `role="listbox"`, `role="option"`, `aria-activedescendant`.

**`16_basta-perfil.html`:** ⚠ tela mais quebrada
- **Envolver os 8 `<input>` em `<form id="profile-form" novalidate>`.**
- **Adicionar `type=` em todos os 5 `<button>`** (4 `type="button"` para ações secundárias, 1 `type="submit"` para salvar).
- Manter os `<label for=>` (já está bom — único arquivo do app que faz certo).
- Adicionar estado dirty: `aria-disabled` no submit até houver mudança.

**`17_basta-ajuda.html`:**
- 7 inline `style=` — eliminar.
- `--wa-hover: #1DA851` movido para `tokens.css`.
- FAQs viram `<details>` / `<summary>` nativos (acessibilidade gratuita) ou usam `_components/accordion.css`.
- Botão WhatsApp `btn btn--wa` com `<svg>` ícone padronizado.

### 7.2 Definition of Done (Onda 5)

- [ ] 5 arquivos passam axe-core com 0 erros.
- [ ] Sidebar/topbar consumidos como partial em todas.
- [ ] 16_perfil tem `<form>` envolvendo os inputs.
- [ ] LOC total da onda cai ≥ 30%.
- [ ] Teste manual de keyboard navigation em cada uma das 5.

---

## 8. Onda 6 — Landing (01)

**Objetivo:** otimizar a única tela pública. Esta é a primeira impressão.

### 8.1 Refactors específicos

**`01_basta-landing.html`:**
- Importar `tokens.css` (substitui o `:root` interno).
- Manter `<style>` local apenas para componentes verdadeiramente exclusivos da landing (hero, FAQ, depoimentos).
- **Critical CSS:** extrair as ~100 linhas above-the-fold para `<style>` no `<head>`; carregar o resto via `<link rel="stylesheet" media="print" onload="this.media='all'">`.
- Logo SVG via `<use href="#logo-basta"/>` (3x → 1 `<symbol>` + 3 `<use>`).
- Validar `theme-color="#FFFFFF"` está intencional (landing clara) vs `#1A1A1A` (app escuro).
- Validar `rel="noopener noreferrer"` em **todos** os `<a target="_blank">` (já parecia OK no scan; reconfirmar).
- Adicionar `<meta property="og:*">` para sharing (atualmente ausentes).
- Adicionar `<link rel="canonical">`.

### 8.2 Definition of Done (Onda 6)

- [ ] LCP < 2,5s em conexão 4G simulada (Lighthouse).
- [ ] CLS < 0,05.
- [ ] axe-core 0 erros.
- [ ] OG tags presentes (testar com `https://opengraph.xyz`).
- [ ] LOC ≤ 1.300 (atual: 1.730).

---

## 9. QA Gates por onda

Cada onda só fecha quando:

| Gate | Ferramenta | Threshold |
|---|---|---|
| **A11y** | axe-core CLI | 0 violations sérias/críticas |
| **Performance** | Lighthouse (mobile) | Performance ≥ baseline; LCP não regride |
| **Visual regression** | comparar screenshot novo vs baseline | nenhuma mudança visual não-intencional |
| **HTML válido** | `html-validate` | 0 erros |
| **CSS válido** | `stylelint --config stylelint-config-standard` | 0 erros |
| **LOC** | `wc -l` | dentro do diff-budget |
| **Manual keyboard** | Tab/Shift-Tab/Enter/Space na tela inteira | nenhum trap, nenhum elemento focado invisível |
| **Manual screen reader** | VoiceOver passada rápida | h1 anunciado, formulários anunciam labels |

**Bloqueio de merge:** qualquer gate vermelho → não mergeia.

---

## 10. Estrutura de commits sugerida

Granular, reversível, revisável. **1 commit = 1 ideia.**

```
Onda 1 — Foundation
  feat(foundation): extract design tokens to tokens.css
  feat(foundation): extract reset and base typography
  feat(foundation): create btn component with 6 variants
  feat(foundation): create form, card, badge, modal components
  feat(foundation): extract logo SVG to symbol partial
  refactor(naming): standardize button classes to BEM (btn--primary)
  refactor(naming): canonicalize token names (--f → --font-family)
  fix(tokens): align --error to #DC2626 in 02-05
  build: add include script for HTML partials

Onda 2 — Auth
  refactor(02): consume foundation, promote h2 to h1, fix microcopy "Criar conta."
  fix(02): add type=button to non-submit buttons
  feat(02): add masks for cpf/cep/date/phone via _scripts/masks.js
  refactor(03-05): same pattern as 02
  fix(06): add space in "Conta criada com sucesso", wrap in <main>, add noindex
  test(auth): pass axe-core on 02-06

Onda 3 — OF
  refactor(07-11): consume foundation, add h1 and main everywhere
  refactor(07): replace inline styles with --bank-color CSS vars
  fix(08): clarify redirect-to-bank semantics in markup
  refactor(09): use design system step-item, replace #FEF2F2 with color-mix
  refactor(10): extract progress-circle to _components/progress.css
  fix(11): add space in "conexão interrompida", convert <a> to <button>, add aria-live
  test(of): pass axe-core on 07-11, manual keyboard test

Onda 4 — App shell
  refactor(12): include sidebar.html, topbar.html, logout-modal.html partials
  refactor(12): remove duplicated CSS now in foundation
  test(12): pass axe-core, validate sidebar contract

Onda 5 — App screens
  refactor(13): include partials, migrate accordion to component
  refactor(14): include partials, fix bank colors via tokens
  refactor(15): include partials, accessible custom-select
  fix(16): wrap inputs in <form>, add type= to all buttons
  refactor(17): include partials, replace inline styles, FAQs as <details>
  test(app): pass axe-core on 13-17

Onda 6 — Landing
  refactor(01): consume tokens.css, extract critical CSS
  refactor(01): use logo symbol partial
  feat(01): add OpenGraph meta tags and canonical link
  test(01): Lighthouse LCP < 2.5s
```

Total: ~30 commits. Cada um pequeno o bastante para revert isolado.

---

## 11. Definition of Done global

O refactor está pronto quando:

| Critério | Estado atual | Alvo |
|---|---:|---:|
| LOC total dos 17 arquivos | 13.342 | ≤ 9.000 |
| LOC de CSS inline | 8.214 | ≤ 1.000 (overrides) |
| Cópias do logo SVG | 15+ | 1 (`<symbol>`) |
| Tokens redefinidos por arquivo | 17 | 0 (todos consumindo `tokens.css`) |
| Variantes de naming de botão | 5 | 1 (`btn btn--variant`) |
| Telas sem `<h1>` | 9 | 0 |
| Telas sem `<main>` | ~6 | 0 |
| `<input>` fora de `<form>` | 8 (em 16) | 0 |
| `<button>` sem `type=` | 5 (em 16) + 2 (em 05) | 0 |
| `<div onclick>` | ~50 distribuídos | 0 |
| Bugs de microcopy (palavras grudadas) | 2 | 0 |
| Drift de cor (`--error`, bank-nubank) | 2 | 0 |
| axe-core erros sérios/críticos | desconhecido | 0 |
| Lighthouse Perf 01_landing (mobile) | desconhecido | ≥ 90 |
| Tempo para criar 18ª tela autenticada | dias (copia tudo) | horas (consome partials) |

---

## 12. Ferramentas a instalar

```bash
# Todos rodando localmente, sem dependência de cloud
npm i -D \
  http-server \              # servir os HTMLs em localhost
  axe-core @axe-core/cli \   # a11y
  pa11y pa11y-ci \           # a11y batch
  html-validate \            # HTML válido
  stylelint stylelint-config-standard \   # CSS válido
  prettier \                 # formatação
  cheerio \                  # parsing HTML para o build de includes
  playwright \               # screenshots para visual regression

# Opcional, mas recomendo
brew install sd               # find-and-replace mais seguro que sed
```

Lighthouse via Chrome DevTools manual (ou `lighthouse-ci` se for crônico).

---

## 13. Riscos e mitigações

| Risco | Probabilidade | Mitigação |
|---|---|---|
| Build de includes quebra deploy estático na Vercel | baixa | Build script gera HTML puro pré-deploy; Vercel só serve. |
| Visual regression em telas que ninguém pediu para mudar | média | Screenshots em Onda 0 + comparação obrigatória em cada PR. |
| Eduardo quer manter alguma divergência (ex.: `--error` `#EF4444` por motivo de marca) | baixa | Cada decisão de tokens passa por aprovação dele antes de Onda 1 fechar. |
| Onda 1 estoura prazo e bloqueia tudo | média | Onda 1 pode ser sub-dividida e mergeada incrementalmente; outras ondas só dependem de partes específicas. |
| A port para Next.js acontecer em paralelo, criando duplicidade | alta | Definir cutoff: ou se faz Onda 0–6 inteiro antes da port, ou se faz Foundation (Onda 1) e já parte para React, descartando 02–17 e reescrevendo direto em React. **Recomendo: Foundation + Auth (Ondas 1–2) primeiro, depois decidir.** |

---

## 14. Próximos 3 passos imediatos

1. **Aprovação deste plano** — Eduardo revê seções 1, 9 e 11 e aprova/ajusta antes de começar.
2. **Criar branch + Onda 0** — baseline arquivado, métricas escritas.
3. **Onda 1.1** — extrair `tokens.css` e fazer um único arquivo (sugestão: `06_basta-conta-criada.html`, o menor) consumi-lo. Validar pipeline ponta a ponta antes de aplicar nos 16 restantes.

---

*Fim. Pronto para virar épico no Linear ou board no Notion. Cada checkbox da seção 11 é uma meta verificável.*
