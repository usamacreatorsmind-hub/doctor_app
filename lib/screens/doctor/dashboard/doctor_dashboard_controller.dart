import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/doctor_model.dart';
import '../../../models/appointment_model.dart';
import '../../../models/notification_model.dart';

class DoctorDashboardController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final isAppointmentsLoading = false.obs;
  final doctorProfile = Rxn<DoctorModel>();
  final appointments = <AppointmentModel>[].obs;
  
  // Reactive selected date string
  final selectedDate = "".obs;
  
  // Stable list of dates for the selector (Next 14 days)
  final dateList = <DateTime>[].obs;

  @override
  void onInit() {
    super.onInit();
    _generateDates();
    selectedDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadDashboardData();
  }

  void _generateDates() {
    final now = DateTime.now();
    // Match the 14 days available on the patient side
    dateList.assignAll(List.generate(14, (i) => now.add(Duration(days: i))));
  }

  Future<void> loadDashboardData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final profile = await _firestoreService.getDoctorByUid(user.uid);
      if (profile != null) {
        doctorProfile.value = profile;
        print("Doctor Dashboard Loaded for: ${profile.doctorId}");
        await loadAppointments(selectedDate.value);
      } else {
        Get.snackbar('Profile Error', 'Doctor profile not found in database. Please contact admin.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> loadAppointments(String date) async {
    // 1. Snappy UI update for selection highlight
    selectedDate.value = date;
    
    if (doctorProfile.value == null) return;
    
    isAppointmentsLoading.value = true;
    update(); // Force GetBuilder/Obx to show sub-loader
    
    try {
      final doctorId = doctorProfile.value!.doctorId;
      final results = await _firestoreService.getDoctorAppointments(doctorId, date: date);
      
      List<AppointmentModel> enhancedAppts = [];
      for (var appt in results) {
        try {
          final patientData = await _firestoreService.getUser(appt.patientId);
          enhancedAppts.add(appt.copyWith(
            patientName: patientData?.name ?? 'Patient',
          ));
        } catch (e) {
          enhancedAppts.add(appt.copyWith(patientName: 'Patient'));
        }
      }
      
      appointments.assignAll(enhancedAppts);
      print("Loaded ${appointments.length} appointments for $date");
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: $e');
    } finally {
      isAppointmentsLoading.value = false;
      update();
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestoreService.updateAppointmentStatus(appointmentId, status);
      
      final appt = appointments.firstWhereOrNull((a) => a.appointmentId == appointmentId);
      if (appt != null) {
        await _firestoreService.createNotification(NotificationModel(
          notificationId: '',
          userId: appt.patientId,
          title: 'Appointment $status',
          message: 'Your appointment on ${appt.appointmentDate} has been $status by Dr. ${doctorProfile.value?.doctorName}',
          type: 'appointment',
          channel: 'app',
          isRead: false,
          createdAt: DateTime.now(),
        ));
      }

      await loadAppointments(selectedDate.value);
      Get.snackbar('Success', 'Appointment $status');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    }
  }

  Future<void> onRefresh() async => await loadDashboardData();
}
