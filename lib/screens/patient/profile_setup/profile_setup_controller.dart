import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/patient_profile_model.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_routes.dart';
import '../../../Repository/FirestoreService.dart';

class ProfileSetupController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final currentStep = 0.obs;
  final isLoading   = false.obs;
  final isSaving    = false.obs;

  // Form Keys
  final step1FormKey = GlobalKey<FormState>();
  final step2FormKey = GlobalKey<FormState>();
  final step3FormKey = GlobalKey<FormState>();

  // Step 1 Controllers
  final nameController      = TextEditingController();
  final mobileController    = TextEditingController();
  final dobController       = TextEditingController();
  final addressController   = TextEditingController();
  final cityController      = TextEditingController();
  final stateController     = TextEditingController();
  final pincodeController   = TextEditingController();

  final selectedGender     = ''.obs;
  final selectedBloodGroup = ''.obs;
  final profilePhotoPath   = ''.obs;

  final genders     = ['Male', 'Female', 'Other'];
  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  // Step 2 Controllers
  final medicalHistoryController   = TextEditingController();
  final medicationController       = TextEditingController();
  final allergyController          = TextEditingController();

  final medicalHistoryList   = <String>[].obs;
  final currentMedications   = <String>[].obs;
  final allergiesList        = <String>[].obs;

  final commonDiseases = ['Diabetes', 'Hypertension', 'Asthma', 'Heart Disease', 'Thyroid', 'Arthritis', 'Anemia', 'None'];
  final commonAllergies = ['Penicillin', 'Aspirin', 'Sulfa Drugs', 'Latex', 'Dust', 'Pollen', 'Nuts', 'None'];

  // Step 3 Controllers
  final emergencyNameController     = TextEditingController();
  final emergencyNumberController   = TextEditingController();
  final insuranceProviderController = TextEditingController();
  final insurancePolicyController   = TextEditingController();

  final selectedRelation = ''.obs;
  final relations = ['Father', 'Mother', 'Spouse', 'Sibling', 'Friend', 'Other'];

  final steps = [
    {'title': 'Personal',  'subtitle': 'Basic info'},
    {'title': 'Medical',   'subtitle': 'Health info'},
    {'title': 'Emergency', 'subtitle': 'Contact & Insurance'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadExistingProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    dobController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    medicalHistoryController.dispose();
    medicationController.dispose();
    allergyController.dispose();
    emergencyNameController.dispose();
    emergencyNumberController.dispose();
    insuranceProviderController.dispose();
    insurancePolicyController.dispose();
    super.onClose();
  }

  Future<void> _loadExistingProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      // 1. Load basic user data (Name and Mobile)
      UserModel? userData = await _firestoreService.getUser(user.uid);
      if (userData != null) {
        nameController.text = userData.name;
        mobileController.text = userData.mobile;
      }

      // 2. Load detailed profile
      final profile = await _firestoreService.getPatientProfile(user.uid);
      if (profile != null) {
        // Step 1: Text Fields
        dobController.text = profile.dob ?? '';
        addressController.text = profile.address ?? '';
        cityController.text = profile.city ?? '';
        stateController.text = profile.state ?? '';
        pincodeController.text = profile.pincode ?? '';
        
        // Gender Auto-fill with Casing Logic
        if (profile.gender != null && profile.gender!.isNotEmpty) {
          String g = profile.gender!.trim().toLowerCase();
          if (g == 'male') {
            selectedGender.value = 'Male';
          } else if (g == 'female') {
            selectedGender.value = 'Female';
          } else if (g == 'other') {
            selectedGender.value = 'Other';
          } else {
            for (var opt in genders) {
              if (opt.toLowerCase() == g) {
                selectedGender.value = opt;
                break;
              }
            }
          }
        }

        // Blood Group Auto-fill
        if (profile.bloodGroup != null && profile.bloodGroup!.isNotEmpty) {
          String bg = profile.bloodGroup!.trim().toUpperCase();
          if (bg.contains('POSITIVE')) bg = bg.replaceAll('POSITIVE', '+').replaceAll(' ', '');
          if (bg.contains('NEGATIVE')) bg = bg.replaceAll('NEGATIVE', '-').replaceAll(' ', '');
          
          if (bloodGroups.contains(bg)) {
            selectedBloodGroup.value = bg;
          }
        }

        // Step 2: Lists
        medicalHistoryList.assignAll(profile.medicalHistory);
        currentMedications.assignAll(profile.currentMedications);
        allergiesList.assignAll(profile.allergies);

        // Step 3: Emergency Info
        emergencyNameController.text = profile.emergencyContactName ?? '';
        emergencyNumberController.text = profile.emergencyContactNumber ?? '';
        selectedRelation.value = profile.emergencyContactRelation ?? '';
        insuranceProviderController.text = profile.insuranceProvider ?? '';
        insurancePolicyController.text = profile.insurancePolicyNumber ?? '';
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void selectGender(String gender) { selectedGender.value = gender; update(); }
  void selectBloodGroup(String bg) { selectedBloodGroup.value = bg; update(); }
  void selectRelation(String relation) { selectedRelation.value = relation; update(); }

  Future<void> pickDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      update();
    }
  }

  void toggleMedicalHistory(String disease) {
    if (medicalHistoryList.contains(disease)) {
      medicalHistoryList.remove(disease);
    } else {
      if (disease == 'None') {
        medicalHistoryList.clear();
      } else {
        medicalHistoryList.remove('None');
      }
      medicalHistoryList.add(disease);
    }
    update();
  }

  void addCustomMedicalHistory() {
    final text = medicalHistoryController.text.trim();
    if (text.isNotEmpty && !medicalHistoryList.contains(text)) {
      medicalHistoryList.add(text);
      medicalHistoryController.clear();
      update();
    }
  }

  void removeMedicalHistory(String item) {
    medicalHistoryList.remove(item);
    update();
  }

  void addMedication() {
    final text = medicationController.text.trim();
    if (text.isNotEmpty && !currentMedications.contains(text)) {
      currentMedications.add(text);
      medicationController.clear();
      update();
    }
  }

  void removeMedication(String item) {
    currentMedications.remove(item);
    update();
  }

  void toggleAllergy(String allergy) {
    if (allergiesList.contains(allergy)) {
      allergiesList.remove(allergy);
    } else {
      if (allergy == 'None') {
        allergiesList.clear();
      } else {
        allergiesList.remove('None');
      }
      allergiesList.add(allergy);
    }
    update();
  }

  void addCustomAllergy() {
    final text = allergyController.text.trim();
    if (text.isNotEmpty && !allergiesList.contains(text)) {
      allergiesList.add(text);
      allergyController.clear();
      update();
    }
  }

  void removeAllergy(String item) {
    allergiesList.remove(item);
    update();
  }

  double get progressValue => (currentStep.value + 1) / steps.length;
  String get nextBtnLabel => currentStep.value == steps.length - 1 ? 'Save & Continue' : 'Next';

  void onNextStep() {
    if (currentStep.value == 0 && !step1FormKey.currentState!.validate()) return;
    if (currentStep.value == 0 && selectedGender.value.isEmpty) {
      Get.snackbar('Required', 'Please select your gender', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (currentStep.value < 2) {
      currentStep.value++;
      update();
    } else {
      _saveProfile();
    }
  }

  void onBackStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      update();
    }
  }

  void onSkip() => Get.offAllNamed(AppRoutes.patientDashboard);

  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    isSaving.value = true;
    update();
    try {
      // 1. Update basic user info in users collection
      await _firestoreService.updateUser(user.uid, {
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
      });

      // 2. Save profile in profile collection
      final profile = PatientProfileModel(
        dob: dobController.text,
        gender: selectedGender.value,
        bloodGroup: selectedBloodGroup.value,
        address: addressController.text,
        city: cityController.text,
        state: stateController.text,
        pincode: pincodeController.text,
        medicalHistory: medicalHistoryList.toList(),
        currentMedications: currentMedications.toList(),
        allergies: allergiesList.toList(),
        emergencyContactName: emergencyNameController.text,
        emergencyContactNumber: emergencyNumberController.text,
        emergencyContactRelation: selectedRelation.value,
        insuranceProvider: insuranceProviderController.text,
        insurancePolicyNumber: insurancePolicyController.text,
        isProfileComplete: true,
      );
      
      await _firestoreService.savePatientProfile(user.uid, profile);

      Get.snackbar('Success', 'Profile updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.patientDashboard);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save profile: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
      update();
    }
  }
}
