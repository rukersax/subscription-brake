#!/usr/bin/env python3
import os
import re
import sys

def patch_file(target_dir="."):
    app_dir = os.path.join(target_dir, "android", "app")
    if not os.path.exists(app_dir):
        print(f"[Patch] Android app directory not found at {app_dir}")
        return

    kts_path = os.path.join(app_dir, "build.gradle.kts")
    groovy_path = os.path.join(app_dir, "build.gradle")

    if os.path.exists(kts_path):
        print(f"[Patch] Found {kts_path}, applying desugaring & minSdk configuration...")
        with open(kts_path, "r", encoding="utf-8") as f:
            content = f.read()

        # 1. Ensure minSdk is 21+
        content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 21', content)
        content = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 21', content)

        # 2. Add multiDexEnabled = true
        if "multiDexEnabled" not in content and "defaultConfig {" in content:
            content = content.replace("defaultConfig {", "defaultConfig {\n        multiDexEnabled = true")

        # 3. Enable isCoreLibraryDesugaringEnabled
        if "isCoreLibraryDesugaringEnabled" not in content and "coreLibraryDesugaringEnabled" not in content:
            if "compileOptions {" in content:
                content = content.replace(
                    "compileOptions {",
                    "compileOptions {\n        isCoreLibraryDesugaringEnabled = true"
                )
            elif "android {" in content:
                content = content.replace(
                    "android {",
                    "android {\n    compileOptions {\n        isCoreLibraryDesugaringEnabled = true\n        sourceCompatibility = JavaVersion.VERSION_1_8\n        targetCompatibility = JavaVersion.VERSION_1_8\n    }"
                )

        # 4. Add coreLibraryDesugaring dependency
        if "desugar_jdk_libs" not in content:
            if "dependencies {" in content:
                content = content.replace(
                    "dependencies {",
                    'dependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")'
                )
            else:
                content += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'

        with open(kts_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[Patch] Successfully patched Kotlin DSL: {kts_path}")

    if os.path.exists(groovy_path):
        print(f"[Patch] Found {groovy_path}, applying desugaring & minSdk configuration...")
        with open(groovy_path, "r", encoding="utf-8") as f:
            content = f.read()

        # 1. Ensure minSdk is 21+
        content = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 21', content)
        content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 21', content)

        # 2. Add multiDexEnabled true
        if "multiDexEnabled" not in content and "defaultConfig {" in content:
            content = content.replace("defaultConfig {", "defaultConfig {\n        multiDexEnabled true")

        # 3. Enable coreLibraryDesugaringEnabled
        if "coreLibraryDesugaringEnabled" not in content:
            if "compileOptions {" in content:
                content = content.replace(
                    "compileOptions {",
                    "compileOptions {\n        coreLibraryDesugaringEnabled true"
                )
            elif "android {" in content:
                content = content.replace(
                    "android {",
                    "android {\n    compileOptions {\n        coreLibraryDesugaringEnabled true\n        sourceCompatibility JavaVersion.VERSION_1_8\n        targetCompatibility JavaVersion.VERSION_1_8\n    }"
                )

        # 4. Add coreLibraryDesugaring dependency
        if "desugar_jdk_libs" not in content:
            if "dependencies {" in content:
                content = content.replace(
                    "dependencies {",
                    "dependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'"
                )
            else:
                content += "\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'\n}\n"

        with open(groovy_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[Patch] Successfully patched Groovy DSL: {groovy_path}")

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "."
    patch_file(target)
