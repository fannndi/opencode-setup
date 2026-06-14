# Analyze Project — Deteksi Stack

## Alur Lengkap

```
1. clone project repo (prd.md only)
2. cd project
3. clone opencode-setup
4. opencode
5. /plan → analisa PRD
6. /project-analyze → buat ai-notes.md
7. /analyze-project → deteksi stack + load skills
8. restart opencode
9. mulai coding
```

## /project-analyze

Analisa PRD dan buat rekomendasi skills/commands.

```powershell
.\scripts\project-analyze.ps1
```

**Yang dilakukan:**
1. Baca prd.md
2. Deteksi stack dari keywords
3. Match skills dari Skill/skill-list.md
4. Generate ai-notes.md

**Output:** `ai-notes.md` di project root

## /analyze-project

Deteksi stack project dan load skills.

```powershell
.\scripts\analyze-project.ps1
```

**Yang dilakukan:**
1. Locate project root (1 level up)
2. Scan for indicator files
3. Match stack
4. Load core + project-specific skills
5. Generate config

## Indicator Files

| File | Stack |
|------|-------|
| `pubspec.yaml` | Dart/Flutter |
| `go.mod` | Go |
| `package.json` | JavaScript |
| `tsconfig.json` | TypeScript |
| `next.config.js` | Next.js |
| `Cargo.toml` | Rust |
| `pom.xml` | Java |
| `build.gradle.kts` | Kotlin |
| `Package.swift` | Swift |
| `pyproject.toml` | Python |
| `manage.py` | Django |
| `composer.json` | PHP/Laravel |
| `CMakeLists.txt` | C++ |
| `Dockerfile` | Docker |
| `AndroidManifest.xml` | Android |

## Cara Pakai

### Via OpenCode

```
/analyze-project
```

### Via Script

```powershell
.\scripts\analyze-project.ps1
```

## Output

```
[1/5] Locating project root...
  Project: C:\Users\...\my-flutter-app

[2/5] Scanning for indicators...
  Found: pubspec.yaml

[3/5] Detected stack: dart-flutter (100% confidence)

[4/5] Loading skills...
  Core: tdd-workflow, security-review, coding-standards, verification-loop
  Project: dart-flutter-patterns
  Rules: common, dart

[5/5] Config generated
```

## Skills per Stack

### dart-flutter
- Core: tdd-workflow, security-review, coding-standards, verification-loop
- Project: dart-flutter-patterns
- Rules: common, dart

### golang
- Core: tdd-workflow, security-review, coding-standards, verification-loop
- Project: golang-patterns, golang-testing
- Rules: common, golang

### react
- Core: tdd-workflow, security-review, coding-standards, verification-loop
- Project: frontend-patterns, react-patterns, react-performance, react-testing, accessibility
- Rules: common, typescript, web, react

### python
- Core: tdd-workflow, security-review, coding-standards, verification-loop
- Project: python-patterns, python-testing
- Rules: common, python

### rust
- Core: tdd-workflow, security-review, coding-standards, verification-loop
- Project: rust-patterns, rust-testing
- Rules: common, rust

### Lengkapnya

Lihat [Skill Selection](../05-skills/01-skill-selection.md) untuk daftar lengkap.

## Config Overwrite

Jika config sudah ada:

```
Config already exists:
  Current model: 9router/gratis
  Detected stack: dart-flutter

  [1] Overwrite (apply detected stack)
  [2] Keep current
  [3] Merge (add project skills)
  Pilih (1/2/3):
```

## Lihat Juga

- [Skill Selection](../05-skills/01-skill-selection.md) — Cara memilih skills
- [Skills Catalog](../06-catalogs/02-skills.md) — Katalog lengkap
