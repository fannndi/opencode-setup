#!/usr/bin/env bash
# OpenCode Full Setup - ECC + 9Router
# Fully automated: clone, install, configure, start
# Usage: ./setup.sh

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ECC_DIR="$SETUP_DIR/ecc"
ROUTER_DIR="$SETUP_DIR/9router"
OPENCODE_CONFIG_DIR="$HOME/.config/opencode"
OPENCODE_CONFIG="$OPENCODE_CONFIG_DIR/opencode.jsonc"
RULES_TARGET="$OPENCODE_CONFIG_DIR/rules/ecc"

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

step() { echo -e "\n${CYAN}[$1/10] $2${NC}"; }
ok()   { echo -e "  ${GREEN}[OK] $1${NC}"; }
skip() { echo -e "  ${YELLOW}[SKIP] $1${NC}"; }
fail() { echo -e "  ${RED}[FAIL] $1${NC}"; exit 1; }

# ============================================================
# Banner
# ============================================================

echo -e "${MAGENTA}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║       OpenCode Full Setup - ECC + 9Router       ║"
echo "  ║    agents · skills · RTK · caveman · fallback   ║"
echo "  ╚══════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================
# Step 1: Pre-flight checks
# ============================================================

step "1/10" "Pre-flight checks..."

command -v node >/dev/null 2>&1 || fail "Node.js not found. Install from https://nodejs.org"
ok "Node.js $(node --version)"

command -v npm >/dev/null 2>&1 || fail "npm not found"
ok "npm $(npm --version)"

command -v git >/dev/null 2>&1 || fail "git not found"
ok "git $(git --version)"

command -v opencode >/dev/null 2>&1 || fail "OpenCode not found. Install: npm install -g opencode"
ok "OpenCode installed"

# ============================================================
# Step 2: Clone repos
# ============================================================

step "2/10" "Clone repositories..."

# Use dedicated clone script
bash "$SETUP_DIR/clone-repo.sh"

# ============================================================
# Step 2.5: Check for changes
# ============================================================

step "2.5/10" "Checking for changes since last sync..."

if [[ -f "$SETUP_DIR/.sync-state.json" ]]; then
    echo -e "  ${GRAY}Running sync-changelog (info only)...${NC}"
    bash "$SETUP_DIR/sync-changelog.sh" --apply 2>/dev/null
    ok "Changelog checked"
else
    skip "No sync state found (first run)"
fi

# ============================================================
# Step 3: Install ECC dependencies
# ============================================================

step "3/10" "Install ECC dependencies..."

if [ ! -d "$ECC_DIR/node_modules" ]; then
    echo -e "  ${GRAY}Installing root dependencies...${NC}"
    cd "$ECC_DIR" && npm install --silent 2>/dev/null && cd "$SETUP_DIR"
fi
ok "Root dependencies"

if [ ! -d "$ECC_DIR/.opencode/node_modules" ]; then
    echo -e "  ${GRAY}Installing .opencode dependencies...${NC}"
    cd "$ECC_DIR/.opencode" && npm install --silent 2>/dev/null && cd "$SETUP_DIR"
fi
ok ".opencode dependencies"

# ============================================================
# Step 4: Build ECC OpenCode plugin
# ============================================================

step "4/10" "Build ECC OpenCode plugin..."

cd "$ECC_DIR" && npm run build:opencode 2>/dev/null && cd "$SETUP_DIR"
if [ -f "$ECC_DIR/.opencode/dist/index.js" ]; then
    ok "Plugin built successfully"
else
    fail "Plugin build failed"
fi

# ============================================================
# Step 5: Install 9Router
# ============================================================

step "5/10" "Install 9Router..."

if command -v 9router >/dev/null 2>&1; then
    skip "9Router already installed globally"
else
    echo -e "  ${GRAY}Installing 9Router globally...${NC}"
    npm install -g 9router 2>/dev/null
    ok "9Router installed"
fi

# ============================================================
# Step 6: Ask user profile
# ============================================================

step "6/10" "Configure profile..."

echo ""
echo -e "  ${WHITE}Pilih provider untuk OpenCode:${NC}"
echo -e "  [1] Free Only (OpenCode Free + Kiro)     <- \$0/bulan"
echo -e "  [2] Go Subscription (Kimi/Qwen/DeepSeek) <- \$5/bulan pertama"
echo -e "  [3] Custom (masukkan API key sendiri)"
echo ""

PROFILE_CHOICE=""
while [[ ! "$PROFILE_CHOICE" =~ ^[123]$ ]]; do
    read -p "  Pilih (1/2/3): " PROFILE_CHOICE
done

GO_API_KEY=""
CUSTOM_API_KEY=""
CUSTOM_MODEL=""

case $PROFILE_CHOICE in
    1)
        PROFILE_NAME="free"
        ok "Free profile selected"
        ;;
    2)
        PROFILE_NAME="go"
        echo ""
        echo -e "  ${YELLOW}Masukkan OpenCode Go API key:${NC}"
        echo -e "  ${GRAY}(Dapatkan dari https://opencode.ai/console)${NC}"
        read -p "  API Key: " GO_API_KEY
        [ -z "$GO_API_KEY" ] && fail "API key tidak boleh kosong"
        ok "Go profile selected"
        ;;
    3)
        PROFILE_NAME="custom"
        echo ""
        read -p "  Provider API Key: " CUSTOM_API_KEY
        read -p "  Model ID (contoh: deepseek/deepseek-chat): " CUSTOM_MODEL
        ok "Custom profile selected"
        ;;
esac

# ============================================================
# Step 7: Generate opencode.jsonc
# ============================================================

step "7/10" "Generate opencode.jsonc..."

mkdir -p "$OPENCODE_CONFIG_DIR"

# Backup existing config
if [ -f "$OPENCODE_CONFIG" ]; then
    cp "$OPENCODE_CONFIG" "${OPENCODE_CONFIG}.bak.$(date +%Y%m%d-%H%M%S)"
    ok "Existing config backed up"
fi

# Set agent models based on profile
case $PROFILE_NAME in
    free)
        PRIMARY="9router/oc/mimo-v2.5-free"
        SUBAGENT_SMART="9router/oc/deepseek-v4-flash-free"
        SUBAGENT_CODE="9router/oc/mimo-v2.5-free"
        PROVIDER_MODELS='"oc/deepseek-v4-flash-free": {"name":"DeepSeek V4 Flash Free"},"oc/mimo-v2.5-free": {"name":"MiMo V2.5 Free"},"oc/nemotron-3-ultra-free": {"name":"Nemotron 3 Ultra Free"},"kr/claude-sonnet-4.5": {"name":"Kiro Claude 4.5 Free"},"kr/glm-5": {"name":"Kiro GLM-5 Free"}'
        ;;
    go)
        PRIMARY="9router/go/kimi-k2.7"
        SUBAGENT_SMART="9router/go/qwen3.7-max"
        SUBAGENT_CODE="9router/go/deepseek-v4-pro"
        PROVIDER_MODELS='"go/kimi-k2.7": {"name":"Kimi K2.7"},"go/qwen3.7-max": {"name":"Qwen3.7 Max"},"go/qwen3.7-plus": {"name":"Qwen3.7 Plus"},"go/deepseek-v4-pro": {"name":"DeepSeek V4 Pro"},"go/deepseek-v4-flash": {"name":"DeepSeek V4 Flash"},"oc/deepseek-v4-flash-free": {"name":"DeepSeek V4 Flash Free (fallback)"}'
        ;;
    custom)
        PRIMARY="9router/$CUSTOM_MODEL"
        SUBAGENT_SMART="9router/$CUSTOM_MODEL"
        SUBAGENT_CODE="9router/$CUSTOM_MODEL"
        PROVIDER_MODELS="\"$CUSTOM_MODEL\": {\"name\":\"$CUSTOM_MODEL\"}"
        ;;
esac

cat > "$OPENCODE_CONFIG" << JSONEOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "$PRIMARY",
  "small_model": "$SUBAGENT_SMART",
  "default_agent": "build",

  "provider": {
    "9router": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local 9Router",
      "options": {
        "baseURL": "http://127.0.0.1:20128/v1",
        "apiKey": "{env:NINEROUTER_API_KEY}"
      },
      "models": {
        $PROVIDER_MODELS
      }
    }
  },

  "instructions": [
    "AGENTS.md", "CONTRIBUTING.md", "instructions/INSTRUCTIONS.md",
    "skills/tdd-workflow/SKILL.md", "skills/security-review/SKILL.md",
    "skills/coding-standards/SKILL.md", "skills/frontend-patterns/SKILL.md",
    "skills/frontend-slides/SKILL.md", "skills/backend-patterns/SKILL.md",
    "skills/e2e-testing/SKILL.md", "skills/verification-loop/SKILL.md",
    "skills/api-design/SKILL.md", "skills/strategic-compact/SKILL.md",
    "skills/eval-harness/SKILL.md"
  ],

  "plugin": ["./plugins"],
  "skills": {"paths": ["../skills"]},

  "agent": {
    "build": {"description":"Primary coding agent","mode":"primary","model":"$PRIMARY","tools":{"write":true,"edit":true,"bash":true,"read":true,"changed-files":true}},
    "planner": {"description":"Planning specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/planner.txt}","tools":{"read":true,"bash":true,"write":false,"edit":false}},
    "architect": {"description":"Architecture specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/architect.txt}","tools":{"read":true,"bash":true,"write":false,"edit":false}},
    "code-reviewer": {"description":"Code review specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/code-reviewer.txt}","tools":{"read":true,"bash":true,"write":false,"edit":false}},
    "security-reviewer": {"description":"Security specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/security-reviewer.txt}","tools":{"read":true,"bash":true,"write":true,"edit":true}},
    "tdd-guide": {"description":"TDD specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/tdd-guide.txt}","tools":{"read":true,"write":true,"edit":true,"bash":true}},
    "build-error-resolver": {"description":"Build error resolver","mode":"subagent","model":"$SUBAGENT_CODE","prompt":"{file:prompts/agents/build-error-resolver.txt}","tools":{"read":true,"write":true,"edit":true,"bash":true}},
    "e2e-runner": {"description":"E2E testing specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/e2e-runner.txt}","tools":{"read":true,"write":true,"edit":true,"bash":true}},
    "doc-updater": {"description":"Documentation specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/doc-updater.txt}","tools":{"read":true,"write":true,"edit":true,"bash":true}},
    "refactor-cleaner": {"description":"Refactoring specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/refactor-cleaner.txt}","tools":{"read":true,"write":true,"edit":true,"bash":true}},
    "go-reviewer": {"description":"Go code review","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/go-reviewer.txt}","tools":{"read":true,"bash":true,"write":false,"edit":false}},
    "go-build-resolver": {"description":"Go build resolver","mode":"subagent","model":"$SUBAGENT_CODE","prompt":"{file:prompts/agents/go-build-resolver.txt}","tools":{"read":true,"write":true,"edit":true,"bash":true}},
    "database-reviewer": {"description":"Database specialist","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/database-reviewer.txt}","tools":{"read":true,"write":true,"edit":true,"bash":true}},
    "python-reviewer": {"description":"Python code review","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/python-reviewer.txt}","tools":{"read":true,"bash":true,"write":false,"edit":false}},
    "loop-operator": {"description":"Autonomous loop operator","mode":"subagent","model":"$SUBAGENT_SMART","prompt":"{file:prompts/agents/loop-operator.txt}","tools":{"read":true,"bash":true,"edit":true}}
  },

  "command": {
    "plan": {"description":"Implementation plan","template":"{file:commands/plan.md}\n\n\$ARGUMENTS","agent":"planner","subtask":true},
    "tdd": {"description":"TDD workflow","template":"{file:commands/tdd.md}\n\n\$ARGUMENTS","agent":"tdd-guide","subtask":true},
    "code-review": {"description":"Code review","template":"{file:commands/code-review.md}\n\n\$ARGUMENTS","agent":"code-reviewer","subtask":true},
    "security": {"description":"Security review","template":"{file:commands/security.md}\n\n\$ARGUMENTS","agent":"security-reviewer","subtask":true},
    "build-fix": {"description":"Fix build errors","template":"{file:commands/build-fix.md}\n\n\$ARGUMENTS","agent":"build-error-resolver","subtask":true},
    "e2e": {"description":"E2E tests","template":"{file:commands/e2e.md}\n\n\$ARGUMENTS","agent":"e2e-runner","subtask":true},
    "refactor-clean": {"description":"Remove dead code","template":"{file:commands/refactor-clean.md}\n\n\$ARGUMENTS","agent":"refactor-cleaner","subtask":true},
    "orchestrate": {"description":"Multi-agent workflow","template":"{file:commands/orchestrate.md}\n\n\$ARGUMENTS","agent":"planner","subtask":true},
    "learn": {"description":"Extract patterns","template":"{file:commands/learn.md}\n\n\$ARGUMENTS"},
    "checkpoint": {"description":"Save progress","template":"{file:commands/checkpoint.md}\n\n\$ARGUMENTS"},
    "verify": {"description":"Verification loop","template":"{file:commands/verify.md}\n\n\$ARGUMENTS"},
    "eval": {"description":"Evaluation","template":"{file:commands/eval.md}\n\n\$ARGUMENTS"},
    "update-docs": {"description":"Update docs","template":"{file:commands/update-docs.md}\n\n\$ARGUMENTS","agent":"doc-updater","subtask":true},
    "test-coverage": {"description":"Test coverage","template":"{file:commands/test-coverage.md}\n\n\$ARGUMENTS","agent":"tdd-guide","subtask":true},
    "go-review": {"description":"Go review","template":"{file:commands/go-review.md}\n\n\$ARGUMENTS","agent":"go-reviewer","subtask":true},
    "go-test": {"description":"Go TDD","template":"{file:commands/go-test.md}\n\n\$ARGUMENTS","agent":"tdd-guide","subtask":true},
    "go-build": {"description":"Go build fix","template":"{file:commands/go-build.md}\n\n\$ARGUMENTS","agent":"go-build-resolver","subtask":true},
    "skill-create": {"description":"Generate skills","template":"{file:commands/skill-create.md}\n\n\$ARGUMENTS"},
    "instinct-status": {"description":"View instincts","template":"{file:commands/instinct-status.md}\n\n\$ARGUMENTS"},
    "instinct-import": {"description":"Import instincts","template":"{file:commands/instinct-import.md}\n\n\$ARGUMENTS"},
    "instinct-export": {"description":"Export instincts","template":"{file:commands/instinct-export.md}\n\n\$ARGUMENTS"},
    "evolve": {"description":"Cluster instincts","template":"{file:commands/evolve.md}\n\n\$ARGUMENTS"}
  },

  "permission": {"mcp_*": "ask"}
}
JSONEOF

ok "Config generated: $OPENCODE_CONFIG"

# ============================================================
# Step 8: Copy rules
# ============================================================

step "8/10" "Install ECC rules..."

mkdir -p "$RULES_TARGET"

for dir in common typescript python golang; do
    src="$ECC_DIR/rules/$dir"
    dst="$RULES_TARGET/$dir"
    if [ -d "$src" ]; then
        rm -rf "$dst"
        cp -r "$src" "$dst"
        ok "rules/$dir"
    else
        skip "rules/$dir not found"
    fi
done

# ============================================================
# Step 9: Set environment variables
# ============================================================

step "9/10" "Set environment variables..."

SHELL_RC=""
[ -f "$HOME/.bashrc" ] && SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

if [ -n "$SHELL_RC" ]; then
    sed -i '/^export ECC_HOOK_PROFILE=/d' "$SHELL_RC"
    sed -i '/^export ECC_AGENT_DATA_HOME=/d' "$SHELL_RC"
    sed -i '/^export NINEROUTER_API_KEY=/d' "$SHELL_RC"

    echo "export ECC_HOOK_PROFILE=standard" >> "$SHELL_RC"
    echo "export ECC_AGENT_DATA_HOME=\"\$HOME/.opencode/ecc\"" >> "$SHELL_RC"

    if [ -z "${NINEROUTER_API_KEY:-}" ]; then
        echo "export NINEROUTER_API_KEY='SET-YOUR-KEY-FROM-DASHBOARD'" >> "$SHELL_RC"
    fi

    ok "Env vars added to $SHELL_RC"
fi

export ECC_HOOK_PROFILE=standard
export ECC_AGENT_DATA_HOME="$HOME/.opencode/ecc"

# ============================================================
# Step 10: Start 9Router + Summary
# ============================================================

step "10/10" "Start 9Router..."

if lsof -Pi :20128 -sTCP:LISTEN -t >/dev/null 2>&1; then
    skip "9Router already running on port 20128"
else
    echo -e "  ${GRAY}Starting 9Router in background...${NC}"
    nohup 9router >/dev/null 2>&1 &
    sleep 3

    if lsof -Pi :20128 -sTCP:LISTEN -t >/dev/null 2>&1; then
        ok "9Router started on http://localhost:20128"
    else
        echo -e "  ${YELLOW}[INFO] 9Router may need manual start: run '9router'${NC}"
    fi
fi

# Open dashboard
echo -e "  ${GRAY}Opening 9Router dashboard...${NC}"
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "http://localhost:20128/dashboard"
elif command -v open >/dev/null 2>&1; then
    open "http://localhost:20128/dashboard"
fi

# ============================================================
# Final Summary
# ============================================================

echo ""
echo -e "  ${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║              Setup Complete!                     ║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${WHITE}Profile:       $PROFILE_NAME${NC}"
echo -e "  ${WHITE}ECC:           $ECC_DIR${NC}"
echo -e "  ${WHITE}9Router:       $ROUTER_DIR${NC}"
echo -e "  ${WHITE}Config:        $OPENCODE_CONFIG${NC}"
echo -e "  ${WHITE}Rules:         $RULES_TARGET${NC}"
echo ""
echo -e "  ${YELLOW}Token Optimization:${NC}"
echo -e "  ${WHITE}    RTK Token Saver:   ON  (compresses tool output -20-40%)${NC}"
echo -e "  ${WHITE}    Caveman Mode:      ON  (terse replies -65% output)${NC}"
echo -e "  ${WHITE}    Auto-fallback:     ON  (subscription -> cheap -> free)${NC}"
echo ""

case $PROFILE_NAME in
    go)
        echo -e "  ${YELLOW}Go Models:${NC}"
        echo -e "  ${WHITE}    Primary:    9router/go/kimi-k2.7${NC}"
        echo -e "  ${WHITE}    Reasoning:  9router/go/qwen3.7-max${NC}"
        echo -e "  ${WHITE}    Review:     9router/go/deepseek-v4-pro${NC}"
        ;;
    free)
        echo -e "  ${YELLOW}Free Models:${NC}"
        echo -e "  ${WHITE}    Primary:    9router/oc/mimo-v2.5-free${NC}"
        echo -e "  ${WHITE}    Fallback:   9router/oc/deepseek-v4-flash-free${NC}"
        echo -e "  ${WHITE}    Emergency:  9router/kr/claude-sonnet-4.5 (Claude free!)${NC}"
        ;;
esac

echo ""
echo -e "  ${YELLOW}Next Steps:${NC}"
echo -e "  ${GRAY}──────────────────────────────────────────────────${NC}"
echo -e "  ${WHITE}1. Buka dashboard  → http://localhost:20128/dashboard${NC}"
echo -e "  ${WHITE}2. Login           → password: 123456${NC}"
echo -e "  ${WHITE}3. Connect provider → Kiro AI (free) atau OpenCode Free${NC}"
echo -e "  ${WHITE}4. Create API key  → Endpoint page → Create Key${NC}"
echo -e "  ${WHITE}5. Set API key:${NC}"
echo -e "     ${CYAN}export NINEROUTER_API_KEY='your-key-here'${NC}"
echo -e "  ${WHITE}6. Start OpenCode:${NC}"
echo -e "     ${CYAN}opencode${NC}"
echo ""
