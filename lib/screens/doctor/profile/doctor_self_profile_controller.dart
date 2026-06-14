// File: lib/screens/doctor/profile/doctor_self_profile_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/doctor_model.dart';
import '../../../models/hospital_model.dart';
import '../../../utils/helper.dart';

class DoctorSelfProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isMasterLoading = false.obs;
  final isEditing = false.obs;
  final doctorProfile = Rxn<DoctorModel>();

  // Master Data Lists
  final hospitals = <HospitalModel>[].obs;
  final availableSpecializations = <String>[].obs;
  final availableQualifications = <String>[].obs;
  final availableSymptoms = <String>[].obs;
  final availableDiseases = <String>[].obs;
  final availableLanguages = <String>['Hindi', 'English', 'Punjabi', 'Marathi', 'Gujarati', 'Tamil', 'Bengali'].obs;

  // Form Controllers
  late TextEditingController nameController;
  late TextEditingController experienceController;
  late TextEditingController feeController;
  late TextEditingController bioController;
  late TextEditingController mobileController;

  // Selected values
  final selectedHospitalIds = <String>[].obs;
  final selectedSpecializations = <String>[].obs;
  final selectedQualifications = <String>[].obs;
  final selectedSymptoms = <String>[].obs;
  final selectedDiseases = <String>[].obs;
  final selectedLanguages = <String>[].obs;

  final selectedGender = 'male'.obs;
  final selectedConsultationMode = 'Both'.obs;

  final pickedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    experienceController = TextEditingController();
    feeController = TextEditingController();
    bioController = TextEditingController();
    mobileController = TextEditingController();
    loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    experienceController.dispose();
    feeController.dispose();
    bioController.dispose();
    mobileController.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    update();
    try {
      await fetchMasterData();
      await loadProfile();
    } catch (e) {
      print("Error loading initial data: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> fetchMasterData() async {
    isMasterLoading.value = true;
    update();
    try {
      final results = await Future.wait([
        _firestoreService.getAllHospitals(),
        _firestoreService.getSpecializations(),
        _firestoreService.getSymptoms(),
        _firestoreService.getDiseases(),
        _firestoreService.getQualifications(),
      ]);

      hospitals.assignAll(results[0] as List<HospitalModel>);
      availableSpecializations.assignAll(results[1] as List<String>);
      availableSymptoms.assignAll(results[2] as List<String>);
      availableDiseases.assignAll(results[3] as List<String>);
      availableQualifications.assignAll(results[4] as List<String>);
    } catch (e) {
      print("Error fetching master data: $e");
    } finally {
      isMasterLoading.value = false;
      update();
    }
  }

  Future<void> loadProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final profile = await _firestoreService.getDoctorByUid(user.uid);
        if (profile != null) {
          doctorProfile.value = profile;
          _fillControllers(profile);
        }
      }
    } catch (e) {
      AppSnackBar.show('Failed to load profile: $e');
    }
  }

  void _fillControllers(DoctorModel profile) {
    nameController.text = profile.doctorName;
    experienceController.text = profile.experience.toString();
    feeController.text = profile.consultationFee.toString();
    bioController.text = profile.biography ?? '';
    mobileController.text = profile.mobileNumber;

    selectedGender.value = profile.gender;
    selectedConsultationMode.value = profile.consultationMode;

    selectedHospitalIds.assignAll(profile.hospitalIds);
    selectedSpecializations.assignAll(profile.specialization);
    selectedQualifications.assignAll(profile.qualification);
    selectedLanguages.assignAll(profile.languagesKnown);
    selectedSymptoms.assignAll(profile.symptomsCovered);
    selectedDiseases.assignAll(profile.diseasesCovered);
    pickedImage.value = null;
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value && doctorProfile.value != null) {
      _fillControllers(doctorProfile.value!);
    }
    update();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (image != null) {
      pickedImage.value = File(image.path);
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

  Future<void> updateProfile() async {
    if (doctorProfile.value == null) return;

    if (selectedQualifications.isEmpty) {
      AppSnackBar.show('Please select at least one qualification');
      return;
    }
    if (selectedSpecializations.isEmpty) {
      AppSnackBar.show('Please select at least one specialization');
      return;
    }

    isLoading.value = true;
    update();
    try {
      String? photoUrl = doctorProfile.value?.photoUrl;
      if (pickedImage.value != null) {
        final ref = _storage.ref().child('doctor_profiles').child(doctorProfile.value!.uid).child('profile.jpg');
        await ref.putFile(pickedImage.value!);
        photoUrl = await ref.getDownloadURL();
      }

      final data = {
        'doctorName': nameController.text.trim(),
        'qualification': selectedQualifications.toList(),
        'specialization': selectedSpecializations.toList(),
        'experience': int.tryParse(experienceController.text) ?? 0,
        'consultationFee': double.tryParse(feeController.text) ?? 0.0,
        'mobileNumber': mobileController.text.trim(),
        'gender': selectedGender.value,
        'languagesKnown': selectedLanguages.toList(),
        'biography': bioController.text.trim(),
        'consultationMode': selectedConsultationMode.value,
        'hospitalIds': selectedHospitalIds.toList(),
        'hospitalId': selectedHospitalIds.isNotEmpty ? selectedHospitalIds.first : '',
        'symptomsCovered': selectedSymptoms.toList(),
        'diseasesCovered': selectedDiseases.toList(),
        'photoUrl': photoUrl,
        'photo': photoUrl,
      };

      await _firestoreService.updateDoctor(doctorProfile.value!.doctorId, data);
      await loadProfile();
      isEditing.value = false;
      AppSnackBar.show('Profile updated successfully');
    } catch (e) {
      AppSnackBar.show('Failed to update profile: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}