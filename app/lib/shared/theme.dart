import 'package:flutter/material.dart';

/// The shop's look: calm deep blue on clean white and soft grey, plain green /
/// amber / red only to say good / careful / problem. One place, so every
/// screen looks like the same app.
abstract final class AppPalette {
  static const blue = Color(0xFF1D3F91); // main colour
  static const blueDark = Color(0xFF152F6E);
  static const blueTint = Color(0xFFE8EEFB); // light wash behind blue things
  static const page = Color(0xFFF4F6FA); // screen background
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFDDE2EC); // thin borders and dividers
  static const text = Color(0xFF111827);
  static const muted = Color(0xFF5B6475);

  static const green = Color(0xFF15803D);
  static const greenTint = Color(0xFFE7F5EC);
  static const amber = Color(0xFFB45309);
  static const amberTint = Color(0xFFFDF1E1);
  static const red = Color(0xFFB91C1C);
  static const redTint = Color(0xFFFCE8E8);
}

/// Meaning colours, read with `Theme.of(context).extension<AppColors>()!` or [context.colors].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors();

  Color get success => AppPalette.green;
  Color get successTint => AppPalette.greenTint;
  Color get warning => AppPalette.amber;
  Color get warningTint => AppPalette.amberTint;
  Color get danger => AppPalette.red;
  Color get dangerTint => AppPalette.redTint;
  Color get muted => AppPalette.muted;
  Color get line => AppPalette.line;
  Color get blueTint => AppPalette.blueTint;

  @override
  AppColors copyWith() => const AppColors();

  @override
  AppColors lerp(AppColors? other, double t) => this;
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>() ?? const AppColors();
}

/// Text styles for money, so amounts line up and read at a glance.
abstract final class AppText {
  static const _tabular = [FontFeature.tabularFigures()];

  /// A big amount, such as a bill total.
  static TextStyle total(BuildContext context) => Theme.of(context).textTheme.headlineMedium!.copyWith(
        fontWeight: FontWeight.w700,
        fontFeatures: _tabular,
        color: AppPalette.text,
      );

  /// An amount inside a row or card.
  static TextStyle amount(BuildContext context, {bool bold = false}) => Theme.of(context).textTheme.bodyLarge!.copyWith(
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
        fontFeatures: _tabular,
      );
}

abstract final class AppTheme {
  static const fontFamily = 'NotoSans';

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.blue,
      onPrimary: Colors.white,
      primaryContainer: AppPalette.blueTint,
      onPrimaryContainer: AppPalette.blueDark,
      secondary: AppPalette.blue,
      onSecondary: Colors.white,
      secondaryContainer: AppPalette.blueTint,
      onSecondaryContainer: AppPalette.blueDark,
      tertiary: AppPalette.blue,
      onTertiary: Colors.white,
      error: AppPalette.red,
      onError: Colors.white,
      errorContainer: AppPalette.redTint,
      onErrorContainer: AppPalette.red,
      surface: AppPalette.card,
      onSurface: AppPalette.text,
      onSurfaceVariant: AppPalette.muted,
      outline: AppPalette.line,
      outlineVariant: AppPalette.line,
      surfaceContainerLowest: AppPalette.card,
      surfaceContainerLow: AppPalette.page,
      surfaceContainer: AppPalette.page,
      surfaceContainerHigh: AppPalette.blueTint,
      surfaceContainerHighest: AppPalette.blueTint,
      inverseSurface: AppPalette.text,
      onInverseSurface: Colors.white,
      shadow: Color(0x1A000000),
      surfaceTint: Colors.transparent,
    );

    final base = ThemeData(brightness: Brightness.light, useMaterial3: true, colorScheme: scheme, fontFamily: fontFamily);
    final text = base.textTheme.copyWith(
      headlineMedium: base.textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 28),
      headlineSmall: base.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700, fontSize: 22),
      titleLarge: base.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: base.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: base.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: base.textTheme.bodyLarge!.copyWith(fontSize: 16),
      bodyMedium: base.textTheme.bodyMedium!.copyWith(fontSize: 14.5),
      labelLarge: base.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
    );

    final radius = BorderRadius.circular(12);
    OutlineInputBorder border(Color c, {double w = 1}) =>
        OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: c, width: w));

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: AppPalette.page,
      extensions: const [AppColors()],
      dividerTheme: const DividerThemeData(color: AppPalette.line, thickness: 1, space: 1),
      // Gentle fade-and-rise when a screen opens, instead of the default jump.
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
      appBarTheme: AppBarTheme(
        backgroundColor: AppPalette.card,
        foregroundColor: AppPalette.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppPalette.line)),
        titleTextStyle: text.titleLarge!.copyWith(color: AppPalette.text),
        iconTheme: const IconThemeData(color: AppPalette.text),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppPalette.line)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppPalette.muted,
        tileColor: AppPalette.card,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: text.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: const BorderSide(color: AppPalette.line),
          foregroundColor: AppPalette.blue,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.blue,
          textStyle: text.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppPalette.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: border(AppPalette.line),
        enabledBorder: border(AppPalette.line),
        focusedBorder: border(AppPalette.blue, w: 2),
        errorBorder: border(AppPalette.red),
        focusedErrorBorder: border(AppPalette.red, w: 2),
        labelStyle: const TextStyle(color: AppPalette.muted),
        hintStyle: const TextStyle(color: AppPalette.muted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.card,
        selectedColor: AppPalette.blueTint,
        side: const BorderSide(color: AppPalette.line),
        labelStyle: text.labelLarge!.copyWith(fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        titleTextStyle: text.titleLarge,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppPalette.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.text,
        contentTextStyle: text.bodyMedium!.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : AppPalette.muted),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppPalette.blue : AppPalette.line),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppPalette.blue),
      popupMenuTheme: PopupMenuThemeData(
        color: AppPalette.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppPalette.blue,
        unselectedLabelColor: AppPalette.muted,
        indicatorColor: AppPalette.blue,
        dividerColor: AppPalette.line,
      ),
    );
  }
}
