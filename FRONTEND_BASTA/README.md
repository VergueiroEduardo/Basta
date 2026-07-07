# FRONTEND_BASTA

**Pacote de entrega para o time de desenvolvimento.** Última versão consolidada de todos os HTMLs do produto Basta, incluindo Foundation (design system executável), componentes, partials, scripts, assets e documentação.

**Stack-alvo final:** Next.js 14 + React + Tailwind + Supabase + Vercel
**Estado atual:** HTML estático servível diretamente (Vercel ou qualquer host estático). A estrutura espelha o que vai virar React.

---

## O que tem aqui

```
FRONTEND_BASTA/
├── README.md                          ← este arquivo
├── HANDOVER.md                        ← instruções específicas para o dev team
├── basta-design-system.html           ← DS de referência (fonte da verdade visual)
│
├── 01_basta-landing.html              ← landing pública
├── 02_basta-cadastro.html             ← onboarding (cadastro → conta criada)
├── 03_basta-login.html
├── 04_basta-recuperar-senha.html
├── 05_basta-redefinir-senha.html
├── 06_basta-conta-criada.html
├── 07_basta-of-selecao-banco.html     ← Open Finance (07 → 11)
├── 08_basta-of-credenciais.html
├── 09_basta-of-instrucao-banco.html
├── 10_basta-of-progresso.html
├── 11_basta-of-erro.html
├── 12_basta-dashboard.html            ← app autenticado (12 → 17)
├── 13_basta-documentos.html
├── 14_basta-contas-bancarias.html
├── 15_basta-requerimentos.html
├── 16_basta-perfil.html
├── 17_basta-ajuda.html
│
├── _foundation/                       ← tokens + reset + typography + layout + grid
│   ├── tokens.css                     ← design tokens canônicos (ÚNICA fonte da verdade)
│   ├── reset.css                      ← reset, focus visible, skip link, prefers-reduced-motion
│   ├── typography.css                 ← display, heading, body, label utilities
│   ├── layout.css                     ← container, stack, cluster, app-shell
│   ├── grid.css                       ← grid 12-col, gutters fluidos por breakpoint, safe-area
│   └── README.md                      ← guia de uso da Foundation
│
├── _components/                       ← componentes UI reutilizáveis
│   ├── btn.css                        ← btn + 7 variants (primary, ghost, outline-*, error, wa, retry)
│   ├── form.css                       ← form-group, form-label, form-input, form-select, form-error
│   ├── card.css
│   ├── badge.css
│   ├── modal.css
│   ├── sidebar.css                    ← sidebar autenticada (12-17)
│   ├── topbar.css                     ← topbar mobile (12-17)
│   ├── accordion.css                  ← FAQ, documentos
│   ├── custom-select.css              ← select acessível com keyboard nav
│   ├── bank-card.css                  ← bank cards com --bank-color custom prop (07, 14)
│   ├── progress.css                   ← progress-card, progress-bar, progress-circle
│   └── logo.css                       ← logo color contexts (.logo--on-dark / .logo--on-light)
│
├── _partials/                         ← markup reutilizável (vira <Component /> no React)
│   ├── logo-symbol.html               ← <symbol id="logo-basta"> — single source do logo
│   ├── sidebar.html
│   ├── topbar.html
│   ├── logout-modal.html
│   └── head-meta.html
│
├── _scripts/                          ← JS modulares (vão virar hooks/utilities no React)
│   ├── accordion.js                   ← toggle + keyboard support
│   ├── masks.js                       ← CPF, CNPJ, CEP, telefone, data, BRL
│   ├── custom-select.js               ← listbox acessível
│   ├── form-validation.js             ← CPF + helpers
│   └── sidebar.js                     ← active page + logout modal
│
├── _assets/                           ← imagens estáticas
│   └── nvidia-inception-badge.svg
│
└── _docs/                             ← documentação completa para o dev team
    ├── 01_AUDITORIA_INICIAL.md
    ├── 02_PLANO_REFACTOR.md
    ├── 03_RELATORIO_FOUNDATION.md
    ├── 04_PLANO_GRIDS.md
    ├── 05_AUDITORIA_RESPONSIVIDADE.md
    ├── 06_PLANO_MOBILE.md
    └── 07_RELATORIO_MOBILE.md
```

---

## Como rodar localmente

```bash
cd FRONTEND_BASTA
npx http-server . -p 8080
# abrir http://localhost:8080/01_basta-landing.html
```

Não há build step. HTML estático puro com paths relativos. Funciona em qualquer host estático (Vercel, Netlify, S3 + CloudFront).

---

## Antes de começar a portar

**Leia primeiro `HANDOVER.md`.** Contém:
- O que está pronto e por quê
- O que NÃO está pronto (e dívida técnica conhecida)
- Como mapear cada parte para React
- Decisões arquiteturais que precisam ser preservadas
- Validações obrigatórias antes de qualquer release

---

## Princípios não-negociáveis

1. **`tokens.css` é fonte única da verdade visual.** Tudo derivado dali.
2. **BEM duplo-traço** para variants (`btn btn--primary`, não `btn btn-primary`).
3. **Semântica HTML primeiro:** `<button>` para ação, `<a>` para navegação, `<form>` para inputs.
4. **Mobile como caso primário**, não responsive afterthought.
5. **A11y testada, não assumida:** axe-core ≥95.
6. **Microcopy é UI:** alterar texto exige aprovação do PO/design.

---

*Última atualização: 26/04/2026*
