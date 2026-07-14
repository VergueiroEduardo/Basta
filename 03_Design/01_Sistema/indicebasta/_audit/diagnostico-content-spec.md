# Diagnóstico — Spec Canônica de Conteúdo

**Versão:** 1.0
**Data:** 07 maio 2026
**Status:** Ativa
**Mantenedor:** Eduardo (estratégia + design)

## Propósito

O Diagnóstico Basta vive em **dois arquivos** e precisa permanecer **idêntico em conteúdo de miolo** entre eles:

- `23_basta-diagnostico-admin.html` — operação interna (sidebar + banner + preview da peça)
- `24_basta-diagnostico-cliente.html` — peça externa enviada ao cliente via WhatsApp

Esta spec define os **blocos compartilhados** (o miolo) e a regra de sincronia.

**Princípio:** Single Source of Truth de conteúdo, dual surface de apresentação. O conteúdo do miolo é o mesmo. O que muda é o entorno — quem está falando, quem está ouvindo, e o que se faz com a informação.

## Regra de sincronia

Qualquer alteração de conteúdo no miolo **DEVE** ser aplicada nos dois arquivos no mesmo commit. A spec abaixo é o contrato. Se alterar a spec sem atualizar os arquivos, ou alterar os arquivos sem atualizar a spec, está em estado inconsistente.

**Checklist obrigatório por alteração:**

1. Atualizei o conteúdo no `24_basta-diagnostico-cliente.html`
2. Atualizei o mesmo conteúdo no `23_basta-diagnostico-admin.html`
3. Atualizei a spec aqui no `_audit/diagnostico-content-spec.md`
4. Adicionei entrada no changelog ao final desta spec
5. Validei visualmente que os dois arquivos estão idênticos no miolo

## Blocos compartilhados (o miolo)

Os blocos abaixo são idênticos entre os dois arquivos. O entorno admin (sidebar, banner, modal) e o estado do termo (ativo no cliente, preview no admin) são as únicas diferenças permitidas.

### B01 · Header documental

- **Logo Basta** à esquerda
- **Meta documental** à direita: "Diagnóstico nº BST-2026-0507 · 06 maio 2026"

### B02 · Kicker

- Texto: "Diagnóstico Basta"
- Estilo: eyebrow tipográfico, uppercase, letter-spacing alto

### B03 · Hero vocativo

- H1 grande com vocativo: **"Eduardo,"**
- Tipografia: clamp(48px, 11vw, 96px), peso 800, letter-spacing -0.045em

### B04 · Lead narrativo

Parágrafo denso com a história financeira do cliente, intercalando números no fluxo do texto. Modelo:

> "sua dívida total registrada no SCR/Bacen é de R$ 178.000,00 (cento e setenta e oito mil reais), dividida em 4 bancos. Sua renda bruta reportada é de R$ 8.457,89 — sendo que R$ 4.500,00 em empréstimos consignados são descontados em folha antes do salário ser depositado na sua conta. Sobra uma renda líquida de R$ 3.957,89. Em cima dela ainda incidem R$ 3.000,00/mês de parcelas com origem em crédito pessoal e cartões de crédito, e algumas dessas parcelas já estão em atraso."

### B05 · Síntese Financeira (KPI 4-up)

- **Dívida Total** — R$ 178.000 — SCR Bacen · 4 bancos (alerta vermelho)
- **Renda Bruta** — R$ 8.457 — Holerite · CLT
- **Renda Líquida** — R$ 3.957 — Após consignados
- **% Comprometimento** — 88,7% — Crítico · acima de 30% (alerta vermelho)

### B06 · Transição

Texto: "Contas em análise"

### B07 · Bancos Analisados (3-up)

Cada card contém apenas: **Banco** · **Agência/Conta** · **Exposição**.

- Banco do Brasil — Ag. 1234 · Conta 56789-0 — R$ 28.400
- Banco Itaú — Ag. 0345 · Conta 12345-6 — R$ 65.200
- Banco Sicredi — Ag. 0710 · Conta 98765-4 — R$ 44.800

### B08 · Por banco — narrativa + indícios

Para cada banco, eyebrow padrão: **"Indícios de abusos que merecem atenção por banco · X de 3"**.

**Banco do Brasil (4 indícios):**

- AB17 (Crítico) · Cartão Consignado RMC sem solicitação · R$ 89/mês × 14 meses · R$ 2.492 restituição em dobro
- AB16 (Crítico) · Seguro prestamista contratado junto com o empréstimo · R$ 47/mês × 12 meses · R$ 1.128 restituição em dobro
- AB13 (Alto) · Tarifa cobrada em conta salário · R$ 24/mês × 14 meses · R$ 672 restituição em dobro
- AB11 (Médio) · Tarifa de "Cesta Personalizada" sem prestação clara · R$ 12,90/mês × 8 meses · R$ 206,40 restituição em dobro

**Banco Itaú (5 indícios):**

- AB16 (Crítico) · 8 seguros prestamistas contratados sem aceite separado · R$ 304/mês total · R$ 7.296 restituição em dobro
- AB02 (Alto) · Capitalização de juros sem cláusula expressa · 4,8 p.p. · R$ 3.200 redução estimada
- AB03 (Alto) · Juros moratórios acima do limite legal (1,8% vs 1%) · R$ 1.380 redução estimada
- AB13 (Alto) · Tarifa cobrada em conta salário · R$ 32/mês × 18 meses · R$ 1.152 restituição em dobro
- AB07 (Médio) · CET informado divergente do efetivo (42% vs 46,8%) · reforça pedido de revisão

**Banco Sicredi (2 indícios):**

- AB02 (Alto) · Capitalização sem cláusula expressa · 3,4 p.p. · R$ 4.800 redução estimada
- AB10 (Médio) · Tarifa de avaliação de garantia sem laudo · R$ 850 · R$ 1.700 restituição em dobro

### B09 · Síntese de Oportunidade

Bloco preto destacando a economia projetada total:

- **Restituição em dobro:** R$ 14.646
- **Redução de saldo devedor:** R$ 9.380
- **Alívio de fluxo (12 meses):** R$ 8.000
- **Economia projetada total:** **R$ 32.027**

Lead: "Soma das restituições em dobro pelos abusos identificados (CDC art. 42, p.ú.), redução do saldo devedor após recálculo sem capitalização e mora indevida, e alívio mensal estimado via portabilidade dos consignados para uma instituição com taxa menor."

### B10 · Disclaimer (sobre os números)

Bloco com borda lateral verde, eyebrow "Sobre estes números". Cobre:

- Origem dos dados (vieram do próprio cliente via Open Finance, holerite, contratos)
- Natureza estimativa (não vincula como oferta — CDC art. 30)
- Obrigação de meio (Basta orquestra, não promete resultado)
- Variáveis fora de controle (banco, instituição parceira, juízo)
- Success fee como alinhamento ("só ganhamos quando você ganha")
- Direitos preservados (memória de cálculo, retificação, revogação)

Fundamentos legais citados ao final: CDC arts. 6º, III · 30 · 31 · LGPD arts. 8º, §5º e 18, II/III · CC art. 422.

### B11 · Os 3 Caminhos

Três cards lado a lado, peso visual igual:

1. **Portabilidade da dívida** — busca de IFs com condições melhores via Open Finance
2. **Renegociação supervisionada** — diagnóstico para o banco propor acordo, com supervisão Basta
3. **Ação judicial sem custo inicial** — escritório parceiro ingressa com ação

Subtítulo da seção: "Você pode seguir por um, dois ou pelos três caminhos. Eles são complementares."

### B12 · Honorários

Frase canônica: **"Em caso de êxito: 30% sobre a economia projetada total. Sem êxito, sem cobrança."**

Composição: 10% Basta + 20% Escritório parceiro · atuação jurídica e/ou administrativa = 30% total.

Definição de "economia projetada total": restituições efetivamente recebidas + redução do saldo devedor + redução de fluxo de caixa via portabilidade (12 meses pós-migração).

### B13 · Termo de Consentimento Granular

3 checkboxes separados, um por finalidade:

1. Autorizo a busca de portabilidade
2. Autorizo a renegociação supervisionada
3. Autorizo a análise por escritório de advocacia parceiro

Cada um com finalidade específica conforme LGPD art. 7º, I e Resolução BCB 32/2020.

**Comportamento por superfície:**

- No `24` (cliente): checkboxes ativos, podem ser marcados.
- No `23` (admin): checkboxes desabilitados visualmente. Selo lateral: "Pré-visualização — somente o cliente assina".

### B14 · Assinatura

Campos: Nome completo + CPF (com máscara). Aviso legal abaixo dos campos.

**Comportamento por superfície:**

- No `24` (cliente): inputs editáveis, CTA "Autorizar e assinar" funcional, registra timestamp + IP.
- No `23` (admin): inputs desabilitados, CTA desabilitado com texto "(visualização — somente o cliente assina)".

### B15 · Rodapé Documental

- Identificação Basta (CNPJ, endereço, suporte WhatsApp)
- Escritório parceiro (placeholder até definição)
- Base legal (LGPD art. 7º, I · Res. BCB 32/2020)
- ID do diagnóstico repetido

## Diferenças permitidas entre as superfícies

Apenas o **entorno** muda — não o miolo (B01–B15 acima):

| Elemento | `23` (admin) | `24` (cliente) |
|---|---|---|
| Sidebar | Sim, padrão admin (Aliado Legal) | Não |
| Topbar mobile | Sim | Não |
| Banner superior | Sim, com status + ações + link + histórico | Não |
| Banda "Pré-visualização" | Sim, antes da peça | Não |
| Termo (B13) | Checkboxes desabilitados | Ativos |
| Assinatura (B14) | Inputs desabilitados, CTA desabilitado | Ativos |
| Modal de envio WhatsApp | Sim | Não |
| `<title>` do HTML | "Basta. — Diagnóstico (admin) · Eduardo" | "Basta. — Eduardo, sua proposta" |

## Pontos abertos para revisão jurídica

Marcados no HTML como `LEGAL-NOTE` (comentários):

1. **Honorários (B12)** — definir contrato anexo com momento de exigibilidade, base de incidência por caminho, cláusula de rescisão por inação e limite máximo nominal.
2. **Termo de consentimento (B13)** — confirmar redação com escritório parceiro: granularidade Open Finance (Res. BCB 32), base legal LGPD (consentimento art. 7º, I), conformidade com Código de Ética OAB sobre captação (caminho 03 deve ser autorização de análise, não contratação direta).
3. **Template WhatsApp** — submeter à Meta para aprovação. Texto-base no modal de envio do `23`. Prazo Meta: 7 a 14 dias úteis.
4. **Token e TTL do link único** — definir mecanismo (JWT vs random + DB) e prazo de validade (proposta: 7 dias).
5. **Verificação adicional na assinatura** — proposta: CPF + últimos 4 dígitos do telefone para mitigar risco de link compartilhado.

## Pendências de produção (fora deste mock)

- Geração real de token na rota `/d/{id}?t={token}`
- Backend para registro da assinatura (timestamp, IP, hash, caminhos autorizados)
- Webhook WhatsApp para atualização de status (visualizado, clicado)
- Componentização React (`<DiagnosticoContent>` + `<DiagnosticoAdmin>` + `<DiagnosticoCliente>`) na migração para Next.js
- Geração de PDF da peça para anexo de email/contrato

## Changelog

| Data | Versão | Autor | Alteração |
|---|---|---|---|
| 07/05/2026 | 1.0 | Eduardo | Criação da spec. Separação inicial entre `23` (admin) e `24` (cliente). Conteúdo dos blocos B01–B15 documentado. |
| 07/05/2026 | 1.0.1 | Eduardo | Refinamento de ritmo vertical (somente diagramação). Aplicado princípio de Compound Blocks: lead narrativo + KPIs (B04+B05) e transição + cards de bancos (B06+B07) tratados como átomos únicos de informação, com gap interno reduzido e gap externo ampliado. CSS-only via seletor `:has()`. Sincronizado nos dois arquivos. |
| 07/05/2026 | 1.1 | Eduardo | Padronização de personas em todos os HTMLs do sistema. **User cliente padrão:** Maria Carvalho · maria.c@gmail.com (avatar MC). **User funcionário/admin padrão:** Eduardo Vergueiro · eavergueiro@gmail.com (avatar EV). Vocativos do diagnóstico passam a ser "Maria,". Banner admin do `23` mostra "Cliente: Maria Carvalho". Modal de envio com template "Olá, Maria". Sidebar admin nos arquivos 18–23 e ROW 1 da tabela em 22 atualizadas. ROW 5 do 22 ("Eduardo Avergueiro") mantida intacta por ser admin distinto. Mensagem ilustrativa em 19 ("Maria, aqui é o Eduardo da Basta...") preservada. |
| 07/05/2026 | 1.1.1 | Eduardo | Cleanup de inconsistências residuais detectadas via revisão visual. (1) `12_basta-dashboard.html`: saudação H1 "Olá, Eduardo." → "Olá, Maria.". (2) `16_basta-perfil.html`: campo Nome Completo "USUÁRIO DEMO" → "Maria Carvalho". (3) `16_basta-perfil.html`: campo Email "demo@exemplo.com" → "maria.c@gmail.com". Varredura final confirmou zero menções a "Eduardo" em arquivos cliente. |
