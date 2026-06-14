#!/usr/bin/env bash
# Clone ECC + 9Router repos and record SHA
# Usage: ./clone.sh [--force]

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ECC_DIR="$SETUP_DIR/ecc"
ROUTER_DIR="$SETUP_DIR/9router"
SYNC_STATE="$SETUP_DIR/.sync-state.json"

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

# ============================================================
# Colors
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m'

step() { echo -e "\n${CYAN}[$1/2] $2${NC}"; }
ok()   { echo -e "  ${GREEN}[OK] $1${NC}"; }
skip() { echo -e "  ${YELLOW}[SKIP] $1${NC}"; }
fail() { echo -e "  ${RED}[FAIL] $1${NC}"; exit 1; }

# ============================================================
# Banner
# ============================================================

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Clone Repos - ECC + 9Router             ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# Step 1: Clone ECC
# ============================================================

step "1/2" "Clone ECC (fannndi/ECC)..."

if [[ -d "$ECC_DIR/.git" ]]; then
    if [[ "$FORCE" == "true" ]]; then
        echo -e "  ${YELLOW}Force mode: removing existing clone...${NC}"
        rm -rf "$ECC_DIR"
        git clone --quiet https://github.com/fannndi/ECC.git "$ECC_DIR"
    else
        skip "ECC already cloned, pulling latest..."
        cd "$ECC_DIR" && git pull --quiet && cd "$SETUP_DIR"
    fi
else
    echo -e "  ${GRAY}Cloning fannndi/ECC...${NC}"
    git clone --quiet https://github.com/fannndi/ECC.git "$ECC_DIR"
fi

ECC_SHA=$(git -C "$ECC_DIR" log -1 --format="%H")
ECC_DATE=$(git -C "$ECC_DIR" log -1 --format="%ai")
ECC_VERSION=$(cat "$ECC_DIR/VERSION" 2>/dev/null || echo "unknown")
ok "ECC cloned (SHA: ${ECC_SHA:0:7}, Version: $ECC_VERSION, Date: $ECC_DATE)"

# ============================================================
# Step 2: Clone 9Router
# ============================================================

step "2/2" "Clone 9Router (fannndi/9router)..."

if [[ -d "$ROUTER_DIR/.git" ]]; then
    if [[ "$FORCE" == "true" ]]; then
        echo -e "  ${YELLOW}Force mode: removing existing clone...${NC}"
        rm -rf "$ROUTER_DIR"
        git clone --quiet https://github.com/fannndi/9router.git "$ROUTER_DIR"
    else
        skip "9Router already cloned, pulling latest..."
        cd "$ROUTER_DIR" && git pull --quiet && cd "$SETUP_DIR"
    fi
else
    echo -e "  ${GRAY}Cloning fannndi/9router...${NC}"
    git clone --quiet https://github.com/fannndi/9router.git "$ROUTER_DIR"
fi

ROUTER_SHA=$(git -C "$ROUTER_DIR" log -1 --format="%H")
ROUTER_DATE=$(git -C "$ROUTER_DIR" log -1 --format="%ai")
ok "9Router cloned (SHA: ${ROUTER_SHA:0:7}, Date: $ROUTER_DATE)"

# ============================================================
# Update .sync-state.json
# ============================================================

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S")

cat > "$SYNC_STATE" << JSONEOF
{
  "ecc": {
    "last_sha": "$ECC_SHA",
    "last_sync": "$TIMESTAMP",
    "repo": "fannndi/ECC",
    "version": "$ECC_VERSION"
  },
  "9router": {
    "last_sha": "$ROUTER_SHA",
    "last_sync": "$TIMESTAMP",
    "repo": "fannndi/9router"
  }
}
JSONEOF

ok "SHA recorded to .sync-state.json"

# ============================================================
# Summary
# ============================================================

echo ""
echo -e "  ${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║              Clone Complete!                     ║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${WHITE}ECC:     $ECC_DIR${NC}"
echo -e "  ${WHITE}9Router: $ROUTER_DIR${NC}"
echo ""
echo -e "  ${YELLOW}SHA:${NC}"
echo -e "  ${WHITE}    ECC:     ${ECC_SHA:0:7} ($ECC_VERSION)${NC}"
echo -e "  ${WHITE}    9Router: ${ROUTER_SHA:0:7}${NC}"
echo ""
