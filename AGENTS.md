# Project Instructions for Subscription Brake

## Critical Development Rules

1. **Localization (`tr`) Scope Discipline**:
   - Whenever referencing localized strings using `tr.<propertyName>`, always ensure `tr` is defined and in scope.
   - For separate helper methods, private builder functions (e.g. `_buildCustomFormTab(AppStrings tr)`), or modal bottom sheets (e.g. `_showSubscriptionDetailsModal`), always pass `tr` explicitly or obtain it via `ref.read(stringsProvider)`.
   - Never reference `tr` in a method without verifying its parameter or local declaration.

2. **Folder Synchronization**:
   - The workspace maintains both `/lib` and `/frontend/lib`.
   - Any modifications made to `/lib` must be mirrored to `/frontend/lib` (`cp -rf lib/. frontend/lib/`).

3. **Compilation & Quality Check**:
   - Always run `compile_applet` after every batch of changes to verify that the app compiles cleanly with zero syntax or missing symbol errors before completing a task.

4. **Android & Desugaring Requirement**:
   - `flutter_local_notifications` requires `coreLibraryDesugaringEnabled` and `desugar_jdk_libs:2.1.4` along with `multiDexEnabled` and `minSdk 21`.
   - The `.github/workflows/build_apk.yml` and `scripts/patch_android.py` must maintain this configuration.
