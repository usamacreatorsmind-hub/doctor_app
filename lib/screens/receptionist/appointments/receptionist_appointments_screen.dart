import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_routes.dart';
import 'receptionist_appointments_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../models/appointment_model.dart';

class ReceptionistAppointmentsScreen extends GetView<ReceptionistAppointmentsController> {
  const ReceptionistAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final appointments = controller.filteredAppointments;

              if (appointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isEmpty
                            ? 'No appointments found for ${controller.selectedDate.value.toIso8601String().split('T')[0]}'
                            : 'No matches found for "${controller.searchQuery.value}"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  return _AppointmentListCard(
                    appointment: appt,
                    onCheckIn: () => controller.updateStatus(appt.appointmentId, 'Arrived'),
                    onMarkPaid: () => controller.markAsPaid(appt.appointmentId),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search patient name...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.bgPage,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    controller.selectDate(date);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Obx(
                        () => Text(
                          controller.selectedDate.value.toIso8601String().split('T')[0],
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentListCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onCheckIn;
  final VoidCallback onMarkPaid;

  const _AppointmentListCard({required this.appointment, required this.onCheckIn, required this.onMarkPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (!appointment.isForSelf)
                      Text(
                        'For: ${appointment.patientDetails?['relationship'] ?? 'Other'}',
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    Text('Slot: ${appointment.timeSlot}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              _buildStatusTag(appointment.status),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.medical_services_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('Dr. ${appointment.doctorName ?? 'Doctor'}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const Spacer(),
              _buildPaymentStatus(appointment.paymentStatus),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (appointment.status == 'Confirmed' || appointment.status == 'Pending')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCheckIn,
                    icon: const Icon(Icons.hail_rounded, size: 18),
                    label: const Text('Check-in (Arrived)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              else if (appointment.status == 'Arrived')
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Checked In - Waiting',
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              if (appointment.paymentStatus != 'Paid' && appointment.paymentStatus != 'Success') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.payments_outlined, size: 18),
                    label: const Text('Collect Cash'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'arrived':
        color = Colors.blue;
        break;
      case 'confirmed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPaymentStatus(String status) {
    final bool isPaid = status.toLowerCase() == 'paid';
    final bool isBookingPaid = status == 'Booking Charge Paid';

    Color color = Colors.orange;
    String label = 'Unpaid';
    IconData icon = Icons.pending_rounded;

    if (isPaid) {
      color = Colors.green;
      label = 'Paid';
      icon = Icons.check_circle_rounded;
    } else if (isBookingPaid) {
      color = Colors.blue;
      label = 'Booking Charge Paid';
      icon = Icons.info_rounded;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
