import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../models/appointment_model.dart';
import 'patient_appointments_controller.dart';
import 'package:intl/intl.dart';

class PatientAppointmentsScreen extends GetView<PatientAppointmentsController> {
  const PatientAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          title: const Text('My Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              // Upcoming Tab
              _buildAppointmentList(controller.upcomingAppointments, isPast: false),
              // History Tab
              _buildAppointmentList(controller.pastAppointments, isPast: true),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentModel> appointments, {required bool isPast}) {
    if (appointments.isEmpty) {
      return _buildEmptyState(isPast);
    }

    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final appt = appointments[index];
          return _AppointmentCard(
            appointment: appt,
            isPast: isPast,
            onCancel: () => _showCancelDialog(context, appt.appointmentId),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isPast) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            isPast ? 'No past appointments' : 'No upcoming appointments',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          if (!isPast)
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Book your first appointment'),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String appointmentId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelAppointment(appointmentId);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isPast;
  final VoidCallback onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.isPast,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final bool isMissed = isPast && 
                         appointment.appointmentDate.compareTo(todayStr) < 0 && 
                         (appointment.status == 'Pending' || appointment.status == 'Confirmed');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.medical_services_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.doctorName ?? 'Doctor',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(appointment.specialization ?? 'Specialist',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              _statusBadge(isMissed ? 'Missed' : appointment.status),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem(Icons.calendar_today_rounded, appointment.appointmentDate),
              _infoItem(Icons.access_time_rounded, appointment.timeSlot),
              _infoItem(Icons.videocam_outlined, appointment.consultationType),
            ],
          ),
          if (!isPast && (appointment.status == 'Pending' || appointment.status == 'Confirmed')) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel Appointment'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color bg = Colors.grey.shade100;
    Color text = Colors.grey;
    
    if (status == 'Confirmed') {
      bg = Colors.green.shade50;
      text = Colors.green;
    } else if (status == 'Pending') {
      bg = Colors.orange.shade50;
      text = Colors.orange;
    } else if (status == 'Cancelled') {
      bg = Colors.red.shade50;
      text = Colors.red;
    } else if (status == 'Missed') {
      bg = Colors.red.shade50;
      text = Colors.red;
    } else if (status == 'Completed') {
      bg = Colors.blue.shade50;
      text = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status,
          style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
