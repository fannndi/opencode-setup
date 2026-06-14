#!/usr/bin/env bash
# Session Manager — Baca/tulis status workflow
# Usage: ./session-manager.sh --action read|write|reset|status [--key name] [--value data]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SESSION_FILE="$ROOT_DIR/.opencode-session.json"
ACTION=""; KEY=""; VALUE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --action) ACTION="$2"; shift 2 ;;
        --key) KEY="$2"; shift 2 ;;
        --value) VALUE="$2"; shift 2 ;;
        *) echo "Usage: $0 --action read|write|reset|status"; exit 1 ;;
    esac
done

[[ -z "$ACTION" ]] && { echo "[ERROR] --action required"; exit 1; }

case "$ACTION" in
    write)
        [[ -z "$KEY" || -z "$VALUE" ]] && { echo "[ERROR] --key and --value required"; exit 1; }
        if [[ -f "$SESSION_FILE" ]]; then
            python3 -c "
import json
d = json.load(open('$SESSION_FILE'))
d['$KEY'] = '$VALUE'
json.dump(d, open('$SESSION_FILE', 'w'))
" 2>/dev/null || echo "{\"$KEY\":\"$VALUE\"}" > "$SESSION_FILE"
        else
            echo "{\"$KEY\":\"$VALUE\"}" > "$SESSION_FILE"
        fi
        echo "[OK] Session $KEY = $VALUE"
        ;;
    read|status)
        if [[ -f "$SESSION_FILE" ]]; then
            python3 -c "import json; d=json.load(open('$SESSION_FILE')); [print(f'  {k}: {v}') for k,v in d.items()]" 2>/dev/null
        else
            echo "No session file"
        fi
        ;;
    reset)
        rm -f "$SESSION_FILE"
        echo "[OK] Session reset"
        ;;
esac
