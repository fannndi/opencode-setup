#!/usr/bin/env bash
# Project Skills — Lihat skills yang cocok untuk project
# Usage: ./project-skills.sh [--project-path "C:\path"]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do case $1 in --project-path) PROJECT_PATH="$2"; shift 2 ;; *) shift ;; esac; done

if [[ -z "$PROJECT_PATH" && -f "$ROOT_DIR/.opencode-session.json" ]]; then
    PROJECT_PATH=$(python3 -c "import json; print(json.load(open('$ROOT_DIR/.opencode-session.json')).get('current_project',''))" 2>/dev/null || echo "")
fi
[[ -z "$PROJECT_PATH" ]] && { echo "[ERROR] No project path"; exit 1; }

echo "Project: $(basename "$PROJECT_PATH")"
echo ""
echo "─── Core Skills ───"
echo "• tdd-workflow — Test-driven development"
echo "• security-review — Security checklist"
echo "• coding-standards — KISS, DRY, YAGNI"
echo "• verification-loop — Build/type/lint/test"
echo ""
echo "─── Recommended Commands ───"
echo "/tdd, /code-review, /security, /verify, /build-fix"
