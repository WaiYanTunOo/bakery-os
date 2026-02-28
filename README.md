# bakery_os

> **Security Notice:** This project uses Supabase with permissive row-level security (RLS) policies for development. Before production deploy:
> 
> 1. Configure RLS rules in Supabase to enforce role-based access control.
> 2. Only select necessary columns (see `lib/services/supabase_service.dart`).
> 3. Store sensitive keys in a `.env` file and do **not** commit it (see `.env.example`).

A new Flutter project.

## Continuous Integration

This repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs on every push or pull request. It performs the following checks:

1. `flutter analyze` to enforce static analysis rules.
2. `flutter test` to execute widget/unit tests.
3. A basic secret scan that fails if a `.env` file is committed or if common key patterns (e.g. `SUPABASE_`, `API_KEY`, `SECRET`) are detected in the source.

Keep the workflow up‑to‑date and extend it as needed for linting, formatting, or other quality gates.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
