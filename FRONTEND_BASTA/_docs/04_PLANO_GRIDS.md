# Plano de Revisão de Grids + Revisão Geral — Basta

**Autor:** Claude (lente de senior designer Huge Inc + engenheiro front-end)
**Insumo:** screenshots do hero do `01_basta-landing.html` + auditoria estrutural pós-Onda 1
**Status:** **Para aprovação antes de execução.**

---

## 0. O que aconteceu

Os screenshots mostram três sintomas no hero:

1. **Headline `Saia do endividamento de forma ju...`** sangra à esquerda — sem gutter respeitado, conteúdo cola na borda da viewport.
2. **CTA `COMEÇAR AGORA`** corta na direita — o gutter direito também não existe.
3. **Header preto (acima)** mantém uma margem visível, **conteúdo do hero (abaixo) não.** Quebra do contrato visual.

Causa-raiz mapeada (não é miopia da Foundation; é **regressão da Onda 1**):

> O `cleanup_local_root.py` removeu o bloco `:root` local de cada arquivo. O landing usa `--max-w` e `--px` — tokens **encurtados** que **só existiam** naquele `:root` local e nunca foram migrados para `tokens.css` (eu criei aliases para `--f`, `--t`, `--ease`, mas esqueci destes dois). Resultado: `padding: 0 var(--px)` resolve para `padding: 0` e o conteúdo fica sem gutter.

Outros achados ligados:

4. **Logo Basta no footer está no markup, mas pode estar invisível.** O baseline usava `<path class="logo-fill" d="…">` + CSS `.footer-logo-svg .logo-fill { fill: var(--black); }`. Substituí por `<use href="#logo-basta">`, que herda `currentColor` do `<symbol>`. As regras `.logo-fill`/`.logo-dot` não casam mais — o footer logo provavelmente está com cor herdada errada (ou preto sobre branco por sorte, ou invisível em alguns contextos).
5. **NVIDIA Inception badge** está em `Basta/03_Design/nvidia-inception-badge.svg` (12 KB, fora de `01_Sistema/`). **Zero referências** em qualquer HTML. Foi planejado, nunca implementado.
6. **Hero usa `.container > .hero-content` com `max-width: 680px`** — design intencional (texto narrow, fundo full-bleed). Mas como o `.container` está sem padding, o `max-width: 680px` está sendo medido a partir de 0px, então a leitura é "headline ocupa 680px do canto esquerdo, o resto fica vazio" — não "headline tem max 680px **dentro** de um container com gutter". Diferença visual = sangria de borda.

---

## 1. Princípios da revisão (lente Huge)

A correção precisa ser feita uma vez, formal, e nunca mais regredir. Princípios que guiam:

1. **Grid é tabela formal, não soma de paddings ad-hoc.** Definir `--container-max`, `--gutter-mobile`, `--gutter-tablet`, `--gutter-desktop`, `--column-gap`, e usar **só** esses tokens.
2. **Gutter responde a viewport, não a "talvez fique melhor".** 16px mobile (alinha com edge-to-edge UI), 24px tablet (≥768), 32px desktop (≥1024) — proporção 1:1.5:2.
3. **Hero, header e footer compartilham o mesmo `.container`.** Se um tem 24px de gutter, todos têm. Quebra disso é decisão criativa explícita (ex.: fundo full-bleed mas conteúdo alinhado).
4. **Tokens canônicos têm aliases retrocompatíveis durante a migração.** Nunca remover token usado sem rodar diff antes.
5. **Logo Basta tem 1 fonte (`<symbol>`), 3 contextos.** Cor controlada por classe contextual: `.logo--on-dark` (header, hero), `.logo--on-light` (footer). Nunca por `currentColor` herdado por acidente.
6. **Selos de credibilidade (Inception, Cubo, etc.) são âncora institucional.** Vivem no footer, não como decoração — como prova.
7. **Safe area mobile.** iOS notch e Android nav bar: `padding-inline: max(var(--gutter-mobile), env(safe-area-inset-left))`.

---

## 2. Plano em 4 ondas

| Onda | Escopo | Custo | Risco |
|---|---|---:|:---:|
| **7a — Hotfix regressão** | Restaurar `--max-w` e `--px` como aliases; corrigir cor do logo nos 3 contextos | 30 min | baixo |
| **7b — Grid system formal** | Criar `_foundation/grid.css` com tokens nomeados; promover `.container` em todos os 17 arquivos | 2h | médio |
| **7c — Brand anchors no footer** | Mover Inception badge para `_assets/`, inserir no footer com link oficial; validar logo footer | 1h | baixo |
| **7d — Auditoria visual de margem** | Screenshot diff de header/hero/footer em desktop e mobile; ajustes finos | 1h | baixo |

**Total estimado:** ~5 horas de execução. Ordem importa — **7a é hotfix**, não pode esperar; 7c e 7d podem ser paralelas.

---

### Onda 7a — Hotfix da regressão (urgente)

**O que muda:**

`_foundation/tokens.css` ganha 4 aliases retrocompatíveis no bloco DEPRECATED:

```css
/* === LEGADO (DEPRECATED — usado pelo 01_landing) === */
--max-w:  var(--max-width);    /* 1200px */
--px:     var(--px-mobile);    /* 16px (mobile-first) */
--px-md:  var(--px-desktop);   /* 24px (≥1024) */
```

`_components/btn.css` (ou novo `_components/logo.css`) ganha as classes contextuais:

```css
.logo--on-dark  { color: var(--white); }
.logo--on-light { color: var(--black); }
```

E em `01_basta-landing.html`, **3 alterações cirúrgicas** (markup, sem alterar texto):

```diff
- <svg class="logo-svg logo-svg-lg" aria-label="Basta." role="img"><use href="#logo-basta"/></svg>
+ <svg class="logo-svg logo-svg-lg logo--on-dark" aria-label="Basta." role="img"><use href="#logo-basta"/></svg>

- <svg class="hero-logo" aria-label="Basta." role="img"><use href="#logo-basta"/></svg>
+ <svg class="hero-logo logo--on-dark" aria-label="Basta." role="img"><use href="#logo-basta"/></svg>

- <svg class="logo-svg footer-logo-svg" aria-label="Basta." role="img"><use href="#logo-basta"/></svg>
+ <svg class="logo-svg footer-logo-svg logo--on-light" aria-label="Basta." role="img"><use href="#logo-basta"/></svg>
```

Equivalente para os outros 16 arquivos (sidebar, topbar = `--on-light`; só 02–05 têm logo branco em fundo preto = `--on-dark`).

**Validação:**
- Reabrir landing no navegador. Headline "Saia do endividamento" deve respeitar gutter de 16px mobile.
- Logo Basta no header: branco sobre preto. No hero: branco. No footer: preto sobre branco.

---

### Onda 7b — Grid system formal

**Criar `_foundation/grid.css`:**

```css
/* ============================================================================
   GRID SYSTEM — Basta
   12-col, gutters fluidos por breakpoint, max-width 1200px
   ============================================================================ */
:root {
  --container-max:    1200px;
  --gutter-mobile:    16px;
  --gutter-tablet:    24px;
  --gutter-desktop:   32px;
  --column-gap:       24px;
  --col-count:        12;
}

/* Container canônico — substitui todas as variantes locais */
.container {
  width: 100%;
  max-width: var(--container-max);
  margin-inline: auto;
  padding-inline: max(var(--gutter-mobile), env(safe-area-inset-left));
}
@media (min-width: 768px) {
  .container { padding-inline: var(--gutter-tablet); }
}
@media (min-width: 1024px) {
  .container { padding-inline: var(--gutter-desktop); }
}

/* Container narrow — para texto longo (manifesto, FAQ) */
.container--narrow { max-width: 720px; }

/* Container wide — para hero full-bleed com conteúdo ainda alinhado */
.container--wide { max-width: 1440px; }

/* Full-bleed útil — background quebra, conteúdo respeita */
.bleed {
  margin-inline: calc(50% - 50vw);
  padding-inline: max(var(--gutter-mobile), 50vw - var(--container-max)/2);
}

/* Grid 12 colunas (para layouts internos) */
.grid {
  display: grid;
  grid-template-columns: repeat(var(--col-count), 1fr);
  gap: var(--column-gap);
}
```

**Promover `.container` em todos os 17 arquivos:**
- Validar que cada `<div class="container">` lê do `tokens.css`/`grid.css` e não de override local.
- Remover declarações duplicadas de `.container` em CSS local (pelo menos no landing).

**Adicionar grid.css ao `head-meta.html`** para que entre na Foundation default.

**Validação:**
- Inspector do browser: cada `.container` deve ter `padding-inline` resolvido pelos tokens, em todos os 17 arquivos.
- Mobile (390px): conteúdo do hero deve ter exatamente 16px de margem nas duas bordas.
- Desktop (1440px): conteúdo deve estar centralizado em 1200px com 32px de gutter externo.

---

### Onda 7c — Brand anchors no footer

**3 ações:**

1. **Mover** `Basta/03_Design/nvidia-inception-badge.svg` → `01_Sistema/_assets/nvidia-inception-badge.svg`. (Cria pasta `_assets/`.)

2. **Inserir no footer** do `01_basta-landing.html` (em `.footer-bottom`, antes do copyright):

```html
<div class="footer-bottom">
  <a href="https://www.nvidia.com/en-us/startups/"
     target="_blank" rel="noopener noreferrer"
     class="footer-badge"
     aria-label="Membro do programa NVIDIA Inception">
    <img src="_assets/nvidia-inception-badge.svg"
         alt="NVIDIA Inception Program — membro" width="120" height="40" loading="lazy">
  </a>
  <span class="footer-copy">&copy; 2026 Basta. Todos os direitos reservados.</span>
  <div class="footer-social">…</div>
</div>
```

CSS:
```css
.footer-badge { display: inline-flex; align-items: center; opacity: 0.85; transition: opacity var(--transition); }
.footer-badge:hover { opacity: 1; }
.footer-badge img { display: block; width: 120px; height: auto; }
@media (min-width: 768px) {
  .footer-bottom { display: grid; grid-template-columns: auto 1fr auto; gap: 32px; align-items: center; }
}
```

3. **Validar logo Basta no footer** após Onda 7a — deve estar preto sobre branco, alinhado ao gutter, com `margin-bottom: 32px` antes da grade do footer.

---

### Onda 7d — Auditoria visual de margem (loop)

**Por arquivo, validar:**

- Header e hero compartilham mesmo gutter visual (alinhamento de coluna esquerda).
- Footer compartilha mesmo gutter (alinhamento de coluna esquerda).
- Em mobile (390px): nenhum elemento sangra além de `var(--gutter-mobile)`.
- Em desktop (1440px): conteúdo principal fica em 1200px máx, centralizado, com 32px de gutter externo respeitado.

**Ferramenta:** Chrome DevTools com Device Toolbar (390 + 768 + 1024 + 1440 + 1920) ou Playwright + screenshot diff contra `_audit/baseline/`.

**Saída:** lista de arquivos que precisam de ajuste fino + patches.

---

## 3. Definição de Done

- [ ] Conteúdo do hero do `01_landing` respeita gutter em 4 breakpoints.
- [ ] Logo Basta visível e na cor correta nos 3 contextos (header preto, hero preto, footer branco) em todos os arquivos onde aparece.
- [ ] NVIDIA Inception badge presente no footer do `01_landing`, com link funcional, alt text correto, cumprindo guidelines do programa (placement no footer, link para startups.nvidia.com).
- [ ] `_foundation/grid.css` criado e linkado em todos os 17 arquivos via `head-meta.html`.
- [ ] Tokens `--max-w` e `--px` viram aliases retrocompat em `tokens.css` (não são deletados — mantidos como tech-debt explícito a remover na port React).
- [ ] 0 regressões no smoke test estrutural.
- [ ] Diff visual aprovado por Eduardo em pelo menos 3 telas-chave (01, 12, 16).

---

## 4. Riscos e mitigações

| Risco | Probabilidade | Mitigação |
|---|:---:|---|
| `padding-inline` legado quebrar em browsers antigos | baixa | usar `padding: 0 var(--gutter-*)` como fallback antes de `padding-inline` |
| Mudança de gutter desktop (24→32px) afetar densidade visual de outras telas | média | aplicar primeiro só no 01; validar; só depois propagar para 12–17 |
| `<use href="#logo-basta">` + `currentColor` ter glitch em Safari iOS antigo | baixa | manter `aria-label` no `<use>`, fallback `<img>` opcional para casos extremos |
| NVIDIA badge violar guideline de uso (tamanho, espaçamento mínimo) | média | conferir guideline oficial em https://images.nvidia.com/aem-dam/Solutions/inception/NVIDIA-Inception-Program-Brand-Guidelines.pdf antes de mergeear |

---

## 5. Cronograma sugerido

```
HOJE — Onda 7a (30 min, urgente, descoberta para baseline restaurada)
HOJE — Onda 7b (2h)
HOJE — Onda 7c (1h, paralelizável com 7b)
AMANHÃ — Onda 7d (1h, depende de 7a/7b/7c estarem mergeados)
```

Total: **5 horas em ~1 dia**.

---

## 6. Decisões que precisam de você antes da execução

1. **Cor do badge NVIDIA Inception:** o SVG é monocromático (verde NVIDIA). Mantenho como está ou aplico filtro para alinhar à paleta brand do Basta? **Recomendação:** manter original (selo institucional, marca de terceiros).
2. **Tagline da marca abaixo do logo no footer:** já existe `.footer-tagline` no CSS, sem markup. Adicionar? Se sim, qual texto? (Aceito não fazer — você pediu para não alterar textos.) **Recomendação:** deixar para você decidir o copy depois; markup pode ficar pronto, comentado.
3. **Aliases vs migração agressiva:** mantenho `--max-w` e `--px` como aliases (mais seguro, dívida técnica), ou já migro o landing para os tokens canônicos `--max-width` e `--px-mobile/desktop`? **Recomendação:** aliases agora (5 min, zero risco), migração na próxima onda.
4. **NVIDIA badge: também nas telas autenticadas?** Padrão da indústria é só na landing/marketing. **Recomendação:** só no 01.

---

*Aguardando aprovação para executar Ondas 7a–7d. Reverto facilmente via `cp _audit/baseline/01_basta-landing.html .` se algo der ruim.*
