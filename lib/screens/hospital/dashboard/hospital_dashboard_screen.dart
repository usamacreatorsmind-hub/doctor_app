import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'hospital_dashboard_controller.dart';

class HospitalDashboardScreen extends GetView<HospitalDashboardController> {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: controller.onRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _buildHeader(),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildStatCards(),
                          const SizedBox(height: 24),
                          _buildJoinRequestsSection(),
                          const SizedBox(height: 24),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _buildSectionHeader('Our Doctors'),
                          const SizedBox(height: 12),
                          _buildDoctorsList(),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            'Today\'s Appointments', 
                            onAction: controller.goToAllAppointments,
                            actionLabel: 'View All'
                          ),
                          const SizedBox(height: 12),
                          _buildAppointmentsList(),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(Icons.local_hospital_rounded, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hospital Admin', 
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.hospital.value?.hospitalName ?? 'Loading...',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: controller.goToHospitalProfile,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Total Doctors',
                controller.doctors.length.toString(),
                Icons.people_alt_rounded,
                const Color(0xFF42A5F5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Active Doctors',
                controller.activeDoctorsCount.value.toString(),
                Icons.verified_user_rounded,
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
                'Today\'s Appts',
                controller.todayAppointments.length.toString(),
                Icons.calendar_today_rounded,
                const Color(0xFFFFA726),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Today\'s Revenue',
                '₹${controller.todayRevenue.value.toStringAsFixed(0)}',
                Icons.account_balance_wallet_rounded,
                const Color(0xFFEC407A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickActionButton(
            'Reports',
            Icons.bar_chart_rounded,
            Colors.deepPurple,
            controller.goToReports,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickActionButton(
            'Departments',
            Icons.category_rounded,
            Colors.teal,
            () => Get.toNamed('/hospital-departments'), // Placeholder for now
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinRequestsSection() {
    return Obx(() {
      if (controller.pendingRequestsCount.value == 0) return const SizedBox.shrink();
      
      return GestureDetector(
        onTap: controller.goToJoinRequests,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.notification_important_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.pendingRequestsCount.value} New Join Requests',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Doctors want to join your hospital',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onAction, String? actionLabel}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        if (onAction != null)
          TextButton(
            onPressed: onAction, 
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionLabel ?? 'See All', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13))
          ),
      ],
    );
  }

  Widget _buildDoctorsList() {
    if (controller.doctors.isEmpty) return _emptyState('No doctors associated');
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: controller.doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final doc = controller.doctors[index];
          return GestureDetector(
            onTap: () => controller.onDoctorTapped(doc),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(doc.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(doc.specialization.join(', '), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: doc.status.toLowerCase() == 'active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            doc.status.toUpperCase(),
                            style: TextStyle(
                              color: doc.status.toLowerCase() == 'active' ? Colors.green : Colors.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (controller.todayAppointments.isEmpty) return _emptyState('No appointments for today');
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.todayAppointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final appt = controller.todayAppointments[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text(appt.timeSlot.split(' ')[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(appt.timeSlot.split(' ').length > 1 ? appt.timeSlot.split(' ')[1] : '', style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.patientName ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('With Dr. ${appt.doctorName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              _statusBadge(appt.status),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color bg = Colors.grey.shade100;
    Color text = Colors.grey;
    if (status == 'Confirmed') { bg = const Color(0xFFE8F5E9); text = const Color(0xFF4CAF50); }
    else if (status == 'Pending') { bg = const Color(0xFFFFF3E0); text = const Color(0xFFFB8C00); }
    else if (status == 'Completed') { bg = const Color(0xFFE3F2FD); text = const Color(0xFF2196F3); }
    else if (status == 'Cancelled') { bg = const Color(0xFFFFEBEE); text = const Color(0xFFF44336); }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, color: AppColors.textHint.withOpacity(0.5), size: 40),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
