import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';
import '../../../models/doctor_model.dart';
import 'patient_dashboard_controller.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientDashboardController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          body: Obx(() => controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  onRefresh: controller.onRefresh,
                  color: AppColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      _buildTopSection(controller),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // Upcoming Appointment Section
                            Obx(() {
                              if (controller.upcomingAppointment.value == null) return const SizedBox.shrink();
                              return _buildUpcomingSection(controller);
                            }),
                            const SizedBox(height: 16),
                            _buildSpecializationsSection(controller),
                            const SizedBox(height: 16),
                            _buildTopDoctorsSection(controller),
                            const SizedBox(height: 16),
                            // Only show summary section if Blood Group is available
                            Obx(() {
                              if (controller.bloodGroup.value == 'N/A' || controller.bloodGroup.value.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return _buildHealthSummary(controller);
                            }),
                          ]),
                        ),
                      ),
                    ],
                  ),
                )),
          bottomNavigationBar: _buildBottomNav(controller),
        );
      },
    );
  }

  Widget _buildTopSection(PatientDashboardController controller) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.primary,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome Ba',
                              style: TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 2),
                          Obx(() => Text(
                                controller.patientName.value,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              )),
                        ],
                      ),
                    ),
                    _buildIconBtn(Icons.notifications_outlined, controller.onNotificationTapped,
                        hasBadge: true),
                    const SizedBox(width: 10),
                    _buildAvatar(controller),
                  ],
                ),
              ),
              _buildSearchBar(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap, {bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (hasBadge)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      border: Border.all(color: AppColors.primary, width: 1.5))),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(PatientDashboardController controller) {
    return GestureDetector(
      onTap: controller.onProfileTapped,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: const Center(
            child: Text('P',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary))),
      ),
    );
  }

  Widget _buildSearchBar(PatientDashboardController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GestureDetector(
        onTap: controller.onSearchTapped,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text('Search doctor, symptom, disease...',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(PatientDashboardController controller) {
    final appt = controller.upcomingAppointment.value!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBorder, width: 0.5)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Appointment',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              GestureDetector(
                onTap: controller.onViewAllAppointments,
                child: const Text('View All',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBorder, width: 0.5)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                      BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt.doctorName ?? 'Doctor',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('${appt.specialization ?? ""} · ${appt.hospitalName ?? ""}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (appt.specialization != null)
                            _tag(appt.specialization!, AppColors.primarySurface, AppColors.primary),
                          _tag(appt.status, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('${appt.appointmentDate} · ${appt.timeSlot}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textColor)),
    );
  }

  Widget _buildSpecializationsSection(PatientDashboardController controller) {
    return Column(
      children: [
        _sectionHeader('Specializations', 'See All', controller.onSeeAllDoctors),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.specializations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final spec = controller.specializations[index];
              return Obx(() {
                final bool isActive = controller.selectedSpecIndex.value == index;
                return GestureDetector(
                  onTap: () => controller.onSpecializationTapped(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: isActive ? AppColors.primary : AppColors.primaryBorder,
                          width: 0.5),
                    ),
                    child: Text(spec['label']!,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopDoctorsSection(PatientDashboardController controller) {
    return Column(
      children: [
        _sectionHeader('Top Doctors', 'See All', controller.onSeeAllDoctors),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.topDoctors.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No doctors found',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            );
          }
          return Column(
            children: controller.topDoctors
                .map((doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _DoctorCard(
                          doctor: doc,
                          onBook: () => controller.onDoctorBookTapped(doc)),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildHealthSummary(PatientDashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBorder, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('My Health Summary', 'Edit', controller.onProfileTapped),
          const SizedBox(height: 12),
          // Showing only Blood Group as a single card
          _healthItem(Icons.water_drop_outlined, const Color(0xFFE53935), 'Blood Group',
              controller.bloodGroup.value),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        GestureDetector(
          onTap: onAction,
          child: Text(action,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _healthItem(IconData icon, Color color, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBorder, width: 0.5)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(PatientDashboardController controller) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, 'Home', true, () {}),
          _navItem(Icons.calendar_month_rounded, 'Book', false, controller.onSeeAllDoctors),
          _navItem(Icons.assignment_rounded, 'History', false, controller.onViewAllAppointments),
          _navItem(Icons.person_rounded, 'Profile', false, controller.onProfileTapped),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? AppColors.primary : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? AppColors.primary : Colors.grey)),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onBook;

  const _DoctorCard({required this.doctor, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBorder, width: 0.5)),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.bgPage,
              borderRadius: BorderRadius.circular(12),
              image: (doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(doctor.photoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (doctor.photoUrl == null || doctor.photoUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.grey, size: 30)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.doctorName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(doctor.specialization,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Colors.amber, size: 14),
                    const SizedBox(width: 2),
                    Text(doctor.rating.toString(),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Text(' (${doctor.totalReviews} reviews)',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBook,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Book',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
