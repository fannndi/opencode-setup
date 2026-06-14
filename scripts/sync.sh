#!/usr/bin/env bash
# Fetch changes since last sync and display changelog
# Usage: ./sync.sh [--apply]

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ECC_DIR="$SETUP_DIR/ecc"
ROUTER_DIR="$SETUP_DIR/9router"
SYNC_STATE="$SETUP_DIR/.sync-state.json"

APPLY=false
[[ "${1:-}" == "--apply" ]] && APPLY=true

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
# Opencode-related check
# ============================================================

is_opencode_related() {
    local msg="${1,,}"
    case "$msg" in
        *opencode*|*plugin*|*.opencode*|*agent*|*command*|*skill*|*hook*|*rule*|*config*|*build:opencode*|*rtk*|*caveman*|*fallback*|*opencode-plugin*)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

# ============================================================
# Banner
# ============================================================

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Sync Changelog - ECC + 9Router          ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# Check prerequisites
# ============================================================

[[ -d "$ECC_DIR/.git" ]] || fail "ECC not cloned. Run: ./clone-repo.sh"
[[ -d "$ROUTER_DIR/.git" ]] || fail "9Router not cloned. Run: ./clone-repo.sh"
[[ -f "$SYNC_STATE" ]] || fail ".sync-state.json not found. Run: ./clone-repo.sh"

# ============================================================
# Read sync state
# ============================================================

ECC_LAST_SHA=$(python3 -c "import json; print(json.load(open('$SYNC_STATE'))['ecc']['last_sha'])" 2>/dev/null || cat "$SYNC_STATE" | grep -A1 '"last_sha"' | head -2 | tail -1 | tr -d ' ",' || echo "")
ROUTER_LAST_SHA=$(python3 -c "import json; print(json.load(open('$SYNC_STATE'))['9router']['last_sha'])" 2>/dev/null || echo "")

if [[ -z "$ECC_LAST_SHA" ]]; then
    fail "Cannot read .sync-state.json"
fi

echo -e "  ${GRAY}Last sync ECC:     ${ECC_LAST_SHA:0:7}${NC}"
echo -e "  ${GRAY}Last sync 9Router: ${ROUTER_LAST_SHA:0:7}${NC}"

# ============================================================
# Get current SHAs
# ============================================================

ECC_CURRENT_SHA=$(git -C "$ECC_DIR" log -1 --format="%H")
ROUTER_CURRENT_SHA=$(git -C "$ROUTER_DIR" log -1 --format="%H")

ECC_HAS_CHANGES=false
ROUTER_HAS_CHANGES=false
[[ "$ECC_LAST_SHA" != "$ECC_CURRENT_SHA" ]] && ECC_HAS_CHANGES=true
[[ "$ROUTER_LAST_SHA" != "$ROUTER_CURRENT_SHA" ]] && ROUTER_HAS_CHANGES=true

if [[ "$ECC_HAS_CHANGES" == "false" && "$ROUTER_HAS_CHANGES" == "false" ]]; then
    echo ""
    echo -e "  ${GREEN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "  ${GREEN}║           No changes since last sync            ║${NC}"
    echo -e "  ${GREEN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
fi

# ============================================================
# ECC Changelog
# ============================================================

if [[ "$ECC_HAS_CHANGES" == "true" ]]; then
    step "1/2" "ECC Changelog (${ECC_LAST_SHA:0:7}..${ECC_CURRENT_SHA:0:7})..."
    echo ""

    ECC_OPENCODE_CHANGES=0

    while IFS='|' read -r sha date author message; do
        [[ -z "$sha" ]] && continue
        short_date=$(echo "$date" | cut -d' ' -f1)
        is_opencode_related "$message" && ECC_OPENCODE_CHANGES=$((ECC_OPENCODE_CHANGES + 1))

        if is_opencode_related "$message"; then
            echo -e "  ${WHITE}[$short_date]${NC} ${GRAY}$author${NC}  $message ${YELLOW}← [opencode]${NC}"
        else
            echo -e "  ${WHITE}[$short_date]${NC} ${GRAY}$author${NC}  $message"
        fi
    done < <(git -C "$ECC_DIR" log "$ECC_LAST_SHA..$ECC_CURRENT_SHA" --format="%H|%ai|%an|%s" 2>/dev/null)

    echo ""
    if [[ $ECC_OPENCODE_CHANGES -gt 0 ]]; then
        echo -e "  ${YELLOW}⚡ $ECC_OPENCODE_CHANGES change(s) mempengaruhi setup (plugin, agents, config)${NC}"
    fi
fi

# ============================================================
# 9Router Changelog
# ============================================================

if [[ "$ROUTER_HAS_CHANGES" == "true" ]]; then
    step "2/2" "9Router Changelog (${ROUTER_LAST_SHA:0:7}..${ROUTER_CURRENT_SHA:0:7})..."
    echo ""

    ROUTER_OPENCODE_CHANGES=0

    while IFS='|' read -r sha date author message; do
        [[ -z "$sha" ]] && continue
        short_date=$(echo "$date" | cut -d' ' -f1)
        is_opencode_related "$message" && ROUTER_OPENCODE_CHANGES=$((ROUTER_OPENCODE_CHANGES + 1))

        if is_opencode_related "$message"; then
            echo -e "  ${WHITE}[$short_date]${NC} ${GRAY}$author${NC}  $message ${YELLOW}← [opencode]${NC}"
        else
            echo -e "  ${WHITE}[$short_date]${NC} ${GRAY}$author${NC}  $message"
        fi
    done < <(git -C "$ROUTER_DIR" log "$ROUTER_LAST_SHA..$ROUTER_CURRENT_SHA" --format="%H|%ai|%an|%s" 2>/dev/null)

    echo ""
    if [[ $ROUTER_OPENCODE_CHANGES -gt 0 ]]; then
        echo -e "  ${YELLOW}⚡ $ROUTER_OPENCODE_CHANGES change(s) mempengaruhi setup (RTK, caveman, config)${NC}"
    fi
fi

# ============================================================
# Ask user
# ============================================================

echo ""
echo -e "  ${GRAY}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${WHITE}Apakah ada perubahan berarti yang mempengaruhi setupmu?${NC}"
echo ""
echo -e "  ${GREEN}[1]${NC} Ya, tampilkan detail"
echo -e "  ${GRAY}[2]${NC} Tidak, skip"
echo -e "  ${YELLOW}[3]${NC} Update setup sekarang"
echo ""

if [[ "$APPLY" == "true" ]]; then
    CHOICE="3"
    echo -e "  ${YELLOW}(Auto-selected: 3 - Apply mode)${NC}"
else
    read -p "  Pilih (1/2/3): " CHOICE
    [[ ! "$CHOICE" =~ ^[123]$ ]] && CHOICE="2"
fi

case $CHOICE in
    1)
        echo ""
        echo -e "  ${CYAN}Detail perubahan:${NC}"
        if [[ "$ECC_HAS_CHANGES" == "true" ]]; then
            echo ""
            echo -e "  ${YELLOW}ECC:${NC}"
            git -C "$ECC_DIR" log "$ECC_LAST_SHA..$ECC_CURRENT_SHA" --oneline 2>/dev/null | while read -r line; do
                if is_opencode_related "$line"; then
                    echo -e "    ${YELLOW}$line ← [opencode]${NC}"
                else
                    echo -e "    ${GRAY}$line${NC}"
                fi
            done
        fi
        if [[ "$ROUTER_HAS_CHANGES" == "true" ]]; then
            echo ""
            echo -e "  ${YELLOW}9Router:${NC}"
            git -C "$ROUTER_DIR" log "$ROUTER_LAST_SHA..$ROUTER_CURRENT_SHA" --oneline 2>/dev/null | while read -r line; do
                if is_opencode_related "$line"; then
                    echo -e "    ${YELLOW}$line ← [opencode]${NC}"
                else
                    echo -e "    ${GRAY}$line${NC}"
                fi
            done
        fi
        echo ""
        echo -e "  ${GRAY}Jalankan './setup.sh' untuk apply perubahan.${NC}"
        ;;
    2)
        echo ""
        echo -e "  ${GRAY}Skipped. SHA tidak di-update.${NC}"
        echo -e "  ${GRAY}Jalankan lagi nanti: ./sync-changelog.sh${NC}"
        exit 0
        ;;
    3)
        echo ""
        echo -e "  ${YELLOW}Updating SHA...${NC}"

        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S")
        ECC_VERSION=$(cat "$ECC_DIR/VERSION" 2>/dev/null || echo "unknown")

        cat > "$SYNC_STATE" << JSONEOF
{
  "ecc": {
    "last_sha": "$ECC_CURRENT_SHA",
    "last_sync": "$TIMESTAMP",
    "repo": "fannndi/ECC",
    "version": "$ECC_VERSION"
  },
  "9router": {
    "last_sha": "$ROUTER_CURRENT_SHA",
    "last_sync": "$TIMESTAMP",
    "repo": "fannndi/9router"
  }
}
JSONEOF

        ok "SHA updated to ${ECC_CURRENT_SHA:0:7} / ${ROUTER_CURRENT_SHA:0:7}"
        echo ""
        echo -e "  ${GRAY}Jalankan './setup.sh' untuk apply perubahan.${NC}"
        ;;
esac

echo ""
