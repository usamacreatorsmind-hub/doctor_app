import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'booking_confirm_controller.dart';

class BookingConfirmScreen extends GetView<BookingConfirmController> {
  const BookingConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          title: const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorInfoCard(),
                const SizedBox(height: 20),
                _buildBookingForSelection(),
                const SizedBox(height: 20),
                Obx(() => controller.isForSelf.value ? const SizedBox.shrink() : _buildOtherPatientForm()),
                Obx(() => controller.isForSelf.value ? const SizedBox.shrink() : const SizedBox(height: 20)),
                _buildAppointmentDetails(),
                const SizedBox(height: 20),
                _buildSymptomsInput(),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          );
        }),
        bottomSheet: _buildBottomAction(),
      ),
    );
  }

  Widget _buildDoctorInfoCard() {
    final doctor = controller.doctor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(12),
              image: (doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty)
                  ? DecorationImage(image: NetworkImage(doctor.photoUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: (doctor.photoUrl == null || doctor.photoUrl!.isEmpty)
                ? const Icon(Icons.person, color: AppColors.primary, size: 35)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('${doctor.qualification.join(', ')} - ${doctor.specialization.join(', ')}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Obx(() => Text(controller.hospitalName.value, style: const TextStyle(fontSize: 12, color: AppColors.textHint))), // Hospital Name
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking for', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _selectionChip(
                      label: 'Myself',
                      isSelected: controller.isForSelf.value,
                      onTap: () => controller.isForSelf.value = true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _selectionChip(
                      label: 'Someone Else',
                      isSelected: !controller.isForSelf.value,
                      onTap: () => controller.isForSelf.value = false,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _selectionChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOtherPatientForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Patient Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const Divider(height: 24),
          _textField(label: 'Full Name', controller: controller.otherNameController, hint: 'Enter name'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _textField(label: 'Age', controller: controller.otherAgeController, hint: 'Age', keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gender', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.selectedGender.value,
                              isExpanded: true,
                              items: controller.genders
                                  .map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 14))))
                                  .toList(),
                              onChanged: (val) => controller.selectedGender.value = val!,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Relationship', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedRelationship.value,
                        isExpanded: true,
                        items: controller.relationships
                            .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14))))
                            .toList(),
                        onChanged: (val) => controller.selectedRelationship.value = val!,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _textField(label: 'Mobile Number (Optional)', controller: controller.otherMobileController, hint: 'Enter mobile', keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _textField({required String label, required TextEditingController controller, String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appointment Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const Divider(height: 24),
          _detailRow(Icons.calendar_today_rounded, 'Date', DateFormat('MMM dd, yyyy').format(DateTime.parse(controller.selectedDateStr))),
          const SizedBox(height: 10),
          _detailRow(Icons.access_time_rounded, 'Time', controller.selectedTimeSlot),
          const SizedBox(height: 10),
          _detailRow(Icons.payments_rounded, 'Fee', '₹${controller.doctor.consultationFee.toInt()}'),
          const SizedBox(height: 10),
          _detailRow(Icons.location_on_rounded, 'Type', 'Offline (In-Clinic)'),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildSymptomsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Symptoms (Optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        TextFormField(
          onChanged: controller.updatePatientSymptoms,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe your symptoms...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm & Pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ));
  }
}
