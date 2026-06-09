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
  final specializations = <String>[].obs;
  final maxFee = 5000.0.obs; // Default high value to show all initially

  // Debounce query
  final searchQuery = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadSpecializations();
    
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['specialization'] != null) {
      selectedSpecialization.value = args['specialization'];
    }

    // Debounce: 500ms delay after typing stops before searching
    debounce(searchQuery, (_) => searchDoctors(), time: const Duration(milliseconds: 500));
    
    searchDoctors();
  }

  Future<void> loadSpecializations() async {
    try {
      final list = await _firestoreService.getSpecializations();
      specializations.assignAll(list);
    } catch (e) {
      print("Error loading specializations: $e");
    }
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  Future<void> searchDoctors() async {
    isLoading.value = true;
    update();

    try {
      final results = await _firestoreService.searchDoctors(
        name: searchController.text.trim(),
        specialization: selectedSpecialization.value,
        maxFee: maxFee.value,
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

  void onFeeFilterChanged(double val) {
    maxFee.value = val;
    searchDoctors();
  }

  void clearFilters() {
    searchController.clear();
    searchQuery.value = "";
    selectedSpecialization.value = '';
    maxFee.value = 5000.0;
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
