# شرح UCPAE بالعربية

## هل يمكن تقسيم التطبيق إلى تطبيقين؟

نعم، وهذا ما تم عمله هنا.
بدل أن يكون هناك مشروع واحد ضخم يحتوي Android وWindows معًا، أصبح لدينا تطبيقان مستقلان يشتركان في نفس منطق الوصولية.

## البنية الجديدة

### 1. النواة المشتركة

المسار:

`packages/ucpae_core`

هذه النواة تحتوي على:

- `ScreenEvent`
- `LuaCommand`
- `LuaBindings`
- `LuaRuntimeEngine`
- ملفات Lua داخل `assets/lua`

هذا يعني أن منطق الإعلان والوصولية مكتوب مرة واحدة فقط.

### 2. تطبيق Android

المسار:

`apps/ucpae_android`

يحتوي على:

- واجهة Flutter خاصة بالأندرويد
- `AndroidAccessibilityBridge`
- `UcpaeAccessibilityService.kt`
- خدمة TTS للأندرويد
- مجلدات `jniLibs` الخاصة بمكتبة Lua

### 3. تطبيق Windows

المسار:

`apps/ucpae_windows`

يحتوي على:

- واجهة Flutter خاصة بويندوز
- `WindowsAccessibilityBridge`
- العامل `Ucpae.AccessibilityWorker`
- خدمة TTS لويندوز
- مجلد مكتبة `lua54.dll`

## كيف يشتركان في نفس المنطق؟

كل تطبيق يعتمد على نفس الحزمة المشتركة عبر `path dependency`:

- `apps/ucpae_android/pubspec.yaml`
- `apps/ucpae_windows/pubspec.yaml`

وكلاهما يستورد:

`package:ucpae_core/ucpae_core.dart`

وبذلك عندما تغيّر قاعدة Lua أو منطق التعامل مع الحدث، يكفي تعديل `ucpae_core` فقط.

## السكربتات التي أضفتها

- `scripts/bootstrap.ps1`
  لجلب الاعتمادات من الجذر.

- `scripts/prepare-lua-libs.ps1`
  لنسخ `lua54.dll` و `liblua.so` إلى أماكنها المتوقعة.

- `scripts/build-windows-worker.ps1`
  لبناء عامل Windows.

- `scripts/dev-android.ps1`
  لتشغيل تطبيق Android بسرعة.

- `scripts/dev-windows.ps1`
  لتشغيل تطبيق Windows بسرعة.

## إعدادات GitHub Actions التي أضفتها

- `.github/workflows/ci.yml`
  هذا المسار ينفذ التحقق المستمر.
  يقوم بـ:
  - تنزيل الكود
  - تثبيت Flutter
  - تنفيذ `flutter pub get`
  - فحص التنسيق `dart format`
  - تنفيذ `flutter analyze`
  - بناء عامل Windows عبر .NET

- `.github/workflows/packaging-assets.yml`
  هذا المسار يرفع artifacts مفيدة:
  - عامل Windows بعد `dotnet publish`
  - ملفات Lua المشتركة

- `.github/workflows/native-libs-check.yml`
  هذا المسار يتأكد فقط من وجود أماكن المكتبات الأصلية داخل الشجرة.

## لماذا هذا أنسب للحجم؟

إذا أبقيت كل شيء داخل تطبيق واحد، فسيحدث غالبًا واحد أو أكثر من الآتي:

- زيادة في التعقيد التنظيمي
- صعوبة في التغليف packaging
- احتمال حمل ملفات أو إعدادات لا تخص المنصة الحالية
- تشابك بين منطق Android ومنطق Windows

أما بعد الفصل:

- Android يبني Android فقط
- Windows يبني Windows فقط
- النواة تبقى صغيرة ومشتركة
- الصيانة أسهل والتوزيع أوضح

## أين يوجد مفسر Lua الحقيقي الآن؟

داخل:

`packages/ucpae_core/lib/src/services/lua_runtime_engine.dart`

هذا الملف يستخدم `Dart FFI` للوصول مباشرة إلى Lua C API.
أي أن التطبيقين لا يعيدان كتابة المحرك، بل كلاهما يشتركان في نفس المحرك.

## مثال تدفق الحدث بعد إعادة الهيكلة

### Android

1. المستخدم يضغط زرًا.
2. `UcpaeAccessibilityService` يلتقط الحدث.
3. `AndroidAccessibilityBridge` يحوله إلى `ScreenEvent`.
4. `LuaRuntimeEngine` في `ucpae_core` يعالج الحدث.
5. يعود `LuaCommand` بالنص المنطوق.
6. TTS في تطبيق Android ينطق النص.

### Windows

1. يتغير التركيز Focus.
2. عامل `Ucpae.AccessibilityWorker` يلتقط الحدث.
3. `WindowsAccessibilityBridge` يقرأ JSON ويحوله إلى `ScreenEvent`.
4. `LuaRuntimeEngine` في `ucpae_core` يعالج الحدث.
5. يعود `LuaCommand` بالنص المنطوق.
6. TTS في تطبيق Windows ينطق النص.

## كيف تبدأ الآن؟

### Android

1. شغّل `scripts/bootstrap.ps1 -Android`
2. جهّز `liblua.so`
3. شغّل `scripts/dev-android.ps1`

### Windows

1. شغّل `scripts/bootstrap.ps1 -Windows`
2. جهّز `lua54.dll`
3. شغّل `scripts/build-windows-worker.ps1`
4. شغّل `scripts/dev-windows.ps1`

## ملاحظة مهمة

إعدادات GitHub Actions الحالية قوية كمرحلة CI/CD أولى، لكنها لا تبني بعد تطبيق Flutter النهائي لكل منصة لأن كل تطبيق ما زال يحتاج Flutter runner/scaffold الكامل الذي ينتجه عادة `flutter create`. لذلك ما تم تجهيزه الآن مناسب جدًا للتحقق، التحليل، بناء عامل Windows، ورفع artifacts المشتركة.

## ما الذي يجب العمل عليه لاحقًا؟

- توليد Flutter scaffold الكامل داخل `apps/ucpae_android` و `apps/ucpae_windows`
- إضافة build فعلي لـ APK أو AppBundle
- إضافة build فعلي لتطبيق Windows النهائي
- إعداد نسخ تلقائي بعد build داخل Windows runner النهائي
- إعداد تضمين تلقائي لـ `liblua.so` في Android
- إضافة اختبارات على مستوى `ucpae_core` لأن هذه الطبقة أصبحت القلب المشترك

## الخلاصة

نعم، تقسيم التطبيق إلى تطبيقين مستقلين هو خيار ممتاز هنا، وقد أعدت تنظيم المشروع على هذا الأساس بالفعل. بهذه الطريقة تحافظ على نفس منطق الوصولية وLua، وتقلل الحجم والتشابك لكل منصة.
