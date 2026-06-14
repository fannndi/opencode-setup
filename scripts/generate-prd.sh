#!/usr/bin/env bash
# Generate PRD — Ide → Product Requirements Document
# Usage: ./generate-prd.sh --idea "deskripsi aplikasi" [--project-path "C:\path"]

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IDEA=""; PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in --idea) IDEA="$2"; shift 2 ;; --project-path) PROJECT_PATH="$2"; shift 2 ;; *) shift ;; esac
done

[[ -z "$IDEA" ]] && { echo "[ERROR] --idea required"; exit 1; }
[[ -z "$PROJECT_PATH" ]] && PROJECT_PATH="$PWD"

PRD_FILE="$PROJECT_PATH/prd.md"
cat > "$PRD_FILE" << PRDEOF
# PRD — $(basename "$PROJECT_PATH")

**Generated:** $(date +%Y-%m-%d)
**Source:** AI-generated dari ide Anda

---

## Ringkasan
$IDEA

## Tech Stack (Rekomendasi AI)
- Frontend: Flutter (cross-platform)
- Backend: Firebase (gratis untuk skala kecil)
- Database: Firestore (real-time)

## Skills yang Dibutuhkan
- dart-flutter-patterns, tdd-workflow, security-review, coding-standards

*PRD ini di-generate otomatis. Edit jika perlu.*
PRDEOF
echo "[OK] PRD generated: $PRD_FILE"
