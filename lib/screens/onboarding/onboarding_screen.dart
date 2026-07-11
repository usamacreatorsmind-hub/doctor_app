import 'package:doctor_app/utils/app_routes.dart' show AppRoutes;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/onboarding_data.dart';
import '../../widgets/page_indicator_dots.dart';
import 'onboarding_page.dart';
import '../role_selection/role_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToNextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _navigateToRoleSelection();
    }
  }

  void _skipOnboarding() {
    _navigateToRoleSelection();
  }

  void _navigateToRoleSelection() {
    if (!mounted) return;
    Get.offNamed(AppRoutes.roleSelection);
  }

  bool get _isLastPage => _currentPage == onboardingData.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── PageView ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(data: onboardingData[index], pageIndex: index);
                },
              ),
            ),

            // ── Bottom Section ──
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        children: [
          // Dots
          PageIndicatorDots(totalPages: onboardingData.length, currentPage: _currentPage),
          const SizedBox(height: 20),

          // Next / Get Started Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _goToNextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLastPage ? 'Get Started' : 'Next', style: AppTextStyles.btnPrimary),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Skip / Login button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isLastPage
                  ? () {
                      // Navigate to login screen
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    }
                  : _skipOnboarding,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(_isLastPage ? 'Already have an account? Login' : 'Skip', style: AppTextStyles.btnSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
