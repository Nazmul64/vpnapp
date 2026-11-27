import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // XJ Tunnel Screen Typography
  static TextStyle get appBarTitle => GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static TextStyle get tabActive => GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF43A047),
    letterSpacing: 0.5,
  );

  static TextStyle get tabInactive => GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF212121),
    letterSpacing: 0.5,
  );

  static TextStyle get itemTitle => GoogleFonts.roboto(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1F2937),
  );

  static TextStyle get itemSubtitle => GoogleFonts.roboto(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: const Color(0xFF6B7280),
  );

  static TextStyle get timerCountdown => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF111827),
    letterSpacing: 0.5,
  );

  static TextStyle get buttonText => GoogleFonts.roboto(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  static TextStyle get badgeText => GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static TextStyle get footerVersion => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF1F2937),
    letterSpacing: 0.4,
  );

  // Legacy & Compatibility Aliases
  static TextStyle get titleLarge => GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static TextStyle get titleMedium => GoogleFonts.roboto(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get titleSmall => GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyMedium => GoogleFonts.roboto(
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodySmall => GoogleFonts.roboto(
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get caption => GoogleFonts.roboto(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle get monospaceLarge => GoogleFonts.jetBrainsMono(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static TextStyle get monospaceMedium => GoogleFonts.jetBrainsMono(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get monospaceSmall => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );
}
