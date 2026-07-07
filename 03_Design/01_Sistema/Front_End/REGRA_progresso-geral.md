# Regra — Progresso Geral (card do dashboard)

**Modelo:** Y2
**Onde:** card "Progresso geral" em `12_basta-dashboard.html`
**Cap visível:** 100%

---

## Quadro-resumo

| Modelo | 1ª conexão | Adicionais | Docs | Requerim. | Reneg. | Total |
|---|---|---|---|---|---|---|
| **PG** | 50% | 20% (teto) | 20% | 5% | 5% | 100% |

Legenda rápida: 1ª conexão é binária; adicionais somam +10% por conta até o teto de 20%; docs são 4 × 5%; requerimentos e renegociação são proporcionais ao nº de contas.

> **Nota:** com **uma conta**, o máximo que o usuário alcança é **80%**. É intencional — o bucket de 20% "contas adicionais" exige contas além da primeira. Queremos assim para **incentivá-lo a conectar outras contas**.

---

## 1. Pesos (somam 100%)

| Componente | Peso | Como pontua |
|---|---|---|
| 1ª conexão Open Finance | **50%** | binário — conectou a 1ª conta ou não |
| Contas adicionais | **20%** | +10% por conta além da 1ª, **teto de 20%** (2 adicionais já fecham o bucket; 3+ não mudam nada) |
| Documentos únicos | **20%** | 4 documentos × 5% cada, proporcional a `docsEnviados / 4` |
| Requerimentos assinados | **5%** | proporcional a `assinados / (3 × contas)` |
| Registro de renegociação | **5%** | proporcional a `registros / contas` |

Documentos são **únicos** (independem do nº de contas): RG/CNH, SCR, Holerite etc., 4 no total.
Requerimentos são **3 por conta** → denominador `3 × contas`.
Renegociação é **1 registro por conta** → denominador `contas`.

---

## 2. Fórmula

```
N = contasConectadas

se N <= 0  →  progresso = 0

pConexao1   = 50
pAdicionais = min( max(N-1, 0) × 10 , 20 )
pDocs       = 20 × ( min(docsEnviados, 4) / 4 )
pRequerim   =  5 × ( min(requerimentosAssinados, 3N) / (3N) )
pReneg      =  5 × ( min(renegociacoesRegistradas, N) / N )

progresso = round( pConexao1 + pAdicionais + pDocs + pRequerim + pReneg )
```

---

## 3. Contrato de entrada (ESTADO)

Fonte única de verdade. Em produção vem do backend.

```js
{
  contasConectadas: number,        // nº de contas via Open Finance
  docsEnviados: number,            // 0..4
  requerimentosAssinados: number,  // 0..(3 × contasConectadas)
  renegociacoesRegistradas: number // 0..contasConectadas
}
```

---

## 4. Regras de comportamento (obrigatórias)

1. **A barra nunca regride.** Conectar uma nova conta adiciona trabalho nos buckets proporcionais (requerimentos/renegociação), mas o crédito já obtido não é retirado. Garantir monotonicidade na camada de exibição se necessário.
2. **Teto de contas adicionais = 20%.** A 3ª conta em diante não move a barra por conexão. É intencional.
3. **Conta única trava em 80%.** Quem tem 1 conta e completa tudo (docs + requerimentos + renegociação) chega a **80%** — nunca 100%, porque o bucket de 20% "contas adicionais" exige contas adicionais. **É intencional e honesto:** o devedor de conta única cobriu o essencial dele. Não há mecanismo de "declarar que não tem mais contas".
4. **Cap em 100%.** `round` no final; nunca exceder 100.

---

## 5. Copy dinâmico

Título e subtítulo do card apontam a **maior alavanca pendente**, nesta ordem de prioridade:

1. `N <= 0` → "Comece conectando uma conta." / "A primeira conexão já avança metade do processo."
2. `docsEnviados < 4` → "Envie seus documentos essenciais." / "Falta enviar RG/CNH, SCR ou Holerite."
3. `renegociacoesRegistradas < N` → "Registre sua tentativa de renegociação." / "Documente a negociação de cada conta conectada."
4. `requerimentosAssinados < 3N` → "Assine seus requerimentos." / "Ainda há requerimentos pendentes de assinatura."
5. tudo completo → "Preparação concluída." / "Você completou todas as etapas iniciais."

---

## 6. Cenários validados

| Estado | Progresso |
|---|---|
| 0 contas | 0% |
| 1 conta só conectada | 50% |
| 1 conta, tudo feito | 80% |
| 2 contas, tudo feito | 90% |
| 3 contas, tudo feito | 100% |
| 5 contas, tudo feito | 100% |
| Demo atual (3 contas, 0 docs, 9 requerim., 0 reneg.) | 75% |

---

## 7. Função de referência (JS, já em produção no HTML)

```js
function calcularProgresso(e) {
  var N = e.contasConectadas;
  if (N <= 0) return 0;

  var pConexao1   = 50;
  var pAdicionais = Math.min(Math.max(N - 1, 0) * 10, 20);
  var pDocs       = 20 * (Math.min(e.docsEnviados, 4) / 4);
  var pRequerim   = 5  * (Math.min(e.requerimentosAssinados, 3 * N) / (3 * N));
  var pReneg      = 5  * (Math.min(e.renegociacoesRegistradas, N) / N);

  return Math.round(pConexao1 + pAdicionais + pDocs + pRequerim + pReneg);
}
```
