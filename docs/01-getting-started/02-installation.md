# Instalasi Lengkap

## Prasyarat

| Tool | Versi Minimum | Cek |
|------|---------------|-----|
| Node.js | 18.x | `node --version` |
| npm | 9.x | `npm --version` |
| Git | 2.x | `git --version` |
| OpenCode | 1.17+ | `opencode --version` |

## Instalasi OpenCode

```bash
npm install -g opencode
```

## Instalasi ECC + 9Router

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

## Opsi Setup

### Full Setup (dari nol)

```powershell
.\scripts\setup.ps1
```

Setup lengkap: clone repos, install, build, generate config, start 9Router.

### Quick Re-Apply (sudah clone sebelumnya)

```powershell
.\scripts\install.ps1 -Profile gratis
.\scripts\install.ps1 -Profile go
```

Hanya copy config + rebuild plugin.

### Sync Changelog

```powershell
.\scripts\sync.ps1
```

Cek perubahan terbaru dari ECC/9Router.

## Verifikasi

```bash
# Cek OpenCode
opencode --version

# Cek 9Router
curl http://localhost:20128/api/health
# Output: {"ok":true}
```

## Troubleshooting

Jika ada error, baca [FAQ](../08-troubleshooting/01-common-issues.md).
