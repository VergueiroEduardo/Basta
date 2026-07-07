# Handover Técnico — FRONTEND_BASTA

**Para:** time de desenvolvimento Basta
**Stack-alvo:** Next.js 14 (App Router) + React 18 + Tailwind + Supabase + Vercel
**Estado deste pacote:** HTML estático production-ready, **especificação executável** do que vai virar React

---

## 1. Resumo executivo

Este pacote contém os **17 HTMLs canônicos** do produto Basta, refatorados em 9 ondas durante março–abril/2026. Está pronto para servir como:

1. **Spec de design** para o time de produto.
2. **Especificação executável** para a port React (cada `_components/*.css` vira componente, cada `_partials/*.html` vira `<Component />`).
3. **Site temporário** se precisar deploy estático imediato (Vercel funciona out-of-the-box).

**Não está pronto para produção como app real** — não tem backend, autenticação, Supabase wiring, validação server-side, máscaras de input em produção, etc. É a camada UI.

---

## 2. Métricas técnicas atuais

| Métrica | Estado |
|---|---|
| Total de telas | 17 |
| Total de bytes | 602.101 (~588 KB) |
| Hierarquia de heading (`<h1>` único por tela) | 17/17 ✓ |
| Foundation tokens.css consumido | 17/17 ✓ |
| Single source do logo (`<symbol>`) | 17/17 ✓ |
| Inputs anti-zoom iOS (≥16px mobile) | 5/5 ✓ |
| `safe-area-inset` em fixed elements | 17/17 ✓ |
| Touch targets ≥44px | ✓ (`.btn--sm` 44px, `.nav-item` 48px) |
| Hover-guard touch (sem stuck hover) | 6/6 telas autenticadas ✓ |
| App-shell sidebar↔topbar threshold | 960px (todas as 6) ✓ |
| Tokens órfãos | 0 ✓ |
| Smoke test estrutural | 17/17 ✓ |

---

## 3. Estrutura → mapeamento React

### Foundation → `app/globals.css` ou `theme/`

```
_foundation/tokens.css       →  CSS variables em globals.css OU tema Tailwind (tailwind.config.ts)
_foundation/reset.css        →  globals.css (manter)
_foundation/typography.css   →  Tailwind utility classes ou globals.css
_foundation/layout.css       →  Tailwind container + custom utilities
_foundation/grid.css         →  Tailwind container queries OU manter como CSS layer
```

**Recomendação:** mapear `tokens.css` para `tailwind.config.ts`:

```ts
// tailwind.config.ts
export default {
  theme: {
    colors: {
      black: 'var(--black)',
      white: 'var(--white)',
      green: { DEFAULT: 'var(--green)', hover: 'var(--green-hover)' },
      // ...
    },
    fontFamily: { sans: 'var(--font-family)' },
    spacing: { /* --space-* */ },
  }
}
```

### Components → `components/ui/`

```
_components/btn.css          →  components/ui/Button.tsx (variant prop)
_components/form.css         →  components/ui/{Input,Label,Select,Form}.tsx
_components/card.css         →  components/ui/Card.tsx
_components/modal.css        →  components/ui/Dialog.tsx (radix-ui ou headless-ui)
_components/sidebar.css      →  components/layout/Sidebar.tsx
_components/topbar.css       →  components/layout/Topbar.tsx
_components/accordion.css    →  components/ui/Accordion.tsx (radix-ui)
_components/custom-select.css→  components/ui/Select.tsx (radix-ui Listbox)
_components/bank-card.css    →  components/ui/BankCard.tsx
_components/progress.css     →  components/ui/{Progress,ProgressCircle}.tsx
_components/logo.css         →  components/ui/Logo.tsx (com prop `tone`: "light" | "dark")
```

**Recomendação:** usar `radix-ui` (ou `shadcn/ui`) para primitives — eles já resolvem accessibility, focus management, escape key, keyboard nav. Reaproveitar nosso CSS via `className`.

### Partials → componentes finais

```
_partials/logo-symbol.html   →  app/layout.tsx (inserido uma vez no <body>)
_partials/sidebar.html       →  components/layout/Sidebar.tsx
_partials/topbar.html        →  components/layout/Topbar.tsx
_partials/logout-modal.html  →  components/dialogs/LogoutDialog.tsx
_partials/head-meta.html     →  app/layout.tsx (metadata API do Next 14)
```

### Scripts → hooks/utils

```
_scripts/accordion.js        →  Use radix-ui Accordion (já implementa)
_scripts/masks.js            →  hooks/useMask.ts ou lib via react-imask
_scripts/custom-select.js    →  Use radix-ui Listbox (já implementa)
_scripts/form-validation.js  →  React Hook Form + Zod
_scripts/sidebar.js          →  hooks/useActivePage.ts + componente Dialog
```

### Páginas → `app/(routes)/`

```
01_basta-landing.html        →  app/page.tsx                     (público)
02_basta-cadastro.html       →  app/(auth)/cadastro/page.tsx
03_basta-login.html          →  app/(auth)/login/page.tsx
04_basta-recuperar-senha.html →  app/(auth)/recuperar-senha/page.tsx
05_basta-redefinir-senha.html →  app/(auth)/redefinir-senha/page.tsx
06_basta-conta-criada.html   →  app/(auth)/conta-criada/page.tsx
07-11 (Open Finance)         →  app/(of)/[banco|credenciais|instrucao|progresso|erro]/page.tsx
12-17 (App)                  →  app/(app)/[dashboard|documentos|contas|requerimentos|perfil|ajuda]/page.tsx
```

**Layouts:**
- `app/(auth)/layout.tsx` — fundo escuro, logo branco, sem sidebar
- `app/(of)/layout.tsx` — sem sidebar, sem header (passo cerimonial do funil)
- `app/(app)/layout.tsx` — sidebar + topbar + main shell (12-17)

---

## 4. O que está pronto

### Funcional
- 17 telas com markup semântico, classes BEM consistentes, IDs únicos.
- Hierarquia de heading em todas as telas (1 `<h1>` por página).
- Forms com `<label for=>`, `inputmode`, `autocomplete`, `type=`.
- Modals com `role="dialog"`, `aria-modal`, `aria-labelledby`.
- Acessibilidade: skip link, focus visible, `prefers-reduced-motion` global.

### Visual
- Design tokens completos (cores, fontes, espaçamento, motion, layout, sombras).
- Tipografia fluida em headlines (`clamp()`).
- App-shell responsivo (sidebar fixa em ≥960px, topbar mobile abaixo).
- Logo único via `<symbol>` + `<use>` (zero duplicação).
- NVIDIA Inception badge no footer da landing.

### Mobile
- Inputs com `font-size: 16px` mobile (anti auto-zoom iOS).
- `safe-area-inset` em todos os fixed elements.
- Touch targets ≥44px (WCAG 2.5.5 + iOS HIG).
- Hover-guard global em telas autenticadas.
- `viewport-fit=cover` em 17/17.

---

## 5. O que NÃO está pronto (dívida conhecida)

### Backend e dados
- Nenhuma chamada de API real. Tudo é mockup com dados estáticos.
- Sem integração Supabase (auth, database, storage).
- Sem integração Pluggy/Open Finance.
- Sem ClickSign para assinatura digital.
- Sem WhatsApp Cloud API.

### Validação
- Forms validam apenas via JS leve em `_scripts/form-validation.js` (CPF). Para produção: usar **React Hook Form + Zod**.
- Sem CSRF protection. Implementar via Next.js Server Actions com tokens.

### Imagens
- Hero da landing usa `<img class="hero-bg-img">` com src vazio. Adicionar foto real antes de publicar.
- Sem sistema de imagens otimizadas (`next/image`). Implementar na port.

### Performance
- CSS local ainda existe nos arquivos (vai ser eliminado quando virar componentes React reaproveitando Foundation).
- Sem critical CSS extraction.
- Sem code splitting.

### A11y
- Auditoria axe-core não foi rodada em devices reais.
- Contraste de cores não foi medido tela a tela (alguns gray-600 sobre off-white podem não passar AA).
- Screen reader passes (VoiceOver, NVDA) não foram feitos.

---

## 6. Validações obrigatórias antes de qualquer release

| # | Validação | Ferramenta | Threshold |
|---|---|---|---|
| 1 | Lighthouse Mobile Performance | Chrome DevTools | ≥85 |
| 2 | Lighthouse Mobile Accessibility | Chrome DevTools | ≥95 |
| 3 | Lighthouse Mobile Best Practices | Chrome DevTools | ≥95 |
| 4 | axe-core: violations sérias/críticas | `@axe-core/cli` | 0 |
| 5 | CLS (Cumulative Layout Shift) | Web Vitals | <0,05 |
| 6 | LCP (Largest Contentful Paint) em 4G | Lighthouse | <2,5s |
| 7 | Smoke test em iPhone real (com notch) | manual | input não dá zoom; FAB não cobre home indicator |
| 8 | Smoke test em Android entry-level | BrowserStack | layout não quebra abaixo de 360px |
| 9 | HTML válido | `html-validate` | 0 erros |
| 10 | CSS válido | `stylelint` | 0 erros |

---

## 7. Devices a testar (mínimo viável)

- iPhone SE (375×667) — menor moderno
- iPhone 14 Pro (393×852) — notch + dynamic island
- Pixel 7 (412×915) — Android moderno
- Galaxy A54 (360×780) — entry-level brasileiro
- iPad Mini (768×1024) — tablet portrait
- iPad Pro (1024×1366) — tablet landscape
- MacBook Air (1440×900) — desktop pequeno
- iMac (1920×1080) — desktop grande

---

## 8. Decisões arquiteturais que precisam ser preservadas

1. **Naming BEM duplo-traço** para variants. `btn btn--primary`, não `btn-primary`.
2. **Logo via `<symbol>` + `<use>`.** Nunca duplicar SVG inline.
3. **Cores institucionais de bancos** vivem em `tokens.css` como `--bank-*`. Aplicar via `style="--bank-color: var(--bank-nubank)"` no markup.
4. **Hover apenas com `@media (hover: hover)`** ou via hover-guard global. Nunca deixar hover ativo em touch.
5. **Modais com `aria-labelledby` e `aria-describedby`.** Sempre.
6. **`<form>` envolvendo qualquer agrupamento de input.** Nunca inputs órfãos.
7. **`type="button"` explícito** em qualquer `<button>` que não é submit.
8. **`safe-area-inset` em fixed elements**, nunca valores absolutos sem `max()`.

---

## 9. Backlog (próximas ondas, não-bloqueantes)

- **Onda 9b — Reduzir 9 breakpoints da landing para 4 canônicos** (640/768/1024/1200). Requer screenshot diff em viewports intermediárias. Ver `_docs/05_AUDITORIA_RESPONSIVIDADE.md`.
- **Onda 10 — Critical CSS extraction** para landing (above the fold).
- **Onda 11 — Code splitting** + `next/dynamic` para modais e componentes pesados.
- **Onda 12 — Storybook** para os componentes da Foundation (importante para o dev team trabalhar em paralelo).
- **Onda 13 — Container queries** (`@container`) onde fizer sentido — futuro-proof para o React.

---

## 10. Contatos

- **Produto:** Eduardo Vergueiro (eavergueiro@gmail.com)
- **Suporte ao usuário:** ola@bastaeponto.com.br
- **Repositório de tokens visuais:** `basta-design-system.html` (na raiz desta pasta)

---

*Boa port. Qualquer dúvida sobre uma decisão específica, ler `_docs/` na ordem 01→07.*
