import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_routes.dart';
import '../../utils/helper.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> resetPassword() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    update();

    try {
      // In a real Firebase flow with OTP, the user is already signed in 
      // with the phone credential. We can update their password.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(passwordController.text.trim());
        Get.offAllNamed(AppRoutes.login);
        AppSnackBar.show('Password reset successfully. Please login with your new password.');
      } else {
        AppSnackBar.show('User session not found. Please try again.');
      }
    } catch (e) {
      AppSnackBar.show('Failed to reset password: ${e.toString()}');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
