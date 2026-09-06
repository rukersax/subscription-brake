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
