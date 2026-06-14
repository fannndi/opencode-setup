#!/usr/bin/env bash
# Analyze Project - Detect stack and load appropriate skills (macOS/Linux)
# Usage: ./analyze-project.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ECC_DIR="$ROOT_DIR/ecc"
OPENCODE_DIR="$HOME/.config/opencode"
OPENCODE_CONFIG="$OPENCODE_DIR/opencode.jsonc"

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
echo "  ║         Project Analysis                         ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# [1/5] Locate project root
# ============================================================

step "1/5" "Locating project root..."

PROJECT_DIR="$(cd "$ROOT_DIR/.." && pwd)"

echo -e "  ${WHITE}Project: $PROJECT_DIR${NC}"
echo -e "  ${GRAY}From:    $ROOT_DIR${NC}"

if [[ ! -d "$PROJECT_DIR" ]]; then
    fail "Project directory not found: $PROJECT_DIR"
    exit 1
fi

# ============================================================
# [2/5] Scan for indicators
# ============================================================

step "2/5" "Scanning for indicators..."

declare -A INDICATORS=(
    ["pubspec.yaml"]="dart-flutter"
    ["go.mod"]="golang"
    ["package.json"]="javascript"
    ["tsconfig.json"]="typescript"
    ["next.config.js"]="nextjs"
    ["next.config.ts"]="nextjs"
    ["Cargo.toml"]="rust"
    ["pom.xml"]="java"
    ["build.gradle"]="java"
    ["build.gradle.kts"]="kotlin"
    ["settings.gradle.kts"]="kotlin"
    ["Package.swift"]="swift"
    ["Gemfile"]="ruby"
    ["composer.json"]="php-laravel"
    ["artisan"]="php-laravel"
    ["CMakeLists.txt"]="cpp"
    ["Makefile"]="cpp"
    ["manage.py"]="django"
    ["requirements.txt"]="python"
    ["pyproject.toml"]="python"
    ["setup.py"]="python"
    ["Dockerfile"]="docker"
    ["docker-compose.yml"]="docker"
    ["compose.yaml"]="docker"
    ["AndroidManifest.xml"]="android"
)

DETECTED_STACK=""
DETECTED_FILES=()

for FILE in "${!INDICATORS[@]}"; do
    if [[ -f "$PROJECT_DIR/$FILE" ]]; then
        STACK="${INDICATORS[$FILE]}"
        DETECTED_FILES+=("$FILE")
        if [[ -z "$DETECTED_STACK" ]]; then
            DETECTED_STACK="$STACK"
        fi
    fi
done

if [[ -n "$DETECTED_STACK" ]]; then
    ok "Found: ${DETECTED_FILES[*]}"
else
    fail "No indicators found in $PROJECT_DIR"
    info "Expected files: pubspec.yaml, go.mod, package.json, etc."
    exit 1
fi

# ============================================================
# [3/5] Match stack
# ============================================================

step "3/5" "Matching stack..."

declare -A STACK_NAME=(
    ["dart-flutter"]="Dart/Flutter"
    ["golang"]="Go"
    ["javascript"]="JavaScript"
    ["typescript"]="TypeScript"
    ["nextjs"]="Next.js"
    ["rust"]="Rust"
    ["java"]="Java"
    ["kotlin"]="Kotlin"
    ["swift"]="Swift"
    ["ruby"]="Ruby"
    ["php-laravel"]="PHP/Laravel"
    ["cpp"]="C++"
    ["python"]="Python"
    ["django"]="Django"
    ["docker"]="Docker"
    ["android"]="Android"
)

declare -A STACK_SKILLS=(
    ["dart-flutter"]="dart-flutter-patterns"
    ["golang"]="golang-patterns golang-testing"
    ["javascript"]="frontend-patterns"
    ["typescript"]="frontend-patterns backend-patterns"
    ["nextjs"]="frontend-patterns backend-patterns"
    ["rust"]="rust-patterns rust-testing"
    ["java"]="java-coding-standards jpa-patterns"
    ["kotlin"]="kotlin-patterns kotlin-testing kotlin-coroutines-flows"
    ["swift"]="swiftui-patterns swift-concurrency-6-2"
    ["php-laravel"]="laravel-patterns laravel-tdd laravel-security"
    ["cpp"]="cpp-coding-standards cpp-testing"
    ["python"]="python-patterns python-testing"
    ["django"]="django-patterns django-tdd django-security"
    ["docker"]="docker-patterns deployment-patterns"
    ["android"]="android-clean-architecture kotlin-patterns compose-multiplatform-patterns"
)

declare -A STACK_RULES=(
    ["dart-flutter"]="common dart"
    ["golang"]="common golang"
    ["javascript"]="common typescript"
    ["typescript"]="common typescript"
    ["nextjs"]="common typescript web react"
    ["rust"]="common rust"
    ["java"]="common java"
    ["kotlin"]="common kotlin"
    ["swift"]="common swift"
    ["ruby"]="common ruby"
    ["php-laravel"]="common php"
    ["cpp"]="common cpp"
    ["python"]="common python"
    ["django"]="common python"
    ["docker"]="common"
    ["android"]="common kotlin"
)

STACK_NAME="${STACK_NAME[$DETECTED_STACK]:-$DETECTED_STACK}"
STACK_SKILLS="${STACK_SKILLS[$DETECTED_STACK]:-}"
STACK_RULES="${STACK_RULES[$DETECTED_STACK]:-common}"

ok "Detected: $STACK_NAME (100% confidence)"

# ============================================================
# [4/5] Load skills
# ============================================================

step "4/5" "Loading skills..."

CORE_SKILLS="tdd-workflow security-review coding-standards verification-loop"
ALL_SKILLS="$CORE_SKILLS $STACK_SKILLS"

CORE_COUNT=$(echo $CORE_SKILLS | wc -w | tr -d ' ')
PROJECT_COUNT=$(echo $STACK_SKILLS | wc -w | tr -d ' ')
TOTAL_COUNT=$(echo $ALL_SKILLS | wc -w | tr -d ' ')

echo -e "  ${WHITE}Core ($CORE_COUNT): $CORE_SKILLS${NC}"
if [[ -n "$STACK_SKILLS" ]]; then
    echo -e "  ${YELLOW}Project ($PROJECT_COUNT): $STACK_SKILLS${NC}"
fi
echo -e "  ${GRAY}Rules: $STACK_RULES${NC}"
echo -e "  ${GREEN}Total: $TOTAL_COUNT skills loaded${NC}"

# ============================================================
# [5/5] Generate config
# ============================================================

step "5/5" "Generating config..."

OVERWRITE=true

if [[ -f "$OPENCODE_CONFIG" ]]; then
    echo ""
    echo -e "  ${YELLOW}Config already exists:${NC}"
    echo -e "  ${GRAY}$OPENCODE_CONFIG${NC}"

    CURRENT_MODEL=$(python3 -c "import json; print(json.load(open('$OPENCODE_CONFIG')).get('model','unknown'))" 2>/dev/null || echo "unknown")
    echo -e "  ${WHITE}Current model: $CURRENT_MODEL${NC}"
    echo ""
    echo -e "  ${CYAN}Detected stack: $STACK_NAME${NC}"
    echo ""
    echo -e "  ${GREEN}[1] Overwrite (apply detected stack)${NC}"
    echo -e "  ${GRAY}[2] Keep current${NC}"
    echo -e "  ${YELLOW}[3] Merge (add project skills)${NC}"
    echo ""

    read -p "  Pilih (1/2/3): " CHOICE

    case $CHOICE in
        1) OVERWRITE=true ;;
        2)
            ok "Keeping current config"
            echo ""
            exit 0
            ;;
        3) OVERWRITE=false ;;
        *) OVERWRITE=true ;;
    esac
fi

# Build skill paths
SKILL_PATHS=""
IFS=' ' read -ra SKILLS <<< "$ALL_SKILLS"
for SKILL in "${SKILLS[@]}"; do
    SKILL_FILE="$ECC_DIR/skills/$SKILL/SKILL.md"
    if [[ -f "$SKILL_FILE" ]]; then
        SKILL_PATHS="$SKILL_PATHS    \"C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/$SKILL/SKILL.md\",\n"
    fi
done

# Generate config
mkdir -p "$OPENCODE_DIR"

cat > "$OPENCODE_CONFIG" << 'CONFIGEOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "9router/gratis",
  "small_model": "9router/gratis-small",
  "default_agent": "build",
  "provider": {
    "9router": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local 9Router",
      "options": {
        "baseURL": "http://localhost:20128/v1",
        "apiKey": "{env:NINEROUTER_API_KEY}"
      },
      "models": {
        "oc/mimo-v2.5-free": { "name": "MiMo V2.5 Free" },
        "oc/deepseek-v4-flash-free": { "name": "DeepSeek V4 Flash Free" },
        "oc/nemotron-3-ultra-free": { "name": "Nemotron 3 Ultra Free" },
        "oc/north-mini-code-free": { "name": "North Mini Code Free" },
        "oc/big-pickle": { "name": "Big Pickle" },
        "kr/claude-sonnet-4.5": { "name": "Kiro Claude 4.5 Free" },
        "kr/glm-5": { "name": "Kiro GLM-5 Free" }
      }
    }
  },
  "instructions": [
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/AGENTS.md",
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/CONTRIBUTING.md",
CONFIGEOF

# Add skill paths
IFS=' ' read -ra SKILLS <<< "$ALL_SKILLS"
for SKILL in "${SKILLS[@]}"; do
    if [[ -f "$ECC_DIR/skills/$SKILL/SKILL.md" ]]; then
        echo "    \"C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/$SKILL/SKILL.md\"," >> "$OPENCODE_CONFIG"
    fi
done

# Close instructions and add rest
cat >> "$OPENCODE_CONFIG" << 'CONFIGEOF'
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/9router/SKILL.md",
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/9router-chat/SKILL.md",
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/9router-image/SKILL.md",
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/9router-web-search/SKILL.md",
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/9router-web-fetch/SKILL.md",
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/9router-tts/SKILL.md",
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/9router-stt/SKILL.md",
    "C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills/9router-embeddings/SKILL.md"
  ],
  "plugin": ["C:/Users/FANNNDI/Documents/opencode-setup/ecc/plugins"],
  "skills": {
    "paths": ["C:/Users/FANNNDI/Documents/opencode-setup/ecc/skills"]
  },
  "command": {
    "plan": { "description": "Create implementation plan", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/ecc/.opencode/commands/plan.md}\n\n$ARGUMENTS", "agent": "planner", "subtask": true },
    "tdd": { "description": "Enforce TDD workflow", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/ecc/.opencode/commands/tdd.md}\n\n$ARGUMENTS", "agent": "tdd-guide", "subtask": true },
    "code-review": { "description": "Review code quality", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/ecc/.opencode/commands/code-review.md}\n\n$ARGUMENTS", "agent": "code-reviewer", "subtask": true },
    "security": { "description": "Run security review", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/ecc/.opencode/commands/security.md}\n\n$ARGUMENTS", "agent": "security-reviewer", "subtask": true },
    "build-fix": { "description": "Fix build errors", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/ecc/.opencode/commands/build-fix.md}\n\n$ARGUMENTS", "agent": "build-error-resolver", "subtask": true },
    "verify": { "description": "Run verification loop", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/ecc/.opencode/commands/verify.md}\n\n$ARGUMENTS" },
    "analyze-project": { "description": "Analyze project stack", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/commands/analyze-project.md}\n\n$ARGUMENTS" },
    "start-free": { "description": "Daily workflow - free models", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/commands/start-free.md}\n\n$ARGUMENTS" },
    "start-go": { "description": "Daily workflow - go models", "template": "{file:C:/Users/FANNNDI/Documents/opencode-setup/commands/start-go.md}\n\n$ARGUMENTS" }
  },
  "permission": { "mcp_*": "ask" }
}
CONFIGEOF

ok "Config generated: $OPENCODE_CONFIG"

# ============================================================
# Summary
# ============================================================

echo ""
echo -e "  ${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║              Analysis Complete!                  ║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${WHITE}Stack:     $STACK_NAME${NC}"
echo -e "  ${WHITE}Project:   $PROJECT_DIR${NC}"
echo -e "  ${WHITE}Config:    $OPENCODE_CONFIG${NC}"
echo -e "  ${WHITE}Skills:    $TOTAL_COUNT loaded${NC}"
echo -e "  ${WHITE}Rules:     $STACK_RULES${NC}"
echo ""
echo -e "  ${CYAN}Next: opencode${NC}"
echo ""
