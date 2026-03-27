# UCPAE

Unified Cross-Platform Accessibility Engine.

UCPAE is a screen reader architecture prototype that combines:

- `Flutter` for UI and settings
- `Lua` for shared announcement logic and user extensions
- `Kotlin` for Android accessibility hooks
- `C#` for Windows UI Automation hooks

## Vision

Build two independent apps, one for Android and one for Windows, while keeping the accessibility logic shared in a single core package.

This keeps each app smaller and easier to maintain:

- Android ships Android-specific code only
- Windows ships Windows-specific code only
- Lua rules and event-processing logic stay shared

## Monorepo Layout

- `packages/ucpae_core`
  Shared models, Lua FFI runtime, and Lua rules.
- `apps/ucpae_android`
  Android Flutter app, official Android scaffold, `AccessibilityService`, Android TTS, and `liblua.so` integration.
- `apps/ucpae_windows`
  Windows Flutter app, official Windows scaffold, UI Automation worker, Windows TTS, and `lua54.dll` integration.
- `scripts`
  Bootstrap, native library preparation, local Android Lua build, and development helpers.
- `.github/workflows`
  CI, packaging, and Windows build workflows for the monorepo.

## Current Status

What is already in place:

- Shared `LuaRuntimeEngine` through Dart FFI
- Shared Lua rules and extension structure
- Official Flutter scaffold for both Android and Windows apps
- Android accessibility bridge prototype
- Windows worker prototype for UI Automation
- GitHub Actions for CI, worker build, shared artifacts, analysis, tests, and Windows app build
- Local `flutter analyze` passes for both apps
- Local `flutter test` passes for both apps
- Local Android `app-debug.apk` build succeeds after generating `liblua.so`

What still needs completion for full production builds:

- Final signed Android release pipeline
- Verification of the Windows GitHub Action bundle on the first CI run
- Automatic native library bundling for tagged releases
- End-to-end on-device accessibility validation

## Quick Start

### 1. Bootstrap dependencies

```powershell
./scripts/bootstrap.ps1
```

### 2. Build Android Lua libraries locally

```powershell
./scripts/build-lua-android.ps1
```

### 3. Build Android locally

```powershell
./scripts/build-android.ps1
```

### 4. Prepare native Lua libraries manually if needed

```powershell
./scripts/prepare-lua-libs.ps1 `
  -WindowsLuaDll C:\path\to\lua54.dll `
  -AndroidArm64So C:\path\to\arm64-v8a\liblua.so `
  -AndroidArmv7So C:\path\to\armeabi-v7a\liblua.so `
  -AndroidX64So C:\path\to\x86_64\liblua.so
```

### 5. Run local development

Android:

```powershell
./scripts/dev-android.ps1
```

Windows:

```powershell
./scripts/build-windows-worker.ps1
./scripts/dev-windows.ps1
```

## GitHub Actions

- [ci.yml](./.github/workflows/ci.yml)
  Runs dependency resolution, format checks, Flutter analysis, Flutter tests, and Windows worker build.
- [packaging-assets.yml](./.github/workflows/packaging-assets.yml)
  Publishes the Windows worker and shared Lua assets as artifacts.
- [native-libs-check.yml](./.github/workflows/native-libs-check.yml)
  Verifies expected native library directories exist.
- [build-windows-app.yml](./.github/workflows/build-windows-app.yml)
  Downloads official Lua source, builds `lua54.dll`, builds the Windows worker, builds the Flutter Windows app, bundles the worker and DLL, and uploads the final Windows app artifact.

## Arabic Documentation

Arabic technical explanation is available in:

- [docs/explanation_ar.md](./docs/explanation_ar.md)

## Notes

- Native Lua binaries are intentionally not committed to the repository.
- Downloaded Lua source used for local builds is kept out of git.
- CI validates code structure and now includes a dedicated Windows app build workflow.

## License

No license file has been added yet. Add one before public redistribution.
