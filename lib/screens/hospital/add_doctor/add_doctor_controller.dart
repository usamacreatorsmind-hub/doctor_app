import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/doctor_model.dart';

class AddDoctorController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final qualificationController = TextEditingController();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();
  final feeController = TextEditingController();
  final bioController = TextEditingController();

  final isLoading = false.obs;
  final selectedGender = 'Male'.obs;
  final selectedMode = 'Both'.obs;

  late String hospitalId;

  @override
  void onInit() {
    super.onInit();
    hospitalId = Get.arguments['hospitalId'] ?? '';
  }

  Future<void> saveDoctor() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    update();

    try {
      final newDoctor = DoctorModel(
        doctorId: '', // Firestore will generate ID
        uid: '', // This should ideally be linked to a new Auth user, but for now we just create the profile
        hospitalId: hospitalId,
        doctorName: nameController.text.trim(),
        qualification: qualificationController.text.trim(),
        specialization: specializationController.text.trim(),
        experience: int.parse(experienceController.text),
        consultationFee: double.parse(feeController.text),
        mobileNumber: mobileController.text.trim(),
        email: emailController.text.trim(),
        gender: selectedGender.value,
        languagesKnown: ['English', 'Hindi'],
        biography: bioController.text.trim(),
        symptomsCovered: [],
        diseasesCovered: [],
        consultationMode: selectedMode.value,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _firestoreService.createDoctor(newDoctor);
      Get.back();
      Get.snackbar('Success', 'Doctor added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add doctor: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    qualificationController.dispose();
    specializationController.dispose();
    experienceController.dispose();
    feeController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
