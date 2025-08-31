import 'package:flutter/material.dart';
import 'package:mytracker/theme/app_colors.dart';

class AppStyles {
  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: AppColors.primary.withOpacity(0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  );

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.secondary,
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  );

  // Input Field Styles
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cards,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 16),
    errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
  );

  // Card & Container Styles
  static BoxDecoration cardContainerDecoration = BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static CardThemeData get formSectionCardTheme => CardThemeData(
    elevation: 1.5,
    shadowColor: Colors.black.withOpacity(0.08),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: AppColors.cards,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );

  // Spacing Values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXL = 24.0;

  // Animation Durations
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration normalAnimationDuration = Duration(milliseconds: 300);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Shadow Levels
  static List<BoxShadow> get shadows => [
        // Level 0: No shadow
        const BoxShadow(color: Colors.transparent),
        // Level 1: Subtle shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        // Level 2: Medium shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        // Level 3: Prominent shadow
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];
}