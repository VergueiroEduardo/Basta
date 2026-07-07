#!/bin/bash
# Launcher de export — double-click executa tudo
cd "$(dirname "$0")"

echo "═══════════════════════════════════════════════════════════"
echo " EXPORT FEEDS — Basta · 35 PNGs em 1080×1350"
echo "═══════════════════════════════════════════════════════════"
echo ""

if ! command -v node &> /dev/null; then
  echo "✗ Node.js não encontrado."
  echo "  Instale em: https://nodejs.org (versão LTS)"
  echo ""
  read -p "Pressione Enter para fechar..."
  exit 1
fi

echo "✓ Node $(node --version)"
echo ""

if [ ! -d "node_modules/puppeteer" ]; then
  echo "Puppeteer não encontrado. Instalando..."
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

echo "Capturando 35 feeds..."
echo ""
node export_feeds.js

echo ""
echo "═══════════════════════════════════════════════════════════"
echo " Pronto. PNGs em: exports_feeds/carrossel_01..07/"
echo "═══════════════════════════════════════════════════════════"
echo ""
read -p "Pressione Enter para fechar..."
