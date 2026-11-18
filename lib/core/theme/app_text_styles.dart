import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get displayHero => GoogleFonts.plusJakartaSans(
        fontSize: 48,
        height: 56 / 48,
        letterSpacing: -0.03 * 48,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        height: 24 / 18,
        letterSpacing: -0.005 * 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.02 * 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.04 * 12,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get labelMono => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        height: 18 / 13,
        letterSpacing: 0.05 * 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.005 * 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.01 * 12,
        fontWeight: FontWeight.w400,
      );
}
