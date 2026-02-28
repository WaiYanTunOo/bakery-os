# bakery_os

> **Security Notice:** This project now uses Supabase Auth email/password login and role-scoped UI guards. Before production deploy:
> 
> 1. Configure RLS rules in Supabase to enforce role-based access control.
> 2. Configure JWT claims (`app_role`, `staff_name`, optional `staff_id`) for every staff auth user.
> 3. Only select necessary columns (see `lib/services/supabase_service.dart`).
> 4. Store sensitive keys in a `.env` file and do **not** commit it (see `.env.example`).

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

### Auth-to-Staff Binding (Safer Onboarding + Audit)

Apply `supabase/production_auth_staff_binding.sql` after base schema and production hardening scripts.

It adds:

- `staff_auth_bindings`: one active mapping between `auth.users.id` and `staff_directory.id`
- `staff_auth_binding_audit`: append-only trail for onboarding/rebinding actions
- `v_staff_auth_active_with_last_audit`: read-only view of active mappings + latest audit action
- `get_staff_auth_audit_report(role, email, from_date, to_date, limit)`: backend-only filtered reporting function
- `bind_auth_user_to_staff(...)`: secure function (service role only) for controlled linking
- `deactivate_staff_auth_binding(...)`: secure offboarding unlink with mandatory audit reason

Recommended onboarding flow:

1. Create/confirm staff record in `staff_directory` (with correct role).
2. Create Supabase Auth user (email/password or invite).
3. Call `bind_auth_user_to_staff(auth_user_id, staff_id, email, performed_by, reason)` via backend/service-role context.
4. Set JWT claims from the bound record (`app_role`, `staff_name`, `staff_id`) so app/UI and RLS are aligned.
5. Review `v_staff_auth_active_with_last_audit` and `staff_auth_binding_audit` for compliance checks.

Recommended offboarding flow:

1. Call `deactivate_staff_auth_binding(performed_by, reason, staff_id, auth_user_id)` from backend/service-role context.
2. Verify return value > 0 (active binding(s) were deactivated).
3. Confirm an `unlink` record exists in `staff_auth_binding_audit` with the reason.

Reporting example (backend/service-role context): `select * from public.get_staff_auth_audit_report('FH', null, current_date - 30, current_date, 200);`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
