# Handoff para o Cursor — Basta (Fase B)

Pacote gerado a partir da arquitetura corrigida (`sistema-basta_17.html`) e das decisões D1–D5.

## O que tem neste pacote

| Arquivo | Para onde vai no repo |
|---------|------------------------|
| `schema.sql` | `supabase/migrations/0001_init.sql` |
| `AGENTS.md` | raiz do repo (ou `.cursor/rules/basta.mdc`) |
| `sistema-basta_17.html` | `docs/sistema-basta_17.html` |
| `handoff.md` (este) | `docs/` (referência) |

## Setup inicial (uma vez)

1. Crie o projeto Next.js + Supabase e copie os arquivos acima para os destinos da tabela.
2. Aplique a migration: `supabase db push` (ou cole o `schema.sql` no SQL Editor do Supabase).
3. Gere os tipos: `supabase gen types typescript --local > src/lib/database.types.ts`.
4. Configure as variáveis de ambiente (sem chaves no código): Supabase URL/anon/service,
   Pluggy, ClickSign, Z-API, Anthropic.

## Ordem de implementação (não fazer tudo de uma vez)

1. **Fundações** — migration aplicada + RLS (policies via `auth_user_id`) + buckets privados de Storage.
2. **Eixo central** — `Pessoa → Ciclo → próxima_ação`, com `eventos_ciclo` e idempotência desde já.
3. **Canal** — Z-API (webhook de entrada + envio) ligado ao loop principal; Marina só comunica.
4. **Integrações** — Pluggy/OF (upsert por `fonte_id_externo`), ClickSign, ViaCEP, Anthropic.
5. **Motor de auditoria** — começar por 5–7 critérios AB mais frequentes, depois os 32.
6. **Diagnóstico + Contratação** — snapshots imutáveis + trilha de consentimento (D5).
7. **Jobs** — rodada 2 (recusado, lembretes D+3/7/14, reset de protocolo).

## Prompts prontos para colar no Cursor

Cada prompt assume que `AGENTS.md` está ativo e que você `@`-menciona os arquivos citados.

**Prompt 1 — Fundações / RLS**
```
Contexto: @docs/sistema-basta_17.html @supabase/migrations/0001_init.sql
A migration 0001 já cria as tabelas e habilita RLS em pessoas e ciclos com 2 policies de exemplo.
Complete as policies de RLS para todas as tabelas ligadas à Pessoa, navegando até pessoas.auth_user_id
(contas via ciclo; documentos via ciclo; operacoes via conta→ciclo; abusos via conta/operacao→ciclo;
diagnosticos via ciclo; contratacoes via pessoa_id). Apenas SELECT pela sessão da Pessoa; escrita fica
para a service role. Entregue como migration 0002_rls.sql. Não altere a 0001.
```

**Prompt 2 — Núcleo da lógica de funil**
```
Contexto: @docs/sistema-basta_17.html (Cap. 3 e 6)
Implemente proximaAcao(pessoaId, cicloId) em src/lib/proxima-acao.ts seguindo EXATAMENTE a máquina de
12 estados + 3 terminais do documento. Função pura: lê o ciclo e retorna { tipo, payload? } conforme o
type AcaoSugerida do Cap. 6. Sem efeitos colaterais, sem chamar Marina. Inclua testes unitários cobrindo
cada transição e os terminais.
```

**Prompt 3 — Eventos + idempotência**
```
Contexto: @supabase/migrations/0001_init.sql (tabela eventos_ciclo)
Crie src/lib/eventos.ts com registrarEvento({cicloId, tipoEvento, origem, estadoAnterior, estadoNovo,
payload, idempotencyKey}). Deve ser idempotente: se idempotencyKey já existe, retorna o evento existente
sem reprocessar. Toda transição de estado e todo webhook passam por aqui.
```

**Prompt 4 — Webhook Open Finance (Pluggy) com upsert**
```
Contexto: @docs/sistema-basta_17.html (Cap. 4 e 6) @supabase/migrations/0001_init.sql
Implemente o webhook de Open Finance em src/app/api/webhooks/of/route.ts. Ao receber consentimento +
primeira sincronização: faz UPSERT de contas e operacoes por fonte_id_externo (nunca duplica),
registra evento idempotente, e transiciona o ciclo para open_finance_conectado. Em seguida gera os
6 Requerimentos por Conta (um por Template ativo) e envia ao ClickSign apenas o Res. CMN 4.790.
```

## Lembrete sobre a rodada 2

Itens deixados para depois (já mapeados no `plano-ajustes-arquitetura_r1.md`): gatilhos de
`desqualificado`/`abandonado`, índice único de ciclo ativo por Pessoa, reordenar SCR no funil, buffer de
anexos não classificados, `updated_at` com trigger, contador de mensagens, race do protocolo anual e a
validação ClickSign↔WhatsApp.
