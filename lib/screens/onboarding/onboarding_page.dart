import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/onboarding_data.dart';
import '../../widgets/feature_card.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingModel data;
  final int pageIndex;

  const OnboardingPage({super.key, required this.data, required this.pageIndex});

  IconData _getHeaderIcon(int index) {
    switch (index) {
      case 0:
        return Icons.medical_services_rounded;
      case 1:
        return Icons.calendar_month_rounded;
      case 2:
        return Icons.folder_shared_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Blue Header ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Icon Circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
                child: Icon(_getHeaderIcon(pageIndex), size: 42, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(data.title, style: AppTextStyles.heading2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(data.subtitle, style: AppTextStyles.body, textAlign: TextAlign.center),
            ],
          ),
        ),

        // ── Feature Cards ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              children: data.features
                  .map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FeatureCard(feature: feature),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
