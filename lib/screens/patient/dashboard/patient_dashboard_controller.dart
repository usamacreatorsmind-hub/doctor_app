import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/doctor_model.dart';
import '../../../models/appointment_model.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../utils/app_routes.dart';

class PatientDashboardController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final selectedSpecIndex = 0.obs;
  final patientName = 'Patient'.obs;
  final specializations = <String>[].obs;

  final upcomingAppointment = Rxn<AppointmentModel>();
  final topDoctors = <DoctorModel>[].obs;
  final bloodGroup = 'N/A'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final userData = await _firestoreService.getUser(user.uid);
      if (userData != null) patientName.value = userData.name;

      final profile = await _firestoreService.getPatientProfile(user.uid);
      if (profile != null) {
        bloodGroup.value = (profile.bloodGroup != null && profile.bloodGroup!.isNotEmpty)
            ? profile.bloodGroup! : 'N/A';
      }

      final specs = await _firestoreService.getSpecializations();
      if (specs.isNotEmpty) specializations.assignAll(specs);

      final doctors = await _firestoreService.getTopDoctors(limit: 5);
      topDoctors.value = doctors;

      final appointments = await _firestoreService.getPatientAppointments(user.uid);
      if (appointments.isNotEmpty) {
        // Strict filtering for Dashboard: Only Today or Future
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        
        final upcomingList = appointments.where((a) {
          final isActive = a.status != 'Cancelled' && a.status != 'Completed';
          // Ensure appointment date is >= today
          final isUpcomingOrToday = a.appointmentDate.compareTo(todayStr) >= 0;
          return isActive && isUpcomingOrToday;
        }).toList();

        if (upcomingList.isNotEmpty) {
          upcomingList.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
          final rawAppt = upcomingList.first;
          
          final doctorData = await _firestoreService.getDoctor(rawAppt.doctorId);
          final hospitalData = await _firestoreService.getHospital(rawAppt.hospitalId);
          
          upcomingAppointment.value = rawAppt.copyWith(
            doctorName: doctorData?.doctorName ?? 'Doctor',
            specialization: doctorData?.specialization.join(', ') ?? 'Specialist',
            hospitalName: hospitalData?.hospitalName ?? 'Hospital',
          );
        } else {
          upcomingAppointment.value = null;
        }
      }
    } catch (e) {
      print("Dashboard Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void onSpecializationTapped(int index) {
    selectedSpecIndex.value = index;
    update();
    Get.toNamed(AppRoutes.doctorSearch, arguments: {'specialization': specializations[index]});
  }

  void onDoctorBookTapped(DoctorModel doctor) => Get.toNamed(AppRoutes.doctorProfile, arguments: {'doctor': doctor});
  void onViewAllAppointments() => Get.toNamed(AppRoutes.patientAppointments);
  void onSeeAllDoctors() => Get.toNamed(AppRoutes.doctorSearch);
  void onSearchTapped() => Get.toNamed(AppRoutes.doctorSearch);
  void onNotificationTapped() => Get.toNamed(AppRoutes.notifications);
  void onProfileTapped() => Get.toNamed(AppRoutes.patientProfile);

  Future<void> onRefresh() async => await _loadDashboardData();
}
