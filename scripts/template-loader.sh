#!/usr/bin/env bash
# Template Loader — Copy template docs ke project (Master Control)
# Usage: ./template-loader.sh --template flutter-firebase [--project-path "C:\path\to\project"]

set -euo pipefail

TEMPLATE=""
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --template) TEMPLATE="$2"; shift 2 ;;
        --project-path) PROJECT_PATH="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$TEMPLATE" ]]; then
    echo "[ERROR] --template is required"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_DIR="$ROOT_DIR/templates/$TEMPLATE"
SESSION_FILE="$ROOT_DIR/.opencode-session.json"

if [[ -z "$PROJECT_PATH" ]]; then
    if [[ -f "$SESSION_FILE" ]]; then
        PROJECT_PATH=$(python3 -c "import json; print(json.load(open('$SESSION_FILE')).get('current_project',''))" 2>/dev/null || echo "")
    fi
fi

if [[ -z "$PROJECT_PATH" ]]; then
    echo "[ERROR] No project path specified."
    exit 1
fi

mkdir -p "$PROJECT_PATH/docs"
cp "$TEMPLATE_DIR/template.md" "$PROJECT_PATH/docs/TEMPLATE-GUIDE.md"
echo "[OK] Template $TEMPLATE applied to $PROJECT_PATH"
