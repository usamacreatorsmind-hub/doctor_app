import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/doctor_model.dart';
import '../../../utils/app_routes.dart';

class DoctorSearchController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final searchResults = <DoctorModel>[].obs;

  // Filters
  final selectedSpecialization = ''.obs;
  final List<String> specializations = [
    'Cardiology', 'Neurology', 'Orthopedic', 'ENT', 'Pediatric', 'Pulmonology', 'General'
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['specialization'] != null) {
      selectedSpecialization.value = args['specialization'];
      searchDoctors();
    } else {
      searchDoctors(); // Load all doctors initially
    }
  }

  Future<void> searchDoctors() async {
    isLoading.value = true;
    update();

    try {
      final results = await _firestoreService.searchDoctors(
        name: searchController.text.trim(),
        specialization: selectedSpecialization.value,
      );
      searchResults.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void onSpecializationFilter(String spec) {
    if (selectedSpecialization.value == spec) {
      selectedSpecialization.value = '';
    } else {
      selectedSpecialization.value = spec;
    }
    searchDoctors();
  }

  void clearFilters() {
    searchController.clear();
    selectedSpecialization.value = '';
    searchDoctors();
  }

  void goToDoctorProfile(DoctorModel doctor) {
    Get.toNamed(AppRoutes.doctorProfile, arguments: {'doctor': doctor});
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
