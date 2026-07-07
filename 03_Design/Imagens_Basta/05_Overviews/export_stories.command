#!/bin/bash
# Launcher de export — double-click executa tudo
cd "$(dirname "$0")"

echo "═══════════════════════════════════════════════════════════"
echo " EXPORT STORIES — Basta · 35 PNGs em 1080×1920"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Checa Node
if ! command -v node &> /dev/null; then
  echo "✗ Node.js não encontrado."
  echo "  Instale em: https://nodejs.org (versão LTS)"
  echo ""
  read -p "Pressione Enter para fechar..."
  exit 1
fi

echo "✓ Node $(node --version)"
echo ""

# Instala puppeteer se necessário
if [ ! -d "node_modules/puppeteer" ]; then
  echo "Instalando Puppeteer (primeira vez — ~2 a 3 min, baixa Chromium)..."
  echo ""
  npm install puppeteer
  if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Falha na instalação do Puppeteer."
    read -p "Pressione Enter para fechar..."
    exit 1
  fi
  echo ""
fi

echo "Capturando 35 stories..."
echo ""
node export_stories.js

echo ""
echo "═══════════════════════════════════════════════════════════"
echo " Pronto. PNGs em: exports_stories/carrossel_01..07/"
echo "═══════════════════════════════════════════════════════════"
echo ""
read -p "Pressione Enter para fechar..."
