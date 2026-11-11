import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const TextStyle h1Bold = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.surface,
    height: 1.2,
  );

  static const TextStyle h2Bold = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h3Bold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleBold = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.surface,
  );

  static const TextStyle subtitleRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.surface,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textLightSubtle,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textDarkMuted,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.surface,
  );
}
