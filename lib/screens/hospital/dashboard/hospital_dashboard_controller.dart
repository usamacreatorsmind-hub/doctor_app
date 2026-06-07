import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/hospital_model.dart';
import '../../../models/doctor_model.dart';
import '../../../models/appointment_model.dart';
import '../../../utils/app_routes.dart';

class HospitalDashboardController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final hospital = Rxn<HospitalModel>();
  final doctors = <DoctorModel>[].obs;
  final todayAppointments = <AppointmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final managedHospital = await _firestoreService.getHospitalByAdminUid(user.uid);
      
      if (managedHospital != null) {
        hospital.value = managedHospital;
        
        // Fetch Doctors
        final hospitalDoctors = await _firestoreService.getDoctorsByHospital(managedHospital.hospitalId);
        doctors.value = hospitalDoctors;

        // Fetch Today's Appointments
        final today = DateTime.now().toIso8601String().split('T')[0];
        
        // ✅ Fixed: Added 'date:' named parameter
        final appts = await _firestoreService.getHospitalAppointments(managedHospital.hospitalId, date: today);
        
        // Fetch Patient Names for display
        List<AppointmentModel> enhancedAppts = [];
        for (var appt in appts) {
          final patientData = await _firestoreService.getUser(appt.patientId);
          enhancedAppts.add(appt.copyWith(patientName: patientData?.name ?? 'Patient'));
        }
        todayAppointments.value = enhancedAppts;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void goToAddDoctor() {
    if (hospital.value != null) {
      Get.toNamed(AppRoutes.addDoctor, arguments: {'hospitalId': hospital.value!.hospitalId});
    }
  }

  void goToHospitalProfile() => Get.toNamed(AppRoutes.hospitalProfile);
  void goToAllAppointments() => Get.toNamed(AppRoutes.hospitalAppointments, arguments: {'hospitalId': hospital.value?.hospitalId});

  Future<void> onRefresh() async => await loadDashboardData();
}
