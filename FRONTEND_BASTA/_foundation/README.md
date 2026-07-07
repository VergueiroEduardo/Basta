# Foundation Basta — Guia de uso

Este diretório contém a **fonte única da verdade** visual e técnica do Basta.
Tudo aqui é derivado do `basta-design-system.html`. Nada é inventado.

## Como usar em uma tela

No `<head>` do arquivo:

```html
<link rel="stylesheet" href="_foundation/tokens.css" />
<link rel="stylesheet" href="_foundation/reset.css" />
<link rel="stylesheet" href="_foundation/typography.css" />
<link rel="stylesheet" href="_foundation/layout.css" />

<link rel="stylesheet" href="_components/btn.css" />
<link rel="stylesheet" href="_components/form.css" />
<!-- ...só os que a tela usa -->
```

No topo do `<body>`, antes de qualquer conteúdo:

```html
<!-- Conteúdo do _partials/logo-symbol.html embutido aqui -->
<svg width="0" height="0" style="position:absolute" aria-hidden="true">
  <symbol id="logo-basta" viewBox="0 0 602.25 254.23">…</symbol>
</svg>
```

E onde quiser usar o logo:

```html
<svg class="sidebar__logo" aria-label="Basta." role="img">
  <use href="#logo-basta"/>
</svg>
```

## Convenções

- **Naming:** BEM duplo-traço para variants — `btn btn--primary`, não `btn btn-primary`.
  Aliases de legado existem em `_components/btn.css` para retrocompatibilidade durante a migração.
- **Cores:** sempre via `var(--token)`. Nunca hex literal exceto para cores institucionais de bancos (que ficam em tokens dedicados `--bank-*`).
- **Espaçamento:** sempre via `var(--space-*)`. Px hardcoded é dívida técnica.
- **Tipografia:** sempre via `var(--fs-*)` ou classes utilitárias (`heading-1`, `body`, `label`).
- **Logo:** sempre `<use href="#logo-basta">`. Cor controlada por `currentColor` (definir `color:` no container).

## Arquivos

```
_foundation/
  tokens.css        → todos os tokens DS (cores, fontes, espaços, motion, layout)
  reset.css         → reset minimalista, focus visible, skip link, sr-only
  typography.css    → display-1, heading-1, body, label utilities
  layout.css        → container, stack, cluster, grid-2/3, app-shell

_components/
  btn.css           → btn + 7 variants (primary, ghost, outline-*, error, wa, retry)
  form.css          → form-group, form-label, form-input, form-select
  card.css          → card, card--dark, card--soft
  badge.css         → badge--success/warning/info/error
  modal.css         → modal-overlay + modal-content
  sidebar.css       → sidebar autenticada (12-17)
  topbar.css        → topbar mobile autenticada (12-17)
  accordion.css     → para FAQ, docs (13, 17)
  custom-select.css → select acessível com listbox/option (15)
  bank-card.css     → cards de banco com --bank-color (07, 14)
  progress.css      → progress-card, progress-bar, progress-circle (10, 12)

_partials/
  logo-symbol.html  → <svg><symbol id="logo-basta">…</symbol></svg>
  sidebar.html      → markup canônico da sidebar (12-17)
  topbar.html       → markup canônico da topbar mobile (12-17)
  logout-modal.html → markup canônico do modal de logout
  head-meta.html    → meta tags padrão para telas autenticadas

_scripts/
  accordion.js      → toggle + keyboard support (Enter, Space)
  masks.js          → CPF, CNPJ, CEP, telefone, data, moeda BRL
  custom-select.js  → listbox acessível com keyboard nav completa
  sidebar.js        → marca página ativa + abre/fecha logout modal
  form-validation.js → validação CPF + helpers para erro
```

## Princípio de migração

A Foundation foi adicionada **sem remover** o CSS local antigo, para garantir zero
quebra visual. Cada arquivo terá um commit separado para:

1. Importar Foundation
2. Padronizar naming (find-and-replace)
3. Remover CSS local que agora vem da Foundation
4. Substituir SVG do logo inline por `<use>`
5. Substituir sidebar/topbar inline pelo conteúdo do partial

A próxima vez que criar uma tela nova, ela já nasce consumindo Foundation.
