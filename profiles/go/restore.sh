#!/usr/bin/env bash
# Restore Go Profile (Limited Quota Models)
# Switch global OpenCode config to Go models with auto-fallback combos

set -euo pipefail

CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.jsonc"
BACKUP_DIR="$CONFIG_DIR/backups"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CONFIG="$SCRIPT_DIR/opencode.jsonc"
API_URL="http://localhost:20128"
API_PASS="123456"

echo ""
echo "=== Restore Go Profile ==="
echo "Models: ocg/kimi-k2.6 -> ocg/qwen3.6-plus -> ocg/glm-5.1"
echo "WARNING: Go models have limited quota!"
echo ""

# Backup current config
if [[ -f "$CONFIG_FILE" ]]; then
    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    cp "$CONFIG_FILE" "$BACKUP_DIR/opencode.jsonc.$TIMESTAMP.bak"
    echo "[OK] Backup: $BACKUP_DIR/opencode.jsonc.$TIMESTAMP.bak"
fi

# Copy config
if [[ ! -f "$SOURCE_CONFIG" ]]; then
    echo "[ERROR] opencode.jsonc not found in $SCRIPT_DIR"
    exit 1
fi

mkdir -p "$CONFIG_DIR"
cp "$SOURCE_CONFIG" "$CONFIG_FILE"

# Fix hardcoded paths → dynamic
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OLD_PATH="C:/Users/FANNNDI/Documents/opencode-setup"
if [[ "$OSTYPE" == "darwin"* || "$OSTYPE" == "linux-gnu"* ]]; then
    sed -i "s|$OLD_PATH|$ROOT_DIR|g" "$CONFIG_FILE"
fi
echo "[OK] Restored: $CONFIG_FILE"

# Verify 9Router
if curl -s "$API_URL/api/health" | grep -q '"ok":true'; then
    echo "[OK] 9Router running"
else
    echo "[WARN] 9Router NOT running. Run: 9router --tray"
fi

# Verify combos
LOGIN=$(curl -s -X POST "$API_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"password\":\"$API_PASS\"}" \
    -c /tmp/9router-cookies.txt 2>/dev/null || echo '{"success":false}')

if echo "$LOGIN" | grep -q '"success":true'; then
    COMBOS=$(curl -s -X GET "$API_URL/api/combos" \
        -b /tmp/9router-cookies.txt 2>/dev/null || echo '{"combos":[]}')
    NAMES=$(echo "$COMBOS" | python3 -c "import sys,json; print(' '.join([c['name'] for c in json.load(sys.stdin).get('combos',[])]))" 2>/dev/null || echo "unable to parse")
    echo "[OK] Combos: $NAMES"
fi

# Verify env var
if [[ -n "${NINEROUTER_API_KEY:-}" ]]; then
    echo "[OK] NINEROUTER_API_KEY set"
else
    echo "[WARN] NINEROUTER_API_KEY not set. Edit api-key.txt or set manually."
fi

echo ""
echo "Done! Restart OpenCode to apply."
