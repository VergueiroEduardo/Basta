# Plano de Excelência Mobile — Basta HTMLs

**Autor:** Claude (lente de senior UI/UX Huge Inc)
**Princípio:** o público da Basta é majoritariamente mobile, com Androids de entrada e iPhones com notch. **Mobile não é "responsive support"; é o caso de uso primário.** O desktop é segundo cidadão.

## 1. Personas e contexto

| Eixo | Realidade |
|---|---|
| Device dominante | Android entry/mid (Samsung Galaxy A-series, Motorola G-series) |
| Largura típica | 360–412px |
| iPhone share | ~25% — quase todos com notch (iPhone X+) |
| Conexão | 4G de borda, 3G ainda relevante fora de capitais |
| Postura | Em trânsito (ônibus, metrô), uma mão, polegar |
| Estado emocional | Estresse financeiro, vergonha, urgência |
| Tolerância a fricção | Baixa — qualquer bug visual é interpretado como "site fraudulento" |

**Implicação de design:** o produto precisa parecer **trustworthy**, **fluido** e **confiável** no primeiro toque. Bug de auto-zoom no iOS = perda imediata de credibilidade.

---

## 2. Critérios de excelência (Definition of Done)

| # | Critério | Verificação |
|---|---|---|
| 1 | Zero auto-zoom no iOS Safari ao focar inputs | `font-size ≥ 16px` em mobile |
| 2 | Conteúdo nunca cortado pelo notch ou home indicator | `safe-area-inset` respeitado em todos os fixed bottom/right/top |
| 3 | Todo elemento clicável tem ≥44×44px | Auditoria por seletor |
| 4 | Estados :hover não ficam "stuck" em touch | `@media (hover: hover) and (pointer: fine)` |
| 5 | Sem scroll horizontal involuntário em qualquer viewport ≥320px | `overflow-x: clip` + fallback `hidden` |
| 6 | Gutter consistente (16/24/32) em todas as telas | Tokens, não números mágicos |
| 7 | Headlines escalam com viewport | `clamp()` nas telas autenticadas |
| 8 | Sidebar↔Topbar troca em breakpoint único (960px) | Padronizar em 6 arquivos |
| 9 | Form com `inputmode`, `autocomplete`, `type=` corretos | Já existe parcialmente |
| 10 | `prefers-reduced-motion` respeitado | Já existe em 12-17, propagar |

---

## 3. Plano em 4 ondas (~3,5h total)

### Onda 8a — Fixes P0 iOS (30 min · risco zero)

**O que muda:**
- `_components/form.css`: `.form-input { font-size: 16px }` em mobile, `15px` em ≥768px.
- Atualiza CSS local em 02, 03, 04, 05, 16 para alinhar.
- `_foundation/grid.css`: `.fab-area { bottom: max(X, env(safe-area-inset-bottom)) }` helpers.
- Aplica safe-area em `.fab`, `.wa-fab`, `.topbar`, `.btn-close` em todos os arquivos.
- Adiciona `viewport-fit=cover` em `01_landing`.

**Impacto visual:** zero em desktop. Mobile: input fica 1px maior na mesma viewport — imperceptível, mas elimina o auto-zoom.

**Risco:** baixíssimo. Reverter é trivial.

### Onda 8b — Touch targets + hover-only (1h · risco baixo)

**O que muda:**
- `.nav-item` em 12-17: padding mobile sobe de `10px 12px` → `14px 16px` (altura ~48px).
- `.btn--sm` em `_components/btn.css`: min-height 40px → 44px.
- Envolver todos os `:hover` críticos em `@media (hover: hover) and (pointer: fine)`.

**Impacto visual:** sidebar mobile fica 1cm mais "respirável". Em desktop, nada muda. Hover em touch para de ficar stuck após tap.

**Risco:** baixo. Pode aumentar levemente a altura visual da sidebar mobile.

### Onda 8c — Padding/breakpoints padronizados (1h · risco médio)

**O que muda:**
- `.main` mobile padding em 13–17: `20px` → `24px` (= `--gutter-tablet`). Alinha com 12.
- Sidebar/topbar toggle em 12–17: padronizar em **960px** (alguns estão em 768).
- Landing: reduzir 9 breakpoints para 4 canônicos onde possível (preservando intent).

**Impacto visual:** telas autenticadas ganham 4px de respiro lateral em mobile. Sidebar aparece em viewports 4px diferentes — imperceptível.

**Risco:** médio. Mudar breakpoint da sidebar pode quebrar layouts intermediários (768-959px) — devo testar.

### Onda 8d — Polish + validação (1h · risco zero)

**O que muda:**
- `clamp()` nas headlines de 12–17 (`.page-title`, `.greeting`).
- `overflow-x: clip; overflow-x: hidden` (fallback) no `<html>`.
- `loading="lazy"` em `<img>` da landing.
- QA final: smoke test em todos os 17, contagem de tokens órfãos, validação de aspect ratio do logo.

**Impacto visual:** headlines escalam suavemente com viewport (ex: `.page-title` vai de 24px em mobile pequeno até 32px em tablet).

**Risco:** zero — só melhora.

---

## 4. Avaliação de impactos por arquivo

| Arquivo | Onda 8a | Onda 8b | Onda 8c | Onda 8d | Risco regressão |
|---|:---:|:---:|:---:|:---:|:---:|
| 01_landing | viewport-fit, safe-area FAB | hover wrapping | breakpoints | lazy img | baixo |
| 02–05 auth | input font-size | hover btn | — | — | nulo |
| 06 conta-criada | safe-area | — | — | — | nulo |
| 07–11 OF | safe-area | — | — | — | nulo |
| 12 dashboard | safe-area FAB, topbar | nav-item, hover | sidebar 960px | clamp page-title | médio |
| 13–17 app | safe-area FAB | nav-item, hover | padding 24, sidebar 960 | clamp headlines | médio |

**Risco médio em 12-17 é gerenciado com:** screenshot diff antes/depois e baseline já existente em `_audit/baseline/`.

---

## 5. Riscos e mitigações

| Risco | Probabilidade | Mitigação |
|---|:---:|---|
| Auto-zoom não desaparece após font-size 16px | baixa | Confirmar zero `user-scalable=no` / `maximum-scale=1`; se houver, remover (acessibilidade) |
| Safe-area aplicada gera espaços vazios em desktop | baixa | `max(X, env(safe-area-inset-X))` — fallback é o valor original |
| Sidebar a 960px deixa tablets 768-959px com layout estranho | média | Testar visualmente; pode requerer ajuste de breakpoint para 900 ou layout intermediário |
| `@media (hover: hover)` não suportado em Android Chrome muito antigo | baixíssima | Fallback é hover ativo (estado atual) |
| `loading="lazy"` em img acima da fold | média | Aplicar só em images abaixo da fold (já planejado) |

---

## 6. Definition of Done (verificação automatizada)

```bash
# 1. Inputs com font-size adequado
grep -E '\.form-input\s*\{[^}]*font-size:\s*1[6-9]px' (deve aparecer em todos)

# 2. Safe-area em fixed elements
grep -E 'env\(safe-area-inset' (deve haver 10+ matches across files)

# 3. Hover envolvido em media query
grep -B5 ':hover' | grep '@media (hover'

# 4. Touch target nav-item
grep -A2 '\.nav-item\s*{' | grep 'padding'  → ≥14px vertical

# 5. Smoke test estrutural pós-mudança
17/17 arquivos com DOCTYPE/body/html íntegros
```

---

## 7. Métricas de sucesso pós-implementação (para validar em devices)

- **Lighthouse Mobile Performance:** ≥85 (atualmente desconhecido — meça).
- **CLS:** < 0,05.
- **LCP:** < 2,5s em 4G slow.
- **FID/INP:** < 100ms.
- **Auto-zoom no iOS:** **zero** (validar manualmente em iPhone real).
- **Touch fail rate:** < 5% em sessões de 10+ taps (heat map).

---

*Plano executável em ~3,5h. Vou agora aplicar Ondas 8a→8d em sequência. Reportando ao final com diff e validação.*
