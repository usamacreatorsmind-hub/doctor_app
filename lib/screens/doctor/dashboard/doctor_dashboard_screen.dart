import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';
import '../../../models/appointment_model.dart';
import '../../../models/patient_profile_model.dart';
import 'doctor_dashboard_controller.dart';

class DoctorDashboardScreen extends GetView<DoctorDashboardController> {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return RefreshIndicator(onRefresh: controller.onRefresh, child: _buildBody());
      }),
      bottomNavigationBar: SafeArea(child: _buildBottomNav()),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.grid_view_rounded, 'Home', controller.currentIndex.value == 0, () => controller.changeTab(0)),
            _navItem(Icons.event_note_rounded, 'Appts', controller.currentIndex.value == 1, () => controller.changeTab(1)),
            _navItem(Icons.group_rounded, 'Patients', controller.currentIndex.value == 2, () => controller.changeTab(2)),
            _navItem(Icons.person_rounded, 'Profile', controller.currentIndex.value == 3, () => controller.changeTab(3)),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : Colors.grey.shade400, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (controller.currentIndex.value) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildAppointmentsTab();
      case 2:
        return _buildPatientsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUpcomingAppointmentCard(),
                const SizedBox(height: 24),
                _buildStatCards(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildDailyInsight(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentCard() {
    return Obx(() {
      final appt = controller.nextAppointment.value;
      if (appt == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Next Patient',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appt.patientName ?? "Patient",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Token #${appt.tokenNumber?.toString().padLeft(2, '0') ?? "N/A"} · ${appt.timeSlot}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _statusBadge(appt.status, isDark: true),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _nextDetail(Icons.medical_services_outlined, appt.consultationType),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.addPrescription, arguments: {'appointment': appt}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Start Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            _quickActionCard('Schedule', Icons.calendar_month_rounded, Colors.blue, () => Get.toNamed(AppRoutes.doctorSchedule)),
            const SizedBox(width: 12),
            _quickActionCard('My QR', Icons.qr_code_2_rounded, Colors.purple, () => Get.toNamed(AppRoutes.doctorSelfProfile)),
            const SizedBox(width: 12),
            _quickActionCard('Reviews', Icons.star_rounded, Colors.orange, () => Get.toNamed(AppRoutes.doctorReviews)),
            const SizedBox(width: 12),
            _quickActionCard('Reports', Icons.assessment_rounded, Colors.green, () => Get.toNamed(AppRoutes.doctorReports)),
          ],
        ),
      ],
    );
  }

  Widget _quickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nextDetail(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDailyInsight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.shade100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.lightbulb_rounded, color: Colors.amber.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Medical Insight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"Patient communication is just as important as clinical skills. Taking an extra 2 minutes to explain a diagnosis can increase treatment adherence by 40%."',
            style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade800, fontStyle: FontStyle.italic, height: 1.5, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '— World Health Journal',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return SingleChildScrollView(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelector(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Appointments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${controller.appointments.length} Total', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildAppointmentsList(),
                Obx(
                  () => controller.isLoadMore.value
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : const SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsTab() {
    return Column(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: controller.onPatientSearch,
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isPatientsLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredPatients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      controller.patientSearchQuery.value.isEmpty ? 'No patients found' : 'No matches found',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.filteredPatients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final patient = controller.filteredPatients[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primarySurface,
                        child: Text(
                          patient.name[0].toUpperCase(),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(patient.mobile, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                        onPressed: () => _showPatientDetails(context, patient),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _profileMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your basic info and fee',
                  onTap: () => Get.toNamed(AppRoutes.doctorSelfProfile),
                ),
                _profileMenuItem(
                  icon: Icons.support_agent_rounded,
                  title: 'My Assistants',
                  subtitle: 'Manage receptionists and staff',
                  onTap: _showStaffBottomSheet,
                ),
                _profileMenuItem(
                  icon: Icons.calendar_month_rounded,
                  title: 'My Schedule',
                  subtitle: 'Manage availability and time slots',
                  onTap: () => Get.toNamed(AppRoutes.doctorSchedule),
                ),
                _profileMenuItem(
                  icon: Icons.rate_review_outlined,
                  title: 'Patient Reviews',
                  subtitle: 'See what patients are saying about you',
                  onTap: () => Get.toNamed(AppRoutes.doctorReviews),
                ),
                _profileMenuItem(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  color: Colors.red,
                  onTap: controller.logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStaffBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Assistants / Staff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: controller.goToAddReceptionist,
                  icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.receptionists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No assistants added yet', style: TextStyle(color: Colors.grey.shade400)),
                  ),
                );
              }
              return Column(
                children: controller.receptionists.map((staff) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Text(
                            staff.name[0].toUpperCase(),
                            style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(staff.mobile, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                          onPressed: () => controller.removeReceptionist(staff.uid),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _profileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: (color ?? AppColors.primary).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color ?? AppColors.primary, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final profile = controller.doctorProfile.value;
      return Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  backgroundImage: (profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty) ? NetworkImage(profile.photoUrl!) : null,
                  child: (profile?.photoUrl == null || profile!.photoUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome Back,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        profile?.doctorName ?? 'Doctor',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Colors.white60, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            profile?.specialization.join(', ') ?? 'Specialist',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _iconBtn(Icons.notifications_none_rounded, () => Get.toNamed(AppRoutes.notifications), hasBadge: true),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          if (hasBadge)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Obx(
      () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Today\'s Total',
                  controller.totalTodayCount.value.toString(),
                  Icons.calendar_month_rounded,
                  const Color(0xFF42A5F5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Confirmed',
                  controller.confirmedTodayCount.value.toString(),
                  Icons.check_circle_rounded,
                  const Color(0xFF66BB6A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Pending',
                  controller.pendingTodayCount.value.toString(),
                  Icons.pending_actions_rounded,
                  const Color(0xFFFFA726),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Rating',
                  '${controller.doctorProfile.value?.rating.toStringAsFixed(1) ?? "0.0"} (${controller.doctorProfile.value?.totalReviews ?? 0})',
                  Icons.star_rounded,
                  const Color(0xFFEC407A),
                  onTap: () => Get.toNamed(AppRoutes.doctorReviews),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
          boxShadow: [BoxShadow(color: color.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Schedule for', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        SizedBox(
          height: 85,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.dateList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = controller.dateList[index];
              final dateStr = DateFormat('yyyy-MM-dd').format(date);

              return Obx(() {
                final isSelected = controller.selectedDate.value == dateStr;
                return GestureDetector(
                  onTap: () => controller.loadAppointments(dateStr),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder, width: isSelected ? 1.5 : 1),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: TextStyle(color: isSelected ? Colors.white70 : AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    if (controller.isAppointmentsLoading.value) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      );
    }

    if (controller.appointments.isEmpty) {
      return Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, color: Colors.grey.shade300, size: 40),
            const SizedBox(height: 12),
            const Text('No appointments for this day', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appt = controller.appointments[index];

        bool _isTimePassed(String date, String time) {
          try {
            // Simple check: if date is today and time has passed, OR if date is in the past
            final String dtStr = "${date}T${time}:00";
            final DateTime apptTime = DateTime.parse(dtStr);
            return DateTime.now().isAfter(apptTime.subtract(const Duration(minutes: 10))); // Allow 10 mins early
          } catch (e) {
            return false;
          }
        }

        return InkWell(
          onTap: () => _showAppointmentDetails(context, appt),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primarySurface,
                      child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(appt.patientName ?? "Patient", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 8),
                              if (appt.patientType != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: appt.patientType == 'New' ? Colors.orange.shade50 : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    appt.patientType == 'New' ? 'N' : 'O',
                                    style: TextStyle(
                                      color: appt.patientType == 'New' ? Colors.orange.shade700 : Colors.blue.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (!appt.isForSelf)
                            Text(
                              'For: ${appt.patientDetails?['relationship'] ?? 'Other'}',
                              style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          Row(
                            children: [
                              Text(
                                appt.timeSlot,
                                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              if (appt.tokenNumber != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '· Serial: #${appt.tokenNumber.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(appt.status),
                  ],
                ),
                if (appt.symptoms.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Symptoms: ${appt.symptoms}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Divider(height: 24, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (appt.status == 'Confirmed' || appt.status == 'Arrived')
                      if (appt.status == 'Arrived' || _isTimePassed(appt.appointmentDate, appt.timeSlot))
                        ElevatedButton(
                          onPressed: () => Get.toNamed(AppRoutes.addPrescription, arguments: {'appointment': appt}),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appt.status == 'Arrived' ? Colors.blue : Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            appt.status == 'Arrived' ? 'Patient Ready - Start' : 'Start Consultation',
                            style: const TextStyle(fontSize: 13),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                'Starts at ${appt.timeSlot}',
                                style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPatientDetails(BuildContext context, UserModel patient) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Patient Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        patient.name[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(patient.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('ID: ${patient.patientId ?? "N/A"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _detailItem(Icons.phone_android_rounded, 'Mobile Number', patient.mobile),
              _detailItem(Icons.email_outlined, 'Email Address', patient.email),
              const Divider(height: 32),
              FutureBuilder<PatientProfileModel?>(
                future: controller.firestoreService.getPatientProfile(patient.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return const Text('Profile details not found', style: TextStyle(color: AppColors.textHint));
                  }
                  final profile = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _detailItem(Icons.cake_outlined, 'DOB', profile.dob ?? 'N/A')),
                          Expanded(child: _detailItem(Icons.person_outline, 'Gender', profile.gender ?? 'N/A')),
                        ],
                      ),
                      _detailItem(Icons.water_drop_outlined, 'Blood Group', profile.bloodGroup ?? 'N/A'),
                      _detailItem(
                        Icons.location_on_outlined,
                        'Address',
                        '${profile.address ?? ""}\n${profile.city ?? ""}, ${profile.state ?? ""} - ${profile.pincode ?? ""}',
                      ),
                      if (profile.medicalHistory.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Medical History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.medicalHistory
                              .map(
                                (item) => Chip(
                                  label: Text(item, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: AppColors.bgPage,
                                  side: BorderSide.none,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAppointmentDetails(BuildContext context, AppointmentModel appt) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Appointment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _statusBadge(appt.status),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _detailItem(Icons.numbers_rounded, 'Serial Number', '#${appt.tokenNumber?.toString().padLeft(2, '0') ?? "N/A"}')),
                Expanded(child: _detailItem(Icons.person_search_rounded, 'Patient Type', appt.patientType ?? 'New')),
              ],
            ),
            _detailItem(Icons.person_outline, 'Patient Name', appt.patientName ?? 'N/A'),
            _detailItem(Icons.people_outline, 'Relationship', '${appt.patientDetails?['relationship'] ?? 'Self'}'),
            _detailItem(
              Icons.info_outline,
              'Patient Info',
              '${appt.patientDetails?['age'] ?? 'N/A'}, ${appt.patientDetails?['gender'] ?? 'N/A'}',
            ),
            if (!appt.isForSelf) _detailItem(Icons.person_pin_rounded, 'Parents/Guardian', appt.patientDetails?['guardianName'] ?? 'N/A'),

            _detailItem(Icons.location_on_outlined, 'Patient Address', appt.patientDetails?['address'] ?? 'N/A'),
            _detailItem(Icons.calendar_today_outlined, 'Date & Time', '${appt.appointmentDate} at ${appt.timeSlot}'),
            _detailItem(Icons.medical_services_outlined, 'Consultation Type', appt.consultationType),
            _detailItem(Icons.sick_outlined, 'Symptoms', appt.symptoms.isEmpty ? 'No symptoms reported' : appt.symptoms),
            if (appt.notes != null && appt.notes!.isNotEmpty) _detailItem(Icons.note_outlined, 'Notes', appt.notes!),
            const SizedBox(height: 24),
            if (appt.status == 'Confirmed')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.addPrescription, arguments: {'appointment': appt});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Start Consultation & Add Prescription', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status, {bool isDark = false}) {
    Color bg = isDark ? Colors.white.withOpacity(0.2) : Colors.grey.shade100;
    Color text = isDark ? Colors.white : Colors.grey;

    if (status == 'Confirmed') {
      bg = isDark ? Colors.green.withOpacity(0.3) : Colors.green.shade50;
      text = isDark ? Colors.white : Colors.green;
    } else if (status == 'Arrived') {
      bg = isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade50;
      text = isDark ? Colors.white : Colors.blue;
    } else if (status == 'Pending') {
      bg = isDark ? Colors.orange.withOpacity(0.3) : Colors.orange.shade50;
      text = isDark ? Colors.white : Colors.orange;
    } else if (status == 'Cancelled') {
      bg = isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade50;
      text = isDark ? Colors.white : Colors.red;
    } else if (status == 'Completed') {
      bg = isDark ? Colors.blue.withOpacity(0.3) : Colors.blue.shade50;
      text = isDark ? Colors.white : Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
