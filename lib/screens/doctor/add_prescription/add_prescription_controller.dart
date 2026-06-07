import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/prescription_model.dart';
import '../../../models/appointment_model.dart';

class AddPrescriptionController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final formKey = GlobalKey<FormState>();

  late AppointmentModel appointment;
  final isLoading = false.obs;

  final remarksController = TextEditingController();
  final medicinesController = TextEditingController(); // Comma separated: Name|Dosage|Freq|Duration
  final testsController = TextEditingController();
  final followUpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['appointment'] != null) {
      appointment = Get.arguments['appointment'];
    } else {
      Get.back();
      Get.snackbar('Error', 'Appointment details missing');
    }
  }

  Future<void> savePrescription() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    update();

    try {
      // Parse medicines from comma separated string
      // Format: Name|Dosage|Freq|Duration, ...
      List<MedicineModel> medicines = [];
      if (medicinesController.text.isNotEmpty) {
        final lines = medicinesController.text.split(',');
        for (var line in lines) {
          final parts = line.split('|');
          if (parts.length >= 1) {
            medicines.add(MedicineModel(
              name: parts[0].trim(),
              dosage: parts.length > 1 ? parts[1].trim() : '',
              frequency: parts.length > 2 ? parts[2].trim() : '',
              duration: parts.length > 3 ? parts[3].trim() : '',
            ));
          }
        }
      }

      final prescription = PrescriptionModel(
        prescriptionId: '', 
        appointmentId: appointment.appointmentId,
        patientId: appointment.patientId,
        doctorId: appointment.doctorId,
        doctorRemarks: remarksController.text.trim(),
        medicines: medicines,
        tests: testsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        followUpDate: followUpController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestoreService.createPrescription(prescription);
      
      // Update appointment status to Completed
      await _firestoreService.updateAppointmentStatus(appointment.appointmentId, 'Completed');

      Get.back();
      Get.snackbar('Success', 'Prescription saved and appointment completed', 
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save prescription: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    remarksController.dispose();
    medicinesController.dispose();
    testsController.dispose();
    followUpController.dispose();
    super.onClose();
  }
}
