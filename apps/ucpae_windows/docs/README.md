# UCPAE Windows App

هذا التطبيق هو نسخة Windows فقط من UCPAE.

## يعتمد على

- `../../packages/ucpae_core`
- Windows UI Automation worker
- `flutter_tts`
- `lua54.dll`

## التشغيل المحلي

1. نفّذ `flutter pub get`
2. ضع `lua54.dll` في مسار التحميل المناسب أو بجانب التطبيق
3. ابنِ العامل `Ucpae.AccessibilityWorker`
4. شغّل التطبيق

## GitHub Actions

يوجد workflow مخصص لبناء نسخة Windows على GitHub:

- `.github/workflows/build-windows-app.yml`

هذا المسار يقوم بـ:

- تنزيل مصدر Lua الرسمي
- بناء `lua54.dll`
- بناء عامل الوصولية
- بناء تطبيق Flutter Windows
- نسخ `lua54.dll` والعامل داخل الـ bundle النهائي
- رفع الناتج كـ artifact

## الملفات المهمة

- `lib/src/windows_app.dart`
- `lib/src/windows_accessibility_bridge.dart`
- `windows/worker/Ucpae.AccessibilityWorker/`
