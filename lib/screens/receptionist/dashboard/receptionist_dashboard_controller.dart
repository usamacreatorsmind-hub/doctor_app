import 'package:get/get.dart';
import '../../../Repository/auth_repository.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_routes.dart';
import '../../role_selection/role_selection_controller.dart';
import 'package:flutter/material.dart';

class ReceptionistDashboardController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final FirestoreService _firestoreService = FirestoreService();

  final Rxn<UserModel> user = Rxn<UserModel>();
  final hospitalName = 'Loading...'.obs;
  final assignedDoctorName = RxnString();
  final practiceType = 'hospital'.obs;
  final isLoading = false.obs;

  // Stats
  final totalPatientsCount = 0.obs;
  final confirmedCount = 0.obs;
  final pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    isLoading.value = true;
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        final userData = await _authRepository.getUserData(currentUser.uid);
        user.value = userData;
        if (userData?.hospitalId != null) {
          _fetchHospitalName(userData!.hospitalId!);
          await _fetchTodayStats();
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchHospitalName(String hId) async {
    try {
      // 1. If receptionist is assigned to a specific doctor, check for Clinic Name
      if (user.value?.doctorId != null) {
        final doctor = await _firestoreService.getDoctor(user.value!.doctorId!);
        if (doctor != null) {
          assignedDoctorName.value = doctor.doctorName;
          if (doctor.practiceType == 'clinic' && doctor.clinicName != null && doctor.clinicName!.isNotEmpty) {
            hospitalName.value = doctor.clinicName!;
            practiceType.value = 'clinic';
            return;
          }
        }
      }

      // 2. Default to Hospital Name
      practiceType.value = 'hospital';
      final h = await _firestoreService.getHospital(hId);
      if (h != null) {
        hospitalName.value = h.hospitalName;
      } else {
        hospitalName.value = 'Not Assigned';
      }
    } catch (e) {
      hospitalName.value = 'Error';
    }
  }

  Future<void> _fetchTodayStats() async {
    if (user.value?.hospitalId == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0];
    final appointments = await _firestoreService.getHospitalAppointments(user.value!.hospitalId!, date: today);

    // Filter by Doctor if assigned
    final filteredAppts = user.value!.doctorId != null
        ? appointments.where((a) => a.doctorId == user.value!.doctorId).toList()
        : appointments;

    totalPatientsCount.value = filteredAppts.length;
    confirmedCount.value = filteredAppts.where((a) => a.status.toLowerCase() == 'confirmed' || a.status.toLowerCase() == 'arrived').length;
    pendingCount.value = filteredAppts.where((a) => a.status.toLowerCase() == 'pending').length;
  }

  void signOut() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authRepository.signOut();
              Get.offAllNamed(AppRoutes.roleSelection);
              Get.toNamed(AppRoutes.login, arguments: {'role': UserRole.receptionist});
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
