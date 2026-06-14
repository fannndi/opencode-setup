#!/usr/bin/env bash
# Wizard — Panduan interaktif untuk orang awam
# Usage: ./wizard.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo ""
echo "  Selamat datang di AI Coding Studio!"
echo "  ==================================="
echo ""
echo "  Saya akan bantu Anda membuat aplikasi"
echo "  tanpa perlu bisa coding. GRATIS."
echo ""

read -p "  Nama project Anda: " PROJECT_NAME
[[ -z "$PROJECT_NAME" ]] && PROJECT_NAME="my-app"
PROJECT_PATH="$HOME/Documents/$PROJECT_NAME"
mkdir -p "$PROJECT_PATH"

echo "  [OK] Folder dibuat: $PROJECT_PATH"
echo ""
echo "  1. BIKIN PROJECT BARU"
echo "  2. PAKAI PROJECT EXISTING"
read -p "  Pilih (1/2): " MODE

echo ""
echo "  [INFO] AI sedang memproses..."
echo "  [INFO] Next: opencode → /start-free → /wizard"
echo ""
echo "  Selesai! 🎉"
