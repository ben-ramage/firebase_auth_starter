import 'package:flutter/material.dart';
import 'package:firebase_auth_starter/utils/app_colors.dart';

class AppTypography {
  // Prevent instantiation
  AppTypography._();

  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Font sizes
  static const double displayLargeSize = 32.0;
  static const double displayMediumSize = 28.0;
  static const double displaySmallSize = 24.0;
  static const double headlineLargeSize = 22.0;
  static const double headlineMediumSize = 20.0;
  static const double headlineSmallSize = 18.0;
  static const double titleLargeSize = 16.0;
  static const double titleMediumSize = 14.0;
  static const double titleSmallSize = 12.0;
  static const double bodyLargeSize = 16.0;
  static const double bodyMediumSize = 14.0;
  static const double bodySmallSize = 12.0;
  static const double labelLargeSize = 14.0;
  static const double labelMediumSize = 12.0;
  static const double labelSmallSize = 10.0;

  // Display styles
  static TextStyle get displayLarge => TextStyle(
    fontSize: displayLargeSize,
    fontWeight: bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: displayMediumSize,
    fontWeight: bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get displaySmall => TextStyle(
    fontSize: displaySmallSize,
    fontWeight: bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.25,
  );

  // Headline styles
  static TextStyle get headlineLarge => TextStyle(
    fontSize: headlineLargeSize,
    fontWeight: semiBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontSize: headlineMediumSize,
    fontWeight: semiBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontSize: headlineSmallSize,
    fontWeight: semiBold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Title styles
  static TextStyle get titleLarge => TextStyle(
    fontSize: titleLargeSize,
    fontWeight: medium,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleMedium => TextStyle(
    fontSize: titleMediumSize,
    fontWeight: medium,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleSmall => TextStyle(
    fontSize: titleSmallSize,
    fontWeight: medium,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body styles
  static TextStyle get bodyLarge => TextStyle(
    fontSize: bodyLargeSize,
    fontWeight: regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: bodyMediumSize,
    fontWeight: regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: bodySmallSize,
    fontWeight: regular,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Label styles
  static TextStyle get labelLarge => TextStyle(
    fontSize: labelLargeSize,
    fontWeight: medium,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get labelMedium => TextStyle(
    fontSize: labelMediumSize,
    fontWeight: medium,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get labelSmall => TextStyle(
    fontSize: labelSmallSize,
    fontWeight: medium,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}
