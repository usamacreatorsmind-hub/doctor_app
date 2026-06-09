import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/doctor_model.dart';
import '../../../models/hospital_model.dart';

class DoctorSelfProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final isMasterLoading = false.obs;
  final isEditing = false.obs;
  final doctorProfile = Rxn<DoctorModel>();

  // Master Data Lists (Dynamic from DB)
  final hospitals = <HospitalModel>[].obs;
  final availableSpecializations = <String>[].obs;
  final availableSymptoms = <String>[].obs;
  final availableDiseases = <String>[].obs;
  final availableLanguages = <String>['Hindi', 'English', 'Punjabi', 'Marathi', 'Gujarati', 'Tamil', 'Bengali'].obs;

  // Form Controllers
  late TextEditingController nameController;
  late TextEditingController qualificationController;
  late TextEditingController experienceController;
  late TextEditingController feeController;
  late TextEditingController bioController;
  late TextEditingController mobileController;

  // Selected values (Reactive)
  final selectedHospitalIds = <String>[].obs;
  final selectedSpecializations = <String>[].obs;
  final selectedSymptoms = <String>[].obs;
  final selectedDiseases = <String>[].obs;
  final selectedLanguages = <String>[].obs;
  
  final selectedGender = 'male'.obs;
  final selectedConsultationMode = 'Both'.obs;

  // Image upload
  final pickedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    qualificationController = TextEditingController();
    experienceController = TextEditingController();
    feeController = TextEditingController();
    bioController = TextEditingController();
    mobileController = TextEditingController();
    loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    qualificationController.dispose();
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
      print("Error loading profile: $e");
      Get.snackbar('Error', 'Failed to load profile');
    }
  }

  void _fillControllers(DoctorModel profile) {
    nameController.text = profile.doctorName;
    qualificationController.text = profile.qualification;
    experienceController.text = profile.experience.toString();
    feeController.text = profile.consultationFee.toString();
    bioController.text = profile.biography ?? '';
    mobileController.text = profile.mobileNumber;
    
    selectedGender.value = profile.gender;
    selectedConsultationMode.value = profile.consultationMode;
    
    selectedHospitalIds.assignAll(profile.hospitalIds);
    selectedSpecializations.assignAll(profile.specialization);
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

  Future<String?> _uploadImage(String userId) async {
    if (pickedImage.value == null) return doctorProfile.value?.photoUrl;
    
    try {
      // Path: doctor_profiles/{userId}/profile.jpg
      final ref = _storage.ref().child('doctor_profiles').child(userId).child('profile.jpg');
      await ref.putFile(pickedImage.value!);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
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

    if (selectedSpecializations.isEmpty) {
      Get.snackbar('Error', 'Please select at least one specialization');
      return;
    }

    isLoading.value = true;
    update();
    try {
      // 1. Upload image if picked
      final String? photoUrl = await _uploadImage(doctorProfile.value!.uid);

      // 2. Prepare data map
      final data = {
        'doctorName': nameController.text.trim(),
        'qualification': qualificationController.text.trim(),
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
        'photo': photoUrl, // For seed script compatibility
      };

      // 3. Update Firestore
      await _firestoreService.updateDoctor(doctorProfile.value!.doctorId, data);
      
      // 4. Refresh local data
      await loadProfile();
      isEditing.value = false;
      Get.snackbar('Success', 'Profile updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
