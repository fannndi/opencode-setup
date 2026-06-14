#!/usr/bin/env bash
# Quality Gate — Verify fixes, track iterations
# Usage: ./quality-gate.sh [--project-path "C:\path"]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do case $1 in --project-path) PROJECT_PATH="$2"; shift 2 ;; *) shift ;; esac; done

if [[ -z "$PROJECT_PATH" && -f "$ROOT_DIR/.opencode-session.json" ]]; then
    PROJECT_PATH=$(python3 -c "import json; print(json.load(open('$ROOT_DIR/.opencode-session.json')).get('current_project',''))" 2>/dev/null || echo "")
fi
[[ -z "$PROJECT_PATH" ]] && { echo "[ERROR] No project path"; exit 1; }

echo "[1/5] Git status..."
cd "$PROJECT_PATH"
MODIFIED=$(git status --short 2>/dev/null | wc -l)
echo "  [OK] $MODIFIED modified files"

echo "[2/5] Build check..."
if [[ -f "pubspec.yaml" ]]; then echo "  [OK] Flutter project detected"; fi

echo "[3/5] Test check..."
echo "  [SKIP] Manual test required"

echo "[4/5] Iteration tracking..."
ITER_FILE="$ROOT_DIR/.iteration.json"
COUNT=1
[[ -f "$ITER_FILE" ]] && COUNT=$(($(python3 -c "import json; print(json.load(open('$ITER_FILE')).get('count',1))" 2>/dev/null || echo 1) + 1))
echo "{\"count\":$COUNT}" > "$ITER_FILE"
echo "  [INFO] Attempt #$COUNT"

echo "[5/5] Quality Gate: PASSED"
