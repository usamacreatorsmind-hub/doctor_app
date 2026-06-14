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
              const SizedBox(height: 12),
              _buildMedicineInputForm(),
              const SizedBox(height: 16),
              _buildAddedMedicinesList(),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Recommended Tests'),
              const SizedBox(height: 8),
              _buildTextArea(controller.testsController, 'e.g. Blood Test, X-Ray (Comma separated)...', maxLines: 2),
              
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.appointment.patientName ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('Slot: ${controller.appointment.timeSlot} | Date: ${controller.appointment.appointmentDate}', style: const TextStyle(color: AppColors.primary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildMedicineInputForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSimpleInput(controller.medNameController, 'Medicine Name')),
              const SizedBox(width: 8),
              Expanded(child: _buildSimpleInput(controller.medDosageController, 'Dosage (e.g. 500mg)')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildSimpleInput(controller.medFreqController, 'Freq (e.g. 1-0-1)')),
              const SizedBox(width: 8),
              Expanded(child: _buildSimpleInput(controller.medDurationController, 'Duration (e.g. 5 Days)')),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.addMedicine,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add to List'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddedMedicinesList() {
    return Obx(() {
      if (controller.medicines.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No medicines added yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.medicines.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final med = controller.medicines[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.medication_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('${med.dosage} | ${med.frequency} | ${med.duration}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                  onPressed: () => controller.removeMedicine(index),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildSimpleInput(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: AppColors.bgPage,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String hint, {int maxLines = 4, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14),
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
