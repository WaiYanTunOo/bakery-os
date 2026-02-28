# bakery_os

> **Security Notice:** This project uses Supabase with permissive row-level security (RLS) policies for development. Before production deploy:
> 
> 1. Configure RLS rules in Supabase to enforce role-based access control.
> 2. Only select necessary columns (see `lib/services/supabase_service.dart`).
> 3. Store sensitive keys in a `.env` file and do **not** commit it (see `.env.example`).

A new Flutter project.

## Configuration & Secrets

This app requires Supabase credentials:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Production Recommended

Use build-time defines in CI/CD:

```bash
flutter run \
	--dart-define=SUPABASE_URL=https://your-project.supabase.co \
	--dart-define=SUPABASE_ANON_KEY=your_anon_key
```

### Development

You can use a local `.env` file (already git-ignored) based on `.env.example`.
On native platforms, valid credentials are also persisted with `flutter_secure_storage`.

If credentials are missing or invalid, startup now fails safely with an explicit
configuration error screen rather than running in a partially broken state.

## Continuous Integration

This repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs on every push or pull request. It performs the following checks:

1. `flutter analyze` to enforce static analysis rules.
2. `flutter test` to execute widget/unit tests.
3. A basic secret scan that fails if a `.env` file is committed or if common key patterns (e.g. `SUPABASE_`, `API_KEY`, `SECRET`) are detected in the source.

Keep the workflow up‑to‑date and extend it as needed for linting, formatting, or other quality gates.

## Database Hardening (Production)

For production database protections aligned with app-side guards, apply:

- `supabase/schema.sql` (base schema)
- `supabase/production_hardening.sql` (strict constraints + RLS templates)

The hardening script includes:

- status/role check constraints (`pending|verified`, `pending|delivered`, `FH|BH|Owner`)
- non-negative/shape checks for financial and JSON fields
- production RLS policy templates for role-based access using JWT claims

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
