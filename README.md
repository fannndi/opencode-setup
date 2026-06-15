# Bu Rina Mau Bikin Aplikasi

Bu Rina punya toko kelontong. Setiap hari dia catat stok barang di buku, hitung manual pake kalkulator, dan sering kehabisan barang karena lupa order.

Dia ingin punya **aplikasi kasir** — tapi tidak bisa coding. Dan tidak punya duit jutaan rupiah buat sewa programmer.

**Sekarang ada solusinya.**

---

## Yang Ini Bisa Bikin Aplikasi — Gratis

Bayangkan ada **asisten pribadi** yang bisa bikin aplikasi. Anda tinggal ceritakan ide, dia yang kerjakan. Tidak perlu belajar coding. Tidak perlu bayar.

Asisten ini kerja pakai 3 teknologi yang berjalan otomatis di belakang layar:

- **Otak AI** — paham 270+ bahasa dan cara bikin aplikasi
- **Jaringan gratis** — menghubungkan ke AI tanpa biaya
- **Sistem pintar** — memastikan semuanya jalan terus

---

## Cara Pakai (3 Langkah)

### Langkah 1: Download + Jalankan

Download folder ini, lalu **double-click file bernama `install.bat`**.

```
install.bat       ← klik 2x, tunggu bentar
   │
   ├── Cek laptop (apa perlu install sesuatu?)
   ├── Download otak AI (270+ skills)
   ├── Siapkan jaringan gratis
   └── Buka dashboard
```

Komputer akan kerja sendiri. Anda tinggal tunggu 1-2 menit.

### Langkah 2: Ceritakan Ide

Buka terminal (command prompt), ketik:

```
opencode
/start-free
/wizard
```

Lalu jawab pertanyaan dari AI:

| AI Bertanya | Anda Jawab |
|-------------|-----------|
| Project baru atau yang sudah ada? | Baru |
| Nama project? | Aplikasi Kasir |
| Ceritakan aplikasi yang diinginkan? | _"Aplikasi untuk catat stok barang, laporan penjualan harian, dan cetak struk"_ |

Seperti ngobrol dengan teman yang pengen bantu.

### Langkah 3: Dapatkan Aplikasi

AI akan:

1. **Buat rencana** — fitur apa saja yang akan dibuat
2. **Pilih teknologi** — aplikasi mobile atau website
3. **Tulis kode** — kerjakan satu per satu
4. **Tunjukkan hasil** — Anda bisa review dan minta revisi

---

## Yang Perlu Disiapkan

| Kebutuhan | Detail |
|-----------|--------|
| Laptop/Komputer | Windows 10 atau lebih baru |
| Koneksi Internet | Untuk download pertama kali |
| Ide Aplikasi | Ceritakan ke AI nanti |
| Waktu | 10 menit pertama, sisanya biar AI kerja |
| **Biaya** | **$0 — GRATIS TOTAL** |

---

## Contoh: Bu Rina Bikin Aplikasi Kasir

Bu Rina ikuti 3 langkah di atas. Dia ceritakan ke AI:

> _"Saya ingin aplikasi kasir untuk toko kelontong. Bisa catat stok barang, laporan penjualan harian, dan cetak struk belanja."_

**Hasilnya, AI langsung buat:**

| Yang Dibuat | Isinya |
|-------------|--------|
| ✅ Rencana Aplikasi | Fitur: catat stok, laporan harian, cetak struk |
| ✅ Pilihan Teknologi | Aplikasi mobile (Android + iPhone) |
| ✅ Skills yang Dibutuhkan | Semua sudah siap, tinggal eksekusi |
| ✅ Kode Program | Ditulis otomatis oleh AI |

Bu Rina tinggal bilang: _"Tambahin fitur notifikasi kalau stok mau habis"_ — AI langsung kerjakan.

---

## Ingin Tahu Lebih Dalam?

Kalau Anda penasaran bagaimana cara kerjanya, atau ingin menggunakan fitur yang lebih canggih, baca dokumentasi lengkap di folder `docs/`.

Atau cukup buka terminal dan ketik command berikut untuk lihat semua yang bisa dilakukan:

```
opencode
/start-free
```

Ketika sudah masuk mode OpenCode, ketik `/` untuk melihat daftar perintah yang tersedia.

---

## Credits

Proyek ini adalah gabungan 3 teknologi open-source yang semuanya gratis:

- **OpenCode** — AI coding assistant
- **9Router** — Jaringan AI gratis
- **ECC** — Pengetahuan 270+ bahasa pemrograman

Dibuat agar siapapun bisa bikin aplikasi tanpa perlu coding dan tanpa biaya.

---

**Selamat datang di masa depan — di mana Anda tinggal bilang, AI yang kerjakan.**

---

---

# Untuk Developer

---

## AI Agent System

Sistem agent yang bisa autonomous: detect stack → load skills → decompose goal → execute.

### Agent Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `/detect <path>` | Deteksi stack project | `/detect C:\project` |
| `/auto-load <path>` | Auto-load skill sesuai stack | `/auto-load C:\project` |
| `/resume` | Resume session terakhir | `/resume` |
| `/llm on\|off\|status` | Toggle local LLM mode | `/llm status` |
| `/dashboard` | Tampilkan sistem overview | `/dashboard` |
| `/task-queue <goal>` | Autonomous goal → subtasks | `/task-queue "bikin login page"` |
| `/tool-create <template>` | Generate script/command | `/tool-create script=deploy` |

### Agent Flow

```
User: "bikin fitur payment"
  │
  ├─ /task-queue "bikin fitur payment"
  │
  ├─ [Agent Core]
  │   ├─ Detect stack (NestJS + Flutter)
  │   ├─ Auto-load skills (backend-patterns, dart-flutter-patterns, api-design)
  │   └─ Resume session (last progress: P0-1 at 80%)
  │
  ├─ [Task Decomposition]
  │   ├─ Task A: Backend endpoint (depends: none)
  │   ├─ Task B: Frontend screen (depends: A)
  │   └─ Task C: Integration test (depends: A+B)
  │
  ├─ [Execute]
  │   ├─ Execute A → self-heal → auto-fix errors
  │   ├─ Execute B → self-heal → eval gate
  │   └─ Execute C → eval gate → log memory
  │
  └─ [Result]
      ├─ Features completed
      ├─ Patterns extracted
      └─ Session updated
```

### Agent Hooks (Auto-Execute)

| Hook | Trigger | Action |
|------|---------|--------|
| Self-Heal | After Edit/Write | Check types, report errors |
| Eval Gate | After editing test files | Auto-run tests |
| Instinct Extract | Session end | Extract patterns to memory |
| Proactive Research | Before Edit/Write | Track new libraries |

---

### Local LLM Mode

Sistem bisa jalan dengan atau tanpa local LLM. Mode ON = pake Ollama, mode OFF = regex fallback.

```powershell
/llm on       # Aktifkan local LLM (butuh Ollama + qwen3:1.7b)
/llm off      # Matikan (hemat baterai, anti overheat outdoor)
/llm status   # Cek status Ollama + model
```

**Default model:** `qwen3:1.7b` — cocok MX150 2GB (1.4GB VRAM, 0.6GB headroom).
**Auto-fallback:** Kalo Ollama mati atau timeout, semua script otomatis pake regex. Gak perlu manual.

### Intent Compiler

Ubah bahasa manusia → structured JSON spec.

```powershell
/intent "buat CRUD penduduk desa"
/intent "bikin login admin pake PHP"
```

Output: `{ domain, module, features, validation, roles, security, stack_hint }`

LLM ON → output kaya (7+ fields, detail). LLM OFF → regex fallback (cepat, basic).

### Skill Router

Pilih skill relevan dari 270 ECC skills berdasarkan intent.

```powershell
/route "PHP MySQL desa"
/route "Flutter mobile app"
```

Output: 3-10 nama skill yang relevan. Token hemat 60-80%. 

---

## Quick Start

```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1
```

Edit `api-key.txt`, paste API key, lalu:

```powershell
.\scripts\setup.ps1
opencode
/start-free

# Set project — GitHub URL wajib, auto-clone + session terbuat
/set-project C:\path\ke\project
/code-analyze
/analyze-project

# Session tersimpan otomatis per project
restart opencode
```

---

## Commands

### 🌅 Morning Routine
Pertama kali dijalankan setiap hari. 1x jalan, semua beres.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/morning-routine` | start-free → admin → quality-gate → token-stats | verification-loop, cost-aware, strategic-compact |

### 🚀 Start Project
Setup project baru — scan code, deteksi stack, load AI skills.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/start-project` | start-free → set-project → code-analyze → analyze-project | tdd-workflow, coding-standards, codebase-onboarding |

### 📋 PRD Combo
Ubah ide jadi rencana aplikasi lengkap dengan PRD.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/prd-combo` | generate-prd → project-analyze → analyze-project | blueprint, product-capability, architecture-decision-records |

### ⚡ Quick Review
Review kode + cek keamanan + verifikasi sebelum commit.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/quick-review` | code-review → security-scan → verify → research | coding-standards, security-review, verification-loop |

### 🔍 Full Audit
Audit menyeluruh — scan + deteksi + skills + simpan memori.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/full-audit` | code-analyze → analyze-project → project-skills → memory | codebase-onboarding, continuous-learning-v2, skill-scout |

### 🛠️ Maintenance
Update system + cek kesehatan + reset session.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/maintenance` | admin → quality-gate → reset-session | verification-loop, strategic-compact, context-budget |

### 🎨 Generate
Load template + generate boilerplate komponen.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/generate` | template → create api → create widget → create model | coding-standards, 42 framework skills |

### 🐛 Bug Fix
Fix error build + verifikasi + simpan solusi ke memori.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/bug-fix` | build-fix → quality-gate → memory | error-handling, continuous-learning-v2, coding-standards |

### 🔒 Security
Audit keamanan + verifikasi + cari referensi best practices.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/security` | security → quality-gate → research | security-review, security-scan, deep-research |

### 🚢 Deploy
Verifikasi + quality gate + update dokumentasi — siap deploy.

| Combo | Langkah | Skills |
|-------|---------|--------|
| `/deploy` | verify → quality-gate → update-docs | verification-loop, deployment-patterns, docker-patterns |

---

## Workflow Examples

### Flutter — Existing Code

```powershell
cd opencode-setup
opencode
/start-free

# Clone project dari GitHub + setup session
/set-project C:\Users\User\flutter-app
# → Akan minta GitHub URL, clone ke Project/flutter-app/

# Analisa project
/code-analyze
/analyze-project

# Setelah restart, session otomatis terload
restart

/code-review lib/screens/
/security-scan lib/
/tdd buat halaman login
/verify
```

### Flutter — Project Baru (dengan PRD)

```powershell
opencode
/start-free
/set-project C:\Users\User\flutter-app-baru
# → Masukin GitHub URL → clone → session terbuat
/project-analyze
/analyze-project
restart

/plan "buat halaman login"
/tdd buat state management
/code-review lib/
/security-scan
```

### Ganti Project

Session & memory per project. Ganti project = auto-load konteks lama.

```powershell
# Langsung set-path + GitHub → clone + buat session baru
/set-project C:\Users\User\project-lain

# Atau switch ke project yang sudah ada
session-manager.ps1 -Action switch -ProjectPath "C:\Users\User\project-lain"
```

---

## 📚 Referensi Lengkap

| Ingin Lihat | Buka File Ini | Isinya |
|-------------|---------------|--------|
| 📖 **Semua Skills** (270) | [`Skill/skill-list.md`](Skill/skill-list.md) | Skill per kategori + per stack |
| 🎯 **Semua Fitur** (600+) | [`Feature/list.md`](Feature/list.md) | Skills, Agents, Commands, Hooks, Rules, MCP |
| ⌨️ **Semua Commands** (84) | [`docs/04-usage/01-commands.md`](docs/04-usage/01-commands.md) | Referensi lengkap slash commands |
| 🐚 **Semua Scripts** (40) | [`docs/04-usage/02-scripts.md`](docs/04-usage/02-scripts.md) | Semua automation script |
| 🔄 **Changelog** | [`CHANGELOG.md`](CHANGELOG.md) | Riwayat perubahan project |
| 📋 **Admin Log** | [`log-admin.md`](log-admin.md) | History update admin |
| 📋 **Dev Plan** | [`DEV-PLAN.md`](DEV-PLAN.md) | Self-improvement roadmap |

---

## Biaya $0

| Komponen | Biaya | Kegunaan |
|----------|-------|----------|
| OpenCode Free | ✅ $0 | AI coding assistant |
| 9Router | ✅ $0 | AI gateway + combos |
| ECC (270 skills) | ✅ $0 | Knowledge base |
| MiMo Auto | ✅ $0 | Free AI model |

| Komponen | Biaya | Kegunaan |
|----------|-------|----------|
| OpenCode Free | ✅ $0 | AI coding assistant |
| 9Router | ✅ $0 | AI gateway + combos |
| ECC (270 skills) | ✅ $0 | Knowledge base |
| MiMo Auto | ✅ $0 | Free AI model |

---

## Struktur

```
opencode-setup/
├── Project/                   # Per-project data: source, session, memory
│   ├── service-hub/           # Project source code (cloned)
│   ├── Session/               # Session state per project
│   └── Memory/                # Memory per project (logs, patterns, errors)
├── scripts/                   # Automation scripts (40 file)
│   ├── agent-core.ps1         # AI Agent: intent, skill-loader, decompose
│   ├── agent-dashboard.ps1    # System overview dashboard
│   ├── task-queue.ps1         # Autonomous task DAG execution
│   ├── tool-creator.ps1       # Template-based script/command generator
│   └── hooks/                 # Agent hooks (self-heal, instinct, eval)
├── commands/                  # OpenCode command templates
├── profiles/                  # Config profiles (gratis / go)
├── templates/                 # Project templates (4)
├── Feature/                   # 600+ komponen inventory
├── Skill/                     # 270 skills catalog
├── docs/                      # Dokumentasi
├── ecc/                       # ECC repo (auto-cloned)
├── 9router/                   # 9Router repo (auto-cloned)
├── DEV-PLAN.md                 # Self-improvement roadmap
├── CHANGELOG.md
├── caveman-mode.md
├── api-key.txt
├── README.md
└── install.bat                # One-click installer
```

---

## Admin Workflow (Untuk Pengembangan Project Ini)

```powershell
.\scripts\admin-update.ps1     # Update ECC + 9Router + doctor check
.\scripts\start.ps1            # Test model
opencode                       # Verify commands jalan
git add -A && git commit       # Save perubahan
git push                       # Push ke repo
```

### Changelogs

| File | Isi |
|------|-----|
| [changelog-ecc.md](changelog-ecc.md) | Perubahan ECC (skills, agents, commands) |
| [changelog-9router.md](changelog-9router.md) | Perubahan 9Router (models, features) |
| [log-admin.md](log-admin.md) | History update admin |
