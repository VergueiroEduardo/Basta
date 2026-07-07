# Auditoria Técnica e de Qualidade — Basta HTMLs (01–17)

Data: 25/04/2026 · Auditor: Claude (Engenheiro front-end + revisor de DS) · Escopo: `Basta/03_Design/01_Sistema/*.html`

---

## 1. Resumo executivo

**Nota geral: 5,2 / 10**

O design visual está coerente com o conceito Editorial Brutalista Refinado. A execução técnica, **não**. Os 17 arquivos compartilham um look-and-feel mas **não** um sistema: cada arquivo redefine seu próprio `:root`, redesenha tokens com nomes diferentes do DS, repete o SVG do logo até 3x por arquivo e copia headers/sidebars inteiros sem fonte única. 61% das ~13.300 linhas são CSS inline duplicado.

**Top 3 problemas sistêmicos:**

1. **Drift severo do Design System.** Nenhum dos 17 arquivos usa os tokens canônicos do `basta-design-system.html`. Todos criam variantes encurtadas (`--f`, `--t`, `--gray-100`) e divergem em valores críticos — `--error` é `#EF4444` em 01–05 e `#DC2626` no DS e em 12–17. Convenção de botão muda 4 vezes entre os arquivos (`btn-primary`, `btn--primary`, `btn-wa`, `btn-logout-confirm`).
2. **Acessibilidade falha em fluxos críticos.** `<input>` fora de `<form>` em 16_perfil (8 inputs órfãos), `<button>` sem `type` em 16 (5 botões — todos viram submit por default), `<a class="btn">` para CTAs em 02/06/10/11 (anti-pattern semântico), 0% dos arquivos tem `<label>` dedicado nos forms exceto 02/16, e a hierarquia de heading está quebrada em 02–05, 07–11 (zero `<h1>`).
3. **Onboarding e OF têm rendering bugs de microcopy visíveis.** "Conta criada**com** sucesso." e "Ahh não, conexão**interrompida**." — palavras grudadas por falta de espaço entre `<span>` adjacentes. Aparece nas telas 06 e 11. É o tipo de coisa que invalida a percepção de qualidade na primeira impressão.

**Recomendação:** **NÃO portar para Next.js no estado atual.** Antes do refactor componentizado, executar onda 1 (consolidação de tokens, extração de header/sidebar/logo, normalização de nomes) — caso contrário, vai-se carregar 8.000 linhas de débito técnico para dentro do React.

---

## 2. Inventário (Etapa 1)

| Arquivo | KB | Linhas | DOM | inline `style=` | `<style>` | `<script>` | ext-css | fonts CDN |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 01_basta-landing.html | 88 | 1730 | 300 | 0 | 1 | 1 | 0 | 1 |
| 02_basta-cadastro.html | 36 | 818 | 83 | 2 | 1 | 1 | 1 | 3 |
| 03_basta-login.html | 28 | 663 | 48 | 1 | 1 | 1 | 1 | 3 |
| 04_basta-recuperar-senha.html | 20 | 551 | 41 | 0 | 1 | 1 | 1 | 3 |
| 05_basta-redefinir-senha.html | 32 | 741 | 60 | 1 | 1 | 1 | 1 | 3 |
| 06_basta-conta-criada.html | 12 | 245 | 21 | 0 | 1 | 0 | 1 | 3 |
| 07_basta-of-selecao-banco.html | 20 | 501 | 49 | 6 | 1 | 1 | 1 | 3 |
| 08_basta-of-credenciais.html | 20 | 503 | 37 | 2 | 1 | 1 | 1 | 3 |
| 09_basta-of-instrucao-banco.html | 20 | 504 | 49 | 1 | 1 | 1 | 1 | 3 |
| 10_basta-of-progresso.html | 24 | 629 | 59 | 1 | 1 | 1 | 1 | 3 |
| 11_basta-of-erro.html | 16 | 393 | 28 | 1 | 1 | 0 | 1 | 3 |
| 12_basta-dashboard.html | 52 | 1317 | 112 | 2 | 1 | 1 | 1 | 3 |
| 13_basta-documentos.html | 60 | 1064 | 214 | 2 | 1 | 2 | 1 | 3 |
| 14_basta-contas-bancarias.html | 40 | 759 | 90 | 3 | 1 | 2 | 1 | 3 |
| 15_basta-requerimentos.html | 52 | 1012 | 158 | 2 | 1 | 1 | 1 | 3 |
| 16_basta-perfil.html | 44 | 947 | 95 | 0 | 1 | 2 | 1 | 3 |
| 17_basta-ajuda.html | 60 | 965 | 225 | 7 | 1 | 1 | 1 | 3 |
| **TOTAL** | **624** | **13.342** | **1.669** | **31** | **17** | **18** | **16** | — |

CSS inline (entre `<style>`) soma **8.214 linhas**, ou **61% de todo o código**. Zero arquivo CSS externo compartilhado. Logo SVG (path completo do "Basta.") é repetido **15 vezes** apenas nas 7 telas autenticadas — cada cópia tem ~2 KB.

---

## 3. Conformidade com o Design System (Etapa 2)

**O DS define** (em `basta-design-system.html`, linhas 17–93): paleta de 13 tokens nomeados (`--black`, `--white`, `--off-white`, `--sage`, `--green`, `--gray-600/300/200`, `--warning`, `--error`, `--blue`, `--blue-dark`, `--info`), 6 pesos de fonte, escala de 9 font-sizes (`--fs-xs`/`sm`/`base`/`lg`/`xl`/`2xl`/`3xl`/`4xl`/`5xl`), 4 line-heights, 5 letter-spacings, 10 espaços (`--space-xs` … `--space-6xl`), motion (`--ease-out`, `--duration-*`, `--transition`), layout (`--max-width`, `--border-radius:0`, `--border-width-thin/thick`) e 5 sombras.

**O que aparece nos 17 arquivos:** cada arquivo redefine seu próprio `:root` com **subset encurtado** e nomes diferentes:

| Aspecto | Design System | App screens (12–17) | Onboarding (02–06) | OF (07–11) |
|---|---|---|---|---|
| Família de fontes | `--font-family` | `--f` | `--f` | `--f` |
| Transição | `--transition` | `--t` | `--t` | `--t` |
| Cor de erro | `--error: #DC2626` | `--error: #DC2626` ✓ | `--error: #EF4444` ✗ | inexistente |
| `--gray-100: #F4F4F4` | NÃO existe no DS | inventado | inventado em 11 | inventado em 11 |
| `--green-hover` | NÃO existe no DS | inventado | — | — |
| `--sidebar-w` | NÃO existe no DS | inventado | — | — |
| Tokens de espaçamento (`--space-*`) | 10 níveis | NÃO usados — px hard | NÃO usados | NÃO usados |
| Tokens de tipografia (`--fs-*`) | 9 níveis | NÃO usados — px hard | NÃO usados | NÃO usados |
| Tokens de motion | `--ease-out`, `--duration-*` | só `--ease`, `--t` | só `--ease`, `--t` | só `--ease`, `--t` |
| Letter-spacing tokens | 6 níveis | inline em `em` | inline em `em` | inline em `em` |

**Componentes do DS referenciados por nome (`btn-primary`, `card`, `form-input`, `step-item`, `expandable-row`, `requirement-item`, `modal-overlay`, `progress-card`, `stats-grid`, etc.)** usados nos arquivos:

| Tela | Usa DS? | Reimplementa localmente |
|---|---|---|
| 01_landing | ❌ classes próprias (`hero-*`, `step-*` próprios, `faq-*`, `btn-header-cta`) | tudo |
| 02_cadastro | parcial (`btn btn-primary`, `form-input`, `form-group`, `form-label`) | adiciona `btn__arrow`, `btn__text`, `form-input--disabled`, `form-input--readonly`, `password-strength`, `password-checks` |
| 03–05 | parcial (mesmo padrão de 02) | mesmas extensões |
| 06_conta-criada | parcial | classe própria `success-*` |
| 07_OF-seleção | nenhuma classe DS exceto layout | `bank-card`, `bank-list`, `consent-screen` próprios |
| 08–11 (OF) | parcial | reusa parte do 07 + `confirm-box`, `progress-circle`, `error-card` próprios |
| 12_dashboard | nenhuma classe DS | `sidebar`, `topbar`, `progress-card__*`, `section__*`, `step__*`, `stat-card`, `logout-modal` — todos próprios e duplicados |
| 13–17 | mesmo padrão de 12 | acrescenta `acc__*` (accordion), `custom-select`, `profile-*`, `wa-*` (WhatsApp), `faq-*` |

**Conclusão:** o DS está sendo tratado como **inspiração visual**, não como **fonte da verdade**. Nenhum arquivo importa, espelha ou referencia disciplinadamente os tokens nomeados do DS.

---

## 4. Fichas por arquivo (Etapas 3–4)

> Convenção: P0 = bloqueador · P1 = alto · P2 = médio · P3 = baixo. Patches usam o nome de classe atual; trocar por equivalente DS quando aplicável.

---

### 01_basta-landing.html
**Nota: 6,5/10**

- **P0:** —
- **P1:**
  - 1.730 linhas, 88 KB num único HTML estático para landing pública. CSS inline = 1.070 linhas. Sem cache externo, sem critical CSS. Hero acima da dobra é bloqueado por baixar Plus Jakarta Sans síncrono.
  - **Reimplementa todo o sistema visual localmente** (classes `step-*`, `faq-*`, `hero-*`) — não compartilha **um único** componente com as 16 outras telas.
  - SVG do logo aparece **3x** no mesmo arquivo (header, mobile-nav, footer) — extrair para `<symbol>` em `<svg>` topo + `<use>` 3x reduz ~6 KB.
- **P2:**
  - 23 `role=` espalhados sem necessidade (botões e nav já são semânticos).
  - `<a target="_blank">` sem `rel="noopener noreferrer"` em 0 dos 6 noopener encontrados está OK aqui — mas validar que **todos** os links externos têm `rel`.
  - Cor `#3B82F6` aparece hardcoded — não é nenhum dos tokens DS (`--blue: #3B9EE8`).
- **P3:**
  - `meta theme-color="#FFFFFF"` aqui e `#1A1A1A` em todas as outras: inconsistência cosmética que afeta status bar mobile.

**Patch sugerido — extrair logo:**
```html
<!-- topo do <body> -->
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
  <symbol id="logo-basta" viewBox="0 0 602.25 254.23">
    <path fill="currentColor" d="M0,1.25h48.07c27.52,0,43.03,9.7,53.5,43.21..."/>
    <!-- demais paths -->
  </symbol>
</svg>
<!-- onde o logo aparecer -->
<svg class="logo" aria-label="Basta." role="img"><use href="#logo-basta"/></svg>
```

---

### 02_basta-cadastro.html
**Nota: 6/10**

- **P0:**
  - **Microcopy/render:** verificar se "Crie Sua Conta." está intencional — capitalização de "Sua" quebra norma editorial brasileira; nas demais telas o tom é sentence-case. Padronizar.
- **P1:**
  - Token `--error: #EF4444` diverge do DS (`#DC2626`). Idem 03/04/05.
  - Não usa nenhum `--space-*`, todos os paddings/margens em px hardcoded.
  - Ícone WhatsApp verde `#25D366` hardcoded — promover a token (`--wa: #25D366`, já existente em 17).
  - `<input id="cep" inputmode="numeric">` mas sem máscara visível ou JS de formatação no arquivo.
  - Campos de endereço (`logradouro`, `bairro`, `cidade`, `uf`) estão como `readonly` esperando lookup de CEP — JS do lookup não está presente neste HTML estático. Aceitável em mockup, mas tem que ser explicitado para o time de engenharia.
- **P2:**
  - Senha sem indicador real de força (apenas UI de checks) — o cálculo precisa ser implementado no script.
  - `autocomplete="off"` no CPF impede preenchimento legítimo por gestores de senhas em alguns navegadores. Usar `autocomplete="off"` apenas se for política deliberada.
- **P3:**
  - Falta `<h1>` na página — `<h2>` "Crie Sua Conta." deveria ser `<h1>`. Heading hierarchy quebrada.

**Patch — heading e error token:**
```diff
-      <h2 class="form__title">Crie Sua Conta.</h2>
+      <h1 class="form__title">Criar conta.</h1>
...
-      --error:      #EF4444;
+      --error:      #DC2626; /* alinhado ao DS */
```

---

### 03_basta-login.html
**Nota: 6/10**

- **P0:** —
- **P1:**
  - Mesmo `--error: #EF4444` divergente.
  - `<h2 class="form__title">Acesse sua conta.</h2>` — sem `<h1>`. Ajustar.
  - Form sem `novalidate` deliberado e sem feedback de erro de credencial (mockup).
- **P2:**
  - `<a class="btn">` aparece para "Esqueci minha senha" — está OK, é navegação. Mas o CTA principal "Entrar" deve ser `<button type="submit">` (já é, OK).
  - "Continuar com Google/Apple" se existir nesta tela precisa de `aria-label` claro.
- **P3:**
  - `theme-color` `#1A1A1A` no head bloqueia status bar — verificar se é intencional para login (split entre marketing claro e app escuro).

---

### 04_basta-recuperar-senha.html
**Nota: 6,5/10**

- **P0:** —
- **P1:**
  - Mesmo `--error: #EF4444` divergente.
  - Sem `<h1>`. "Esqueceu a Senha?" deveria ser `<h1>`.
- **P2:**
  - 2 estados na mesma página ("Esqueceu a Senha?" e "Link enviado.") — atualmente mostrados via toggle JS no mesmo HTML. Em produção: rota separada ou estado controlado por React.
- **P3:** —

---

### 05_basta-redefinir-senha.html
**Nota: 6/10**

- **P0:** —
- **P1:**
  - 5 botões, só 1 tem `type=` — os outros 4 são default `type="submit"` dentro de form. Risco de submit acidental ao clicar em "mostrar senha".
  - Mesmo `--error` divergente.
- **P2:**
  - Indicador de força de senha presente; validar mesma lógica que 02.
- **P3:** —

**Patch:**
```diff
-<button class="password-toggle">…</button>
+<button type="button" class="password-toggle" aria-label="Mostrar senha">…</button>
```

---

### 06_basta-conta-criada.html
**Nota: 4,5/10** ⚠

- **P0:**
  - **Microcopy quebrada:** `<h1>` renderiza "Conta criada**com** sucesso." (palavras grudadas — `<span>Conta criada</span><span>com sucesso.</span>` sem espaço). Bug visível na primeira impressão pós-cadastro.
  - **Sem `<main>`, `<section>`, `<header>`** — apenas `<div>`s. Tela mais "cerimonial" do funil e a mais pobre semanticamente.
- **P1:**
  - Sem `meta description`. Opcional para tela autenticada, mas zero coerência com 01–05 que têm.
  - Sem JS, sem auto-redirect — presume clique manual no CTA.
- **P2:** —
- **P3:** —

**Patch microcopy:**
```diff
-<span>Conta criada</span><span>com sucesso.</span>
+<span>Conta criada</span> <span>com sucesso.</span>
```
Ou em uma única linha: `<h1>Conta criada<br>com sucesso.</h1>`.

---

### 07_basta-of-selecao-banco.html
**Nota: 5/10**

- **P0:**
  - **6 `style=` inline** (mais alto do funil). Cores institucionais de bancos hardcoded: `#003882` BB, `#005CA9`, `#8A05BE` Nubank, `#CC092F` Bradesco, `#E06000`, `#EC0000`. Mover para um mapa de constantes (`bank-colors.json`) e renderizar via `style="--bank-color:..."`.
  - **0 `<button>` mas 7 `onclick=`** — todo o seletor de banco depende de div clicável sem semântica de botão. Sem `<h1>`. Sem `<main>`.
- **P1:**
  - 7 `tabindex=` espalhados — usar `<button>` resolve sem precisar setar tabindex.
  - Sem `<form>` mesmo sendo passo de credenciais futuro.
- **P2:**
  - Lista de bancos sem busca/filtro — esperado em mockup, marcar como follow-up.
- **P3:** —

**Patch — substituir div clicável por button:**
```diff
-<div class="bank-card" onclick="selectBank('nubank')" tabindex="0" role="button">
+<button type="button" class="bank-card" onclick="selectBank('nubank')">
```

---

### 08_basta-of-credenciais.html
**Nota: 4,5/10** ⚠

- **P0:**
  - **0 `<form>`, 0 `<input>`, 0 `<label>`** — apesar de o título da tela ser "Credenciais". Provavelmente é uma tela de **redirect para banco** (consentimento OF), mas o markup não deixa claro. Adicionar `<h1>` e descrição semântica.
  - Sem `<main>`.
- **P1:**
  - 4 `onclick=` em divs/spans sem role/tabindex.
  - Cor `#8A05BE` (Nubank) hardcoded; promover ao mapa de bank-colors.
- **P2:**
  - `confirm-box__btn--cancel/confirm` é mais um exemplo de botão custom local que deveria reusar `btn-outline-black` + `btn-primary` do DS.
- **P3:** —

---

### 09_basta-of-instrucao-banco.html
**Nota: 5/10**

- **P0:** —
- **P1:**
  - 6 `role=` para guiar leitor — mas sem `<h1>`. Página de instruções deve ter heading.
  - Cor `#FEF2F2` hardcoded (background suave de alerta) — não tem token equivalente no DS.
- **P2:**
  - Markup de instruções (passos) deveria reusar `step-item` do DS, não classe local.
- **P3:** —

---

### 10_basta-of-progresso.html
**Nota: 6/10**

- **P0:** —
- **P1:**
  - **Convenção de botão muda aqui:** `btn btn--primary` e `btn btn--ghost` (BEM duplo-traço). Em 02–09 era `btn btn-primary` (traço simples). Padronizar para uma das duas — eu recomendo o BEM duplo-traço (`btn--primary`).
  - 2 `<a class="btn">` para CTAs — verificar se são navegação (OK) ou ação (não OK).
- **P2:**
  - Progress circle implementado localmente; deveria viver no DS.
  - `--gray-100: #F4F4F4` aparece — promover ao DS ou eliminar.
- **P3:** —

---

### 11_basta-of-erro.html
**Nota: 4/10** ⚠

- **P0:**
  - **Microcopy quebrada:** `<h2>` renderiza "Ahh não, conexão**interrompida**." (palavras grudadas). Mesmo bug de 06.
  - Convenção de botão muda **outra vez:** `btn btn--retry`. Terceira variante em 4 telas.
- **P1:**
  - Sem JS — botão "Tentar novamente" é um `<a>` que recarrega; preferir `<button>` com handler claro.
  - Sem `<h1>`, sem `<main>`.
- **P2:**
  - Cor `#DC2626` (correta do DS) está hardcoded — usar `var(--error)`.
- **P3:** —

**Patch:**
```diff
-<span>conexão</span><span>interrompida.</span>
+<span>conexão</span> <span>interrompida.</span>
...
-<a class="btn btn--retry" href="…">Tentar novamente</a>
+<button type="button" class="btn btn--primary" data-action="retry">Tentar novamente</button>
```

---

### 12_basta-dashboard.html
**Nota: 5,5/10**

- **P0:**
  - **Sidebar + topbar duplicadas inteiras** em 12–17 (~150 linhas idênticas + SVG do logo). Cada nova tela cria mais uma cópia. Sem componentização, isto vira inviável a médio prazo.
- **P1:**
  - 924 linhas de CSS para uma tela só. Boa parte é redefinição local de classes que já existem no DS (`progress-card`, `stats-grid`, `step-item`, `card`).
  - Cor `#eceae4` hardcoded — não está no DS.
  - 4 `onclick=` em elementos não-button.
- **P2:**
  - `<h1>` presente ✓. Hierarquia OK.
  - Modal de logout com `id="logoutTitle"` referenciado por `aria-labelledby` — bem feito. Repetir esse padrão nas demais modais.
- **P3:**
  - Token `--green-hover: #389d3e` poderia ser `color-mix(in srgb, var(--green) 88%, black)` no Next.js — antecipa a portabilidade.

**Patch — extrair sidebar/topbar:** (ver Backlog de Componentização §6)

---

### 13_basta-documentos.html
**Nota: 5/10**

- **P0:**
  - **15 `<div onclick="…">`** — todos os accordions e sub-rows. **Bem feito** que receberam `role="button"`, `tabindex="0"`, `aria-expanded`, `aria-controls`. Só falta o **handler de Enter/Space** no JS (verificar). Caso contrário, P0 vira inválido.
- **P1:**
  - 214 elementos DOM, 60 KB — maior arquivo de tela autenticada. Maior parte é repetição de accordion. Refatorar para template + render JS.
  - Sidebar e topbar duplicadas (idem 12).
- **P2:**
  - Mistura de naming BEM (`acc__header`, `sub-acc__header`, `sub-row`) — coerente entre si, mas isolado das demais telas.
- **P3:** —

---

### 14_basta-contas-bancarias.html
**Nota: 5,5/10**

- **P0:**
  - 8 `onclick=` em divs (selects custom, similar a 15).
- **P1:**
  - Cores institucionais de banco hardcoded outra vez (`#820AD1` Nubank diferente de `#8A05BE` em 07/08; `#CC092F` Bradesco) — **inconsistência interna entre arquivos do mesmo fluxo**.
  - Sidebar/topbar duplicada.
- **P2:**
  - `--gray-100` redefinido aqui também.
- **P3:** —

---

### 15_basta-requerimentos.html
**Nota: 5/10**

- **P0:**
  - **6 `<div class="custom-select__option" onclick=…>` sem role/tabindex** — falha de a11y. Selects customizados sem keyboard support.
- **P1:**
  - 19 `onclick=` no total.
  - Cores institucionais de banco hardcoded com **3 variações para Nubank** entre 07/08/14/15 (`#8A05BE`, `#820AD1`).
- **P2:**
  - Sidebar/topbar duplicada.
- **P3:** —

**Patch — custom select acessível:**
```diff
-<div class="custom-select__option" onclick="pickOption(this)">Nubank</div>
+<button type="button" role="option" class="custom-select__option" onclick="pickOption(this)">Nubank</button>
```

E no container, `role="listbox"` e `aria-activedescendant`.

---

### 16_basta-perfil.html
**Nota: 4/10** ⚠

- **P0:**
  - **8 `<input>` fora de `<form>`.** Browsers não preenchem, autocomplete não funciona, o submit não acontece via Enter, e screen readers anunciam errado.
  - **5 `<button>` sem `type=`.** Default vira submit — mas como não há `<form>`, vira no-op silencioso. Quando entrar no React vai virar bug de submit duplo.
- **P1:**
  - 8 `<label>` com `for=` — bem feito (único arquivo do app que faz isso). Reaproveitar este padrão nas outras telas autenticadas.
  - Sidebar/topbar duplicada.
- **P2:**
  - "Salvar alterações" sem indicação de estado dirty — aceitável em mockup, marcar como follow-up.
- **P3:** —

**Patch:**
```diff
-<div class="profile-form">
+<form class="profile-form" id="profile-form" novalidate>
   <input type="email" id="email" …>
   …
-  <button class="btn btn-primary">Salvar alterações</button>
+  <button type="submit" class="btn btn--primary">Salvar alterações</button>
-</div>
+</form>
```

---

### 17_basta-ajuda.html
**Nota: 5/10**

- **P0:** —
- **P1:**
  - **7 `style=` inline** (maior depois de 07).
  - Cor `#1DA851` (verde escuro WhatsApp variante) e `#25D366` hardcoded — pelo menos `--wa: #25D366` foi promovido a token aqui. Promover `#1DA851` a `--wa-hover`.
  - Cor `#eaf7ec` (verde claro suave) hardcoded — ou virar `color-mix(in srgb, var(--wa) 12%, white)` ou criar token.
  - Sidebar/topbar duplicada.
- **P2:**
  - 9 `onclick=` em divs (FAQs accordions). Verificar a11y idêntica ao 13.
  - Botões "btn-wa" e "btn-logout-cancel/confirm" — 4ª e 5ª variantes nominativas de botão.
- **P3:** —

---

## 5. Backlog de Componentização (Etapa 4)

Padrões repetidos entre os 17 arquivos que pedem componentização imediata:

| # | Componente | Arquivos onde aparece | LOC duplicadas hoje | Ganho estimado |
|---|---|---|---:|---:|
| 1 | **`<Sidebar />`** (nav lateral autenticada) | 12, 13, 14, 15, 16, 17 | ~120 × 6 = **720** | mantém 120, remove 600 |
| 2 | **`<Topbar />`** (header mobile autenticado) | 12, 13, 14, 15, 16, 17 | ~80 × 6 = **480** | mantém 80, remove 400 |
| 3 | **`<LogoBasta />`** (SVG inline) | 01, 12–17 (× 2 cada) | ~90 × 15 = **1.350** | 1 `<symbol>` + 15 `<use>` = ~120; remove ~1.230 |
| 4 | **`<LogoutModal />`** (12, 13, 14, 15, 16, 17) | 12–17 | ~40 × 6 = **240** | mantém 40, remove 200 |
| 5 | **`<AuthFormShell />`** (card central de 02–05) | 02, 03, 04, 05 | ~70 × 4 = **280** | mantém 70, remove 210 |
| 6 | **`<BankCard />`** (07, 08, 14) + mapa de cores | 07, 08, 14, 15 | ~30 × 4 = **120** | mantém 30 + JSON colors = 50; remove 70 |
| 7 | **`<Accordion />`** (sub-acc + acc) | 13, 17 | ~60 × 2 = **120** | mantém 60, remove 60 |
| 8 | **`<CustomSelect />`** acessível | 14, 15 | ~50 × 2 = **100** | mantém 50, remove 50 |
| 9 | **`<ProgressCircle />`** (OF) | 10 (e parcial 09) | ~40 | manter no DS |
| 10 | **`<Btn variant="primary"/"ghost"/"retry"/"wa"/"error"/>`** padronizado | TODOS | ~20 × 17 = **340** | mantém 50 no DS; remove ~290 |
| 11 | **Tokens compartilhados (`tokens.css`)** | TODOS | ~50 × 17 = **850** | mantém 100; remove ~750 |

**Total estimado de redução:** ~**4.000 LOC** (de 8.214 CSS + ~2.000 markup duplicado para ~3.000–4.000 efetivos). Ganho de ~30% no peso total do bundle.

---

## 6. Inconsistências Cross-File (Etapa 5)

1. **`--error` diverge entre tribos.** Onboarding (02–05) usa `#EF4444`; DS e app screens (12–17) usam `#DC2626`. Evidência: `02_basta-cadastro.html:13`, `12_basta-dashboard.html:23`.
2. **Convenção de botão usa 5 padrões diferentes:**
   - `btn btn-primary` (02, 03, 04, 05, 06, 08, 09)
   - `btn btn--primary` / `btn btn--ghost` (10)
   - `btn btn--retry` (11)
   - `btn-logout-confirm` / `btn-logout-cancel` (12, 13, 14, 15, 16, 17)
   - `btn-wa` (17)
3. **Cor institucional do Nubank tem 2 valores:** `#8A05BE` (07, 08, 09, 11) e `#820AD1` (14, 15). Cor real do Nubank: `#820AD1`.
4. **Logo do Basta repetido 15 vezes nas 7 telas autenticadas** (sidebar + topbar de cada). Mesmo SVG path inteiro, byte-a-byte idêntico.
5. **`meta theme-color`:** `01_landing` usa `#FFFFFF`; todas as outras usam `#1A1A1A`. Decidir intenção.
6. **`meta description`:** existe em 01–05; ausente em 06–17. Para PWA / share / SEO de marketing, padronizar — mesmo que seja "noindex" para telas autenticadas.
7. **Hierarquia de heading:** `<h1>` ausente em 02, 03, 04, 05, 07, 08, 09, 10, 11. Falha P1 sistêmica.
8. **`<form>` ausente onde deveria existir:** `08_credenciais` (esperado se for redirect; documentar) e `16_perfil` (não há justificativa).
9. **Microcopy com palavras grudadas:** 06 (`criadacom`) e 11 (`conexãointerrompida`). Provavelmente mesmo padrão de `<span>` adjacente sem espaço — buscar globalmente.
10. **Tokens redefinidos com nomes encurtados** (`--f`, `--t` em vez de `--font-family`, `--transition`). Aparece em 02, 03, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17 — todos exceto 01.
11. **Espaçamento em px hardcoded** em todos os 17 arquivos. Tokens `--space-*` do DS nunca aparecem.
12. **Tipografia em px hardcoded** em todos os 17 arquivos. Tokens `--fs-*` do DS nunca aparecem.
13. **`<button type=>`** ausente em 16 e parcialmente em 05 — risco de submit acidental.
14. **`<a>` usado como botão** em 02, 06, 10, 11 para CTAs de ação (não navegação) — anti-pattern.
15. **`role=` e `tabindex=` aplicados em divs clicáveis** em 07, 08, 09, 11, 13, 14, 15, 16, 17 — corrigível trocando por `<button>`.

---

## 7. Plano de Refactor em 3 ondas

### Onda 1 — **Faça antes de escrever a primeira linha de Next.js**
Custo estimado: 2–3 dias de um sênior · Ganho: bloqueia débito técnico de virar débito de produção.

1. Criar `tokens.css` único, derivado do `basta-design-system.html`. Substituir os 17 `:root` por `<link rel="stylesheet" href="tokens.css">`.
2. Padronizar nomes encurtados → canônicos: `--f` → `--font-family`, `--t` → `--transition`, `--ease` → `--ease-out`. Find-and-replace global.
3. Corrigir `--error` em 02–05 para `#DC2626`.
4. Promover `--wa: #25D366`, `--wa-hover: #1DA851`, `--bank-nubank: #820AD1` (e os outros bancos) para tokens nomeados.
5. Extrair logo SVG para `/assets/logo-basta.svg` (ou `<symbol>` num arquivo `_logo-symbol.html` incluído via SSR).
6. Corrigir bugs de microcopy: `06` e `11` (espaços faltando). Buscar padrão `</span><span>` sem espaço globalmente.
7. Padronizar convenção de botão: escolher **`btn btn--primary | btn--ghost | btn--retry | btn--wa | btn--error`** (BEM duplo-traço). Substituir as 5 variantes por uma só.
8. Adicionar `<h1>` faltante em 02, 03, 04, 05, 07, 08, 09, 10, 11. Trocar `<h2>` da tela principal de cada uma por `<h1>`.

### Onda 2 — **Antes de escalar telas (durante a port para Next.js)**
Custo: 5–7 dias · Ganho: -30% LOC, dobra a velocidade de adicionar tela nova.

9. Componentizar: `<Sidebar />`, `<Topbar />`, `<LogoBasta />`, `<LogoutModal />`, `<AuthFormShell />`, `<BankCard />` (com `bankColors.json`), `<Accordion />`, `<CustomSelect />` (acessível com `role="listbox"` + keyboard), `<ProgressCircle />`, `<Btn />`.
10. Trocar todo `<div onclick="…">` por `<button>` semântico — em 07, 08, 09, 11, 13, 14, 15, 16, 17. Remove `tabindex` e `role` redundantes.
11. Em `16_perfil`: envolver inputs em `<form>` e adicionar `type="submit"`/`type="button"` em todos os 5 botões.
12. Em `02_cadastro` e `05_redefinir`: garantir `type="button"` em todo botão que **não** é submit (mostrar senha, etc.).
13. Trocar `<a class="btn">` por `<button>` em 02, 06, 10, 11 quando o CTA for ação (não navegação).
14. Implementar handlers Enter/Space nos accordions de 13 e 17 se ainda não houver.
15. Adicionar `meta description` em 06–17 ou marcar `<meta name="robots" content="noindex">` em telas autenticadas.

### Onda 3 — **Pode esperar (cosmético / SEO / performance)**
Custo: 2 dias · Ganho: polish + Lighthouse.

16. Padronizar `meta theme-color` por contexto (claro para landing, escuro para app).
17. Otimizar fontes: usar `font-display: swap` + subset Latin-Extended.
18. Adicionar `loading="lazy"` e `width`/`height` em qualquer `<img>` que entrar (atualmente 0 imgs).
19. Critical CSS para `01_landing` (extrair acima-da-dobra; mover resto para arquivo externo).
20. Substituir `--green-hover` por `color-mix(in srgb, var(--green) 88%, black)` no momento da port.

---

## 8. O que NÃO foi auditado

- **Comportamento JS**: cada arquivo tem 70–170 linhas de JS inline. Foi feita análise estrutural (presença de `onclick`, formulários), mas não execução nem teste de keyboard navigation real. Cobrir com Playwright/Cypress na onda 2.
- **Contraste real WCAG**: cores foram inventariadas mas não testadas par-a-par contra fundo. Recomendo rodar axe-core ou Lighthouse em cada tela.
- **Renderização cross-browser/device**: nenhuma captura visual foi feita. Ideal: rodar Chromatic ou Percy nos 17 HTMLs.
- **`basta-design-system.html` (linhas 800–1879)**: foram lidas as primeiras ~810 linhas (tokens, botões, cards, steps, badges, forms, expandable, requirements, modals, dashboard). Componentes posteriores (`stats-grid` e além) não foram cobertos em detalhe — não invalidam o achado de drift, que é estrutural.
- **Conformidade LGPD/financeira**: campo CPF, dados bancários, OF — não auditado quanto a tratamento de dados, criptografia, retenção. Fora do escopo deste passe técnico.
- **Performance real (FCP/LCP/CLS)**: estimativas baseadas em peso e estrutura, sem medição em browser.

---

*Fim do documento. Pronto para virar issues no backlog (recomendo 1 issue por linha do §6 e §7, etiquetadas por onda e prioridade).*
