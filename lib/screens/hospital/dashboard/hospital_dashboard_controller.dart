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
  final pendingRequestsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return;

    isLoading.value = true;
    update();

    try {
      final userModel = await _firestoreService.getUser(firebaseUser.uid);
      HospitalModel? managedHospital;
      
      if (userModel?.hospitalId != null && userModel!.hospitalId!.isNotEmpty) {
        managedHospital = await _firestoreService.getHospital(userModel.hospitalId!);
      }
      
      managedHospital ??= await _firestoreService.getHospitalByAdminUid(firebaseUser.uid);
      
      if (managedHospital != null) {
        hospital.value = managedHospital;
        
        final hospitalDoctors = await _firestoreService.getDoctorsByHospital(managedHospital.hospitalId);
        doctors.assignAll(hospitalDoctors);

        final requests = await _firestoreService.getHospitalJoinRequests(managedHospital.hospitalId);
        pendingRequestsCount.value = requests.length;

        final today = DateTime.now().toIso8601String().split('T')[0];
        final appts = await _firestoreService.getHospitalAppointments(managedHospital.hospitalId, date: today);
        
        List<AppointmentModel> enhancedAppts = [];
        for (var appt in appts) {
          final patientData = await _firestoreService.getUser(appt.patientId);
          final doctor = hospitalDoctors.firstWhereOrNull((d) => d.doctorId == appt.doctorId);
          
          enhancedAppts.add(appt.copyWith(
            patientName: patientData?.name ?? 'Patient',
            doctorName: doctor?.doctorName ?? 'Doctor',
          ));
        }
        todayAppointments.assignAll(enhancedAppts);
      }
    } catch (e) {
      print("Error loading dashboard data: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void onDoctorTapped(DoctorModel doctor) {
    Get.toNamed(AppRoutes.doctorProfile, arguments: {
      'doctor': doctor,
      'isAdmin': true
    });
  }

  void goToAddDoctor() {
    if (hospital.value != null) {
      Get.toNamed(AppRoutes.addDoctor, arguments: {'hospitalId': hospital.value!.hospitalId});
    }
  }

  void goToJoinRequests() {
    if (hospital.value != null) {
      Get.toNamed(AppRoutes.hospitalJoinRequests, arguments: {'hospitalId': hospital.value!.hospitalId});
    }
  }

  void goToHospitalProfile() => Get.toNamed(AppRoutes.hospitalProfile);
  void goToAllAppointments() => Get.toNamed(AppRoutes.hospitalAppointments, arguments: {'hospitalId': hospital.value?.hospitalId});

  Future<void> onRefresh() async => await loadDashboardData();
}
