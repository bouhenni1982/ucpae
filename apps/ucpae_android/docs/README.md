# UCPAE Android App

هذا التطبيق هو نسخة Android فقط من UCPAE.

## يعتمد على

- `../../packages/ucpae_core`
- `AccessibilityService`
- `flutter_tts`
- `liblua.so`

## التشغيل

1. نفّذ `flutter pub get`
2. ضع `liblua.so` داخل `android/app/src/main/jniLibs/...`
3. شغّل التطبيق
4. فعّل خدمة الوصولية من النظام

## الملفات المهمة

- `lib/src/android_app.dart`
- `lib/src/android_accessibility_bridge.dart`
- `android/app/src/main/kotlin/com/example/ucpae_android/accessibility/UcpaeAccessibilityService.kt`
