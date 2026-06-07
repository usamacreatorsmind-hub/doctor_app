import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/onboarding_data.dart';

class FeatureCard extends StatelessWidget {
  final OnboardingFeature feature;

  const FeatureCard({super.key, required this.feature});

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'search':
        return Icons.search_rounded;
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'clock':
        return Icons.access_time_rounded;
      case 'phone':
        return Icons.phone_android_rounded;
      case 'bell':
        return Icons.notifications_rounded;
      case 'file':
        return Icons.description_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'shield':
        return Icons.shield_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBorder, width: 0.8),
      ),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(feature.icon),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title, style: AppTextStyles.cardTitle),
                const SizedBox(height: 2),
                Text(feature.subtitle, style: AppTextStyles.cardSubtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
