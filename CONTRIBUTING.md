# Contributing

## Development Model

This repository is organized as a small monorepo:

- `packages/ucpae_core` for shared logic
- `apps/ucpae_android` for Android-specific integration
- `apps/ucpae_windows` for Windows-specific integration

## General Rules

- Keep shared logic in `packages/ucpae_core` whenever possible.
- Put platform hooks only in the relevant app.
- Do not commit native Lua binaries such as `lua54.dll` or `liblua.so`.
- Keep Arabic documentation updated when architecture changes significantly.

## Before Opening a Pull Request

Run what is relevant locally:

```powershell
./scripts/bootstrap.ps1
```

Then check:

```powershell
cd apps/ucpae_android
flutter analyze

cd ../../apps/ucpae_windows
flutter analyze
```

For Windows worker changes:

```powershell
./scripts/build-windows-worker.ps1
```

## Pull Request Scope

- Prefer small focused pull requests.
- Include a short summary of user-visible impact.
- Mention whether the change affects Android, Windows, or shared logic.

## Documentation

If you change architecture, workflows, or setup steps, update:

- `README.md`
- `docs/explanation_ar.md`
