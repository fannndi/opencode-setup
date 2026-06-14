# Template: Flutter + Firebase

## Stack
- **Language:** Dart
- **Framework:** Flutter
- **Backend:** Firebase (Firestore, Auth, Functions)
- **State Management:** BLoC / Riverpod

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── routes.dart
│   ├── themes.dart
│   └── constants.dart
├── core/
│   ├── errors/
│   │   └── failures.dart
│   ├── usecases/
│   │   └── usecase.dart
│   └── utils/
│       └── extensions.dart
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
test/
├── features/
│   └── [feature_name]/
│       ├── data/
│       ├── domain/
│       └── presentation/
```

## Docs Structure

```
docs/
├── frontend/
│   ├── architecture.md          # Arsitektur Flutter
│   ├── state-management.md      # Pilihan state management
│   ├── navigation.md            # Routing strategy
│   └── widgets.md               # Widget library
├── backend/
│   ├── firebase-config.md       # Setup Firebase
│   ├── firestore-schema.md      # Database schema
│   ├── auth.md                  # Authentication flow
│   └── cloud-functions.md       # Serverless functions
└── database/
    └── firestore-rules.md       # Security rules
```

## Skills to Load

- `dart-flutter-patterns` — Flutter patterns
- `tdd-workflow` — TDD
- `security-review` — Security
- `coding-standards` — Standards
- `verification-loop` — Verification

## Rules

- `common` — Universal
- `dart` — Dart/Flutter conventions

## Agents

| Agent | Use |
|-------|-----|
| tdd-guide | Write tests first |
| code-reviewer | Review widget code |
| security-reviewer | Firebase security rules |
| build-error-resolver | Fix Flutter build errors |
