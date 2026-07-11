import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'receptionist_dashboard_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';

class ReceptionistDashboardScreen extends GetView<ReceptionistDashboardController> {
  const ReceptionistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return CustomScrollView(
          slivers: [
            _buildHeader(context),
            SliverPadding(
              padding: const EdgeInsets.all(18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHospitalInfo(),
                  const SizedBox(height: 24),
                  const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Appointments',
                          subtitle: 'Manage bookings',
                          icon: Icons.calendar_month_rounded,
                          color: const Color(0xFFE3F2FD),
                          iconColor: AppColors.primary,
                          onTap: () => Get.toNamed(AppRoutes.receptionistAppointments),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          title: 'Walk-in',
                          subtitle: 'Direct registration',
                          icon: Icons.person_add_alt_1_rounded,
                          color: const Color(0xFFF3E5F5),
                          iconColor: const Color(0xFF7B1FA2),
                          onTap: () => Get.toNamed(AppRoutes.walkInBooking),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildStatusSection(),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = controller.user.value;
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome Back,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    user?.name ?? 'Receptionist',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Obx(() {
                    if (controller.assignedDoctorName.value != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Staff of Dr. ${controller.assignedDoctorName.value}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            GestureDetector(
              onTap: controller.signOut,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.hospitalBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.business_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.practiceType.value == 'clinic' ? 'Current Clinic' : 'Current Hospital',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
                Obx(() => Text(controller.hospitalName.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBorder.withOpacity(0.4)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Obx(
          () => _buildStatusItem(Icons.people_alt_rounded, 'Total Patients', controller.totalPatientsCount.value.toString(), Colors.blue),
        ),
        Obx(
          () => _buildStatusItem(Icons.check_circle_rounded, 'Confirmed Appts', controller.confirmedCount.value.toString(), Colors.green),
        ),
        Obx(() => _buildStatusItem(Icons.pending_actions_rounded, 'Pending', controller.pendingCount.value.toString(), Colors.orange)),
      ],
    );
  }

  Widget _buildStatusItem(IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }
}
