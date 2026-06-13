#!/usr/bin/env bash
# ECC Setup Installer for OpenCode (macOS/Linux)
# Usage: ./install.sh --profile gratis|go [--ecc-root <path>]

set -euo pipefail

# --- Parse args ---
PROFILE=""
ECC_ROOT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --profile) PROFILE="$2"; shift 2 ;;
        --ecc-root) ECC_ROOT="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 --profile <gratis|go> [--ecc-root <path>]"
            echo ""
            echo "Options:"
            echo "  --profile    Model profile (required): gratis or go"
            echo "  --ecc-root   Path to ECC repo root (auto-detected if not set)"
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Detect ECC Root ---
if [[ -n "$ECC_ROOT" ]]; then
    ECC_ROOT="$(cd "$ECC_ROOT" && pwd)"
elif [[ -d "$SCRIPT_DIR/../rules" ]]; then
    ECC_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [[ -d "$SCRIPT_DIR/../../rules" ]]; then
    ECC_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
else
    echo "[*] ECC repo not found. Cloning to temp directory..."
    ECC_ROOT="/tmp/ecc"
    git clone https://github.com/fannndi/ECC.git "$ECC_ROOT"
fi

OPENCODE_DIR="$HOME/.config/opencode"
RULES_TARGET="$OPENCODE_DIR/rules/ecc"
CONFIG_FILE="$OPENCODE_DIR/opencode.jsonc"

echo ""
echo "========================================"
echo " ECC OpenCode Setup - Profile: $PROFILE"
echo "========================================"
echo ""

# --- Step 1: Backup existing config ---
if [[ -f "$CONFIG_FILE" ]]; then
    BACKUP_FILE="${CONFIG_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo "[*] Existing config backed up to: $BACKUP_FILE"
fi

# --- Step 2: Copy opencode.jsonc ---
SOURCE_CONFIG="$SCRIPT_DIR/$PROFILE/opencode.jsonc"
if [[ ! -f "$SOURCE_CONFIG" ]]; then
    echo "[ERROR] Config not found: $SOURCE_CONFIG"
    exit 1
fi

mkdir -p "$OPENCODE_DIR"
cp "$SOURCE_CONFIG" "$CONFIG_FILE"
echo "[OK] Config copied: $PROFILE -> $CONFIG_FILE"

# --- Step 3: Copy rules ---
echo "[*] Installing rules (common + typescript + python + golang)..."

mkdir -p "$RULES_TARGET"

for dir in common typescript python golang; do
    SRC="$ECC_ROOT/rules/$dir"
    DST="$RULES_TARGET/$dir"
    if [[ -d "$SRC" ]]; then
        rm -rf "$DST"
        cp -r "$SRC" "$DST"
        echo "  [OK] rules/$dir"
    else
        echo "  [SKIP] rules/$dir not found"
    fi
done

# --- Step 4: Build plugin ---
echo ""
echo "[*] Building OpenCode plugin..."

cd "$ECC_ROOT"

if [[ ! -d "node_modules" ]]; then
    echo "  [*] Installing root dependencies..."
    npm install --silent
fi

if [[ ! -d ".opencode/node_modules" ]]; then
    echo "  [*] Installing .opencode dependencies..."
    cd .opencode && npm install --silent && cd ..
fi

npm run build:opencode
echo "[OK] Plugin built successfully"

# --- Step 5: Set environment variables ---
echo "[*] Setting environment variables..."

# For bash/zsh - add to profile
SHELL_RC=""
if [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
elif [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
fi

if [[ -n "$SHELL_RC" ]]; then
    # Remove old ECC entries if any
    sed -i '/^export ECC_HOOK_PROFILE=/d' "$SHELL_RC"
    sed -i '/^export ECC_AGENT_DATA_HOME=/d' "$SHELL_RC"

    echo "export ECC_HOOK_PROFILE=standard" >> "$SHELL_RC"
    echo "export ECC_AGENT_DATA_HOME=\"\$HOME/.opencode/ecc\"" >> "$SHELL_RC"
    echo "  [OK] Environment vars added to $SHELL_RC"
fi

# Also set for current session
export ECC_HOOK_PROFILE=standard
export ECC_AGENT_DATA_HOME="$HOME/.opencode/ecc"

# --- Step 6: Summary ---
echo ""
echo "========================================"
echo " Setup Complete!"
echo "========================================"
echo ""
echo " Profile:      $PROFILE"
echo " Config:       $CONFIG_FILE"
echo " Rules:        $RULES_TARGET"
echo " ECC Root:     $ECC_ROOT"
echo ""
echo "Model mapping:"

if [[ "$PROFILE" == "gratis" ]]; then
    echo "  Primary:    opencode/mimo-v2.5-free"
    echo "  Subagent:   opencode/deepseek-v4-flash-free"
    echo "  Cost:       FREE (rate limited)"
else
    echo "  Primary:    opencode-go/kimi-k2.7"
    echo "  Reasoning:  opencode-go/qwen3.7-max"
    echo "  Review:     opencode-go/deepseek-v4-pro"
    echo "  Cost:       \$5/first month, \$10/mo"
fi

echo ""
echo "Next steps:"
echo "  1. Login OpenCode:  opencode /connect"
echo "  2. Start OpenCode:  opencode"
echo "  3. Test:            /plan 'add auth feature'"
echo ""
