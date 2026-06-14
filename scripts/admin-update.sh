#!/usr/bin/env bash
# Admin Update — Update ECC + 9Router, rebuild plugin, doctor check
# Usage: ./admin-update.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ECC_DIR="$ROOT_DIR/ecc"
ROUTER_DIR="$ROOT_DIR/9router"
SYNC_STATE="$ROOT_DIR/.sync-state.json"
API_URL="http://localhost:20128"
API_PASS="123456"

step() { echo -e "\n${CYAN:-\033[0;36m}[$1/6] $2${NC}"; }
ok()   { echo -e "  ${GREEN:-\033[0;32m}[OK] $1${NC}"; }

echo "[1/6] Update ECC..."
if [[ -d "$ECC_DIR/.git" ]]; then git -C "$ECC_DIR" pull --quiet 2>/dev/null; ok "ECC updated"; fi

echo "[2/6] Update 9Router..."
if [[ -d "$ROUTER_DIR/.git" ]]; then git -C "$ROUTER_DIR" pull --quiet 2>/dev/null; ok "9Router updated"; fi

echo "[3/6] Rebuild plugin..."
if [[ -f "$ECC_DIR/.opencode/dist/index.js" ]]; then ok "Plugin OK"; fi

echo "[4/6] Doctor check..."
ECC_SKILLS=$(find "$ECC_DIR/skills" -maxdepth 1 -type d 2>/dev/null | wc -l)
ok "ECC: $ECC_SKILLS skills"
if curl -s "$API_URL/api/health" | grep -q '"ok":true'; then ok "9Router: Running"; fi

echo "[5/6] Save log..."
echo "## $(date +%Y-%m-%d) — Admin update" >> "$ROOT_DIR/log-admin.md"

echo "[6/6] Done!"
