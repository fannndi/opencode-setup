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
/set-project C:\path\ke\project
/code-analyze
/analyze-project
restart opencode
```

---

## Commands

### 🚀 Combo Shortcuts — 1x jalan, semua beres

| Command | Fungsi | Langkah |
|---------|--------|---------|
| `/start-project` | Setup project baru | start → code-analyze → analyze-project |
| `/quick-review` | Review + security + verify | code-review → security → verify → quality-gate |
| `/full-scan` | Scan menyeluruh | code-analyze → analyze-project → project-skills |
| `/morning-routine` | Rutinitas pagi | start-free → auto-start → admin-update |

### ⚡ Development

| Command | Fungsi |
|---------|--------|
| `/start-free` | Start workflow gratis |
| `/set-project path` | Set project aktif |
| `/current-project` | Lihat project aktif |
| `/code-analyze` | Scan source → ai-notes.md |
| `/project-analyze` | Analisa PRD → ai-notes.md |
| `/analyze-project` | Deteksi stack + load skills |
| `/auto-start` | Chain semua workflow |
| `/template nama` | Load project template |
| `/create widget nama` | Generate boilerplate |
| `/generate-prd "ide"` | Generate PRD dari ide |

### 🔍 Riset & Tools

| Command | Fungsi |
|---------|--------|
| `/research "topik"` | Web search + AI ringkasan |
| `/project-skills` | Lihat AI skills yang cocok |
| `/quality-gate` | Cek layak commit |
| `/token-stats` | Token usage + session stats |
| `/memory` | Simpan/baca memori session |
| `/wizard` | Panduan interaktif pemula |

### 🛠️ Admin & Power

| Command | Fungsi |
|---------|--------|
| `/admin` | Update ECC/9Router, doctor check |
| `/plan` | Buat rencana implementasi |
| `/tdd` | Test-driven development |
| `/code-review` | Review kode |
| `/security` | Security audit |
| `/build-fix` | Fix build errors |
| `/verify` | Verification loop |
| `/reset-session` | Reset session |
| `/orchestrate` | Multi-agent orchestration |
| `/e2e` | End-to-end testing |
| `/refactor-clean` | Hapus dead code |
| `/learn` | Extract patterns |
| `/checkpoint` | Save progress |
| `/update-docs` | Update dokumentasi |
| `/test-coverage` | Analisa test coverage |

---

## Workflow Examples

### Flutter — Existing Code

```powershell
cd opencode-setup
opencode
/start-free
/set-project C:\Users\User\flutter-app
/code-analyze
/analyze-project
restart

/code-review lib/screens/
/security lib/
/tdd buat halaman login
/verify
```

### Flutter — Project Baru (dengan PRD)

```powershell
opencode
/start-free
/set-project C:\Users\User\flutter-app-baru
/project-analyze
/analyze-project
restart

/plan "buat halaman login"
/tdd buat state management
/code-review lib/
/security
```

### Ganti Project

```powershell
/set-project C:\Users\User\project-lain
/code-analyze
/analyze-project
```

---

## Biaya $0

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
├── scripts/                 # Automation scripts (30 file)
├── commands/                # OpenCode command templates
├── profiles/                # Config profiles (gratis / go)
├── templates/               # Project templates (4)
├── Feature/                 # 600+ komponen inventory
├── Skill/                   # 270 skills catalog
├── docs/                    # Dokumentasi
├── ecc/                     # ECC repo (auto-cloned)
├── 9router/                 # 9Router repo (auto-cloned)
├── CHANGELOG.md
├── caveman-mode.md
├── api-key.txt
├── README.md
└── install.bat              # One-click installer
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
