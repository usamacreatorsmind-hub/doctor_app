import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/user_model.dart';
import '../../../utils/helper.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/hospital_model.dart';
import '../../../models/doctor_model.dart';
import '../../../models/appointment_model.dart';
import '../../../utils/app_routes.dart';

class HospitalDashboardController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final currentIndex = 0.obs;
  final hospital = Rxn<HospitalModel>();
  final doctors = <DoctorModel>[].obs;
  final receptionists = <UserModel>[].obs;
  final todayAppointments = <AppointmentModel>[].obs;

  // Analytics
  final activeDoctorsCount = 0.obs;
  final pendingRequestsCount = 0.obs;
  final todayRevenue = 0.0.obs;

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

        // 1. Doctors Stats
        final hospitalDoctors = await _firestoreService.getDoctorsByHospital(managedHospital.hospitalId);
        doctors.assignAll(hospitalDoctors);
        activeDoctorsCount.value = hospitalDoctors.where((d) => d.status.toLowerCase() == 'active').length;

        // 2. Pending Join Requests
        final requests = await _firestoreService.getHospitalJoinRequests(managedHospital.hospitalId);
        pendingRequestsCount.value = requests.length;

        // 3. Receptionists
        final hospitalReceptionists = await _firestoreService.getReceptionistsByHospital(managedHospital.hospitalId);
        receptionists.assignAll(hospitalReceptionists);

        // 4. Today's Appointments & Revenue
        final today = DateTime.now().toIso8601String().split('T')[0];
        final appts = await _firestoreService.getHospitalAppointments(managedHospital.hospitalId, date: today);

        double revenue = 0;
        List<AppointmentModel> enhancedAppts = [];
        for (var appt in appts) {
          final patientData = await _firestoreService.getUser(appt.patientId);
          final doctor = hospitalDoctors.firstWhereOrNull((d) => d.doctorId == appt.doctorId);

          enhancedAppts.add(appt.copyWith(patientName: patientData?.name ?? 'Patient', doctorName: doctor?.doctorName ?? 'Doctor'));

          if (appt.paymentStatus == 'Paid' || appt.paymentStatus == 'Success') {
            revenue += appt.fee;
          }
        }
        todayAppointments.assignAll(enhancedAppts);
        todayRevenue.value = revenue;
      }
    } catch (e) {
      print("Error loading dashboard data: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void onDoctorTapped(DoctorModel doctor) {
    Get.toNamed(AppRoutes.doctorProfile, arguments: {'doctor': doctor, 'isAdmin': true});
  }

  void goToAddDoctor() {
    if (hospital.value != null) {
      Get.toNamed(AppRoutes.addDoctor, arguments: {'hospitalId': hospital.value!.hospitalId});
    }
  }

  void goToAddReceptionist() {
    if (hospital.value != null) {
      Get.toNamed(AppRoutes.addReceptionist, arguments: {'hospitalId': hospital.value!.hospitalId});
    }
  }

  void goToJoinRequests() {
    if (hospital.value != null) {
      Get.toNamed(AppRoutes.hospitalJoinRequests, arguments: {'hospitalId': hospital.value!.hospitalId});
    }
  }

  void goToHospitalProfile() => Get.toNamed(AppRoutes.hospitalProfile);
  void goToAllAppointments() => Get.toNamed(AppRoutes.hospitalAppointments, arguments: {'hospitalId': hospital.value?.hospitalId});
  void goToReports() => Get.toNamed(AppRoutes.hospitalReports);
  void goToDepartments() => Get.toNamed(AppRoutes.hospitalDepartments);
  void goToNotifications() => Get.toNamed(AppRoutes.notifications);

  Future<void> removeReceptionist(String uid) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Staff'),
        content: const Text('Are you sure you want to remove this receptionist? They will no longer be able to log in.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              isLoading.value = true;
              update();
              try {
                await _firestoreService.deleteUser(uid);
                await loadDashboardData();
                AppSnackBar.show('Staff removed successfully');
              } catch (e) {
                AppSnackBar.show('Error: $e');
              } finally {
                isLoading.value = false;
                update();
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }

  Future<void> onRefresh() async => await loadDashboardData();
}
