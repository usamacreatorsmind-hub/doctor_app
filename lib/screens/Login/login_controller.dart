import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Repository/auth_repository.dart';
import '../../models/user_model.dart';
import '../../utils/app_routes.dart';
import '../role_selection/role_selection_controller.dart';

enum LoginRole { hospitalAdmin, doctor, patient }

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final mobileController = TextEditingController();

  final selectedRole = LoginRole.patient.obs;
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;
  final loginWithOtp = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['role'] != null) {
      final UserRole passedRole = args['role'] as UserRole;
      switch (passedRole) {
        case UserRole.hospitalAdmin:
          selectedRole.value = LoginRole.hospitalAdmin;
          break;
        case UserRole.doctor:
          selectedRole.value = LoginRole.doctor;
          break;
        case UserRole.patient:
          selectedRole.value = LoginRole.patient;
          break;
        default:
          selectedRole.value = LoginRole.patient;
      }
    }
    update();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  void selectRole(LoginRole role) {
    selectedRole.value = role;
    update();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
    update();
  }

  void toggleLoginMode() {
    loginWithOtp.value = !loginWithOtp.value;
    update();
  }

  Future<void> onLoginPressed() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;
    update();

    try {
      UserCredential? userCredential = await _authRepository.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (userCredential != null && userCredential.user != null) {
        final String uid = userCredential.user!.uid;
        final String email = userCredential.user!.email ?? emailController.text.trim();

        // 1. Try to get user data by Auth UID
        UserModel? userData = await _authRepository.getUserData(uid);
        
        // 2. Fallback Migration: If UID not found, search by email
        if (userData == null) {
          print("UID not found, searching by email: $email");
          userData = await _authRepository.getUserByEmail(email);
          
          if (userData != null) {
            print("Record found by email. Migrating from ${userData.uid} to UID: $uid");
            String oldDocId = userData.uid;
            
            // Update the UID and migrate the document
            userData = userData.copyWith(uid: uid);
            await _authRepository.migrateUser(oldDocId, userData);
          }
        }

        print("userData ${userData}");

        if (userData != null) {
          Get.snackbar('Success', 'Welcome back, ${userData.name}!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);

          // Role-based Navigation synced with Firestore keys
          if (userData.role == 'patient') {
            Get.offAllNamed(AppRoutes.patientDashboard);
          } else if (userData.role == 'doctor') {
            Get.offAllNamed(AppRoutes.doctorDashboard);
          } else if (userData.role == 'hospital_admin') {
            Get.offAllNamed(AppRoutes.hospitalDashboard);
          } else {
            Get.offAllNamed(AppRoutes.roleSelection);
          }
        } else {
          Get.snackbar('Error', 'User record not found in database. Please register.');
        }
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Login failed');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> onSendOtpPressed() async {
    if (mobileController.text.isEmpty || mobileController.text.length != 10) {
      Get.snackbar('Invalid Number', 'Please enter a valid 10-digit mobile number');
      return;
    }

    isLoading.value = true;
    update();

    try {
      await _authRepository.verifyPhoneNumber(
        mobileController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          update();
          Get.snackbar('Error', e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          update();
          Get.toNamed(
            AppRoutes.otpVerification,
            arguments: {
              'mobile': mobileController.text.trim(),
              'role': selectedRole.value,
              'isLogin': true,
              'verificationId': verificationId,
            },
          );
        },
        codeAutoRetrievalTimeout: (String vId) {},
      );
    } catch (e) {
      isLoading.value = false;
      update();
      Get.snackbar('Error', e.toString());
    }
  }

  void goToRegister() => Get.toNamed(AppRoutes.register, arguments: {'role': selectedRole.value});
  void goToForgotPassword() => Get.toNamed(AppRoutes.forgotPassword);

  String? validateEmail(String? value) => (value == null || !GetUtils.isEmail(value)) ? 'Invalid email' : null;
  String? validatePassword(String? value) => (value == null || value.length < 6) ? 'Min 6 characters' : null;
}
