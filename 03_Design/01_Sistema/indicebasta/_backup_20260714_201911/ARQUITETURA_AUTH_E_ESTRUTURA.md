# Basta — Arquitetura de Autenticação & Estrutura do Sistema

**Status:** proposta para aprovação · **Data:** 2026-06-17 · **Contexto:** startup em MVP

Documento de decisão antes de reorganizar os arquivos. Nada foi movido ainda — os 29 HTMLs seguem na raiz, backup preservado em `_backup_pre_reorg_*`.

---

## 1. Princípio que organiza tudo

Não existe uma camada "pública" universal. **Cada persona é uma fatia vertical (auth → onboarding → app).** O que é de fato compartilhado é só duas coisas:

1. O **design system** (`_foundation`, `_components`, `_assets`, `_partials`, `_scripts`).
2. A **camada de identidade** — login, reset, convite, MFA.

Tudo o mais diverge por persona. A regra que decide o nível de proteção de cada uma é **blast radius**: quanto dano aquela persona pode causar se comprometida.

---

## 2. Decisões travadas

### 2.1 Autenticação
- **Login único que roteia por papel** para Cliente e Parceiro — uma porta, roteamento pós-autenticação.
- **Admin fica fora desse portão.** Federa via **SSO corporativo** (Google Workspace/Okta) com MFA obrigatório. Sem senha local na Basta → sem cadastro e sem reset de admin no sistema. App/subdomínio à parte (ex: `admin.basta.*`), não linkado publicamente.
- O fluxo de login **não pode vazar papel nem existência de conta** (anti-enumeração). Respostas sempre genéricas.

### 2.2 Identidade é uma espinha compartilhada (construir uma vez)
- Login, reset, convite e MFA são **infraestrutura única**, não replicada por produto. Reconstruir isso três vezes (um por produto de parceiro) é o desperdício real a evitar.
- "Três produtos" vive na camada de aplicação; "construa uma vez" vive na camada de identidade. Camadas diferentes, não conflitam.

### 2.3 Três produtos de parceiro distintos
Portabilidade, Abusos e Renegociação são **produtos distintos, entregues por times distintos** (bancos/fintechs, advogados, time de renegociação administrativa). Audiências e jornadas diferentes → **superfícies separadas**, em cima da espinha de identidade comum.

### 2.4 Onboarding por persona
- **Cliente:** auto-cadastro (self-service).
- **Admin:** provisionado (admin cria admin) + SSO.
- **Parceiro:** convite. Parceiro é **organização multiusuário** com hierarquia interna (mín. *Gestor* e *Operador*). Cascata: equipe Basta cria a org + convida o 1º Gestor; o Gestor convida os colegas. Tira a gestão de usuários do time Basta.

### 2.5 Reset de senha por blast radius
- **Admin:** não tem senha local → "reset" é problema do provedor de identidade (SSO+MFA). Elimina a maior superfície de risco.
- **Parceiro:** convite single-use e expirável → no 1º acesso define credencial + matricula MFA. Reset = magic link no e-mail corporativo **somado a MFA** (e-mail sozinho nunca basta). Gestor pode resetar/desativar colega; admin Basta pode suspender a org inteira.
- **Cliente:** self-service, com **OTP no WhatsApp como segundo fator** — canal já verificado na jornada (Open Finance + WhatsApp). Mais forte que reset só por e-mail e contextual ao produto.

### 2.6 Higiene de account takeover (dado financeiro — vale para todos)
- Invalidar **todas as sessões ativas** ao redefinir credencial.
- **Notificar em todos os canais** (e-mail + WhatsApp): "sua senha foi alterada, não foi você?".
- **Step-up antes de reexibir dado sensível:** trocar a senha deixa entrar, mas ver Open Finance/contas exige reverificação. Avaliar reconfirmar o consentimento de Open Finance após reset de credencial.
- Atribuição de auditoria **por usuário** dentro da org parceira (quem acessou o CPF de qual cliente) — exigência LGPD/Open Finance.
- Acesso de parceiro é **least privilege** (escopo do produto) e **revogável instantaneamente**.

---

## 3. Disciplina de MVP — construir agora vs. adiar

**Agora:**
- Login único + reset.
- MFA via app autenticador (**TOTP** — custo zero, inegociável com dado financeiro).
- Admin via SSO de prateleira.
- Modelo de dados de org/papéis **desenhado** corretamente (barato), com UI mínima.

**Adiar (Fase 2):**
- Máquina completa de org-multiusuário (Gestor convidando colegas via self-service).
- RBAC granular e tela de gestão de equipe self-service.
- No MVP, os poucos operadores de cada parceiro são onboardados na mão. O modelo só precisa *permitir* a Fase 2, não entregá-la agora.

---

## 4. Estrutura de pastas proposta

```
Sistema/
├── _shared/                  design system (foundation, components, assets, partials, scripts)
├── _auth/                    login único, reset, convite, MFA  ← NÃO duplicar nos produtos
├── Cliente/                  app cliente + Open Finance (07–11)
├── Parceiro-Portabilidade/   bancos/fintechs   (tem telas hoje)
├── Parceiro-Abusos/          advogados         (vazia → time constrói)
├── Parceiro-Renegociacao/    renegociação      (vazia → time constrói)
└── Admin/                    SSO corporativo, à parte
```

Mapeia quase 1:1 para os *route groups* do Next.js depois: `(auth)` compartilhado, `(cliente)`/`(parceiro-*)` segmentados com layout próprio, Admin como app/subdomínio separado.

### 4.1 Distribuição dos HTMLs atuais

| Pasta | Telas |
|---|---|
| `_auth/` | 03_login (vira login único), 04_recuperar-senha, 05_redefinir-senha, 06_conta-criada, 26_login-parceiros* |
| `Cliente/` | 02_cadastro, 07–11 Open Finance, 12_dashboard, 13_documentos, 14_contas-bancarias, 15_requerimentos, 16_perfil, 17_ajuda, 24_diagnostico-cliente |
| `Admin/` | 18_hoje, 19_conversas, 20_pipeline, 21_templates, 22_usuarios, 23_diagnostico-admin |
| `Parceiro-Portabilidade/` | 25_ficha-credor, 27_dashboard-parceiros, 27_consulta-cpf |
| `Parceiro-Abusos/` | (vazia) |
| `Parceiro-Renegociacao/` | (vazia) |
| (fora do sistema) | 01_landing → institucional, sai do `Front_End` |
| raiz | 00_index (catálogo-mestre) |

\* `26_login-parceiros` e `03_login` se fundem no login único — manter um, descartar/arquivar o outro na execução.

### 4.2 O que muda em relação ao que tentamos no começo
- **Login NÃO se duplica** nas três pastas de parceiro — vai para `_auth` compartilhado.
- Abusos e Renegociação começam **vazias** (cada time constrói), em vez de receberem cópia da Portabilidade.
- **Institucional (landing) sai** do `Front_End` — é outra preocupação (site de marketing).
- Admin tende a virar **app/subdomínio separado**, não só uma subpasta.

---

## 5. Lacunas que esse modelo expõe (telas a desenhar)

- Aceitar convite → definir senha + matricular MFA (parceiro).
- Matrícula de MFA + desafio de MFA (camada `_auth`, compartilhada).
- Gestão de equipe do parceiro: membros, convidar, papéis, desativar — só Gestor (Fase 2).
- Admin Basta: criar/suspender organização-parceira (pode caber no `22_usuarios` ou virar tela nova).

---

## 6. Itens em aberto para decidir
- Renegociação é parceiro **externo** ou time **interno** Basta? (muda se entra como org-parceira ou como papel de admin).
- `01_landing` institucional: move para outro repositório/projeto ou só sai desta pasta?
- Admin como subdomínio separado já no MVP, ou route group por enquanto?
