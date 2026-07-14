import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/prescription_model.dart';
import '../../../models/appointment_model.dart';
import '../../../models/doctor_model.dart';
import '../../../services/pdf_service.dart';
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

    medicines.add(
      MedicineModel(
        name: medNameController.text.trim(),
        dosage: medDosageController.text.trim(),
        frequency: medFreqController.text.trim(),
        duration: medDurationController.text.trim(),
      ),
    );

    // Clear temp controllers
    medNameController.clear();
    medDosageController.clear();
    medFreqController.clear();
    medDurationController.clear();
  }

  void removeMedicine(int index) {
    medicines.removeAt(index);
  }

  String _calculateAge(String dobStr) {
    try {
      DateTime? dob;
      if (dobStr.contains('/')) {
        List<String> parts = dobStr.split('/');
        if (parts.length == 3) {
          dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } else {
        dob = DateTime.tryParse(dobStr);
      }

      if (dob != null) {
        final now = DateTime.now();
        int age = now.year - dob.year;
        if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
        return "$age Years";
      }
    } catch (e) {
      debugPrint("Age calculation error: $e");
    }
    return "N/A";
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
      final docProfile = doctorProfile.value;
      if (docProfile == null) throw "Doctor profile not loaded";

      final prescription = PrescriptionModel(
        prescriptionId: '',
        appointmentId: appointment.appointmentId,
        patientId: appointment.patientId,
        doctorId: appointment.doctorId,
        doctorRemarks: remarksController.text.trim(),
        medicines: medicines.toList(),
        tests: testsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        followUpDate: followUpController.text.trim(),
        createdAt: DateTime.now(),
        doctorName: docProfile.doctorName,
        specialization: docProfile.specialization.join(', '),
      );

      // 1. Save to Firestore
      final prescriptionId = await _firestoreService.createPrescription(prescription);
      await _firestoreService.updateAppointmentStatus(appointment.appointmentId, 'Completed');

      // 2. Prepare Data for PDF
      AppSnackBar.show('Prescription saved. Generating PDF...');

      final hospital = docProfile.hospitalId.isNotEmpty ? await _firestoreService.getHospital(docProfile.hospitalId) : null;

      final patientUser = await _firestoreService.getUser(appointment.patientId);
      final patientProfile = await _firestoreService.getPatientProfile(appointment.patientId);

      if (patientUser != null) {
        // Prepare Patient Details for PDF
        String pName = patientUser.name;
        String pAge = "N/A";
        String pGender = "N/A";
        String pAddress = "N/A";
        String? gName;
        String? rel;

        if (appointment.isForSelf) {
          pName = patientUser.name;
          pGender = patientProfile?.gender ?? "N/A";
          pAddress = patientProfile?.address ?? "N/A";
          rel = "Self";
          
          if (patientProfile?.dob != null && patientProfile!.dob!.isNotEmpty) {
            pAge = _calculateAge(patientProfile!.dob!);
          }
        } else if (appointment.patientDetails != null) {
          pName = appointment.patientDetails!['name'] ?? patientUser.name;
          pAge = "${appointment.patientDetails!['age']} Years";
          pGender = appointment.patientDetails!['gender'] ?? "N/A";
          pAddress = appointment.patientDetails!['address'] ?? "N/A";
          gName = appointment.patientDetails!['guardianName'];
          rel = appointment.patientDetails!['relationship'];
        }

        // 3. Auto-generate PDF
        await PdfService.generatePrescriptionPdf(
          prescription: prescription.copyWith(prescriptionId: prescriptionId),
          doctor: docProfile,
          hospital: hospital,
          patientUser: patientUser,
          appointment: appointment,
          patientName: pName,
          patientAge: pAge,
          patientGender: pGender,
          patientAddress: pAddress,
          guardianName: gName,
          relationship: rel,
        );
      }

      Get.back();
      AppSnackBar.show('Prescription completed successfully');
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
