import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class PageIndicatorDots extends StatelessWidget {
  final int totalPages;
  final int currentPage;

  const PageIndicatorDots({
    super.key,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final bool isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.primaryBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
