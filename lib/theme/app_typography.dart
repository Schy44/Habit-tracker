import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium: GoogleFonts.inter(
      fontSize: 45, fontWeight: FontWeight.w400),
    headlineLarge: GoogleFonts.inter(
      fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: GoogleFonts.inter(
      fontSize: 28, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.inter(
      fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    labelLarge: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
    labelMedium: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
  );
}
