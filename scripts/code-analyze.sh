#!/usr/bin/env bash
# Code Analyze — Scan existing source code → ai-notes.md (macOS/Linux)
# Usage: ./code-analyze.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_DIR="$(cd "$ROOT_DIR/.." && pwd)"
SKILL_LIST="$ROOT_DIR/Skill/skill-list.md"
ECC_DIR="$ROOT_DIR/ecc"
AI_NOTES="$PROJECT_DIR/ai-notes.md"

IGNORE_DIRS="node_modules|.git|build|dist|target|.dart_tool|.next|coverage|__pycache__|.venv|venv|vendor|.opencode|assets|.github|pub-cache|.packages|.pub-preload-cache|.idea|.vscode|.vs|bin|obj|.flutter-plugins|.flutter|android|ios|macos|windows|linux|web"

# ============================================================
# Colors
# ============================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; GRAY='\033[0;90m'; WHITE='\033[1;37m'; NC='\033[0m'

step() { echo -e "\n${CYAN}[$1/6] $2${NC}"; }
ok()   { echo -e "  ${GREEN}[OK] $1${NC}"; }
skip() { echo -e "  ${YELLOW}[SKIP] $1${NC}"; }
fail() { echo -e "  ${RED}[FAIL] $1${NC}"; }
info() { echo -e "  ${GRAY}[INFO] $1${NC}"; }

# ============================================================
# Banner
# ============================================================

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║         Code Analyze — Source → ai-notes.md     ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# [1/6] Scan project structure
# ============================================================

step "1/6" "Scanning project structure..."

TOTAL_FILES=0
TOTAL_LINES=0
DIR_SUMMARY=""

for DIR in "$PROJECT_DIR"/*/; do
    DIR_NAME=$(basename "$DIR")
    echo "$IGNORE_DIRS" | grep -q "$DIR_NAME" && continue

    FILE_COUNT=$(find "$DIR" -type f 2>/dev/null | grep -vE "/($IGNORE_DIRS)/" | wc -l | tr -d ' ')
    LINE_COUNT=$(find "$DIR" -type f 2>/dev/null | grep -vE "/($IGNORE_DIRS)/" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
    [[ -z "$LINE_COUNT" || "$LINE_COUNT" == "0" ]] && LINE_COUNT=0

    TOTAL_FILES=$((TOTAL_FILES + FILE_COUNT))
    TOTAL_LINES=$((TOTAL_LINES + LINE_COUNT))

    echo -e "  ${GRAY}$DIR_NAME — $FILE_COUNT files, $LINE_COUNT lines${NC}"
    DIR_SUMMARY="$DIR_SUMMARY| $DIR_NAME | $FILE_COUNT | $LINE_COUNT |"$'\n'
done

ok "Found $TOTAL_FILES files, $TOTAL_LINES lines"

# ============================================================
# [2/6] Read dependencies
# ============================================================

step "2/6" "Reading dependencies..."

DEPS_FOUND=0
for PATTERN in package.json pubspec.yaml go.mod Cargo.toml composer.json Gemfile requirements.txt pyproject.toml build.gradle.kts; do
    FOUND=$(find "$PROJECT_DIR" -maxdepth 2 -name "$PATTERN" 2>/dev/null | head -3)
    if [[ -n "$FOUND" ]]; then
        info "Found: $(echo "$FOUND" | tr '\n' ' ')"
        DEPS_FOUND=$((DEPS_FOUND + 1))
    fi
done

if [[ $DEPS_FOUND -gt 0 ]]; then
    ok "$DEPS_FOUND dependency files found"
else
    skip "No dependency files found"
fi

# ============================================================
# [3/6] Deep code scan
# ============================================================

step "3/6" "Deep code scan (imports & patterns)..."

MATCHED_FWS=""
IMPORT_COUNT=0

SOURCE_FILES=$(find "$PROJECT_DIR" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.dart" -o -name "*.rs" -o -name "*.php" -o -name "*.rb" \) 2>/dev/null | grep -vE "/($IGNORE_DIRS)/" | head -200)

info "Scanning $(echo "$SOURCE_FILES" | wc -l | tr -d ' ') source files..."

while IFS= read -r FILE; do
    [[ -z "$FILE" ]] && continue
    head -50 "$FILE" 2>/dev/null | while IFS= read -r LINE; do
        if echo "$LINE" | grep -qiE "(import|from|require|use)"; then
            for FW_PATTERN in "react" "vue" "next" "express" "redux" "zustand" "@angular" "@nestjs" "prisma" "supabase" "django" "fastapi" "flask" "gin" "echo" "fiber" "gorilla" "gorm" "flutter" "riverpod" "bloc" "go_router" "dio" "axios" "axum" "actix" "tokio" "serde" "diesel" "sqlx" "laravel" "jwt" "firebase" "stripe"; do
                if echo "$LINE" | grep -qi "$FW_PATTERN"; then
                    if ! echo "$MATCHED_FWS" | grep -q "$FW_PATTERN"; then
                        MATCHED_FWS="$MATCHED_FWS $FW_PATTERN"
                    fi
                fi
            done
        fi
    done
done <<< "$SOURCE_FILES"

IMPORT_COUNT=$(echo "$MATCHED_FWS" | wc -w | tr -d ' ')
ok "Detected $IMPORT_COUNT frameworks/libraries"

# ============================================================
# [4/6] Match skills
# ============================================================

step "4/6" "Matching skills from Skill/skill-list.md..."

CORE_SKILLS=("tdd-workflow" "security-review" "coding-standards" "verification-loop")
MATCHED_SKILLS=("${CORE_SKILLS[@]}")

for FW in $MATCHED_FWS; do
    case "$FW" in
        react) MATCHED_SKILLS+=("react-patterns" "frontend-patterns");;
        next) MATCHED_SKILLS+=("frontend-patterns" "backend-patterns" "nextjs-turbopack");;
        django) MATCHED_SKILLS+=("django-patterns" "django-tdd" "django-security");;
        fastapi|flask) MATCHED_SKILLS+=("python-patterns" "python-testing");;
        gin|echo|fiber|gorilla|gorm) MATCHED_SKILLS+=("golang-patterns" "golang-testing");;
        flutter|riverpod|bloc|dio) MATCHED_SKILLS+=("dart-flutter-patterns");;
        axum|actix|tokio|serde|diesel|sqlx) MATCHED_SKILLS+=("rust-patterns" "rust-testing");;
        laravel) MATCHED_SKILLS+=("laravel-patterns" "laravel-tdd");;
        prisma) MATCHED_SKILLS+=("prisma-patterns" "database-migrations");;
        supabase) MATCHED_SKILLS+=("postgres-patterns");;
        jwt|firebase) MATCHED_SKILLS+=("security-review");;
        angular) MATCHED_SKILLS+=("angular-developer");;
        @nestjs) MATCHED_SKILLS+=("nestjs-patterns");;
        express|axios) MATCHED_SKILLS+=("backend-patterns");;
        redux|zustand) MATCHED_SKILLS+=("frontend-patterns");;
    esac
done

# Deduplicate
UNIQUE_SKILLS=()
for S in "${MATCHED_SKILLS[@]}"; do
    FOUND=false
    for U in "${UNIQUE_SKILLS[@]}"; do
        [[ "$S" == "$U" ]] && FOUND=true
    done
    [[ "$FOUND" == "false" ]] && UNIQUE_SKILLS+=("$S")
done
MATCHED_SKILLS=("${UNIQUE_SKILLS[@]}")

CORE_COUNT=${#CORE_SKILLS[@]}
PROJ_COUNT=$((${#MATCHED_SKILLS[@]} - CORE_COUNT))
ok "Matched ${#MATCHED_SKILLS[@]} skills ($CORE_COUNT core + $PROJ_COUNT project)"

# ============================================================
# [5/6] Generate ai-notes.md
# ============================================================

step "5/6" "Generating ai-notes.md..."

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
SKILLS_LIST=""
for S in "${MATCHED_SKILLS[@]}"; do
    SKILLS_LIST="$SKILLS_LIST- $S"$'\n'
done

cat > "$AI_NOTES" << AIEOF
# AI Notes — Code Analysis

**Generated:** $TIMESTAMP
**Source:** Source code analysis (code-analyze)

---

## Project Overview

\`\`\`
$TOTAL_FILES files, $TOTAL_LINES lines
\`\`\`

## Detected Frameworks

$MATCHED_FWS

## Project Structure

| Directory | Files | Lines |
|-----------|-------|-------|
$DIR_SUMMARY

## Recommended Skills

### Core (always)
$(for S in "${CORE_SKILLS[@]}"; do echo "- $S"; done)

### Project-Specific
$(for S in "${MATCHED_SKILLS[@]}"; do
    FOUND=false
    for C in "${CORE_SKILLS[@]}"; do [[ "$S" == "$C" ]] && FOUND=true; done
    [[ "$FOUND" == "false" ]] && echo "- $S"
done)

## Recommended Commands

| Command | Kapan Dipakai |
|---------|---------------|
| /code-analyze | Scan ulang project |
| /analyze-project | Deteksi ulang stack |
| /code-review | Review existing code |
| /tdd | TDD untuk fitur baru |
| /security | Security audit |
| /build-fix | Fix build errors |
| /verify | Verification loop |

## Next Steps

1. Jalankan /analyze-project untuk load skills
2. Restart opencode
3. Mulai improve code dengan /code-review

---

*File ini di-generate otomatis oleh /code-analyze*
AIEOF

ok "ai-notes.md generated: $AI_NOTES"

# ============================================================
# [6/6] Summary
# ============================================================

step "6/6" "Summary"

echo ""
echo -e "  ${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║              Code Analysis Complete!             ║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${WHITE}Project:    $PROJECT_DIR${NC}"
echo -e "  ${WHITE}Files:      $TOTAL_FILES ($TOTAL_LINES lines)${NC}"
echo -e "  ${WHITE}Frameworks: $IMPORT_COUNT detected${NC}"
echo -e "  ${WHITE}Skills:     ${#MATCHED_SKILLS[@]} matched${NC}"
echo -e "  ${WHITE}AI Notes:   $AI_NOTES${NC}"
echo ""
echo -e "  ${CYAN}Next: /analyze-project${NC}"
echo ""
