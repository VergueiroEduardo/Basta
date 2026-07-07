# Basta — Regras do projeto (Cursor)

> Coloque este arquivo na raiz do repo. Se o seu Cursor usa `.cursor/rules/`, salve como
> `.cursor/rules/basta.mdc` com `alwaysApply: true` no topo. O conteúdo é o mesmo.

## O que é o Basta

Plataforma que ajuda pessoas endividadas a recuperar controle financeiro. Coleta documentos,
estrutura dados financeiros (Open Finance + SCR), identifica condições de crédito e indícios de
abusos bancários, e — com consentimento — conecta a Pessoa a um parceiro executor.

**Princípio do produto:** o Basta informa, orienta, documenta e conecta. **Não** negocia, contesta
ou litiga em nome da Pessoa. A arquitetura prioriza **dossiê probatório** sobre capacidade transacional.

## Fonte de verdade

- **Arquitetura conceitual:** `docs/sistema-basta_17.html` (modelo, máquina de estados, fluxo, módulos).
- **Schema do banco:** `supabase/migrations/0001_init.sql` (igual ao `schema.sql` deste handoff).
- Em conflito, o schema vence para o banco; o HTML vence para regra de negócio/fluxo.
- Sempre `@`-mencione esses arquivos ao pedir implementação.

## Stack

Next.js (App Router) · React · Tailwind · Supabase (Postgres + Auth + Storage) · Vercel · TypeScript.
LLM via API Anthropic (Claude). Integrações: Pluggy (Open Finance), ClickSign, Z-API (WhatsApp), ViaCEP.

## Regras invioláveis

1. **A lógica de funil vive em `próxima_ação(pessoa, ciclo)`** — função pura em TypeScript que retorna a
   primeira etapa não cumprida. O agente conversacional (Marina) é interface: só comunica, não decide.
2. **Identidade (D1):** `pessoas.id` é uuid próprio gerado na captação. O vínculo ao Supabase Auth é
   `pessoas.auth_user_id`, preenchido no signup. RLS usa `auth.uid() = auth_user_id`. Nunca assuma
   `pessoas.id = auth.users.id`.
3. **RLS sempre.** Toda tabela ligada à Pessoa tem Row Level Security. Acesso por sessão é restrito ao
   dono; o backend (fase WhatsApp, jobs) usa service role e bypassa RLS — mantenha essa fronteira explícita.
4. **Idempotência.** Todo webhook (OF, ClickSign, Z-API) e toda transição de estado passam por
   `eventos_ciclo` com `idempotency_key`. Nada de processar o mesmo evento duas vezes.
5. **Open Finance é upsert.** Conta e Operação usam `fonte_id_externo` (id do provedor). Re-sync nunca
   duplica. `contas` tem `UNIQUE(ciclo_id, banco_id, agencia, numero)`.
6. **Diagnóstico é imutável.** Os `snapshot_*` (jsonb) são congelados na emissão; valide a estrutura com
   zod antes do insert e use `snapshot_versao`. Contratação referencia o Diagnóstico vigente no ato.
7. **WhatsApp é o único canal de upload** pela Pessoa (via Z-API). A plataforma web é fase analítica,
   não de coleta.
8. **Storage privado.** Documentos vão para buckets privados; servir só por URL assinada de curta duração.
9. **LGPD.** Consentimento de OF expira em 12 meses (`ciclos.consentimento_of_expira_em`) — prever
   expurgo/re-consent. Consentimento por finalidade.
10. **Valores legais são determinísticos.** Valor estimado de abuso = soma auditável de débitos do extrato
    OF, com `base_calculo`. Sem extrato OF, não há valor estimado. Nada de estimativa probabilística.

## Convenções

- **Idioma do domínio:** nomes de tabelas, colunas e enums em **português** (como no schema). Código e
  comentários técnicos podem ser em português direto, sem floreio.
- **Migrations:** uma migration por mudança de schema, em `supabase/migrations/`, nunca editar uma já aplicada.
- **Tipos:** gerar tipos do Supabase (`supabase gen types typescript`) e tê-los como fonte para o front.
- **Sem segredos no código.** Chaves de Pluggy/ClickSign/Z-API/Anthropic só em variáveis de ambiente.
- **Estados terminais:** `desqualificado`, `abandonado`, `recusado`. "Ciclo ativo" = etapa não terminal.

## Estrutura sugerida do repo

```
/docs/sistema-basta_17.html        # arquitetura (referência)
/supabase/migrations/0001_init.sql # schema
/src/lib/proxima-acao.ts           # núcleo da lógica de funil
/src/lib/eventos.ts                # registro idempotente em eventos_ciclo
/src/app/(plataforma)/...          # dashboard do cliente
/src/app/(admin)/...               # painel admin + CRM/gestor de conversas
/src/app/api/webhooks/...          # of, clicksign, zapi, supabase-auth
/src/integrations/{pluggy,clicksign,zapi,viacep,anthropic}.ts
```

## Fora de escopo no MVP (não implementar)

Leitura analítica de contratos em PDF · módulo de inteligência B2B · integração técnica com parceiros
(coordenação é humana) · magic link (auth é email+senha). Jobs programados (recusado, lembretes D+3/7/14)
e ajustes de funil entram na rodada 2.
