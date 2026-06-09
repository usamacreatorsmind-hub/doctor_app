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
                          _buildSectionHeader(
                            'Our Doctors',
                            controller.goToAddDoctor,
                            actionLabel: 'Add New',
                          ),
                          const SizedBox(height: 12),
                          _buildDoctorsList(),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                            'Today\'s Appointments', 
                            controller.goToAllAppointments,
                            actionLabel: 'View All'
                          ),
                          const SizedBox(height: 12),
                          _buildAppointmentsList(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToAddDoctor,
        label: const Text('Add Doctor',style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add,color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              child: Icon(Icons.local_hospital_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hospital Admin', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    controller.hospital.value?.hospitalName ?? 'Loading...',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: controller.goToHospitalProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Total Doctors',
            controller.doctors.length.toString(),
            Icons.people_alt_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Today\'s Appts',
            controller.todayAppointments.length.toString(),
            Icons.calendar_today_rounded,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildJoinRequestsSection() {
    return Obx(() {
      if (controller.pendingRequestsCount.value == 0) return const SizedBox.shrink();
      
      return GestureDetector(
        onTap: controller.goToJoinRequests,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.notification_important_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.pendingRequestsCount.value} New Join Requests',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Text(
                      'Doctors want to join your hospital',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, VoidCallback onAction, {String actionLabel = 'See All'}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        TextButton(onPressed: onAction, child: Text(actionLabel, style: const TextStyle(color: AppColors.primary))),
      ],
    );
  }

  Widget _buildDoctorsList() {
    if (controller.doctors.isEmpty) return _emptyState('No doctors added yet');
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.doctors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final doc = controller.doctors[index];
          return GestureDetector(
            onTap: () => controller.onDoctorTapped(doc),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: AppColors.primarySurface, child: const Icon(Icons.person, color: AppColors.primary)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(doc.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                        Text(doc.specialization.join(', '), style: const
                        TextStyle(color: AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis),
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
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final appt = controller.todayAppointments[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                child: Text(appt.timeSlot, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.patientName ?? 'Patient ID: ${appt.patientId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Dr. ${appt.doctorName ?? appt.doctorId}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
    if (status == 'Confirmed') { bg = Colors.green.shade50; text = Colors.green; }
    if (status == 'Pending') { bg = Colors.orange.shade50; text = Colors.orange; }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(message, style: const TextStyle(color: AppColors.textSecondary))),
    );
  }
}
