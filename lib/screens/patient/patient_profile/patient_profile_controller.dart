import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/user_model.dart';
import '../../../models/patient_profile_model.dart';
import '../../../utils/app_routes.dart';

class PatientProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void goToEditProfile() {
    // Navigate to profile setup or a dedicated edit screen
    Get.toNamed(AppRoutes.profileSetup);
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(AppRoutes.roleSelection);
  }
}
