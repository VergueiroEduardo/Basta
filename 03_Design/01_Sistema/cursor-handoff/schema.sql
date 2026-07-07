-- ============================================================
-- BASTA — Schema inicial (PostgreSQL / Supabase)
-- Migration 0001_init
-- Rodada 1 de ajustes: bloqueadores + integridade + inconsistencias (itens 1-12)
-- Decisoes aplicadas: D1 (identidade), D2 (prazo restante), D3 (recomendacao),
--                     D4 (tipagem), D5 (trilha de consentimento)
-- Ordem topologica: nenhuma FK referencia tabela criada depois.
-- ============================================================

create extension if not exists "pgcrypto"; -- gen_random_uuid() (nativo no PG13+, garantido aqui)

-- ============ BANCO ============
create table bancos (
  id              uuid primary key default gen_random_uuid(),
  nome            text not null,
  cnpj            text unique,
  codigo_febraban text unique,
  tipo            text check (tipo in ('comercial','cooperativa','financeira','fintech')),
  created_at      timestamptz default now()
);

-- ============ PESSOA ============
-- D1 (item 3): id proprio + auth_user_id nullable -> auth.users.
-- A Pessoa nasce na captacao (fase WhatsApp), ANTES do signup; por isso nao
-- espelha auth.users.id. O vinculo ao Auth e feito no signup (estado conta_criada).
-- RLS usa auth.uid() = auth_user_id.
create type origem_captacao as enum (
  'whatsapp_direto',  -- Pessoa inicia conversa direto no WhatsApp do Basta
  'landing_page'      -- Pessoa preenche LP e e encaminhada ao WhatsApp
);

create table pessoas (
  id                  uuid primary key default gen_random_uuid(),
  auth_user_id        uuid unique references auth.users(id), -- nullable ate o signup
  nome                text not null,
  cpf                 text unique,            -- item 2: nullable ate documento_identidade_recebido
  telefone            text unique not null,   -- WhatsApp: chave de identificacao na captacao
  email               text,                   -- espelhado de auth.users.email no signup
  email_verificado_em timestamptz,            -- nao bloqueia conta_criada
  data_nascimento     date,
  cep                 text,
  cidade              text,                   -- via ViaCEP no signup; editavel pela Pessoa
  uf                  char(2),
  origem              origem_captacao not null,
  data_entrada        timestamptz default now(),
  created_at          timestamptz default now()
);
create index idx_pessoas_telefone on pessoas(telefone);

-- ============ USUARIO ADMIN ============
create table usuarios_admin (
  id               uuid primary key default gen_random_uuid(),
  nome             text not null,
  email            text unique not null,
  papel            text check (papel in ('admin','sdr_humano','analista')),
  ativo            boolean default true,
  convidado_por_id uuid references usuarios_admin(id),
  data_criacao     timestamptz default now(),
  ultimo_acesso    timestamptz
);

-- ============ CONFIGURACOES DE SISTEMA (singleton) ============
create table configuracoes_sistema (
  id                   int primary key default 1,
  ia_globalmente_ativa boolean default true,  -- chave master (contem instabilidade do agente IA)
  ia_pausada_por_id    uuid references usuarios_admin(id),
  ia_pausada_em        timestamptz,
  ia_pausada_motivo    text,
  janela_decisao_dias  int default 15,        -- prazo para autorizar apos recomendacao_entregue
  updated_at           timestamptz default now(),
  constraint singleton check (id = 1)
);

-- ============ CONVERSA (fio unico agente <-> Pessoa) ============
create table conversas (
  id                      uuid primary key default gen_random_uuid(),
  pessoa_id               uuid references pessoas(id) on delete cascade,
  canal                   text default 'whatsapp',
  status                  text default 'em_andamento' check (status in ('em_andamento','finalizada')),
  agente_ia_ativo         boolean default true,  -- false quando humano assume
  pinned                  boolean default false,
  assumida_por_admin_id   uuid references usuarios_admin(id),
  assumida_em             timestamptz,
  finalizada_por_admin_id uuid references usuarios_admin(id),
  finalizada_em           timestamptz,
  data_inicio             timestamptz default now(),
  ultima_interacao        timestamptz default now(),
  total_mensagens         int default 0          -- desnormalizado: manter via trigger (rodada 2)
);
create index idx_conversas_pessoa on conversas(pessoa_id);
create index idx_conversas_status on conversas(status) where status = 'em_andamento';

-- ============ MENSAGEM ============
create type remetente_tipo as enum ('pessoa','agente_ia','agente_humano');

create table mensagens (
  id               uuid primary key default gen_random_uuid(),
  conversa_id      uuid references conversas(id) on delete cascade,
  remetente_tipo   remetente_tipo not null,
  agente_humano_id uuid references usuarios_admin(id), -- quando remetente_tipo = agente_humano
  conteudo         text,
  anexo_url        text,
  metadata         jsonb,
  created_at       timestamptz default now()
);
create index idx_mensagens_conversa on mensagens(conversa_id);

-- ============ CICLO DE ANALISE ============
create type etapa_ciclo as enum (
  'captado',
  'documento_identidade_recebido',
  'comprovante_endereco_recebido',
  'holerite_recebido',
  'scr_coletado',
  'pesquisa_declaratoria_respondida',
  'analise_previa_entregue',
  'conta_criada',
  'open_finance_conectado',
  'requerimento_assinado',
  'recomendacao_entregue',
  'servico_autorizado',
  'desqualificado',
  'abandonado',
  'recusado'
);

create table ciclos (
  id                         uuid primary key default gen_random_uuid(),
  pessoa_id                  uuid references pessoas(id) on delete cascade,
  etapa_atual                etapa_ciclo not null default 'captado',
  data_abertura              timestamptz default now(),
  data_conclusao             timestamptz,
  scr_autorizado_em          timestamptz,        -- autorizacao precede o documento
  pesquisa_declaratoria      jsonb,
  analise_previa             jsonb,              -- panorama: divida, renda, comprometimento
  consentimento_of_id        text,
  consentimento_of_expira_em timestamptz,        -- item 10: retencao/expurgo LGPD (12 meses)
  data_diagnostico_entregue  timestamptz,        -- marco para a janela de decisao -> recusado
  lembretes_enviados         int default 0,      -- contador D+3, D+7, D+14
  esperando                  text,               -- contexto para classificar proximo input
  created_at                 timestamptz default now()
);
create index idx_ciclos_pessoa_etapa on ciclos(pessoa_id, etapa_atual);
create index idx_ciclos_decisao_pendente on ciclos(data_diagnostico_entregue)
  where etapa_atual = 'recomendacao_entregue';
-- ROADMAP rodada 2 (item 14): unique parcial de ciclo ativo por pessoa
--   create unique index idx_ciclo_ativo_unico on ciclos(pessoa_id)
--     where etapa_atual not in ('desqualificado','abandonado','recusado','servico_autorizado');

-- ============ EVENTOS DO CICLO (auditoria + idempotencia) ============
-- itens 4 e 5: trilha de auditoria e deduplicacao de webhooks reentrantes.
create table eventos_ciclo (
  id              uuid primary key default gen_random_uuid(),
  ciclo_id        uuid references ciclos(id) on delete cascade not null,
  tipo_evento     text not null,          -- transicao_estado, webhook, acao_admin, job
  origem          text not null,          -- zapi, open_finance, clicksign, supabase_auth, sistema, admin
  estado_anterior etapa_ciclo,
  estado_novo     etapa_ciclo,
  payload         jsonb,
  idempotency_key text unique,            -- item 5: dedup de webhooks (mesmo evento nao processa 2x)
  created_at      timestamptz default now()
);
create index idx_eventos_ciclo on eventos_ciclo(ciclo_id, created_at);

-- ============ CONTA ============  (item 1: criada ANTES de documentos)
create table contas (
  id               uuid primary key default gen_random_uuid(),
  ciclo_id         uuid references ciclos(id) on delete cascade,
  banco_id         uuid references bancos(id),
  fonte_id_externo text,                  -- item 6: id da conta no provedor OF (Pluggy) p/ upsert
  tipo             text,                  -- corrente, poupanca, salario, pagamento
  agencia          text,
  numero           text,
  data_abertura    date,
  ativa            boolean default true,
  fonte_dado       text,                  -- open_finance, declarado, extrato
  created_at       timestamptz default now(),
  unique (ciclo_id, banco_id, agencia, numero) -- item 6: evita duplicar conta no re-sync do OF
);
create index idx_contas_ciclo on contas(ciclo_id);

-- ============ DOCUMENTO (entidade padronizada de arquivos) ============
create type documento_categoria as enum ('pessoal','bancario','gerado');
create type documento_tipo as enum (
  'rg_cnh','cpf','comprovante_residencia','holerite','scr','susep','inss',
  'extrato','contrato','fatura_cartao','produto','outro_bancario',
  'requerimento_preparado','requerimento_assinado','dossie','comprovante_renegociacao'
);
create type documento_fonte as enum (
  'upload_whatsapp','api_bacen_scr','api_open_finance','geracao_basta','webhook_clicksign'
);

create table documentos (
  id                 uuid primary key default gen_random_uuid(),
  ciclo_id           uuid references ciclos(id) on delete cascade not null,
  conta_id           uuid references contas(id) on delete cascade, -- nullable: so categoria=bancario
  categoria          documento_categoria not null,
  tipo               documento_tipo not null,
  fonte              documento_fonte not null,
  arquivo_url        text not null,
  referencia_periodo jsonb,             -- ex: {"mes":1,"ano":2026}
  metadata           jsonb,
  created_at         timestamptz default now()  -- mais recente vence em queries
);
create index idx_documentos_ciclo_tipo on documentos(ciclo_id, tipo);
create index idx_documentos_conta on documentos(conta_id) where conta_id is not null;
-- mais recente por tipo: select * from documentos where ciclo_id=? and tipo=? order by created_at desc limit 1;

-- ============ TEMPLATE DE REQUERIMENTO (CRUD admin) ============
create table templates_requerimento (
  id                         uuid primary key default gen_random_uuid(),
  nome                       text not null,
  descricao                  text,
  categoria                  text default 'geral',
  html                       text not null,        -- placeholders {{variavel}}
  chaves                     text[],
  dispara_clicksign_imediato boolean default false, -- true so para Res. CMN 4.790 no MVP
  ativo                      boolean default true,
  criado_por_admin_id        uuid references usuarios_admin(id),
  data_criacao               timestamptz default now(),
  atualizado_em              timestamptz default now()
);
-- Variaveis fixas no MVP (hardcoded): {{banco_nome}}, {{conta_numero}}, {{conta_agencia}},
--   {{nome_devedor}}, {{cpf_devedor}}, {{cidade_emissao}}, {{data_emissao}}

-- ============ REQUERIMENTO (carta formal por Conta) ============
create type status_requerimento as enum (
  'preparado','enviado_clicksign','assinado','enviado_banco'
);

create table requerimentos (
  id                     uuid primary key default gen_random_uuid(),
  ciclo_id               uuid references ciclos(id) on delete cascade not null,
  conta_id               uuid references contas(id) on delete cascade not null,
  banco_id               uuid references bancos(id) not null,
  template_id            uuid references templates_requerimento(id) not null,
  status                 status_requerimento not null default 'preparado',
  documento_preparado_id uuid references documentos(id),
  documento_assinado_id  uuid references documentos(id),
  clicksign_id           text,
  data_preparado         timestamptz default now(),
  data_enviado_clicksign timestamptz,
  data_assinado          timestamptz,
  data_enviado_banco     timestamptz,
  created_at             timestamptz default now()
);
create index idx_requerimentos_ciclo on requerimentos(ciclo_id);
create index idx_requerimentos_conta_banco on requerimentos(conta_id, banco_id);
create index idx_requerimentos_status on requerimentos(status);
-- Cada Conta gera 6 Requerimentos (um por Template ativo) ao atingir open_finance_conectado.

-- ============ OPERACAO DE CREDITO ============
create table operacoes (
  id                   uuid primary key default gen_random_uuid(),
  conta_id             uuid references contas(id) on delete cascade,
  fonte_id_externo     text,            -- item 6: id da operacao no provedor OF p/ upsert
  modalidade           text,            -- D4: text (OF traz variedade) -- consignado, cartao, cdc...
  valor_contratado     numeric(14,2),
  valor_em_aberto      numeric(14,2),
  data_contratacao     date,
  prazo_meses          int,             -- prazo total contratado
  parcelas_pagas       int,             -- item 8/D2: do OF quando disponivel
  prazo_restante_meses int,             -- item 8/D2: do OF, ou derivado (prazo_meses - parcelas_pagas)
  parcela_valor        numeric(14,2),
  taxa_juros_mensal    numeric(8,4),
  cet                  numeric(8,4),
  indexador            text,
  status               text,            -- ativo, quitado, em_atraso, renegociado
  fonte_dado           text,
  -- Portabilidade: preenchidos manualmente apos resposta do parceiro ofertante
  parcela_proposta_portabilidade numeric(14,2),
  prazo_proposto_portabilidade   int,
  -- item 8: usa prazo RESTANTE (nao o total) -- alinhado ao texto do Cap.04
  economia_portabilidade_estimada numeric(14,2) generated always as (
    (parcela_valor * prazo_restante_meses) - (parcela_proposta_portabilidade * prazo_proposto_portabilidade)
  ) stored,
  parceiro_ofertante_nome   text,
  portabilidade_proposta_em timestamptz,
  created_at           timestamptz default now()
);
create index idx_operacoes_conta on operacoes(conta_id);

-- ============ ABUSOS ============
create type tipo_calculo_abuso as enum ('restituicao_em_dobro','reducao_estimada');
create type severidade_abuso   as enum ('baixa','media','alta','critica');                       -- D4
create type status_abuso       as enum ('identificado','em_analise','confirmado','descartado','contestado'); -- D4

create table abusos_conta (
  id                 uuid primary key default gen_random_uuid(),
  conta_id           uuid references contas(id) on delete cascade,
  criterio           text not null,        -- AB01..AB32
  severidade         severidade_abuso,
  evidencia          jsonb,
  status             status_abuso default 'identificado',
  base_legal         text,
  valor_estimado     numeric(14,2),
  tipo_calculo       tipo_calculo_abuso,
  base_calculo       jsonb,                -- auditavel: lancamentos do extrato OF, datas, valores, formula
  data_identificacao timestamptz default now()
);
create index idx_abusos_conta_conta on abusos_conta(conta_id);

create table abusos_operacao (
  id                 uuid primary key default gen_random_uuid(),
  operacao_id        uuid references operacoes(id) on delete cascade,
  criterio           text not null,
  severidade         severidade_abuso,
  evidencia          jsonb,
  status             status_abuso default 'identificado',
  base_legal         text,
  valor_estimado     numeric(14,2),
  tipo_calculo       tipo_calculo_abuso,
  base_calculo       jsonb,
  data_identificacao timestamptz default now()
);
create index idx_abusos_operacao_operacao on abusos_operacao(operacao_id);

-- ============ RECOMENDACAO ============
-- D3 (item 7): 3 FKs nullable + CHECK de exatamente uma origem.
-- Substitui o polimorfismo origem_tipo/origem_id, recuperando integridade e CASCADE.
create type recomendacao_tipo as enum (
  'contestacao','restituicao','renegociacao','encaminhamento','acao_judicial'
);

create table recomendacoes (
  id                uuid primary key default gen_random_uuid(),
  operacao_id       uuid references operacoes(id) on delete cascade,
  abuso_conta_id    uuid references abusos_conta(id) on delete cascade,
  abuso_operacao_id uuid references abusos_operacao(id) on delete cascade,
  tipo              recomendacao_tipo,
  prioridade        int,
  descricao         text,
  parceiro_sugerido text,
  status            text default 'sugerida',
  data_geracao      timestamptz default now(),
  data_resolucao    timestamptz,
  constraint origem_unica check (
      (operacao_id       is not null)::int
    + (abuso_conta_id    is not null)::int
    + (abuso_operacao_id is not null)::int = 1
  )
);
create index idx_recomendacoes_operacao on recomendacoes(operacao_id) where operacao_id is not null;
create index idx_recomendacoes_abuso_conta on recomendacoes(abuso_conta_id) where abuso_conta_id is not null;
create index idx_recomendacoes_abuso_operacao on recomendacoes(abuso_operacao_id) where abuso_operacao_id is not null;

-- ============ DIAGNOSTICO (snapshot imutavel) ============
create sequence diagnosticos_protocolo_seq start 1; -- race no virar do ano: tratar na rodada 2

create table diagnosticos (
  id                  uuid primary key default gen_random_uuid(),
  ciclo_id            uuid references ciclos(id) on delete cascade not null,
  numero_protocolo    text unique not null,       -- BST-YYYY-NNNNNN
  vigente             boolean default true,
  snapshot_versao     int not null default 1,     -- item 12: versao do formato dos snapshots
  data_emissao        timestamptz default now(),
  snapshot_financeiro jsonb not null,             -- {divida_total_scr, renda_bruta, renda_liquida, parcela_total, percentual_comprometimento}
  snapshot_abusos     jsonb not null,             -- [{criterio, valor_estimado, tipo_calculo, base_calculo, severidade, base_legal}]
  snapshot_caminhos   jsonb not null,             -- caminhos disponiveis com estrutura 10/20/70
  documento_dossie_id uuid references documentos(id),
  motivo_substituicao text,
  created_at          timestamptz default now()
);
create index idx_diagnosticos_ciclo on diagnosticos(ciclo_id);
create unique index idx_diagnosticos_vigente on diagnosticos(ciclo_id) where vigente = true;
-- item 12: validar a estrutura de snapshot_* na aplicacao (zod) antes do insert.

-- ============ CONTRATACAO (autorizacao + contratacao unificadas) ============
create type caminho_acao as enum (
  'portabilidade','renegociacao_administrativa','representacao_litigiosa'
);
create type parceiro_tipo as enum (
  'ofertante_credito','renegociacao_administrativa','advogado_especializado'
);
create type status_contratacao as enum (     -- D4
  'autorizada','dossie_enviado','em_execucao','concluida','sem_resultado'
);

create table contratacoes (
  id                     uuid primary key default gen_random_uuid(),
  ciclo_id               uuid references ciclos(id),
  pessoa_id              uuid references pessoas(id),
  diagnostico_id         uuid references diagnosticos(id) not null, -- Diagnostico vigente no ato
  caminho_acao           caminho_acao not null,
  parceiro_tipo          parceiro_tipo not null,
  parceiro_nome          text,
  percentual_honorario   numeric(5,2) default 30.00,
  base_calculo_resultado text,
  valor_resultado        numeric(14,2),         -- preenchido apos execucao
  honorario_basta        numeric(14,2),         -- 10% (materializado)
  honorario_parceiro     numeric(14,2),         -- 20% (materializado)
  valor_pessoa           numeric(14,2),         -- 70% (materializado)
  -- item 11/D5: trilha de consentimento (prova do loop legal)
  data_autorizacao       timestamptz default now(),
  autorizado_em_servidor timestamptz default now(), -- timestamp server-side
  autorizado_por_ip      inet,
  user_agent             text,
  diagnostico_hash       text,                  -- SHA-256 do snapshot exibido no ato
  termos_versao          text,
  data_envio_dossie      timestamptz,
  data_conclusao         timestamptz,
  status                 status_contratacao default 'autorizada'
);
create index idx_contratacoes_ciclo on contratacoes(ciclo_id);
create index idx_contratacoes_diagnostico on contratacoes(diagnostico_id);

-- ============================================================
-- RLS — Row Level Security (ponto de partida)
-- Padrao: a Pessoa so enxerga o que e dela, via auth_user_id (D1).
-- O backend (fase WhatsApp e jobs) opera com a SERVICE ROLE, que bypassa RLS;
-- estas policies regem o acesso pela SESSAO autenticada da Pessoa na plataforma.
-- ============================================================
alter table pessoas         enable row level security;
alter table ciclos          enable row level security;
alter table contas          enable row level security;
alter table documentos      enable row level security;
alter table operacoes       enable row level security;
alter table abusos_conta    enable row level security;
alter table abusos_operacao enable row level security;
alter table recomendacoes   enable row level security;
alter table diagnosticos    enable row level security;
alter table contratacoes    enable row level security;
alter table conversas       enable row level security;
alter table mensagens       enable row level security;

-- Pessoa: acesso ao proprio registro
create policy pessoa_self on pessoas
  for select using (auth.uid() = auth_user_id);

-- Ciclo: pertence a Pessoa autenticada
create policy ciclo_self on ciclos
  for select using (exists (
    select 1 from pessoas p where p.id = ciclos.pessoa_id and p.auth_user_id = auth.uid()
  ));

-- Demais tabelas-filhas seguem o MESMO padrao, navegando ate pessoas.auth_user_id:
--   contas        -> via ciclos
--   documentos    -> via ciclos
--   operacoes     -> via contas -> ciclos
--   abusos_*      -> via conta/operacao -> ciclos
--   diagnosticos  -> via ciclos
--   contratacoes  -> via pessoa_id (auth_user_id direto)
-- Escrita (insert/update) majoritariamente via service role no backend.
