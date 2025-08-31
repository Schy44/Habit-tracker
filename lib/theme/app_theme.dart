import 'package:flutter/material.dart' as material;
import 'package:mytracker/theme/app_colors.dart';
import 'package:mytracker/theme/app_typography.dart';
import 'package:mytracker/theme/app_styles.dart';

class AppTheme {
  static material.ThemeData lightTheme = material.ThemeData(
    useMaterial3: true,
    colorScheme: const material.ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryVariant,
      surface: AppColors.background,
      surfaceContainer: AppColors.cards,
      surfaceContainerHigh: AppColors.surfaceElevated,
      error: AppColors.error,
      onPrimary: material.Colors.white,
      onSecondary: material.Colors.white,
      onSurface: AppColors.textPrimary,
      onError: material.Colors.white,
      outline: AppColors.outline,
    ),
    textTheme: AppTypography.textTheme,
    elevatedButtonTheme: material.ElevatedButtonThemeData(
      style: AppStyles.primaryButtonStyle,
    ),
    outlinedButtonTheme: material.OutlinedButtonThemeData(
      style: AppStyles.secondaryButtonStyle,
    ),
    textButtonTheme: material.TextButtonThemeData(
      style: AppStyles.textButtonStyle,
    ),
    inputDecorationTheme: AppStyles.inputDecorationTheme,
    cardTheme: AppStyles.formSectionCardTheme,
    // TODO: Uncomment after Flutter SDK upgrade
    // progressIndicatorTheme: material.CircularProgressIndicatorThemeData(
    //   color: AppColors.primary,
    //   strokeWidth: 3,
    // ),
    // Add other theme properties as needed
  );

  static material.ThemeData darkTheme = material.ThemeData(
    useMaterial3: true,
    colorScheme: const material.ColorScheme.dark(
      primary: AppColors.primaryDark,
      primaryContainer: AppColors.primaryVariant,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondaryVariant,
      surface: AppColors.surfaceDark,
      surfaceContainer: AppColors.surfaceVariantDark,
      surfaceContainerHigh: AppColors.surfaceElevated,
      error: AppColors.error,
      onPrimary: AppColors.textPrimaryDark,
      onSecondary: AppColors.textPrimaryDark,
      onSurface: AppColors.textPrimaryDark,
      onError: material.Colors.white,
      outline: AppColors.outline,
    ),
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    ),
    elevatedButtonTheme: material.ElevatedButtonThemeData(
      style: AppStyles.primaryButtonStyle.copyWith(
        backgroundColor: material.WidgetStateProperty.all(AppColors.primaryDark),
        foregroundColor: material.WidgetStateProperty.all(AppColors.textPrimaryDark),
      ),
    ),
    outlinedButtonTheme: material.OutlinedButtonThemeData(
      style: AppStyles.secondaryButtonStyle.copyWith(
        foregroundColor: material.WidgetStateProperty.all(AppColors.primaryDark),
        side: material.WidgetStateProperty.all(const material.BorderSide(color: AppColors.primaryDark, width: 1.5)),
      ),
    ),
    textButtonTheme: material.TextButtonThemeData(
      style: AppStyles.textButtonStyle.copyWith(
        foregroundColor: material.WidgetStateProperty.all(AppColors.secondary),
      ),
    ),
    inputDecorationTheme: AppStyles.inputDecorationTheme.copyWith(
      fillColor: AppColors.surfaceVariantDark,
      labelStyle: const material.TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
      hintStyle: const material.TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
      enabledBorder: material.OutlineInputBorder(
        borderRadius: material.BorderRadius.circular(12),
        borderSide: const material.BorderSide(color: AppColors.outline),
      ),
      focusedBorder: material.OutlineInputBorder(
        borderRadius: material.BorderRadius.circular(12),
        borderSide: const material.BorderSide(color: AppColors.primaryDark, width: 2),
      ),
    ),
    cardTheme: AppStyles.formSectionCardTheme,
    // TODO: Uncomment after Flutter SDK upgrade
    // progressIndicatorTheme: material.CircularProgressIndicatorThemeData(
    //   color: AppColors.primaryDark,
    //   strokeWidth: 3,
    // ),
  );
}
