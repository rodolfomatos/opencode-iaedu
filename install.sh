#!/usr/bin/env bash
set -euo pipefail

REPO="rodolfomatos/opencode-iaedu"
BRANCH="main"
CONFIG_DIR="$HOME/.config/iaedu"
CONFIG_FILE="$CONFIG_DIR/env"
OPENCODE_CONFIG="$HOME/.config/opencode/opencode.jsonc"

# ── Cores ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# ── Pré-requisitos ─────────────────────────────────────────────────────────
command -v node  >/dev/null 2>&1 || { error "Node.js não encontrado. Instala-o primeiro."; exit 1; }
command -v npm   >/dev/null 2>&1 || { error "npm não encontrado."; exit 1; }
command -v opencode >/dev/null 2>&1 || warn "opencode não encontrado no PATH. O MCP será configurado mais tarde."

# ── Detetar diretório do projeto ───────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/package.json" ]; then
  PROJECT_DIR="$SCRIPT_DIR"
  info "A usar repositório local: $PROJECT_DIR"
else
  TMP_DIR=$(mktemp -d)
  PROJECT_DIR="$TMP_DIR/opencode-iaedu"
  info "A fazer clone do repositório $REPO..."
  git clone -b "$BRANCH" --depth 1 "https://github.com/$REPO.git" "$PROJECT_DIR"
  CLEANUP_TMP=1
fi

cd "$PROJECT_DIR"

# ── 1. Instalar dependências ───────────────────────────────────────────────
info "A instalar dependências npm..."
npm install --silent

# ── 2. Configurar credenciais (se não existirem) ────────────────────────────
if [ -f "$CONFIG_FILE" ]; then
  info "Credenciais já existem em $CONFIG_FILE"
else
  echo ""
  echo -e "${BOLD}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${BOLD}║  opencode-iaedu — Configuração de Credenciais   ║${NC}"
  echo -e "${BOLD}╚══════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "Vai a iaedu.pt, abre o teu agente e copia os valores"
  echo "de Agent ID, API Key e Channel ID."
  echo ""

  read -r -p "IAEDU Agent ID: " AGENT_ID
  while [ -z "$AGENT_ID" ]; do
    echo "  Agent ID não pode estar vazio."
    read -r -p "IAEDU Agent ID: " AGENT_ID
  done

  read -r -p "IAEDU API Key: " API_KEY
  while [ -z "$API_KEY" ]; do
    echo "  API Key não pode estar vazia."
    read -r -p "IAEDU API Key: " API_KEY
  done

  read -r -p "IAEDU Channel ID: " CHANNEL_ID
  while [ -z "$CHANNEL_ID" ]; do
    echo "  Channel ID não pode estar vazio."
    read -r -p "IAEDU Channel ID: " CHANNEL_ID
  done

  mkdir -p "$CONFIG_DIR"
  cat > "$CONFIG_FILE" <<EOF
# iaedu global config — usado por opencode-iaedu
IAEDU_AGENT_ID=$AGENT_ID
IAEDU_CHANNEL_ID=$CHANNEL_ID
IAEDU_API_KEY=$API_KEY
EOF
  chmod 600 "$CONFIG_FILE"
  info "Credenciais guardadas em $CONFIG_FILE"
fi

# ── 3. Instalar globalmente ────────────────────────────────────────────────
info "A instalar opencode-iaedu globalmente..."
npm install -g . 2>&1 | tail -1

# ── 4. Registar MCP server no opencode ─────────────────────────────────────
if command -v opencode >/dev/null 2>&1; then
  if opencode mcp list 2>&1 | grep -q iaedu; then
    info "MCP server 'iaedu' já está registado no opencode"
  else
    info "A registar MCP server 'iaedu' no opencode..."
    if [ -f "$OPENCODE_CONFIG" ]; then
      node -e "
        const fs = require('fs');
        let c = {};
        try { c = JSON.parse(fs.readFileSync('$OPENCODE_CONFIG', 'utf-8').replace(/\/\/.*\$/gm, '').replace(/,\s*([}\]])/g, '\$1')); } catch(e) {}
        if (!c.mcp) c.mcp = {};
        if (!c.mcp.iaedu) {
          c.mcp.iaedu = { type: 'local', command: ['opencode-iaedu'] };
          fs.writeFileSync('$OPENCODE_CONFIG', JSON.stringify(c, null, 2));
          info 'MCP server iaedu adicionado ao opencode.jsonc';
        }
      "
    else
      warn "$OPENCODE_CONFIG não encontrado. Cria manualmente ou corre 'opencode mcp add iaedu'"
    fi
  fi
else
  warn "opencode não está instalado. Quando instalares, corre: opencode mcp add iaedu"
fi

# ── 5. Done ────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║  opencode-iaedu instalado com sucesso!                 ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "  Numa sessão opencode, pede ao agente para usar a"
echo "  ferramenta 'complete' do IAEDU."
echo ""
echo "  Exemplo:"
echo "    opencode run \"usa a complete tool do IAEDU para responder: o que é a capital de Portugal?\""
echo ""

# ── Limpeza ────────────────────────────────────────────────────────────────
if [ -n "${CLEANUP_TMP:-}" ]; then
  rm -rf "$TMP_DIR"
fi
