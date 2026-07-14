import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/prescription_model.dart';
import '../../../models/doctor_model.dart';
import '../../../models/hospital_model.dart';
import '../../../models/appointment_model.dart';
import '../../../models/user_model.dart';
import '../../../services/pdf_service.dart';
import '../../../utils/helper.dart';

class PatientRecordsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = true.obs;
  final isDownloading = false.obs;
  final prescriptions = <PrescriptionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final results = await _firestoreService.getPatientPrescriptions(user.uid);
      prescriptions.value = results;
    } catch (e) {
      AppSnackBar.show('Failed to load medical records: $e');
    } finally {
      isLoading.value = false;
      update();
    }
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

  Future<void> downloadPrescription(PrescriptionModel record) async {
    isDownloading.value = true;
    update();

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // 1. Fetch Related Data
      final doctor = await _firestoreService.getDoctor(record.doctorId);
      if (doctor == null) throw "Doctor details not found";

      final hospital = doctor.hospitalId.isNotEmpty ? await _firestoreService.getHospital(doctor.hospitalId) : null;

      final patientUser = await _firestoreService.getUser(user.uid);
      final patientProfile = await _firestoreService.getPatientProfile(user.uid);
      final appointment = await _firestoreService.getAppointment(record.appointmentId);

      if (patientUser == null) throw "Patient user details not found";

      // 2. Prepare Patient Details for PDF
      String pName = patientUser.name;
      String pAge = "N/A";
      String pGender = "N/A";
      String pAddress = "N/A";
      String? gName;
      String? rel;

      if (appointment?.isForSelf ?? true) {
        pName = patientUser.name;
        pGender = patientProfile?.gender ?? "N/A";
        pAddress = patientProfile?.address ?? "N/A";
        rel = "Self";

        if (patientProfile?.dob != null && patientProfile!.dob!.isNotEmpty) {
          pAge = _calculateAge(patientProfile!.dob!);
        }
      } else if (appointment?.patientDetails != null) {
        pName = appointment!.patientDetails!['name'] ?? patientUser.name;
        pAge = "${appointment.patientDetails!['age']} Years";
        pGender = appointment.patientDetails!['gender'] ?? "N/A";
        pAddress = appointment.patientDetails!['address'] ?? "N/A";
        gName = appointment.patientDetails!['guardianName'];
        rel = appointment.patientDetails!['relationship'];
      }

      // 3. Generate PDF
      await PdfService.generatePrescriptionPdf(
        prescription: record,
        doctor: doctor,
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
    } catch (e) {
      AppSnackBar.show('Error generating PDF: $e');
    } finally {
      isDownloading.value = false;
      update();
    }
  }

  Future<void> onRefresh() async => await loadRecords();
}
