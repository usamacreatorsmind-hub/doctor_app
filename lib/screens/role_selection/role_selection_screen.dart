import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'role_selection_controller.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleSelectionController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                // ── Blue Header ──
                _buildHeader(),

                // ── Role Cards ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      children: [
                        _buildRoleCard(
                          controller: controller,
                          role: UserRole.hospitalAdmin,
                          icon: Icons.local_hospital_rounded,
                          iconBgColor: AppColors.hospitalBg,
                          iconColor: AppColors.hospitalIcon,
                          title: 'Hospital Admin',
                          subtitle: 'Manage doctors & appointments',
                        ),
                        const SizedBox(height: 14),
                        _buildRoleCard(
                          controller: controller,
                          role: UserRole.doctor,
                          icon: Icons.medical_services_rounded,
                          iconBgColor: AppColors.doctorBg,
                          iconColor: AppColors.doctorIcon,
                          title: 'Doctor',
                          subtitle: 'View patients & consultations',
                        ),
                        const SizedBox(height: 14),
                        _buildRoleCard(
                          controller: controller,
                          role: UserRole.patient,
                          icon: Icons.person_rounded,
                          iconBgColor: AppColors.patientBg,
                          iconColor: AppColors.patientIcon,
                          title: 'Patient',
                          subtitle: 'Book appointments & view records',
                        ),
                        const SizedBox(height: 14),
                        _buildRoleCard(
                          controller: controller,
                          role: UserRole.receptionist,
                          icon: Icons.support_agent_rounded,
                          iconBgColor: AppColors.receptionistBg,
                          iconColor: AppColors.receptionistIcon,
                          title: 'Receptionist',
                          subtitle: 'Manage walk-ins & front desk',
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Continue Button ──
                _buildFooter(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)),
            child: const Icon(Icons.favorite_rounded, size: 34, color: Colors.white),
          ),
          const SizedBox(height: 18),
          const Text('Who are you?', style: AppTextStyles.heading2),
          const SizedBox(height: 6),
          const Text('Select your role to continue', style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required RoleSelectionController controller,
    required UserRole role,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = controller.selectedRole.value == role;

    return GestureDetector(
      onTap: () => controller.selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder, width: isSelected ? 1.8 : 0.8),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.roleTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.roleSubtitle),
                ],
              ),
            ),

            // Check circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder, width: 1.5),
              ),
              child: isSelected ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(RoleSelectionController controller) {
    return Obx(() {
      final bool hasSelection = controller.selectedRole.value != null;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: hasSelection ? controller.onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSelection ? AppColors.primary : AppColors.primaryBorder,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Continue', style: AppTextStyles.btnPrimary),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      );
    });
  }
}
