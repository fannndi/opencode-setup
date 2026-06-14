#!/usr/bin/env bash
# Memory — Simpan & baca memori session
# Usage: ./memory.sh --action save|read|status [--value "catatan"] [--key "nama"]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MEMORY_DIR="$ROOT_DIR/project-memory"
ACTION=""; KEY=""; VALUE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --action) ACTION="$2"; shift 2 ;;
        --key) KEY="$2"; shift 2 ;;
        --value) VALUE="$2"; shift 2 ;;
        *) echo "Usage: $0 --action save|read|status"; exit 1 ;;
    esac
done

[[ -z "$ACTION" ]] && { echo "[ERROR] --action required"; exit 1; }

case "$ACTION" in
    save)
        mkdir -p "$MEMORY_DIR/sessions"
        TODAY=$(date +%Y-%m-%d)
        echo "### $(date +%H:%M:%S) - $VALUE" >> "$MEMORY_DIR/sessions/$TODAY.md"
        echo "[OK] Saved to memory"
        ;;
    read|status)
        echo "─── Project Memory ───"
        for f in "$MEMORY_DIR"/sessions/*.md 2>/dev/null; do
            [[ -f "$f" ]] && echo "• $(basename "$f" .md): $(head -3 "$f" 2>/dev/null | tail -1)"
        done
        ;;
esac
