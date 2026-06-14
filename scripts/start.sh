#!/usr/bin/env bash
# OpenCode Daily Workflow (macOS/Linux)
# Check repos, sync, test models, apply profile
# Usage: ./start.sh --profile gratis|go

set -euo pipefail

# ============================================================
# Parse args
# ============================================================

PROFILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --profile) PROFILE="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 --profile <gratis|go>"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$PROFILE" ]]; then
    echo "[ERROR] --profile is required (gratis or go)"
    exit 1
fi

if [[ "$PROFILE" != "gratis" && "$PROFILE" != "go" ]]; then
    echo "[ERROR] Profile must be 'gratis' or 'go'"
    exit 1
fi

# ============================================================
# Paths
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ECC_DIR="$ROOT_DIR/ecc"
ROUTER_DIR="$ROOT_DIR/9router"
SYNC_STATE="$ROOT_DIR/.sync-state.json"
OPENCODE_DIR="$HOME/.config/opencode"
OPENCODE_CONFIG="$OPENCODE_DIR/opencode.jsonc"
PROFILE_CONFIG="$ROOT_DIR/profiles/$PROFILE/opencode.jsonc"
API_URL="http://localhost:20128"
API_PASS="123456"

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

step() { echo -e "\n${CYAN}[$1/7] $2${NC}"; }
ok()   { echo -e "  ${GREEN}[OK] $1${NC}"; }
skip() { echo -e "  ${YELLOW}[SKIP] $1${NC}"; }
fail() { echo -e "  ${RED}[FAIL] $1${NC}"; }
info() { echo -e "  ${GRAY}[INFO] $1${NC}"; }

# ============================================================
# Banner
# ============================================================

PROFILE_LABEL="100% Free"
[[ "$PROFILE" == "go" ]] && PROFILE_LABEL="Go (Limited)"
SESSION_FILE="$ROOT_DIR/.opencode-session.json"

echo -e "${MAGENTA:-\033[0;35m}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         OpenCode Daily Workflow                  ║"
echo "  ║         Profile: $PROFILE_LABEL$(printf '%*s' $((25 - ${#PROFILE_LABEL})) '')║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# Load Session State
# ============================================================

SESSION=""
if [[ -f "$SESSION_FILE" ]]; then
    SESSION=$(cat "$SESSION_FILE" 2>/dev/null || echo "")
    LAST_ACTION=$(echo "$SESSION" | python3 -c "import sys,json; print(json.load(sys.stdin).get('last_action',''))" 2>/dev/null || echo "")
    [[ -n "$LAST_ACTION" ]] && echo -e "  ${GRAY}[SESSION] Loaded previous session ($LAST_ACTION)${NC}"
fi

# ============================================================
# Auto-Update Check
# ============================================================

echo -e "  ${GRAY}[UPDATE] Checking for updates...${NC}"

ECC_BEFORE=$(git -C "$ECC_DIR" log -1 --format="%H" 2>/dev/null || echo "")
ROUTER_BEFORE=$(git -C "$ROUTER_DIR" log -1 --format="%H" 2>/dev/null || echo "")

HAS_ECC_UPDATES=false
HAS_ROUTER_UPDATES=false

if [[ -d "$ECC_DIR/.git" ]]; then
    git -C "$ECC_DIR" pull --quiet 2>/dev/null || true
    ECC_AFTER=$(git -C "$ECC_DIR" log -1 --format="%H" 2>/dev/null || echo "")
    [[ "$ECC_BEFORE" != "$ECC_AFTER" ]] && HAS_ECC_UPDATES=true
fi

if [[ -d "$ROUTER_DIR/.git" ]]; then
    git -C "$ROUTER_DIR" pull --quiet 2>/dev/null || true
    ROUTER_AFTER=$(git -C "$ROUTER_DIR" log -1 --format="%H" 2>/dev/null || echo "")
    [[ "$ROUTER_BEFORE" != "$ROUTER_AFTER" ]] && HAS_ROUTER_UPDATES=true
fi

if [[ "$HAS_ECC_UPDATES" == "true" || "$HAS_ROUTER_UPDATES" == "true" ]]; then
    echo -e "  ${YELLOW}[UPDATE] Updates detected! Rebuilding plugin...${NC}"
    cd "$ECC_DIR"
    [[ ! -d "node_modules" ]] && npm install --silent 2>/dev/null || true
    if [[ ! -d ".opencode/node_modules" ]]; then cd .opencode && npm install --silent 2>/dev/null && cd .. || true; fi
    npm run build:opencode 2>/dev/null || true
    cd "$ROOT_DIR"
    ok "Plugin rebuilt"
    
    # Update sync state
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S")
    ECC_VERSION=$(cat "$ECC_DIR/VERSION" 2>/dev/null || echo "unknown")
    cat > "$SYNC_STATE" << JSONEOF
{
  "ecc": { "last_sha": "$ECC_AFTER", "last_sync": "$TIMESTAMP", "repo": "fannndi/ECC", "version": "$ECC_VERSION" },
  "9router": { "last_sha": "$ROUTER_AFTER", "last_sync": "$TIMESTAMP", "repo": "fannndi/9router" }
}
JSONEOF
    ok "Sync state updated"
else
    ok "No updates"
fi

# ============================================================
# [1/7] Check repos
# ============================================================

step "1/7" "Checking repositories..."

# ECC
if [[ ! -d "$ECC_DIR/.git" ]]; then
    info "ECC not found, cloning..."
    git clone --quiet https://github.com/fannndi/ECC.git "$ECC_DIR"
    ok "ECC cloned"
else
    BEFORE=$(git -C "$ECC_DIR" log -1 --format="%H")
    git -C "$ECC_DIR" pull --quiet 2>/dev/null || true
    AFTER=$(git -C "$ECC_DIR" log -1 --format="%H")
    if [[ "$BEFORE" != "$AFTER" ]]; then
        ok "ECC: updated (${BEFORE:0:7} → ${AFTER:0:7})"
    else
        ok "ECC: already up to date"
    fi
fi

# 9Router
if [[ ! -d "$ROUTER_DIR/.git" ]]; then
    info "9Router not found, cloning..."
    git clone --quiet https://github.com/fannndi/9router.git "$ROUTER_DIR"
    ok "9Router cloned"
else
    BEFORE=$(git -C "$ROUTER_DIR" log -1 --format="%H")
    git -C "$ROUTER_DIR" pull --quiet 2>/dev/null || true
    AFTER=$(git -C "$ROUTER_DIR" log -1 --format="%H")
    if [[ "$BEFORE" != "$AFTER" ]]; then
        ok "9Router: updated (${BEFORE:0:7} → ${AFTER:0:7})"
    else
        ok "9Router: already up to date"
    fi
fi

# ============================================================
# [2/7] Sync changelog
# ============================================================

step "2/7" "Syncing changelog..."

ECC_HAS_CHANGES=false
ROUTER_HAS_CHANGES=false

if [[ -f "$SYNC_STATE" ]]; then
    ECC_LAST_SHA=$(python3 -c "import json; print(json.load(open('$SYNC_STATE'))['ecc']['last_sha'])" 2>/dev/null || echo "")
    ROUTER_LAST_SHA=$(python3 -c "import json; print(json.load(open('$SYNC_STATE'))['9router']['last_sha'])" 2>/dev/null || echo "")
    ECC_CURRENT_SHA=$(git -C "$ECC_DIR" log -1 --format="%H")
    ROUTER_CURRENT_SHA=$(git -C "$ROUTER_DIR" log -1 --format="%H")

    [[ "$ECC_LAST_SHA" != "$ECC_CURRENT_SHA" ]] && ECC_HAS_CHANGES=true
    [[ "$ROUTER_LAST_SHA" != "$ROUTER_CURRENT_SHA" ]] && ROUTER_HAS_CHANGES=true

    if [[ "$ECC_HAS_CHANGES" == "true" || "$ROUTER_HAS_CHANGES" == "true" ]]; then
        ECC_COMMITS=0
        ROUTER_COMMITS=0

        if [[ "$ECC_HAS_CHANGES" == "true" ]]; then
            ECC_COMMITS=$(git -C "$ECC_DIR" log "$ECC_LAST_SHA..$ECC_CURRENT_SHA" --oneline 2>/dev/null | wc -l)
        fi
        if [[ "$ROUTER_HAS_CHANGES" == "true" ]]; then
            ROUTER_COMMITS=$(git -C "$ROUTER_DIR" log "$ROUTER_LAST_SHA..$ROUTER_CURRENT_SHA" --oneline 2>/dev/null | wc -l)
        fi

        echo -e "  ${WHITE}ECC: $ECC_COMMITS new commit(s)${NC}"
        echo -e "  ${WHITE}9Router: $ROUTER_COMMITS new commit(s)${NC}"
    else
        ok "No changes since last sync"
    fi
else
    skip "No sync state found (first run)"
fi

# ============================================================
# [3/7] Analyze updates
# ============================================================

step "3/7" "Analyzing updates..."

NEEDS_REBUILD=false

if [[ "$ECC_HAS_CHANGES" == "true" ]]; then
    ECC_LAST_SHA=$(python3 -c "import json; print(json.load(open('$SYNC_STATE'))['ecc']['last_sha'])" 2>/dev/null || echo "")
    ECC_CURRENT_SHA=$(git -C "$ECC_DIR" log -1 --format="%H")
    COMMITS=$(git -C "$ECC_DIR" log "$ECC_LAST_SHA..$ECC_CURRENT_SHA" --oneline 2>/dev/null || echo "")

    if echo "$COMMITS" | grep -qiE "opencode|plugin|\.opencode|build:opencode"; then
        NEEDS_REBUILD=true
    fi
fi

if [[ "$NEEDS_REBUILD" == "true" ]]; then
    info "Opencode changes detected, rebuilding plugin..."
    cd "$ECC_DIR"

    if [[ ! -d "node_modules" ]]; then
        info "Installing root dependencies..."
        npm install --silent 2>/dev/null || true
    fi

    if [[ ! -d ".opencode/node_modules" ]]; then
        info "Installing .opencode dependencies..."
        cd .opencode && npm install --silent 2>/dev/null && cd .. || true
    fi

    npm run build:opencode 2>/dev/null || true
    if [[ -f ".opencode/dist/index.js" ]]; then
        ok "Plugin rebuilt successfully"
    else
        fail "Plugin build failed"
    fi

    cd "$ROOT_DIR"
else
    ok "No rebuild needed"
fi

# Update sync state
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S")
ECC_VERSION=$(cat "$ECC_DIR/VERSION" 2>/dev/null || echo "unknown")
ECC_SHA=$(git -C "$ECC_DIR" log -1 --format="%H")
ROUTER_SHA=$(git -C "$ROUTER_DIR" log -1 --format="%H")

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

# ============================================================
# [4/7] Test 9Router
# ============================================================

step "4/7" "Testing 9Router..."

if lsof -i :20128 >/dev/null 2>&1; then
    ok "9Router already running on port 20128"
else
    info "9Router not running, auto-starting..."
    9router --tray &
    sleep 4

    if lsof -i :20128 >/dev/null 2>&1; then
        ok "9Router auto-started on port 20128"
    else
        fail "9Router failed to start"
    fi
fi

# Health check
HEALTH=$(curl -s "$API_URL/api/health" 2>/dev/null || echo '{"ok":false}')
if echo "$HEALTH" | grep -q '"ok":true'; then
    ok "Health check passed"
else
    fail "Health check failed"
fi

# ============================================================
# [5/7] Test models
# ============================================================

step "5/7" "Testing models..."

# Login
LOGIN_RESP=$(curl -s -X POST "$API_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"password\":\"$API_PASS\"}" \
    -c /tmp/9router-cookies.txt 2>/dev/null || echo '{"success":false}')

if echo "$LOGIN_RESP" | grep -q '"success":true'; then
    ok "API login successful"
else
    fail "API login failed"
fi

# Determine models to test
MODELS_TO_TEST=()
if [[ "$PROFILE" == "gratis" ]]; then
    MODELS_TO_TEST=("mmf/mimo-auto" "oc/deepseek-v4-flash-free" "oc/mimo-v2.5-free")
else
    MODELS_TO_TEST=("ocg/kimi-k2.6" "ocg/qwen3.6-plus")
fi

for MODEL in "${MODELS_TO_TEST[@]}"; do
    RESP=$(curl -s -X POST "$API_URL/v1/chat/completions" \
        -H "Content-Type: application/json" \
        -b /tmp/9router-cookies.txt 2>/dev/null \
        -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}],\"max_tokens\":10}" \
        --max-time 15 2>/dev/null || echo '{"error":"timeout"}')

    REPLY=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['choices'][0]['message']['content'][:30])" 2>/dev/null || echo "")

    if [[ -n "$REPLY" ]]; then
        ok "$MODEL : responding ($REPLY...)"
    else
        fail "$MODEL : no response"
    fi
done

# ============================================================
# [6/7] Apply profile
# ============================================================

step "6/7" "Applying profile: $PROFILE..."

# Backup existing config
if [[ -f "$OPENCODE_CONFIG" ]]; then
    BACKUP="${OPENCODE_CONFIG}.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$OPENCODE_CONFIG" "$BACKUP"
    ok "Existing config backed up"
fi

# Copy profile config
if [[ ! -f "$PROFILE_CONFIG" ]]; then
    fail "Profile config not found: $PROFILE_CONFIG"
else
    mkdir -p "$OPENCODE_DIR"
    cp "$PROFILE_CONFIG" "$OPENCODE_CONFIG"
    ok "Config: $PROFILE → $OPENCODE_CONFIG"
fi

# Set env vars
if [[ -f "$HOME/.bashrc" ]]; then
    sed -i '/^export ECC_HOOK_PROFILE=/d' "$HOME/.bashrc"
    echo "export ECC_HOOK_PROFILE=standard" >> "$HOME/.bashrc"
elif [[ -f "$HOME/.zshrc" ]]; then
    sed -i '/^export ECC_HOOK_PROFILE=/d' "$HOME/.zshrc"
    echo "export ECC_HOOK_PROFILE=standard" >> "$HOME/.zshrc"
fi
export ECC_HOOK_PROFILE=standard
ok "ECC_HOOK_PROFILE=standard"

# ============================================================
# [7/7] Ready
# ============================================================

step "7/7" "Status summary"

# ============================================================
# Save Session
# ============================================================

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S")
STACK=""
SKILLS="[]"
RULES="[]"
PRD_ANALYZED="false"
AI_NOTES="false"
ANALYZE_DONE="false"
CREATED="$TIMESTAMP"

if [[ -n "$SESSION" ]]; then
    STACK=$(echo "$SESSION" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stack',''))" 2>/dev/null || echo "")
    PRD_ANALYZED=$(echo "$SESSION" | python3 -c "import sys,json; print(json.load(sys.stdin).get('workflow_state',{}).get('prd_analyzed',False))" 2>/dev/null || echo "false")
    AI_NOTES=$(echo "$SESSION" | python3 -c "import sys,json; print(json.load(sys.stdin).get('workflow_state',{}).get('ai_notes_generated',False))" 2>/dev/null || echo "false")
    ANALYZE_DONE=$(echo "$SESSION" | python3 -c "import sys,json; print(json.load(sys.stdin).get('workflow_state',{}).get('analyze_project_done',False))" 2>/dev/null || echo "false")
    CREATED=$(echo "$SESSION" | python3 -c "import sys,json; print(json.load(sys.stdin).get('created_at','$TIMESTAMP'))" 2>/dev/null || echo "$TIMESTAMP")
fi

cat > "$SESSION_FILE" << JSONEOF
{
  "version": "1.0",
  "last_profile": "$PROFILE",
  "stack": "$STACK",
  "skills_loaded": [],
  "rules_applied": [],
  "workflow_state": {
    "prd_analyzed": $PRD_ANALYZED,
    "ai_notes_generated": $AI_NOTES,
    "analyze_project_done": $ANALYZE_DONE
  },
  "last_action": "/start-$PROFILE",
  "created_at": "$CREATED",
  "updated_at": "$TIMESTAMP"
}
JSONEOF

echo -e "  ${GRAY}[SESSION] Saved to .opencode-session.json${NC}"

echo ""
echo -e "  ${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║              All systems GO!                     ║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${WHITE}Profile:     $PROFILE${NC}"
echo -e "  ${WHITE}Config:      $OPENCODE_CONFIG${NC}"
echo -e "  ${WHITE}9Router:     $API_URL${NC}"
echo -e "  ${WHITE}Dashboard:   $API_URL/dashboard${NC}"
echo ""

if [[ "$PROFILE" == "gratis" ]]; then
    echo -e "  ${YELLOW}Combo chain:${NC}"
    echo -e "  ${WHITE}    oc/mimo-v2.5-free → oc/deepseek-v4-flash-free → kr/claude-sonnet-4.5${NC}"
    echo -e "  ${GREEN}    Cost: FREE forever${NC}"
else
    echo -e "  ${YELLOW}Combo chain:${NC}"
    echo -e "  ${WHITE}    ocg/kimi-k2.6 → ocg/qwen3.6-plus → ocg/glm-5.1${NC}"
    echo -e "  ${YELLOW}    Cost: Limited quota${NC}"
fi

echo ""
echo -e "  ${CYAN}Next: opencode${NC}"
echo ""
