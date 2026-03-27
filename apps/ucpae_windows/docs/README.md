# UCPAE Windows App

هذا التطبيق هو نسخة Windows فقط من UCPAE.

## يعتمد على

- `../../packages/ucpae_core`
- Windows UI Automation worker
- `flutter_tts`
- `lua54.dll`

## التشغيل

1. نفّذ `flutter pub get`
2. ضع `lua54.dll` في مسار التحميل المناسب
3. ابنِ العامل `Ucpae.AccessibilityWorker`
4. شغّل التطبيق

## الملفات المهمة

- `lib/src/windows_app.dart`
- `lib/src/windows_accessibility_bridge.dart`
- `windows/worker/Ucpae.AccessibilityWorker/`
