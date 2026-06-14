import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Repository/auth_repository.dart';
import '../../utils/app_routes.dart';
import '../../utils/helper.dart';
import '../Login/login_controller.dart';

enum ResetMethod { email, otp }

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();

  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();

  final isLoading = false.obs;
  final linkSent = false.obs;
  final selectedMethod = ResetMethod.email.obs;

  void selectMethod(ResetMethod method) {
    selectedMethod.value = method;
    update();
  }

  String? validateEmail(String? value) => (value == null || !GetUtils.isEmail(value.trim())) ? 'Enter valid email' : null;
  String? validateMobile(String? value) => (value == null || value.length != 10) ? 'Enter 10 digit number' : null;

  Future<void> onSendPressed() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (selectedMethod.value == ResetMethod.email) {
      await _sendEmailResetLink();
    } else {
      await _sendOtp();
    }
  }

  Future<void> _sendEmailResetLink() async {
    try {
      isLoading.value = true;
      update();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailCtrl.text.trim());
      linkSent.value = true;
      AppSnackBar.show('Password reset link sent to email');
    } catch (e) {
      AppSnackBar.show(e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _sendOtp() async {
    try {
      isLoading.value = true;
      update();

      await _authRepository.verifyPhoneNumber(
        mobileCtrl.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (e) =>
        AppSnackBar.show(e.message ?? 'Verification failed'),
        codeSent: (String vId, int? resendToken) {
          Get.toNamed(AppRoutes.otpVerification, arguments: {
            'mobile': mobileCtrl.text.trim(),
            'isLogin': true,
            'isForgotPassword': true, // Critical for navigating to ResetPasswordScreen
            'verificationId': vId,
            'role': LoginRole.patient,
          });
        },
        codeAutoRetrievalTimeout: (vId) {},
      );
    } catch (e) {
      AppSnackBar.show(e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void goBack() => Get.back();

  @override
  void onClose() {
    emailCtrl.dispose();
    mobileCtrl.dispose();
    super.onClose();
  }
}
