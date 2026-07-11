import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../Repository/auth_repository.dart';
import '../../../models/user_model.dart';
import '../../../models/patient_profile_model.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/helper.dart';
import '../../role_selection/role_selection_controller.dart';

class PatientProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();
  final isLoading = false.obs;
  final userModel = Rxn<UserModel>();
  final profileModel = Rxn<PatientProfileModel>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final userData = await _firestoreService.getUser(user.uid);
      final profileData = await _firestoreService.getPatientProfile(user.uid);
      
      userModel.value = userData;
      profileModel.value = profileData;
    } catch (e) {
      AppSnackBar.show('Failed to load profile: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void goToEditProfile() {
    // Navigate to profile setup or a dedicated edit screen
    Get.toNamed(AppRoutes.profileSetup);
  }

  // Future<void> logout() async {
  //   await _auth.signOut();
  //   Get.offAllNamed(AppRoutes.roleSelection);
  // }


  Future<void> logout() async {
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
              Get.toNamed(AppRoutes.login, arguments: {'role': UserRole.patient});
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}
