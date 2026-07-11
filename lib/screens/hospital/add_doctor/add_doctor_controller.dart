import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../firebase_options.dart';
import '../../../models/doctor_model.dart';
import '../../../models/user_model.dart';
import '../../../utils/helper.dart';

class AddDoctorController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final experienceController = TextEditingController();
  final feeController = TextEditingController();
  final bookingFeeController = TextEditingController(text: '50');
  final bioController = TextEditingController();

  final isLoading = false.obs;
  final isMasterLoading = false.obs;
  final isPasswordHidden = true.obs;
  final selectedGender = 'male'.obs;
  final selectedMode = 'Offline'.obs;

  late String currentHospitalId;

  // Master Data Lists (Fetched from Firestore)
  final availableSpecializations = <String>[].obs;
  final availableQualifications = <String>[].obs;
  final availableSymptoms = <String>[].obs;
  final availableDiseases = <String>[].obs;
  final availableLanguages = <String>['Hindi', 'English', 'Punjabi', 'Marathi', 'Gujarati', 'Tamil', 'Bengali'].obs;

  final selectedSpecializations = <String>[].obs;
  final selectedQualifications = <String>[].obs;
  final selectedSymptoms = <String>[].obs;
  final selectedDiseases = <String>[].obs;
  final selectedLanguages = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Safe argument access
    currentHospitalId = (Get.arguments as Map?)?['hospitalId'] ?? '';
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
        _firestoreService.getQualifications(),
      ]);

      availableSpecializations.assignAll(results[0]);
      availableSymptoms.assignAll(results[1]);
      availableDiseases.assignAll(results[2]);
      availableQualifications.assignAll(results[3]);

      debugPrint("AddDoctor: Loaded ${availableSymptoms.length} symptoms from DB");
    } catch (e) {
      debugPrint("Error fetching master data: $e");
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

  void togglePasswordVisibility() => isPasswordHidden.value = !isPasswordHidden.value;
  void selectGender(String val) => selectedGender.value = val;
  void selectMode(String val) => selectedMode.value = val;

  Future<void> saveDoctor() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) return;

    if (selectedSpecializations.isEmpty) {
      AppSnackBar.show('Please select at least one specialization');
      return;
    }
    if (selectedQualifications.isEmpty) {
      AppSnackBar.show('Please select at least one qualification');
      return;
    }

    isLoading.value = true;
    update();

    FirebaseApp? secondaryApp;
    try {
      // 1. Create Auth Account using Secondary App
      secondaryApp = await Firebase.initializeApp(name: 'DoctorCreationApp', options: DefaultFirebaseOptions.currentPlatform);
      final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      UserCredential userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        final String uid = userCredential.user!.uid;

        // 2. Create Doctor Profile
        final doctor = DoctorModel(
          doctorId: '',
          uid: uid,
          hospitalId: currentHospitalId,
          hospitalIds: [currentHospitalId],
          doctorName: nameController.text.trim(),
          qualification: selectedQualifications.toList(),
          specialization: selectedSpecializations.toList(),
          experience: int.tryParse(experienceController.text) ?? 0,
          consultationFee: double.tryParse(feeController.text) ?? 0.0,
          bookingFee: double.tryParse(bookingFeeController.text) ?? 50.0,
          mobileNumber: mobileController.text.trim(),
          email: emailController.text.trim(),
          gender: selectedGender.value,
          languagesKnown: selectedLanguages.toList(),
          biography: bioController.text.trim(),
          symptomsCovered: selectedSymptoms.toList(),
          diseasesCovered: selectedDiseases.toList(),
          consultationMode: selectedMode.value,
          status: 'active',
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
          status: 'active',
          doctorId: doctorId,
          hospitalId: currentHospitalId,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);

        await secondaryAuth.signOut();
        Get.back();
        AppSnackBar.show('Doctor registered successfully');
      }
    } on FirebaseAuthException catch (e) {
      AppSnackBar.show(e.message ?? 'Auth failed');
    } catch (e) {
      AppSnackBar.show('Error: $e');
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    experienceController.dispose();
    feeController.dispose();
    bookingFeeController.dispose();
    bioController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) => (value == null || !GetUtils.isEmail(value)) ? 'Invalid email' : null;
  String? validateMobile(String? value) => (value == null || value.length != 10) ? 'Enter 10-digit mobile' : null;
  String? validatePassword(String? value) => (value == null || value.length < 6) ? 'Min 6 characters' : null;
}
