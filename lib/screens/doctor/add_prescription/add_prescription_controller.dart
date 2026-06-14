import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/prescription_model.dart';
import '../../../models/appointment_model.dart';
import '../../../models/doctor_model.dart';
import '../../../utils/helper.dart';

class AddPrescriptionController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();

  late AppointmentModel appointment;
  final isLoading = false.obs;
  final doctorProfile = Rxn<DoctorModel>();

  final remarksController = TextEditingController();
  final testsController = TextEditingController();
  final followUpController = TextEditingController();

  // Structured Medicines
  final medicines = <MedicineModel>[].obs;
  
  // Temporary controllers for adding a new medicine
  final medNameController = TextEditingController();
  final medDosageController = TextEditingController();
  final medFreqController = TextEditingController();
  final medDurationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['appointment'] != null) {
      appointment = Get.arguments['appointment'];
      _fetchDoctorProfile();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
        AppSnackBar.show('Appointment details missing');
      });
    }
  }

  Future<void> _fetchDoctorProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final profile = await _firestoreService.getDoctorByUid(user.uid);
        doctorProfile.value = profile;
      }
    } catch (e) {
      debugPrint("Error fetching doctor profile: $e");
    }
  }

  void addMedicine() {
    if (medNameController.text.trim().isEmpty) {
      AppSnackBar.show('Medicine name is required');
      return;
    }
    
    medicines.add(MedicineModel(
      name: medNameController.text.trim(),
      dosage: medDosageController.text.trim(),
      frequency: medFreqController.text.trim(),
      duration: medDurationController.text.trim(),
    ));

    // Clear temp controllers
    medNameController.clear();
    medDosageController.clear();
    medFreqController.clear();
    medDurationController.clear();
  }

  void removeMedicine(int index) {
    medicines.removeAt(index);
  }

  Future<void> savePrescription() async {
    if (!formKey.currentState!.validate()) return;
    
    if (medicines.isEmpty) {
      AppSnackBar.show('Please add at least one medicine');
      return;
    }

    isLoading.value = true;
    update();

    try {
      final prescription = PrescriptionModel(
        prescriptionId: '', 
        appointmentId: appointment.appointmentId,
        patientId: appointment.patientId,
        doctorId: appointment.doctorId,
        doctorRemarks: remarksController.text.trim(),
        medicines: medicines.toList(),
        tests: testsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        followUpDate: followUpController.text.trim(),
        createdAt: DateTime.now(),
        doctorName: doctorProfile.value?.doctorName ?? appointment.doctorName ?? 'Doctor',
        specialization: doctorProfile.value?.specialization.join(', ') ?? appointment.specialization ?? 'Specialist',
      );

      await _firestoreService.createPrescription(prescription);
      await _firestoreService.updateAppointmentStatus(appointment.appointmentId, 'Completed');

      Get.back();
      AppSnackBar.show('Prescription saved and appointment completed');
    } catch (e) {
      AppSnackBar.show('Failed to save prescription: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    remarksController.dispose();
    testsController.dispose();
    followUpController.dispose();
    medNameController.dispose();
    medDosageController.dispose();
    medFreqController.dispose();
    medDurationController.dispose();
    super.onClose();
  }
}
