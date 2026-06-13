# Session Log — ECC + OpenCode + 9Router Setup

**Date:** 2026-06-14
**Session:** Full setup dari nol sampai controller repo

---

## Summary

Setup ECC (agents/skills) + 9Router (RTK/Caveman/fallback) untuk OpenCode, 
semua diatur dari 1 controller repo: `fannndi/opencode-setup`.

---

## Timeline

### 1. Research ECC
- Fetch README dari https://github.com/affaan-m/ECC
- ECC v2.0.0: 24 agents, 31 commands, 14 skills, 5 hooks, 3 custom tools
- Support 12+ bahasa (TS, Python, Go, Java, Kotlin, Rust, C++, dll)
- License MIT, 215K+ stars

### 2. Rencana Install di OpenCode
- OpenCode v1.17.0 terinstall (npm)
- Global config: `~/.config/opencode/opencode.jsonc` (kosong)
- Plugin SDK: `@opencode-ai/plugin` 1.17.0 sudah ada
- Target: Global install, TS + Python + Go, Full (agents + skills + hooks + rules)

### 3. Masalah: Tidak Ada Claude API Key
- ECC default pakai `claude-sonnet-4-5` / `claude-opus-4-5`
- User punya OpenCode Go subscription ($5/bulan)
- Go tidak include Claude, include: Kimi, Qwen, DeepSeek, MiMo, GLM, MiniMax

### 4. Solusi Model
- **Opsi Gratis:** MiMo-V2.5 Free + DeepSeek V4 Flash Free ($0)
- **Opsi Go:** Kimi K2.7 + Qwen3.7 Max + DeepSeek V4 Pro ($5/mo)
- User pilih: coba gratis dulu

### 5. Buat fanndi/ Folder di ECC Repo
Buat folder `fanndi/` dengan:
- `gratis/opencode.jsonc` — config free models (24 agents, 31 commands)
- `go/opencode.jsonc` — config Go models
- `install.ps1` — PowerShell install script
- `install.sh` — Bash install script
- `README.md` — dokumentasi

### 6. Buat Repositori
- **fannndi/ecc-setup** — standalone setup folder (sudah di-delete, merge ke opencode-setup)
- **fannndi/ECC** — fork dari affaan-m/ECC + fanndi/ folder
- Semua sudah di-push ke GitHub

### 7. Caveman Mode + 9Router Integration
- Tambah field `system` di opencode.jsonc (terse-style prompting)
- 9Router: RTK Token Saver (-20-40% input) + Caveman Mode (-65% output)
- Token savings: ~70-80% total

### 8. Controller Repo: opencode-setup
Buat `fannndi/opencode-setup`:
- `setup.ps1` / `setup.sh` — full auto (clone, install, config, start)
- `install.ps1` / `install.sh` — quick re-apply
- `profiles/gratis/` + `profiles/go/` — static config reference
- `caveman-mode.md` — reference doc

### 9. 9Router URL Fix
- Change: `decolua/9router` → `fannndi/9router` (user fork sendiri)

### 10. Merge ecc-setup → opencode-setup
- Copy semua file dari ecc-setup ke opencode-setup
- Delete ecc-setup repo (user perlu manual delete dari GitHub)

---

## Final Repositories

| Repo | URL | Fungsi |
|------|-----|--------|
| **opencode-setup** | https://github.com/fannndi/opencode-setup | Controller repo (1 command setup) |
| **ECC (fork)** | https://github.com/fannndi/ECC | Fork ECC + fanndi/ folder |
| **9Router (fork)** | https://github.com/fannndi/9router | Fork 9Router |

---

## File Structure (opencode-setup)

```
opencode-setup/
├── README.md
├── setup.ps1              ← Full auto setup (Windows)
├── setup.sh               ← Full auto setup (macOS/Linux)
├── install.ps1            ← Quick re-apply (Windows)
├── install.sh             ← Quick re-apply (macOS/Linux)
├── caveman-mode.md        ← Caveman Mode reference
├── profiles/
│   ├── gratis/
│   │   └── opencode.jsonc ← Static config: free models
│   └── go/
│       └── opencode.jsonc ← Static config: Go models
├── ecc/                   ← auto-cloned dari fannndi/ECC
└── 9router/               ← auto-cloned dari fannndi/9router
```

---

## Architecture

```
[OpenCode] → [9Router localhost:20128] → [Provider]
               │
               ├── RTK: compress tool output (-20-40% input tokens)
               ├── Caveman: terse replies (-65% output tokens)
               └── Auto-fallback: subscription → cheap → free
```

---

## How to Use

### Laptop Baru
```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\setup.ps1
```

### Ganti Profile
```powershell
.\install.ps1 -Profile go      # atau
.\install.ps1 -Profile gratis
```

### Update ECC + 9Router
```powershell
cd ecc && git pull && cd ..
cd 9router && git pull && cd ..
cd ecc && npm run build:opencode && cd ..
.\setup.ps1
```

---

## What's Next (Belum Selesai)

- [ ] User belum connect provider di 9Router dashboard
- [ ] User belum set NINEROUTER_API_KEY
- [ ] User belum test OpenCode dengan setup baru
- [ ] Delete ecc-setup repo dari GitHub (perlu manual)
- [ ] Test apakah agents/commands jalan dengan free models

---

## Key Decisions

1. **Model strategy:** Gratis dulu, upgrade ke Go kalau perlu
2. **RTK + Caveman:** Handle oleh 9Router, bukan ECC
3. **Controller repo:** 1 repo untuk semua (opencode-setup)
4. **Fork semua:** ECC, 9Router, semua under fannndi/ account
5. **Config generation:** Dynamic (setup.ps1 generate berdasarkan profile)

---

## Environment Variables

```powershell
# Set by setup script
ECC_HOOK_PROFILE=standard
ECC_AGENT_DATA_HOME=$HOME/.opencode/ecc
NINEROUTER_API_KEY=your-key-from-dashboard  # user perlu set manual
```

---

## Troubleshooting Notes

- Plugin build wajib: `npm run build:opencode` di folder ECC
- 9Router port: 20128 (cek `lsof -i :20128` atau `netstat -ano | findstr :20128`)
- Dashboard: http://localhost:20128/dashboard (password: 123456)
- RTK + Caveman: ON by default, toggle di Dashboard → Endpoint settings
- Model IDs: jangan guess, query `/v1/models` dulu
