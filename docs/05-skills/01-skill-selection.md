# Skill Selection — Cara Memilih Skills

## Prinsip

**Hybrid approach:**
- Core skills → selalu di-load (untuk semua project)
- Project skills → berdasarkan stack yang terdeteksi

## Core Skills (Selalu Di-load)

| Skill | Fungsi |
|-------|--------|
| `tdd-workflow` | Test-driven development |
| `security-review` | Security checklist |
| `coding-standards` | Konvensi coding |
| `verification-loop` | Build, type, lint, test |

## Project Skills (Berdasarkan Stack)

### Dart/Flutter
```yaml
project: dart-flutter-patterns
rules: common, dart
```

### Go
```yaml
project: golang-patterns, golang-testing
rules: common, golang
```

### React
```yaml
project: frontend-patterns, react-patterns, react-performance, react-testing, accessibility
rules: common, typescript, web, react
```

### Next.js
```yaml
project: frontend-patterns, backend-patterns, nextjs-turbopack
rules: common, typescript, web, react
```

### Python
```yaml
project: python-patterns, python-testing
rules: common, python
```

### Rust
```yaml
project: rust-patterns, rust-testing
rules: common, rust
```

### Java
```yaml
project: java-coding-standards, jpa-patterns
rules: common, java
```

### Spring Boot
```yaml
project: springboot-patterns, springboot-tdd, springboot-verification, springboot-security
rules: common, java
```

### Kotlin
```yaml
project: kotlin-patterns, kotlin-testing, kotlin-coroutines-flows
rules: common, kotlin
```

### Swift
```yaml
project: swiftui-patterns, swift-concurrency-6-2, swift-actor-persistence, swift-protocol-di-testing
rules: common, swift
```

### PHP/Laravel
```yaml
project: laravel-patterns, laravel-tdd, laravel-verification, laravel-security
rules: common, php
```

### C++
```yaml
project: cpp-coding-standards, cpp-testing
rules: common, cpp
```

### Django
```yaml
project: django-patterns, django-tdd, django-verification, django-security
rules: common, python
```

### Android
```yaml
project: android-clean-architecture, kotlin-patterns, compose-multiplatform-patterns
rules: common, kotlin
```

### Docker
```yaml
project: docker-patterns, deployment-patterns
rules: common
```

## Manual Skill Selection

Jika tidak ingin auto-detect, bisa pilih manual:

```jsonc
// opencode.jsonc
{
  "instructions": [
    "C:/path/to/ecc/skills/tdd-workflow/SKILL.md",
    "C:/path/to/ecc/skills/security-review/SKILL.md",
    "C:/path/to/ecc/skills/dart-flutter-patterns/SKILL.md"
  ]
}
```

## Lihat Juga

- [Analyze Project](../04-usage/04-analyze-project.md) — Auto-detect
- [Skills Catalog](../06-catalogs/02-skills.md) — Katalog 270 skills
