import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../Repository/auth_repository.dart';
import '../../../models/user_model.dart';
import '../../../models/doctor_model.dart';
import '../../../models/hospital_model.dart';
import '../../../utils/app_routes.dart';

class DoctorRegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthRepository _authRepository = AuthRepository();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final qualificationController = TextEditingController();
  final experienceController = TextEditingController();
  final feeController = TextEditingController();
  final bioController = TextEditingController();

  // Selections
  final isLoading = false.obs;
  final isMasterLoading = false.obs;
  final isPasswordHidden = true.obs;

  // Multiple Hospitals Selection
  final selectedHospitalIds = <String>[].obs;

  final selectedGender = 'male'.obs;
  final selectedConsultationMode = 'Both'.obs;

  // Master Data Lists (Fetched from Firestore)
  final hospitals = <HospitalModel>[].obs;
  final availableSpecializations = <String>[].obs;
  final availableSymptoms = <String>[].obs;
  final availableDiseases = <String>[].obs;
  final availableLanguages = <String>['Hindi', 'English', 'Punjabi', 'Marathi', 'Gujarati', 'Tamil', 'Bengali'].obs;

  final selectedSpecializations = <String>[].obs;
  final selectedSymptoms = <String>[].obs;
  final selectedDiseases = <String>[].obs;
  final selectedLanguages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    isMasterLoading.value = true;
    update();
    try {
      final results = await Future.wait([
        _firestoreService.getAllHospitals(),
        _firestoreService.getSpecializations(),
        _firestoreService.getSymptoms(),
        _firestoreService.getDiseases(),
      ]);

      hospitals.assignAll(results[0] as List<HospitalModel>);
      availableSpecializations.assignAll(results[1] as List<String>);
      availableSymptoms.assignAll(results[2] as List<String>);
      availableDiseases.assignAll(results[3] as List<String>);
    } catch (e) {
      print("Error fetching master data: $e");
    } finally {
      isMasterLoading.value = false;
      update();
    }
  }

  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;
  void selectGender(String val) => selectedGender.value = val;
  void selectMode(String val) => selectedConsultationMode.value = val;

  void toggleHospital(String hospitalId) {
    if (selectedHospitalIds.contains(hospitalId)) {
      selectedHospitalIds.remove(hospitalId);
    } else {
      selectedHospitalIds.add(hospitalId);
    }
  }

  void toggleSelection(RxList<String> list, String value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
  }

  Future<void> onRegisterPressed() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedHospitalIds.isEmpty) {
      Get.snackbar('Error', 'Please select at least one hospital');
      return;
    }
    if (selectedSpecializations.isEmpty) {
      Get.snackbar('Error', 'Please select at least one specialization');
      return;
    }

    isLoading.value = true;
    update();

    try {
      // 1. Create Auth User
      UserCredential? userCredential = await _authRepository.signUpAuth(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (userCredential != null && userCredential.user != null) {
        final String uid = userCredential.user!.uid;

        // 2. Create Doctor Profile (Saving specialization as List)
        final doctor = DoctorModel(
          doctorId: '',
          uid: uid,
          hospitalId: selectedHospitalIds.first,
          hospitalIds: selectedHospitalIds.toList(),
          doctorName: nameController.text.trim(),
          qualification: qualificationController.text.trim(),
          specialization: selectedSpecializations.toList(),
          experience: int.tryParse(experienceController.text) ?? 0,
          consultationFee: double.tryParse(feeController.text) ?? 0.0,
          mobileNumber: mobileController.text.trim(),
          email: emailController.text.trim(),
          gender: selectedGender.value,
          languagesKnown: selectedLanguages.toList(),
          biography: bioController.text.trim(),
          symptomsCovered: selectedSymptoms.toList(),
          diseasesCovered: selectedDiseases.toList(),
          consultationMode: selectedConsultationMode.value,
          status: 'pending',
          createdAt: DateTime.now(),
        );

        final String doctorId = await _firestoreService.createDoctor(doctor);

        // 3. Create User Document
        final userModel = UserModel(
          uid: uid,
          name: nameController.text.trim(),
          mobile: mobileController.text.trim(),
          email: emailController.text.trim(),
          role: 'doctor',
          status: 'pending', // Set to pending until approved
          doctorId: doctorId,
          hospitalId: selectedHospitalIds.first,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);

        // 4. Create Join Requests for each selected hospital
        for (String hId in selectedHospitalIds) {
          await _firestoreService.createJoinRequest({
            'doctorId': doctorId,
            'doctorUid': uid,
            'hospitalId': hId,
            'doctorName': doctor.doctorName,
            'specialization': doctor.specialization,
            'doctorEmail': doctor.email,
            'doctorMobile': doctor.mobileNumber,
            'status': 'pending',
          });
        }

        Get.snackbar('Success', 'Registration successful! Please wait for admin approval.',
            backgroundColor: Colors.green, colorText: Colors.white);

        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  String? validateName(String? v) => (v == null || v.isEmpty) ? 'Enter name' : null;
  String? validateEmail(String? v) => (v == null || !GetUtils.isEmail(v)) ? 'Invalid email' : null;
  String? validateMobile(String? v) => (v == null || v.length != 10) ? 'Enter 10-digit number' : null;
  String? validatePassword(String? v) => (v == null || v.length < 6) ? 'Min 6 characters' : null;
}
