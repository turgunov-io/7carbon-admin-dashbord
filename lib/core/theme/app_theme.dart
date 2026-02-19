import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      // Avoid remote Roboto fetch on restricted networks in Flutter Web.
      fontFamily: 'Arial',
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.scaffoldLight,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ).copyWith(
            primary: AppColors.primary,
            surface: AppColors.surfaceDark,
            onSurface: AppColors.white90,
          ),
      fontFamily: 'Arial',
      brightness: Brightness.dark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surfaceDeep,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.surfaceDarker,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDarker,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surfaceDarker,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borderLight),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceDarkerSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceNight,
        contentTextStyle: TextStyle(color: AppColors.white90),
      ),
    );
  }
}
