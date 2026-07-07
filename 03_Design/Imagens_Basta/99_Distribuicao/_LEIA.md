# Distribuição

Versões autocontidas (imagens em base64 + fontes embutidas), prontas para enviar por WhatsApp, e-mail, GitHub Pages, etc.

## Estrutura

```
gallery/                  → galeria de posts individuais
  post_1080x1350.html     → versão feed (50 posts, 5×10)
  story_1080x1920.html    → versão story (50 posts, 5×10)

overview-5x5/             → board de carrosséis
  post_1080x1350.html     → versão feed (5 carrosséis × 5 slides)
  story_1080x1920.html    → versão story (5 carrosséis × 5 slides)

_sobressalentes/          → versões antigas e arquivos descartáveis
  _backup/                → snapshots antes de revisões
  *_redundante.html       → cópias intermediárias
```

## Regras

- **NÃO editar** os HTMLs nas pastas gallery/ e overview-5x5/ — são distribuíveis finais.
- Para editar conteúdo, voltar aos mestres em `../05_Overviews/` (refs externas + assets em `01_Imagens_Brutas/`) e gerar nova versão autocontida.
- Arquivos em `_sobressalentes/` podem ser apagados a qualquer momento.
