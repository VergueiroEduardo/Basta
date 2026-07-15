# Plano de Implementação — Fluxos de Parceiro (06–09)

**Data:** 2026-06-24 · **Escopo:** padronizar os quatro fluxos de parceiro com a mesma espinha de telas.

---

## 1. Princípio

Todo fluxo de parceiro tem a **mesma estrutura de quatro telas**, na mesma ordem:

```
Login  →  Painel  →  Detalhe do cliente  →  Perfil
```

O **fluxo 06 (Crédito) é o template de referência** — é o único 100% construído. Os fluxos 07, 08 e 09 espelham essa estrutura.

O **login é único e compartilhado** (`26_basta-login-parceiros.html`), roteado por papel pós-autenticação, conforme o `ARQUITETURA_AUTH_E_ESTRUTURA.md` (seção 2.1 e 2.2). No index ele aparece como card em cada fluxo por clareza de navegação, mas o arquivo é o mesmo — não se duplica.

---

## 2. Estado atual e arquivos por fluxo

Legenda: ✅ existe · ⛏️ existe em rascunho · 🔲 planejado (sem arquivo)

| Fluxo | Login | Painel | Detalhe do cliente | Perfil |
|---|---|---|---|---|
| **06 · Crédito** | ✅ `26_basta-login-parceiros` | ✅ `27_basta-dashboard-parceiros` | ✅ `27_basta-parceiro-consulta-cpf` | ✅ `27_basta-parceiro-perfil` |
| **07 · Renegociação** | ✅ `26_basta-login-parceiros` | ⛏️ `28_basta-dashboard-parceiros` | ⛏️ `28_basta-parceiro-renegociacao` | 🔲 `28_basta-parceiro-perfil` |
| **08 · Cancelamento** | ✅ `26_basta-login-parceiros` | ✅ `29_basta-dashboard-cancelamentos` | ✅ `29_basta-cancela-tudo-detalhe` | 🔲 `29_basta-parceiro-perfil` |
| **09 · Advogado** | ✅ `26_basta-login-parceiros` | 🔲 `30_basta-dashboard-advogado` | 🔲 `30_basta-advogado-detalhe` | 🔲 `30_basta-advogado-perfil` |

### Convenção de nomes
- Prefixo numérico agrupa o fluxo: **27** = Crédito, **28** = Renegociação, **29** = Cancelamento, **30** = Advogado.
- Padrão: `<NN>_basta-<dominio>-<tela>.html`.
- O `00_index.html` já aponta para todos esses nomes — inclusive os planejados (links quebram até o HTML existir).

---

## 3. Telas a construir (5 arquivos)

| Prioridade | Arquivo | Base para clonar | Observação |
|---|---|---|---|
| P1 | `28_basta-parceiro-perfil.html` | `27_basta-parceiro-perfil.html` | Ajustar copy/contexto para renegociação |
| P1 | `29_basta-parceiro-perfil.html` | `27_basta-parceiro-perfil.html` | Ajustar copy/contexto para cancelamento |
| P2 | `30_basta-dashboard-advogado.html` | `27_basta-dashboard-parceiros.html` | Carteira de processos/casos |
| P2 | `30_basta-advogado-detalhe.html` | `27_basta-parceiro-consulta-cpf.html` | Ficha do cliente + andamento do caso |
| P2 | `30_basta-advogado-perfil.html` | `27_basta-parceiro-perfil.html` | Campos OAB, escritório |

Também vale **promover os rascunhos do fl. 07** (`28_dashboard` e `28_renegociacao`) de "Rascunho" para funcional quando o fluxo for fechado.

---

## 4. Como clonar (cada tela nova)

1. Copiar o arquivo-base do fl. 06 com o novo nome.
2. Trocar `<title>` e o copy de cabeçalho/seções para o domínio do fluxo.
3. Conferir que o `href` do logo (topbar) volta para o **painel daquele fluxo**.
4. Ajustar a navegação lateral (sidebar) e dados mock do contexto.
5. Manter intactos os `_foundation/`, `_components/`, `_scripts/` — são compartilhados.
6. Tirar a tag `Planejado` do card correspondente no `00_index.html`.

---

## 5. Sequência sugerida

1. **Fechar fl. 07** — criar `28_parceiro-perfil`, promover os dois rascunhos. Fluxo completo.
2. **Fechar fl. 08** — criar `29_parceiro-perfil`. Fluxo completo.
3. **Construir fl. 09** — 3 telas próprias (`30_*`) clonando o fl. 06.
4. A cada tela concluída, remover a tag `Planejado` no index e atualizar o `section__status` do fluxo para `Funcional`.

---

## 6. Pendências de decisão (do doc de arquitetura)

- Renegociação (fl. 07) é parceiro **externo** ou time **interno** Basta? Muda se entra como org-parceira ou papel de admin.
- Advogado (fl. 09) já tem jornada própria definida, ou continua espelhando renegociação na prática até haver requisitos específicos?
- Reorganização de pastas (`_auth/`, `Cliente/`, `Parceiro-*/`) permanece adiada — este plano opera na estrutura plana atual.
