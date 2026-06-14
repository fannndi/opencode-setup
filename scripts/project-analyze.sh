#!/usr/bin/env bash
# Project Analyze — Analisa PRD dan buat ai-notes.md (macOS/Linux)
# Usage: ./project-analyze.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ECC_DIR="$ROOT_DIR/ecc"
SKILL_LIST="$ROOT_DIR/Skill/skill-list.md"
FEATURE_LIST="$ROOT_DIR/Feature/list.md"

# ============================================================
# Colors
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m'

step() { echo -e "\n${CYAN}[$1/5] $2${NC}"; }
ok()   { echo -e "  ${GREEN}[OK] $1${NC}"; }
skip() { echo -e "  ${YELLOW}[SKIP] $1${NC}"; }
fail() { echo -e "  ${RED}[FAIL] $1${NC}"; }
info() { echo -e "  ${GRAY}[INFO] $1${NC}"; }

# ============================================================
# Banner
# ============================================================

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Project Analyze — PRD → ai-notes.md     ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# [1/5] Locate project root
# ============================================================

step "1/5" "Locating project root..."

PROJECT_DIR="$(cd "$ROOT_DIR/.." && pwd)"
PRD_FILE="$PROJECT_DIR/prd.md"
AI_NOTES="$PROJECT_DIR/ai-notes.md"

echo -e "  ${WHITE}Project: $PROJECT_DIR${NC}"

if [[ ! -f "$PRD_FILE" ]]; then
    fail "prd.md not found in $PROJECT_DIR"
    info "Buat prd.md terlebih dahulu di project root"
    exit 1
fi

ok "prd.md found"

# ============================================================
# [2/5] Read PRD
# ============================================================

step "2/5" "Reading PRD..."

PRD_CONTENT=$(cat "$PRD_FILE")
PRD_LINES=$(echo "$PRD_CONTENT" | wc -l | tr -d ' ')
PRD_LENGTH=$(echo "$PRD_CONTENT" | wc -c | tr -d ' ')

ok "PRD loaded ($PRD_LINES lines, $PRD_LENGTH chars)"

# ============================================================
# [3/5] Detect stack from PRD
# ============================================================

step "3/5" "Detecting stack from PRD..."

DETECTED_STACK=()
PRD_LOWER=$(echo "$PRD_CONTENT" | tr '[:upper:]' '[:lower:]')

declare -A KEYWORDS=(
    ["flutter"]="dart-flutter"
    ["dart"]="dart-flutter"
    ["react"]="react"
    ["next.js"]="nextjs"
    ["nextjs"]="nextjs"
    ["vue"]="vue"
    ["angular"]="angular"
    ["python"]="python"
    ["django"]="django"
    ["fastapi"]="python"
    ["golang"]="golang"
    ["rust"]="rust"
    ["java"]="java"
    ["spring"]="springboot"
    ["kotlin"]="kotlin"
    ["swift"]="swift"
    ["ios"]="swift"
    ["android"]="android"
    ["php"]="php"
    ["laravel"]="php-laravel"
    ["ruby"]="ruby"
    ["docker"]="docker"
    ["postgresql"]="postgres"
    ["mysql"]="mysql"
    ["redis"]="redis"
    ["supabase"]="supabase"
    ["rest api"]="api"
    ["graphql"]="graphql"
    ["jwt"]="authentication"
    ["auth"]="authentication"
    ["payment"]="payment"
    ["stripe"]="payment"
    ["ml"]="machine-learning"
    ["machine learning"]="machine-learning"
    ["ai"]="ai"
    ["llm"]="ai"
)

for KW in "${!KEYWORDS[@]}"; do
    if echo "$PRD_LOWER" | grep -q "$KW"; then
        STACK="${KEYWORDS[$KW]}"
        # Check if already in array
        FOUND=false
        for S in "${DETECTED_STACK[@]}"; do
            [[ "$S" == "$STACK" ]] && FOUND=true
        done
        [[ "$FOUND" == "false" ]] && DETECTED_STACK+=("$STACK")
    fi
done

if [[ ${#DETECTED_STACK[@]} -gt 0 ]]; then
    ok "Detected: ${DETECTED_STACK[*]}"
else
    skip "No specific stack detected from PRD"
    DETECTED_STACK=("general")
fi

# ============================================================
# [4/5] Match skills
# ============================================================

step "4/5" "Matching skills..."

CORE_SKILLS=("tdd-workflow" "security-review" "coding-standards" "verification-loop")
MATCHED_SKILLS=("${CORE_SKILLS[@]}")
MATCHED_RULES=()

# Stack-specific skills
declare -A STACK_SKILLS=(
    ["dart-flutter"]="dart-flutter-patterns"
    ["react"]="frontend-patterns react-patterns react-performance react-testing accessibility"
    ["nextjs"]="frontend-patterns backend-patterns nextjs-turbopack"
    ["python"]="python-patterns python-testing"
    ["django"]="django-patterns django-tdd django-verification django-security"
    ["golang"]="golang-patterns golang-testing"
    ["rust"]="rust-patterns rust-testing"
    ["java"]="java-coding-standards jpa-patterns"
    ["springboot"]="springboot-patterns springboot-tdd springboot-verification springboot-security"
    ["kotlin"]="kotlin-patterns kotlin-testing kotlin-coroutines-flows"
    ["swift"]="swiftui-patterns swift-concurrency-6-2"
    ["php-laravel"]="laravel-patterns laravel-tdd laravel-verification laravel-security"
    ["cpp"]="cpp-coding-standards cpp-testing"
    ["docker"]="docker-patterns deployment-patterns"
    ["postgres"]="postgres-patterns database-migrations"
    ["redis"]="redis-patterns"
    ["api"]="api-design backend-patterns"
    ["authentication"]="security-review"
    ["payment"]="security-review"
)

declare -A STACK_RULES=(
    ["dart-flutter"]="common dart"
    ["react"]="common typescript web react"
    ["nextjs"]="common typescript web react"
    ["python"]="common python"
    ["django"]="common python"
    ["golang"]="common golang"
    ["rust"]="common rust"
    ["java"]="common java"
    ["springboot"]="common java"
    ["kotlin"]="common kotlin"
    ["swift"]="common swift"
    ["php-laravel"]="common php"
    ["cpp"]="common cpp"
)

for STACK in "${DETECTED_STACK[@]}"; do
    if [[ -n "${STACK_SKILLS[$STACK]:-}" ]]; then
        for SKILL in ${STACK_SKILLS[$STACK]}; do
            FOUND=false
            for S in "${MATCHED_SKILLS[@]}"; do
                [[ "$S" == "$SKILL" ]] && FOUND=true
            done
            [[ "$FOUND" == "false" ]] && MATCHED_SKILLS+=("$SKILL")
        done
    fi
    if [[ -n "${STACK_RULES[$STACK]:-}" ]]; then
        for RULE in ${STACK_RULES[$STACK]}; do
            FOUND=false
            for R in "${MATCHED_RULES[@]}"; do
                [[ "$R" == "$RULE" ]] && FOUND=true
            done
            [[ "$FOUND" == "false" ]] && MATCHED_RULES+=("$RULE")
        done
    fi
done

ok "Matched ${#MATCHED_SKILLS[@]} skills, ${#MATCHED_RULES[@]} rules"

# ============================================================
# [5/5] Generate ai-notes.md
# ============================================================

step "5/5" "Generating ai-notes.md..."

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

cat > "$AI_NOTES" << EOF
# AI Notes — Project Analysis

**Generated:** $TIMESTAMP
**PRD Source:** prd.md

---

## Project Overview

Project ini dianalisa dari prd.md. Berikut rekomendasi stack, skills, dan architecture.

## Detected Stack

| Komponen | Pilihan | Alasan |
|----------|---------|--------|
$(for S in "${DETECTED_STACK[@]}"; do echo "| Stack | $S | Terdeteksi dari PRD |"; done)

## Recommended Skills

### Core (always)
$(for S in "${CORE_SKILLS[@]}"; do echo "- $S"; done)

### Project-Specific
$(for S in "${MATCHED_SKILLS[@]}"; do
    FOUND=false
    for C in "${CORE_SKILLS[@]}"; do
        [[ "$S" == "$C" ]] && FOUND=true
    done
    [[ "$FOUND" == "false" ]] && echo "- $S"
done)

## Recommended Rules

$(for R in "${MATCHED_RULES[@]}"; do echo "- $R"; done)

## Recommended Commands

| Command | Kapan Dipakai |
|---------|---------------|
| /plan | Perencanaan implementasi |
| /tdd | Test-driven development |
| /code-review | Review kode |
| /security | Security review |
| /build-fix | Fix build errors |
| /verify | Verification loop |

## Recommended Agents

| Agent | Kapan Dipakai |
|-------|---------------|
| planner | Perencanaan fitur |
| code-reviewer | Review kode |
| security-reviewer | Security audit |
| tdd-guide | TDD workflow |
| build-error-resolver | Fix build errors |

## Implementation Notes

### Skills to Load
\`\`\`json
"instructions": [
$(for S in "${MATCHED_SKILLS[@]}"; do echo "    \"$ROOT_DIR/ecc/skills/$S/SKILL.md\","; done)
]
\`\`\`

### Rules to Apply
\`\`\`
Rules: ${MATCHED_RULES[*]}
\`\`\`

## Next Steps

1. Review ai-notes.md ini
2. Sesuaikan rekomendasi jika perlu
3. Jalankan: \`\`/make-docs\`\`
4. Review docs/ yang dihasilkan
5. Jalankan: \`\`/implement\`\`

---

*File ini di-generate otomatis oleh /project-analyze*
*Untuk rekomendasi manual, edit file ini langsung*
EOF

ok "ai-notes.md generated: $AI_NOTES"

# ============================================================
# Summary
# ============================================================

echo ""
echo -e "  ${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║              Analysis Complete!                  ║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${WHITE}PRD:       $PRD_FILE${NC}"
echo -e "  ${WHITE}AI Notes:  $AI_NOTES${NC}"
echo -e "  ${WHITE}Stack:     ${DETECTED_STACK[*]}${NC}"
echo -e "  ${WHITE}Skills:    ${#MATCHED_SKILLS[@]} matched${NC}"
echo -e "  ${WHITE}Rules:     ${MATCHED_RULES[*]}${NC}"
echo ""
echo -e "  ${CYAN}Next: review ai-notes.md, lalu /make-docs${NC}"
echo ""
