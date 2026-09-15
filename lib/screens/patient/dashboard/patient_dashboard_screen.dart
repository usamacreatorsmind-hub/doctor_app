import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';
import '../../../models/doctor_model.dart';
import '../doctor_search/doctor_search_screen.dart';
import '../appointments/patient_appointments_screen.dart';
import '../patient_profile/patient_profile_screen.dart';
import 'patient_dashboard_controller.dart';
import 'patient_qr_scan_tab.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatientDashboardController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          body: Obx(
            () => IndexedStack(
              index: controller.selectedIndex.value,
              children: [
                _buildHomeTab(controller),
                const DoctorSearchScreen(),
                const PatientQrScanTab(),
                const PatientAppointmentsScreen(),
                const PatientProfileScreen(),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(child: _buildBottomNav(controller)),
        );
      },
    );
  }

  Widget _buildHomeTab(PatientDashboardController controller) {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: controller.onRefresh,
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  _buildTopSection(controller),
                  SliverToBoxAdapter(child: _buildCarouselSlider(controller)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 50),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Upcoming Appointment Section
                        Obx(() {
                          if (controller.upcomingAppointment.value == null) return const SizedBox.shrink();
                          return Column(children: [const SizedBox(height: 20), _buildUpcomingSection(controller)]);
                        }),

                        const SizedBox(height: 24),
                        _buildQuickActions(), // PRESCRIPTION BUTTON IS HERE
                        const SizedBox(height: 24),
                        _buildSpecializationsSection(controller),
                        const SizedBox(height: 24),
                        _buildTopDoctorsSection(controller),
                        const SizedBox(height: 28),
                        _buildPromoBannerCard(controller),
                        const SizedBox(height: 28),
                        _buildWhyChooseUsSection(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
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
                          const Text('Welcome Back,', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 2),
                          Obx(
                            () => Text(
                              controller.patientName.value.toUpperCase(),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildIconBtn(Icons.notifications_outlined, controller.onNotificationTapped, hasBadge: true),
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

  Widget _buildCarouselSlider(PatientDashboardController controller) {
    return Obx(() {
      if (controller.banners.isEmpty) {
        return const SizedBox.shrink();
      }
      return CarouselSlider(
        options: CarouselOptions(
          height: 200.0,
          autoPlay: true,
          enlargeCenterPage: false,
          viewportFraction: 1.0,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayCurve: Curves.fastOutSlowIn,
          enableInfiniteScroll: controller.banners.length > 1,
        ),
        items: controller.banners.map((url) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.grey.shade200,
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40));
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  },
                ),
              );
            },
          );
        }).toList(),
      );
    });
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionCard(
                'Prescriptions',
                Icons.description_rounded,
                const Color(0xFFE3F2FD),
                AppColors.primary,
                () => Get.toNamed(AppRoutes.patientRecords),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionCard(
                'Appointments',
                Icons.calendar_month_rounded,
                const Color(0xFFE8F5E9),
                Colors.green,
                () => Get.toNamed(AppRoutes.patientAppointments),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, Color bg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
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
            width: 40,
            height: 40,
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

  Widget _buildAvatar(PatientDashboardController controller) {
    return GestureDetector(
      onTap: controller.onProfileTapped,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Center(
          child: Text(
            controller.patientName.value.isNotEmpty ? controller.patientName.value[0].toUpperCase() : 'P',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
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
              Text('Search doctor, symptom, disease...', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(PatientDashboardController controller) {
    final appt = controller.upcomingAppointment.value!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Appointment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: controller.onViewAllAppointments,
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.doctorName ?? 'Doctor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(appt.specialization ?? 'Specialist', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _tag(appt.status, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                  if (appt.tokenNumber != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Token: #${appt.tokenNumber.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${appt.appointmentDate} · ${appt.timeSlot}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                appt.hospitalName ?? '',
                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildSpecializationsSection(PatientDashboardController controller) {
    // Helper function to map specialization name to appropriate icons
    IconData getSpecIcon(String name) {
      final n = name.toLowerCase();
      if (n.contains('all')) return Icons.grid_view_rounded;
      if (n.contains('ayurveda') || n.contains('ayur')) return Icons.nature_people_rounded;
      if (n.contains('cardiology') || n.contains('heart')) return Icons.favorite_rounded;
      if (n.contains('ent') || n.contains('ear') || n.contains('nose')) return Icons.hearing_rounded;
      if (n.contains('pediatric') || n.contains('child') || n.contains('baby')) return Icons.child_care_rounded;
      if (n.contains('general') || n.contains('physician')) return Icons.medical_services_rounded;
      if (n.contains('dermatology') || n.contains('skin')) return Icons.clean_hands_rounded;
      if (n.contains('ortho') || n.contains('bone')) return Icons.accessibility_new_rounded;
      if (n.contains('dental') || n.contains('teeth')) return Icons.clean_hands_rounded;
      return Icons.health_and_safety_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Search by Specialty', 'See All', controller.onSeeAllDoctors),
        const SizedBox(height: 12),
        SizedBox(
          height: 90, // increased height for vertical icon + text layout
          child: Obx(
            () => ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.specializations.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final bool isAll = index == 0;
                final String title = isAll ? 'All' : controller.specializations[index - 1];
                final bool isActive = isAll ? controller.selectedSpecIndex.value == -1 : controller.selectedSpecIndex.value == index - 1;

                final IconData icon = getSpecIcon(title);

                return GestureDetector(
                  onTap: () {
                    if (isAll) {
                      controller.selectedSpecIndex.value = -1;
                      controller.onSeeAllDoctors();
                    } else {
                      controller.onSpecializationTapped(index - 1);
                    }
                  },
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: isActive ? AppColors.primary : AppColors.primaryBorder.withOpacity(0.6), width: 1),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Icon(icon, color: isActive ? Colors.white : AppColors.primary, size: 22),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 65, // fixed width to align text perfectly
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isActive ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDoctorsSection(PatientDashboardController controller) {
    return Column(
      children: [
        _sectionHeader('Top Rated Doctors', 'See All', controller.onSeeAllDoctors),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.topDoctors.isEmpty) {
            return const Center(
              child: Text('No doctors available', style: TextStyle(fontSize: 13, color: Colors.grey)),
            );
          }
          return Column(
            children: controller.topDoctors
                .map((doc) => _DoctorCard(doctor: doc, onBook: () => controller.onDoctorBookTapped(doc)))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPromoBannerCard(PatientDashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLight.withOpacity(0.4), AppColors.primaryLighter.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          // Smart Queue Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  'Smart Queue Technology ⚡',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Main Header Text
          const Text(
            'The right doctor, at\nthe right time',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.hospitalIcon, height: 1.25),
          ),
          const SizedBox(height: 12),

          // Body Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Connect with the best doctors near you with Aarogya Pass. Book appointments, track live queues, and manage all your health records in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF557A74), height: 1.5, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 20),

          // Find a Doctor Button
          ElevatedButton.icon(
            onPressed: () => controller.onSeeAllDoctors(),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Find a Doctor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.hospitalIcon,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(200, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(height: 24),

          // Small Status Item 1: Appointment Confirmed
          _buildPromoStatusRow(
            Icons.check_circle_outline_rounded,
            const Color(0xFFE0F2F1),
            const Color(0xFF009688),
            'Appointment Confirmed',
            'Dr. Sameer, Cardiology • 10:30 AM',
          ),
          const SizedBox(height: 12),

          // Small Status Item 2: Live Queue Update
          _buildPromoStatusRow(
            Icons.access_time_rounded,
            const Color(0xFFE8EAF6),
            const Color(0xFF3F51B5),
            'Live Queue Update',
            'Your turn in approx. 12 mins',
          ),
          const SizedBox(height: 12),

          // Small Status Item 3: Digital Vault
          _buildPromoStatusRow(
            Icons.assignment_turned_in_rounded,
            const Color(0xFFF3E5F5),
            const Color(0xFF9C27B0),
            'Digital Vault',
            'All records safely secured',
          ),
        ],
      ),
    );
  }

  Widget _buildPromoStatusRow(IconData icon, Color bg, Color iconColor, String title, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Why Choose Ayu Veda Care?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Experience a smarter, faster, and more reliable way to handle your family\'s healthcare needs.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
          ),
        ),
        const SizedBox(height: 18),
        _buildFeatureItem(
          Icons.verified_user_outlined,
          'Verified Partners',
          'Every doctor and lab is manually verified for your complete safety.',
        ),
        _buildFeatureItem(
          Icons.stacked_line_chart_rounded,
          'Live Queue',
          'Track your turn in real-time. Arrive only when it\'s your time.',
        ),
        _buildFeatureItem(Icons.qr_code_2_rounded, 'Instant QR Pass', 'Skip the reception lines with a simple scan. Paperless & Fast.'),
        _buildFeatureItem(Icons.headset_mic_outlined, '24/7 Support', 'Real humans to help you with your bookings and queries anytime.'),
        _buildFeatureItem(Icons.local_hospital_outlined, 'Emergency Duty', 'Quick access to 24/7 emergency facilities in your city.'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLighter.withOpacity(0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.015), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryLighter.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.hospitalIcon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: onAction,
          child: Text(
            action,
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(PatientDashboardController controller) {
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
            _navItem(Icons.home_filled, 'Home', controller.selectedIndex.value == 0, () => controller.changeTab(0)),
            _navItem(Icons.calendar_month_rounded, 'Book', controller.selectedIndex.value == 1, () => controller.changeTab(1)),
            _navItem(Icons.qr_code_scanner_rounded, 'Scan', controller.selectedIndex.value == 2, () => controller.changeTab(2)),
            _navItem(Icons.assignment_rounded, 'History', controller.selectedIndex.value == 3, () => controller.changeTab(3)),
            _navItem(Icons.person_rounded, 'Profile', controller.selectedIndex.value == 4, () => controller.changeTab(4)),
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
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onBook;

  const _DoctorCard({required this.doctor, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBook,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(12),
                image: (doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty)
                    ? DecorationImage(image: NetworkImage(doctor.photoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: (doctor.photoUrl == null || doctor.photoUrl!.isEmpty) ? const Icon(Icons.person, color: Colors.grey, size: 30) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.doctorName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    doctor.specialization.join(', '),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                      Text(doctor.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      const Icon(Icons.work_history_outlined, size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text('${doctor.experience} yrs', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
