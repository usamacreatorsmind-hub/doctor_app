import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/appointment_model.dart';

class PatientAppointmentsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final appointments = <AppointmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final results = await _firestoreService.getPatientAppointments(user.uid);
      
      List<AppointmentModel> enhancedAppts = [];
      for (var appt in results) {
        final doctor = await _firestoreService.getDoctor(appt.doctorId);
        final hospital = await _firestoreService.getHospital(appt.hospitalId);
        
        enhancedAppts.add(appt.copyWith(
          doctorName: doctor?.doctorName ?? 'Doctor',
          specialization: doctor?.specialization ?? 'Specialist',
          hospitalName: hospital?.hospitalName ?? 'Hospital',
        ));
      }
      
      appointments.value = enhancedAppts;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestoreService.updateAppointmentStatus(appointmentId, 'Cancelled');
      await loadAppointments();
      Get.snackbar('Success', 'Appointment cancelled successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel: $e');
    }
  }

  Future<void> onRefresh() async {
    await loadAppointments();
  }
}
