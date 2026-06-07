import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_routes.dart';
import '../../utils/onboarding_data.dart';

class OnboardingController extends GetxController {
  // PageController for PageView
  final PageController pageController = PageController();

  // Observable current page index
  final RxInt currentPage = 0.obs;

  // Total pages
  int get totalPages => onboardingData.length;

  // Check if last page
  bool get isLastPage => currentPage.value == totalPages - 1;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  // Called when user swipes page
  void onPageChanged(int index) {
    currentPage.value = index;
    update(); // Notify GetBuilder
  }

  // Next button pressed
  void onNextPressed() {
    if (isLastPage) {
      goToRoleSelection();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Skip button pressed
  void onSkipPressed() {
    goToRoleSelection();
  }

  // Login button pressed (last page)
  void onLoginPressed() {
    goToRoleSelection();
  }

  void goToRoleSelection() {
    Get.offNamed(AppRoutes.roleSelection);
  }
}
