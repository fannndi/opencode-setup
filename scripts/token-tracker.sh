#!/usr/bin/env bash
# Token Tracker — Track token usage from 9Router
# Usage: ./token-tracker.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SESSION_FILE="$ROOT_DIR/.opencode-session.json"
API_URL="http://localhost:20128"

echo "─── Token Tracker ───"

# Check 9Router health
if curl -s "$API_URL/api/health" | grep -q '"ok":true'; then
    echo "[OK] 9Router connected"
fi

# Session stats
if [[ -f "$SESSION_FILE" ]]; then
    echo ""
    echo "─── Session Stats ───"
    python3 -c "import json; d=json.load(open('$SESSION_FILE')); print(f'Profile: {d.get(\"last_profile\",\"-\")}'); print(f'Project: {d.get(\"current_project\",\"-\")}'); print(f'Last action: {d.get(\"last_action\",\"-\")}')" 2>/dev/null
    echo "Cost: FREE"
fi
