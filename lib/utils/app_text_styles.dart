import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: 0.5,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 13, color: Colors.white70, letterSpacing: 1.5,
  );
  static const TextStyle body = TextStyle(
    fontSize: 13, color: Colors.white70, height: 1.6,
  );
  static const TextStyle cardTitle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 12, color: AppColors.textSecondary, height: 1.4,
  );
  static const TextStyle roleTitle = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static const TextStyle roleSubtitle = TextStyle(
    fontSize: 12, color: AppColors.textSecondary,
  );
  static const TextStyle btnPrimary = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
  );
  static const TextStyle btnSecondary = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary,
  );
}
