# A0: Scaffold

**Status:** done (2026-11-11). **Commit:** `fb7611e chore: project scaffold`.

## Purpose
Get an empty but working Flutter Android app onto a real phone, with the repo, folders and
packages the plan calls for, so every later milestone starts from a known-good base.

## What was built
- Git repo `shop-app/` with `.gitignore` (excludes `.env`, sample invoices, build output).
- `AGENTS.md` (the build plan), `docs/decisions.md` (decision log), `docs/sample_invoices/` (kept local).
- Flutter project in `app/` (Android only, org `com.pravinelectricals`, project `shop_app`).
- All packages from plan section 6.6 (Drift, Riverpod, dio, mobile_scanner, pdf, printing,
  flutter_local_notifications, workmanager, local_auth, camera, image_picker and others).
- Private GitHub repo: https://github.com/Panubhati/Pravin_electricals

## Environment this was built on
| Item | Version |
|---|---|
| Flutter / Dart | 3.29.0 / 3.7.0 |
| Android SDK | 36 (build-tools 35.0.1) |
| JDK | Android Studio's bundled JDK 21 |
| Test phone | Samsung SM A356E, Android 16 |

## Build fixes that were needed (all logged in `decisions.md`)
Flutter 3.29's project template is older than the latest plugin versions, so the Android build
config was updated:

| Change | Why |
|---|---|
| Gradle heap 8 GB to 3 GB | the Gradle JVM crashed on a 15 GB PC |
| Kotlin plugin 1.8.22 to 2.1.0 | `mobile_scanner` needs it |
| Android Gradle plugin 8.9.1, Gradle 8.11.1, compileSdk 36 | newer AndroidX libraries need them |
| NDK 27, core library desugaring on | plugins and `flutter_local_notifications` need them |
| minSdk 23 (Android 6.0) | `mobile_scanner` needs it |
| `flutter_riverpod` pinned to 2.6.1 | 3.x cannot resolve with `drift_dev` on Dart 3.7 |

Files: `app/android/settings.gradle.kts`, `app/android/gradle.properties`,
`app/android/gradle/wrapper/gradle-wrapper.properties`, `app/android/app/build.gradle.kts`.

## How to verify
```bash
cd app
flutter test
flutter run        # phone connected, USB debugging on
```

## Known limits
- Android only (no iOS), by design.
- Upgrading Flutter later may allow newer Riverpod and removes some of the pins above.
