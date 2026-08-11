import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand / theme colors
  static const Color primary = Color(0xFF212121);
  static const Color secondary = Color(0xFF757575);
  static const Color error = Color(0xFFB00020);
  static const Color alternateRed = Color(0xFFA81717);

  // Text colors
  // These currently match the brand colors, but are kept separate so
  // typography can change independently from app branding.
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Background colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
}
