# UCPAE Monorepo Structure

تمت إعادة هيكلة المشروع إلى تطبيقين مستقلين مع نواة مشتركة، حتى لا يحمل كل إصدار ملفات المنصة الأخرى.

## البنية الجديدة

- `packages/ucpae_core`
  نواة مشتركة تحتوي:
  - نماذج `ScreenEvent` و `LuaCommand`
  - ربط Lua الحقيقي عبر FFI
  - ملفات Lua والقواعد والإضافات

- `apps/ucpae_android`
  تطبيق Android مستقل يحتوي:
  - Flutter UI للأندرويد
  - `AccessibilityService`
  - TTS Android
  - تحميل `liblua.so`

- `apps/ucpae_windows`
  تطبيق Windows مستقل يحتوي:
  - Flutter UI لويندوز
  - Windows worker عبر UI Automation
  - TTS Windows
  - تحميل `lua54.dll`

## GitHub Actions

- `.github/workflows/ci.yml`
  يتحقق من تنسيق Dart، يجلب الاعتمادات، يحلل التطبيقين، ويبني عامل Windows.

- `.github/workflows/packaging-assets.yml`
  ينشر عامل Windows كـ artifact ويرفع ملفات Lua المشتركة.

- `.github/workflows/native-libs-check.yml`
  يتحقق من وجود المسارات المتوقعة للمكتبات الأصلية.

## السكربتات الجاهزة

- `scripts/bootstrap.ps1`
  يجلب الاعتمادات للتطبيقين.

- `scripts/prepare-lua-libs.ps1`
  ينسخ `lua54.dll` و `liblua.so` إلى أماكنها الصحيحة.

- `scripts/build-windows-worker.ps1`
  يبني عامل Windows، ويمكنه تشغيل Flutter بعد البناء.

- `scripts/dev-android.ps1`
  يبدأ تطوير Android.

- `scripts/dev-windows.ps1`
  يبدأ تطوير Windows.

## لماذا هذا أفضل للحجم

- تطبيق Android لا يشحن ملفات Windows أو عامل C#.
- تطبيق Windows لا يشحن ملفات Android أو `jniLibs`.
- المنطق الحقيقي يبقى مرة واحدة فقط داخل `ucpae_core`.
- تحديث قواعد Lua يتم في مكان واحد ويستفيد منه التطبيقان.

## مسار التطوير

### Android

اعمل داخل:

`apps/ucpae_android`

### Windows

اعمل داخل:

`apps/ucpae_windows`

### Shared logic

اعمل داخل:

`packages/ucpae_core`

## التشغيل المتوقع

### Android

- شغّل `scripts/bootstrap.ps1 -Android`
- استخدم `scripts/prepare-lua-libs.ps1` إذا كانت ملفات Lua الأصلية خارج المشروع
- شغّل `scripts/dev-android.ps1`
- فعّل خدمة الوصولية من النظام

### Windows

- شغّل `scripts/bootstrap.ps1 -Windows`
- استخدم `scripts/prepare-lua-libs.ps1`
- شغّل `scripts/build-windows-worker.ps1`
- شغّل `scripts/dev-windows.ps1`

## ملاحظة مهمة

الـ GitHub Actions الحالية مناسبة جدًا للتحقق المستمر وبناء عامل Windows ورفع artifacts، لكنها لا تبني حتى الآن حزمة Flutter النهائية لكل منصة لأن هذا يتطلب Flutter runner/scaffold مكتملًا داخل كل تطبيق. الملفات القديمة في الجذر تُركت كمرجع مرحلي، لكن المسار المعتمد الآن هو `apps/` و `packages/`.
