#!/usr/bin/env bash
# Project Resolve — Per-project session & memory management for shell
# Source this file: . ./project-resolve.sh
# 
# Functions:
#   get_registry         — read Project/registry.json
#   get_active_project   — echo current active project path
#   get_project_slug     — echo folder name from path
#   get_session_file     — echo Project/Session/<slug>/session.json
#   get_memory_dir       — echo Project/Memory/<slug>/
#   resolve_project      — ensure session+memory dirs exist, register if new

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$ROOT_DIR/Project"
REGISTRY_FILE="$PROJECT_ROOT/registry.json"

get_registry() {
    if [[ -f "$REGISTRY_FILE" ]]; then
        python3 -c "
import json
try:
    d = json.load(open('$REGISTRY_FILE'))
    print(d.get('active_project', ''))
except: print('')
" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

get_active_project() {
    get_registry
}

get_project_slug() {
    local path="$1"
    basename "$path" | sed 's/[^a-zA-Z0-9_-]/_/g'
}

get_session_file() {
    local path="$1"
    local slug
    slug=$(get_project_slug "$path")
    echo "$PROJECT_ROOT/Session/$slug/session.json"
}

get_memory_dir() {
    local path="$1"
    local slug
    slug=$(get_project_slug "$path")
    echo "$PROJECT_ROOT/Memory/$slug"
}

resolve_project() {
    local path="$1"
    local slug
    slug=$(get_project_slug "$path")
    local session_file
    session_file=$(get_session_file "$path")
    local memory_dir
    memory_dir=$(get_memory_dir "$path")

    mkdir -p "$PROJECT_ROOT/Session/$slug"
    mkdir -p "$memory_dir/sessions"
    mkdir -p "$memory_dir/patterns"
    mkdir -p "$memory_dir/errors"

    # Check registry
    if [[ -f "$REGISTRY_FILE" ]]; then
        local exists
        exists=$(python3 -c "
import json
d = json.load(open('$REGISTRY_FILE'))
print('yes' if '$(echo "$path" | sed "s/\\\\/\\\\\\\\/g")' in d.get('projects', {}) else 'no')
" 2>/dev/null || echo "no")
        if [[ "$exists" == "no" ]]; then
            # Register new project
            local timestamp
            timestamp=$(date -Iseconds 2>/dev/null || date "+%Y-%m-%dT%H:%M:%S%z")
            python3 -c "
import json
d = json.load(open('$REGISTRY_FILE'))
d['active_project'] = '$path'
d.setdefault('projects', {})['$path'] = {
    'slug': '$slug',
    'stack': '',
    'profile': '',
    'first_seen': '$timestamp',
    'last_seen': '$timestamp'
}
json.dump(d, open('$REGISTRY_FILE', 'w'))
" 2>/dev/null || true
            echo "[PROJECT] Created new: $slug"
        fi
    else
        # Create new registry
        local timestamp
        timestamp=$(date -Iseconds 2>/dev/null || date "+%Y-%m-%dT%H:%M:%S%z")
        mkdir -p "$(dirname "$REGISTRY_FILE")"
        python3 -c "
import json
d = {'version':'1.0','active_project':'$path','projects':{'$path':{'slug':'$slug','stack':'','profile':'','first_seen':'$timestamp','last_seen':'$timestamp'}}}
json.dump(d, open('$REGISTRY_FILE', 'w'))
" 2>/dev/null || true
        echo "[PROJECT] Created new: $slug"
    fi

    # Create session if not exists
    if [[ ! -f "$session_file" ]]; then
        local timestamp
        timestamp=$(date -Iseconds 2>/dev/null || date "+%Y-%m-%dT%H:%M:%S%z")
        python3 -c "
import json
d = {
    'version': '2.0',
    'project_path': '$path',
    'project_name': '$slug',
    'stack': '',
    'skills_loaded': [],
    'rules_applied': [],
    'workflow_state': {'prd_analyzed': False, 'ai_notes_generated': False, 'analyze_project_done': False},
    'last_action': '',
    'created_at': '$timestamp',
    'updated_at': '$timestamp'
}
json.dump(d, open('$session_file', 'w'), indent=2)
" 2>/dev/null || true
        echo "[SESSION] Created: Session/$slug/session.json"
    fi
}

# Direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    action="${1:-}"
    path="${2:-}"
    case "$action" in
        resolve)
            [[ -z "$path" ]] && { echo "Error: project path required"; exit 1; }
            resolve_project "$path"
            ;;
        active)
            get_active_project
            ;;
        slug)
            [[ -z "$path" ]] && { echo "Error: path required"; exit 1; }
            get_project_slug "$path"
            ;;
        *)
            echo "Usage: source project-resolve.sh or ./project-resolve.sh <resolve|active|slug> [path]"
            ;;
    esac
fi
