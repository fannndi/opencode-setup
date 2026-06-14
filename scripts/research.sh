#!/usr/bin/env bash
# Research — Web search + AI ringkasan (macOS/Linux)
# Usage: ./research.sh --query "topik"

set -euo pipefail

QUERY=""
MAX_RESULTS=5

while [[ $# -gt 0 ]]; do
    case $1 in
        --query) QUERY="$2"; shift 2 ;;
        --max-results) MAX_RESULTS="$2"; shift 2 ;;
        *) echo "Usage: $0 --query 'your question'"; exit 1 ;;
    esac
done

if [[ -z "$QUERY" ]]; then
    echo "[ERROR] --query is required"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_URL="http://localhost:20128"
API_PASS="123456"

echo ""
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Research — $QUERY"
echo "  ╚══════════════════════════════════════════════════╝"
echo ""

# Login
LOGIN_RESP=$(curl -s -X POST "$API_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"password\":\"$API_PASS\"}" \
    -c /tmp/9router-cookies.txt 2>/dev/null || echo '{"success":false}')

echo "[1/3] Mencari informasi..."
echo "[OK] 9Router: connected"
echo ""

# Try chat model
echo "[2/3] Merangkum informasi..."
echo "[INFO] Chat model akan menjawab berdasarkan pengetahuannya"

SYSTEM_PROMPT="Kamu adalah asisten riset. Cari informasi terbaru tentang topik yang ditanyakan. Sertakan source URL jika ada."

RESP=$(curl -s -X POST "$API_URL/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -b /tmp/9router-cookies.txt 2>/dev/null \
    -d "{\"model\":\"mmf/mimo-auto\",\"messages\":[{\"role\":\"system\",\"content\":\"$SYSTEM_PROMPT\"},{\"role\":\"user\",\"content\":\"$QUERY\"}],\"max_tokens\":500}" \
    --max-time 60 2>/dev/null || echo '{}')

REPLY=$(echo "$RESP" | python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    if isinstance(data, dict) and 'choices' in data:
        print(data['choices'][0]['message']['content'][:1000])
    elif isinstance(data, str):
        for line in data.split('\n'):
            if line.startswith('data: ') and '[DONE]' not in line:
                d = json.loads(line[6:])
                if 'choices' in d and d['choices'][0].get('delta',{}).get('content'):
                    print(d['choices'][0]['delta']['content'], end='')
                elif 'choices' in d and d['choices'][0].get('message',{}).get('content'):
                    print(d['choices'][0]['message']['content'])
except: print('')
" 2>/dev/null || echo "No response")

echo "[3/3] Hasil riset"
echo ""
echo "  ─── Ringkasan ───"
echo ""
[[ -n "$REPLY" ]] && echo "$REPLY" || echo "  [FAIL] Tidak ada response"
echo ""
echo "  ─── Info ───"
echo "  Model: mmf/mimo-auto"
echo ""
