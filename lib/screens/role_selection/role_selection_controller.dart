
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_routes.dart' show AppRoutes;

enum UserRole { hospitalAdmin, doctor, patient }

class RoleSelectionController extends GetxController {
  final selectedRole = Rxn<UserRole>();

  void selectRole(UserRole role) {
    selectedRole.value = role;
    update();
  }

  void onContinue() {
    if (selectedRole.value == null) {
      Get.snackbar(
        'Select Role',
        'Please select your role to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1565C0),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
      );
      return;
    }

    // Navigate to login and pass role as argument
    Get.toNamed(
      AppRoutes.login,
      arguments: {'role': selectedRole.value},
    );
  }
}
