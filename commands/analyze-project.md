---
description: Analyze project and load appropriate skills
agent: build
---

# Analyze Project

Jalankan analisis project untuk detect stack dan load skills yang sesuai.

## Instructions

1. Jalankan script berikut (set project dulu atau kasih -ProjectPath):
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\analyze-project.ps1 -ProjectPath "C:\path\to\project"
```

Atau kalau sudah pakai session:
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\analyze-project.ps1
```

2. Script akan:
   - Scan project root (1 level up dari opencode-setup)
   - Detect stack (Flutter, Go, React, etc.)
   - Load core skills + project-specific skills
   - Generate config

3. Review output

4. Setelah selesai, restart OpenCode (Ctrl+C, lalu `opencode`) untuk apply config baru

## Detected Stacks

| Stack | Indicators | Skills |
|-------|-----------|--------|
| dart-flutter | pubspec.yaml | dart-flutter-patterns |
| golang | go.mod | golang-patterns, golang-testing |
| javascript | package.json | frontend-patterns |
| typescript | tsconfig.json | frontend-patterns, backend-patterns |
| nextjs | next.config.js | frontend-patterns, backend-patterns |
| rust | Cargo.toml | rust-patterns, rust-testing |
| java | pom.xml | java-coding-standards, jpa-patterns |
| kotlin | build.gradle.kts | kotlin-patterns, kotlin-testing |
| swift | Package.swift | swiftui-patterns, swift-concurrency-6-2 |
| python | pyproject.toml | python-patterns, python-testing |
| django | manage.py | django-patterns, django-tdd |
| php-laravel | composer.json | laravel-patterns, laravel-tdd |
| cpp | CMakeLists.txt | cpp-coding-standards, cpp-testing |
| docker | Dockerfile | docker-patterns, deployment-patterns |
| android | AndroidManifest.xml | android-clean-architecture, kotlin-patterns |

## Task

$ARGUMENTS
