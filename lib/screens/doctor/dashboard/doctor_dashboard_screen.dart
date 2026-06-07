import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/app_routes.dart';
import 'doctor_dashboard_controller.dart';

class DoctorDashboardScreen extends GetView<DoctorDashboardController> {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Doctor Dashboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.doctorSchedule),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
        ],
      ),
      body: Obx(() {
        // Main loading state
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: SingleChildScrollView(
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
                          Obx(() => Text('${controller.appointments.length} Total', 
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildAppointmentsList(),
                      const SizedBox(height: 100), // Safety space at bottom
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final profile = controller.doctorProfile.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white24,
              backgroundImage: (profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty) 
                  ? NetworkImage(profile.photoUrl!) : null,
              child: (profile?.photoUrl == null || profile!.photoUrl!.isEmpty) 
                  ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    profile?.doctorName ?? 'Doctor',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile?.specialization ?? 'Specialist',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                onPressed: () => Get.offAllNamed(AppRoutes.roleSelection),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Schedule for', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        SizedBox(
          height: 85,
          child: Obx(() => ListView.separated(
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
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.primaryBorder,
                        width: isSelected ? 1.5 : 1
                      ),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
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
                          style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          )),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    return Obx(() {
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
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primarySurface, 
                      child: const Icon(Icons.person, color: AppColors.primary, size: 20)
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appt.patientName ?? "Patient", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(appt.timeSlot, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    _statusBadge(appt.status),
                  ],
                ),
                const Divider(height: 24, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (appt.status == 'Pending') ...[
                      TextButton(
                        onPressed: () => controller.updateAppointmentStatus(appt.appointmentId, 'Cancelled'),
                        child: const Text('Reject', style: TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => controller.updateAppointmentStatus(appt.appointmentId, 'Confirmed'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary, 
                          foregroundColor: Colors.white, 
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Accept', style: TextStyle(fontSize: 13)),
                      ),
                    ] else if (appt.status == 'Confirmed')
                      ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.addPrescription, arguments: {'appointment': appt}),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, 
                          foregroundColor: Colors.white, 
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Add Prescription', style: TextStyle(fontSize: 13)),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _statusBadge(String status) {
    Color bg = Colors.grey.shade100;
    Color text = Colors.grey;
    if (status == 'Confirmed') { bg = Colors.green.shade50; text = Colors.green; }
    if (status == 'Pending') { bg = Colors.orange.shade50; text = Colors.orange; }
    if (status == 'Completed') { bg = Colors.blue.shade50; text = Colors.blue; }
    if (status == 'Cancelled') { bg = Colors.red.shade50; text = Colors.red; }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
