#!/usr/bin/env bash
# Auto Start — Chain semua workflow dalam 1 command
# Usage: ./auto-start.sh --profile gratis|go [--project-path "C:\path"]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SESSION_FILE="$ROOT_DIR/.opencode-session.json"

PROFILE="${1:-gratis}"
MODE="${2:-existing}"
PROJECT_PATH="${3:-}"

if [[ -z "$PROJECT_PATH" && -f "$SESSION_FILE" ]]; then
    PROJECT_PATH=$(python3 -c "import json; print(json.load(open('$SESSION_FILE')).get('current_project',''))" 2>/dev/null || echo "")
fi

if [[ -z "$PROJECT_PATH" ]]; then echo "[ERROR] No project path"; exit 1; fi

echo "[1/3] Start workflow ($PROFILE)..."
bash "$SCRIPT_DIR/start.sh" --profile "$PROFILE" 2>/dev/null || true

echo "[2/3] Analyze code..."
bash "$SCRIPT_DIR/code-analyze.sh" --project-path "$PROJECT_PATH" 2>/dev/null || true

echo "[3/3] Detect stack..."
bash "$SCRIPT_DIR/analyze-project.sh" --project-path "$PROJECT_PATH" 2>/dev/null || true

echo "[OK] Auto-start complete!"
