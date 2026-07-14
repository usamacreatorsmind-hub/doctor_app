import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../models/prescription_model.dart';
import 'patient_records_controller.dart';

class PatientRecordsScreen extends GetView<PatientRecordsController> {
  const PatientRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Medical Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.prescriptions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('No medical records found', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.prescriptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = controller.prescriptions[index];
              return InkWell(
                onTap: () => _showPrescriptionDetails(context, record),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.description_rounded, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(record.doctorName ?? 'Doctor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text(
                                  'Prescribed on ${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.downloadPrescription(record),
                            icon: const Icon(Icons.download_for_offline_rounded, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        'Medicines: ${record.medicines.map((m) => m.name).join(", ")}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (record.followUpDate != null && record.followUpDate!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.event_repeat_rounded, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              'Follow-up: ${record.followUpDate}',
                              style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _showPrescriptionDetails(BuildContext context, PrescriptionModel record) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Prescription Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              _infoRow('Date', '${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}'),
              _infoRow('Doctor', record.doctorName ?? 'N/A'),
              _infoRow('Specialization', record.specialization ?? 'General Physician'),

              const SizedBox(height: 16),
              const Text('Medicines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              ...record.medicines.map((m) => _medicineItem(m)),

              if (record.tests.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Recommended Tests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Text(record.tests.join(', '), style: const TextStyle(color: AppColors.textSecondary)),
              ],

              if (record.doctorRemarks.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Doctor Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Text(record.doctorRemarks, style: const TextStyle(color: AppColors.textSecondary)),
              ],

              if (record.followUpDate != null && record.followUpDate!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _infoRow('Follow-up', record.followUpDate!, isHighlight: true),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    controller.downloadPrescription(record);
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Download PDF Prescription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isHighlight ? Colors.orange : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineItem(MedicineModel m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.medication_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${m.dosage} | ${m.frequency} | ${m.duration}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
