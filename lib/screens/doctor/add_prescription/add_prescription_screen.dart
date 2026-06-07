import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'add_prescription_controller.dart';

class AddPrescriptionScreen extends GetView<AddPrescriptionController> {
  const AddPrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Add Prescription', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPatientInfo(),
              const SizedBox(height: 24),
              _buildSectionTitle('Doctor Remarks'),
              const SizedBox(height: 8),
              _buildTextArea(controller.remarksController, 'General observations...', validator: (v) => v!.isEmpty ? 'Required' : null),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Medicines'),
              const SizedBox(height: 4),
              const Text('Enter medicines separated by commas', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              _buildTextArea(controller.medicinesController, 'e.g. Paracetamol 500mg, Amoxicillin...', maxLines: 3),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Recommended Tests'),
              const SizedBox(height: 8),
              _buildTextArea(controller.testsController, 'e.g. Blood Test, X-Ray...', maxLines: 2),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Follow-up Date'),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.followUpController,
                decoration: InputDecoration(
                  hintText: 'e.g. After 1 week',
                  prefixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
                ),
              ),
              
              const SizedBox(height: 40),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.savePrescription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save & Complete Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient ID: ${controller.appointment.patientId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('Slot: ${controller.appointment.timeSlot}', style: const TextStyle(color: AppColors.primary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildTextArea(TextEditingController controller, String hint, {int maxLines = 4, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}
