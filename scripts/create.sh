#!/usr/bin/env bash
# Create — Generate boilerplate widget/api/test/model
# Usage: ./create.sh --type widget|api|test|model --name login [--project-path "C:\path"]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TYPE=""; NAME=""; PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --type) TYPE="$2"; shift 2 ;;
        --name) NAME="$2"; shift 2 ;;
        --project-path) PROJECT_PATH="$2"; shift 2 ;;
        *) echo "Usage: $0 --type widget|api|test|model --name NAME"; exit 1 ;;
    esac
done

[[ -z "$TYPE" || -z "$NAME" ]] && { echo "[ERROR] --type and --name required"; exit 1; }

if [[ -z "$PROJECT_PATH" && -f "$ROOT_DIR/.opencode-session.json" ]]; then
    PROJECT_PATH=$(python3 -c "import json; print(json.load(open('$ROOT_DIR/.opencode-session.json')).get('current_project',''))" 2>/dev/null || echo "")
fi
[[ -z "$PROJECT_PATH" ]] && { echo "[ERROR] No project path"; exit 1; }

NAME_PASCAL=$(echo "$NAME" | sed 's/[-_]/ /g' | sed 's/\b\(.\)/\u\1/g' | sed 's/ //g')
echo "[OK] Would create $TYPE: $NAME_PASCAL at $PROJECT_PATH"
