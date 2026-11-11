# Design decisions

## 2026-11-11 Cable length representation
Cable (and any length item) uses the metre as its display unit, stored as an **integer number of millimetres** in base units (0.5 m = 500, 2.5 m = 2500). Reason: shop sells fractions such as 0.5 m and 2.5 m; integers avoid floating-point errors in stock maths.

## 2026-11-11 GST rounding
GST is rounded **per line** (to the nearest paisa), and the invoice tax is the sum of rounded line taxes. Reason: standard billing practice, matches per-line HSN reporting.

## 2026-11-11 Printer
The shop has no thermal printer yet. A5 is limited to PDF generation and sharing; Bluetooth thermal printing is deferred until a printer is bought.

## 2026-11-11 Riverpod pinned to 2.x
Installed Flutter is 3.29 (Dart 3.7). flutter_riverpod 3.x and drift_dev could not be resolved together on that SDK, so flutter_riverpod is pinned to ^2.6.1. Revisit if Flutter is upgraded.

## 2026-11-11 Gradle heap reduced
Default -Xmx8G caused a JVM crash (access violation in jvm.dll) on a 15 GB dev PC during first Android build. Set to -Xmx3G / Metaspace 1G in app/android/gradle.properties.

## 2026-11-11 Kotlin Gradle plugin bumped to 2.1.0
mobile_scanner 7.5.0 failed to build on the template's Kotlin 1.8.22 (unresolved compilerOptions). Bumped in app/android/settings.gradle.kts.

## 2026-11-11 Android Gradle plugin 8.9.1, Gradle 8.11.1, compileSdk 36
Latest androidx libs pulled in by plugins (core 1.18.0) require AGP >= 8.9.1 and compileSdk 36. Updated settings.gradle.kts, gradle-wrapper.properties and app/build.gradle.kts.

## 2026-11-11 NDK 27 and core library desugaring
Plugins require NDK 27.0.12077973 and flutter_local_notifications requires core library desugaring (desugar_jdk_libs 2.1.4). Set in app/build.gradle.kts.

## 2026-11-11 minSdk 23
mobile_scanner requires minSdk 23 (Android 6.0). App will not install on older phones.
