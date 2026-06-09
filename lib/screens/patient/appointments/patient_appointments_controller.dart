import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/appointment_model.dart';

class PatientAppointmentsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  
  final upcomingAppointments = <AppointmentModel>[].obs;
  final pastAppointments = <AppointmentModel>[].obs;

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
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      // Fetch details for all appointments in parallel for better performance
      final enhancedAppts = await Future.wait(results.map((appt) async {
        final doctor = await _firestoreService.getDoctor(appt.doctorId);
        final hospital = await _firestoreService.getHospital(appt.hospitalId);
        
        return appt.copyWith(
          doctorName: doctor?.doctorName ?? 'Doctor',
          specialization: doctor?.specialization.join(', ') ?? 'Specialist',
          hospitalName: hospital?.hospitalName ?? 'Hospital',
        );
      }));

      List<AppointmentModel> upcoming = [];
      List<AppointmentModel> past = [];

      for (var appt in enhancedAppts) {
        bool isDateFutureOrToday = appt.appointmentDate.compareTo(todayStr) >= 0;
        bool isActiveStatus = appt.status == 'Pending' || appt.status == 'Confirmed';

        if (isDateFutureOrToday && isActiveStatus) {
          upcoming.add(appt);
        } else {
          past.add(appt);
        }
      }

      // Sort lists
      upcoming.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      past.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      
      upcomingAppointments.assignAll(upcoming);
      pastAppointments.assignAll(past);
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

  Future<void> onRefresh() async => await loadAppointments();
}
