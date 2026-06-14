# Quick Start — Setup 1 Menit

Setup **Master Control** — clone sekali, kelola semua project dari satu tempat.

## Prasyarat

- [Node.js](https://nodejs.org) terinstall
- [Git](https://git-scm.com) terinstall
- [OpenCode](https://opencode.ai) terinstall (`npm install -g opencode`)

## Langkah

### Windows (PowerShell)

```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1
```

### macOS / Linux

```bash
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
chmod +x scripts/setup.sh
./scripts/setup.sh
```

## Yang Terjadi

1. Clone ECC + 9Router repos
2. Install dependencies
3. Build OpenCode plugin
4. Generate config
5. Start 9Router

## Selanjutnya

1. Baca [Setelah Setup](03-after-setup.md) untuk API key
2. Buka OpenCode: `opencode`
3. `/start-free` — start dulu
4. `/set-project C:\path\ke\project` — set project
5. `/code-analyze` — scan source code
6. `/analyze-project` — load skills
