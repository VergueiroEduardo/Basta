# Relatório de Cores Órfãs — Fase 2

**Data:** 2026-05-07
**Total de ocorrências órfãs:** 181
**Cores únicas:** 49

## Sumário por categoria

- **rgba_derivada:** 116 ocorrências, 38 cores únicas
- **hex_isolada:** 65 ocorrências, 11 cores únicas

## (1) rgba derivadas de tokens existentes

Tons com transparência sobre cores tokenizadas. Soluções possíveis:
- Criar tokens dedicados (`--black-overlay-55`, `--green-tint-08`...)
- Migrar para `color-mix(in srgb, var(--token), transparent X%)` (CSS moderno, requer browsers atuais)
- Manter como exceção (mais simples, menor risco)

| Cor | Ocorrências | Token base |
|---|---|---|
| `rgba(26,26,26,0.55)` | 18 | `--black` |
| `rgba(255,255,255,0.02)` | 12 | `--white` |
| `rgba(0,0,0,0.05)` | 8 | `(black puro, fora do DS)` |
| `rgba(255,255,255,0.15)` | 6 | `--white` |
| `rgba(26, 26, 26, 0.72)` | 5 | `--black` |
| `rgba(66,180,73,0.05)` | 5 | `--green` |
| `rgba(245,158,11,0.18)` | 5 | `--warning` |
| `rgba(255, 255, 255, 0.5)` | 4 | `--white` |
| `rgba(255,255,255,0.3)` | 4 | `--white` |
| `rgba(220,38,38,0.06)` | 4 | `--error` |
| `rgba(66,180,73,0.18)` | 4 | `--green` |
| `rgba(66,180,73,0.06)` | 4 | `--green` |
| `rgba(255,255,255,0.7)` | 3 | `--white` |
| `rgba(0, 0, 0, 0.08)` | 3 | `(black puro, fora do DS)` |
| `rgba(66,180,73,0.08)` | 3 | `--green` |
| `rgba(255,255,255,0.6)` | 2 | `--white` |
| `rgba(255, 255, 255, 0.3)` | 2 | `--white` |
| `rgba(26,26,26,0.18)` | 2 | `--black` |
| `rgba(255,255,255,0.78)` | 2 | `--white` |
| `rgba(255,255,255,0.12)` | 2 | `--white` |
| `rgba(255,255,255,0.5)` | 1 | `--white` |
| `rgba(255,255,255,0.35)` | 1 | `--white` |
| `rgba(26, 26, 26, 0.88)` | 1 | `--black` |
| `rgba(0, 0, 0, 0.05)` | 1 | `(black puro, fora do DS)` |
| `rgba(66, 180, 73, 0)` | 1 | `--green` |
| `rgba(66, 180, 73, 0.4)` | 1 | `--green` |
| `rgba(26,26,26,0.7)` | 1 | `--black` |
| `rgba(0,0,0,0.06)` | 1 | `(black puro, fora do DS)` |
| `rgba(0,0,0,0.3)` | 1 | `(black puro, fora do DS)` |
| `rgba(245,158,11,0.08)` | 1 | `--warning` |
| `rgba(66,180,73,0.04)` | 1 | `--green` |
| `rgba(59,158,232,0.08)` | 1 | `--blue` |
| `rgba(59,158,232,0.3)` | 1 | `--blue` |
| `rgba(255,255,255,0.18)` | 1 | `--white` |
| `rgba(255,255,255,0.08)` | 1 | `--white` |
| `rgba(220,38,38,0.18)` | 1 | `--error` |
| `rgba(245,158,11,0.06)` | 1 | `--warning` |
| `rgba(59,158,232,0.06)` | 1 | `--blue` |

## (2) Hex isoladas (sem token correspondente)

Cores que não derivam de tokens existentes. Cada uma exige decisão de DS:
- Adicionar como token novo se for cor recorrente do produto
- Trocar para token existente próximo (com possível pequena mudança visual)
- Manter como exceção justificada

| Cor | Ocorrências | Sugestão |
|---|---|---|
| `#b91c1c` | 28 | Vermelho mais escuro que `--error` — propor `--error-dark: #b91c1c` |
| `#999` | 23 | Gray médio — propor `--gray-500: #999999` |
| `#fff8e6` | 3 | Amarelo bg para alertas/warnings — propor `--warning-tint: #fff8e6` |
| `#fca5a5` | 3 | Vermelho claro — bg de error states — propor `--error-tint: #fca5a5` |
| `#1a2d52` | 2 | Azul muito escuro — usado em admin? Verificar contexto |
| `#f5f5f5` | 1 | Investigar contexto e decidir |
| `#fef2f2` | 1 | Investigar contexto e decidir |
| `#eceae4` | 1 | Investigar contexto e decidir |
| `#edf7ee` | 1 | Investigar contexto e decidir |
| `#eaf7ec` | 1 | Investigar contexto e decidir |
| `#6b7048` | 1 | Investigar contexto e decidir |
