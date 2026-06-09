/*
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
  final experienceController = TextEditingController();
  final feeController = TextEditingController();
  final bioController = TextEditingController();

  final isLoading = false.obs;
  final isMasterLoading = false.obs;
  final selectedGender = 'male'.obs;
  final selectedMode = 'Both'.obs;

  late String currentHospitalId;

  // Master Data Lists (Fetched from Firestore)
  final availableSpecializations = <String>[].obs;
  final availableSymptoms = <String>[].obs;
  final availableDiseases = <String>[].obs;

  final selectedSpecializations = <String>[].obs;
  final selectedSymptoms = <String>[].obs;
  final selectedDiseases = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentHospitalId = Get.arguments['hospitalId'] ?? '';
    fetchMasterData();
  }

  Future<void> fetchMasterData() async {
    isMasterLoading.value = true;
    update();
    try {
      final results = await Future.wait([
        _firestoreService.getSpecializations(),
        _firestoreService.getSymptoms(),
        _firestoreService.getDiseases(),
      ]);
      
      availableSpecializations.assignAll(results[0]);
      availableSymptoms.assignAll(results[1]);
      availableDiseases.assignAll(results[2]);
      
      print("AddDoctor: Loaded ${availableSymptoms.length} symptoms from DB");
    } catch (e) {
      print("Error fetching master data: $e");
    } finally {
      isMasterLoading.value = false;
      update();
    }
  }

  void toggleSelection(RxList<String> list, String value) {
    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }
  }

  Future<void> saveDoctor() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedSpecializations.isEmpty) {
      Get.snackbar('Error', 'Please select at least one specialization');
      return;
    }

    isLoading.value = true;
    update();

    try {
      final newDoctor = DoctorModel(
        doctorId: '', 
        uid: '', 
        hospitalId: currentHospitalId,
        hospitalIds: [currentHospitalId], 
        doctorName: nameController.text.trim(),
        qualification: qualificationController.text.trim(),
        specialization: selectedSpecializations.join(', '),
        experience: int.tryParse(experienceController.text) ?? 0,
        consultationFee: double.tryParse(feeController.text) ?? 0.0,
        mobileNumber: mobileController.text.trim(),
        email: emailController.text.trim(),
        gender: selectedGender.value,
        languagesKnown: ['English', 'Hindi'],
        biography: bioController.text.trim(),
        symptomsCovered: selectedSymptoms.toList(),
        diseasesCovered: selectedDiseases.toList(),
        consultationMode: selectedMode.value,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _firestoreService.createDoctor(newDoctor);
      Get.back();
      Get.snackbar('Success', 'Doctor registered successfully');
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
    experienceController.dispose();
    feeController.dispose();
    bioController.dispose();
    super.onClose();
  }
}
*/
