import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../Repository/auth_repository.dart';
import '../../../models/user_model.dart';
import '../../../models/doctor_model.dart';
import '../../../models/hospital_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/helper.dart';
import '../../Login/login_controller.dart';

class DoctorRegisterController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://ayuveda-care-42292.firebasestorage.app');
  final ImagePicker _picker = ImagePicker();

  final pickedImage = Rxn<File>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final experienceController = TextEditingController();
  final feeController = TextEditingController();
  final bookingFeeController = TextEditingController(text: '50');
  final bioController = TextEditingController();
  final clinicNameController = TextEditingController();

  // Address Controllers for Clinic
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  final latitude = Rxn<double>();
  final longitude = Rxn<double>();

  // Selections
  final isLoading = false.obs;
  final isMasterLoading = false.obs;
  final isPasswordHidden = true.obs;

  final practiceType = 'hospital'.obs; // 'hospital' or 'clinic'

  // Multiple Hospitals Selection
  final selectedHospitalIds = <String>[].obs;

  final selectedGender = 'male'.obs;
  final selectedConsultationMode = 'Offline'.obs; // Default to Offline

  // Master Data Lists (Fetched from Firestore)
  final hospitals = <HospitalModel>[].obs;
  final availableSpecializations = <String>[].obs;
  final availableQualifications = <String>[].obs; // Added
  final availableSymptoms = <String>[].obs;
  final availableDiseases = <String>[].obs;
  final availableLanguages = <String>['Hindi', 'English', 'Punjabi', 'Marathi', 'Gujarati', 'Tamil', 'Bengali'].obs;

  final selectedSpecializations = <String>[].obs;
  final selectedQualifications = <String>[].obs; // Added
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
        _firestoreService.getQualifications(), // Added
      ]);

      hospitals.assignAll(results[0] as List<HospitalModel>);

      availableSpecializations.assignAll(results[1] as List<String>);
      availableSymptoms.assignAll(results[2] as List<String>);
      availableDiseases.assignAll(results[3] as List<String>);
      availableQualifications.assignAll(results[4] as List<String>);

      print("DataGets hospitals  ${hospitals}");
      print("DataGets hospitals  ${availableSpecializations}");
      print("DataGets hospitals  ${availableSymptoms}");
      print("DataGets hospitals  ${availableDiseases}");
      print("DataGets hospitals  ${availableQualifications}");

      // Added
    } catch (e) {
      print("Error fetching master data: $e");
    } finally {
      isMasterLoading.value = false;
      update();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppSnackBar.show('Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppSnackBar.show('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppSnackBar.show('Location permissions are permanently denied.');
        return;
      }

      isLoading.value = true;
      update();

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // ── Reverse Geocoding ──
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];

          String name = place.name ?? "";
          String street = place.street ?? "";
          String subLocality = place.subLocality ?? "";
          String locality = place.locality ?? "";
          String subAdministrativeArea = place.subAdministrativeArea ?? "";
          String administrativeArea = place.administrativeArea ?? "";

          // More robust address construction
          List<String> addressParts = [];
          if (name.isNotEmpty && name != street) addressParts.add(name);
          if (street.isNotEmpty) addressParts.add(street);
          if (subLocality.isNotEmpty) addressParts.add(subLocality);
          if (locality.isNotEmpty) addressParts.add(locality);

          addressController.text = addressParts.join(", ");

          // Fallback for City
          cityController.text = locality.isNotEmpty ? locality : subAdministrativeArea;
          stateController.text = administrativeArea;
          pincodeController.text = place.postalCode ?? "";

          update(); // Force UI refresh
        }
      } catch (e) {
        debugPrint("Reverse geocoding failed: $e");
      }

      AppSnackBar.show('Location & Address Fetched Successfully 📍');
    } catch (e) {
      debugPrint("Error getting location: $e");
      AppSnackBar.show('Failed to get location: $e');
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
    passwordController.dispose();
    experienceController.dispose();
    feeController.dispose();
    bookingFeeController.dispose();
    bioController.dispose();
    clinicNameController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.onClose();
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

  void showImagePickerBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Profile Picture',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: const Text('Take Photo from Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            if (pickedImage.value != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                ),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.back();
                  pickedImage.value = null;
                  update();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 800, maxHeight: 800);
      if (image != null) {
        pickedImage.value = File(image.path);
        update();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      AppSnackBar.show('Failed to pick image: $e');
    }
  }

  Future<void> onRegisterPressed() async {
    if (!formKey.currentState!.validate()) return;

    if (practiceType.value == 'hospital' && selectedHospitalIds.isEmpty) {
      AppSnackBar.show('Please select at least one hospital');
      return;
    }

    if (practiceType.value == 'clinic' && clinicNameController.text.trim().isEmpty) {
      AppSnackBar.show('Please enter your clinic name');
      return;
    }

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
      // 1. Create Auth User
      UserCredential? userCredential = await _authRepository.signUpAuth(emailController.text.trim(), passwordController.text.trim());

      if (userCredential != null && userCredential.user != null) {
        final String uid = userCredential.user!.uid;

        // Upload Profile Photo if selected
        String? uploadedPhotoUrl;
        if (pickedImage.value != null) {
          try {
            final ref = _storage.ref().child('doctor_profiles').child(uid).child('profile.jpg');
            await ref.putFile(pickedImage.value!);
            uploadedPhotoUrl = await ref.getDownloadURL();
          } catch (e) {
            debugPrint("Doctor photo upload error: $e");
            AppSnackBar.show('Photo upload error: $e');
          }
        }

        String finalHospitalId = '';
        List<String> finalHospitalIds = [];

        if (practiceType.value == 'clinic') {
          // Create a new Hospital record for the individual clinic
          final clinic = HospitalModel(
            hospitalId: '',
            adminUserId: uid,
            hospitalName: clinicNameController.text.trim(),
            registrationNo: 'CLINIC-${DateTime.now().millisecondsSinceEpoch}',
            address: addressController.text.trim().isEmpty ? 'To be updated' : addressController.text.trim(),
            city: cityController.text.trim().isEmpty ? 'To be updated' : cityController.text.trim(),
            state: stateController.text.trim().isEmpty ? 'To be updated' : stateController.text.trim(),
            pincode: pincodeController.text.trim(),
            contactNumber: mobileController.text.trim(),
            email: emailController.text.trim(),
            departments: selectedSpecializations.toList(),
            workingHours: {'open': '09:00 AM', 'close': '08:00 PM'},
            emergencyAvailable: false,
            status: 'active',
            createdAt: DateTime.now(),
            latitude: latitude.value,
            longitude: longitude.value,
          );
          finalHospitalId = await _firestoreService.createHospital(clinic);
          finalHospitalIds = [finalHospitalId];
        } else {
          finalHospitalId = selectedHospitalIds.first;
          finalHospitalIds = selectedHospitalIds.toList();
        }

        // 2. Create Doctor Profile
        final doctor = DoctorModel(
          doctorId: '',
          uid: uid,
          hospitalId: finalHospitalId,
          hospitalIds: finalHospitalIds,
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
          photoUrl: uploadedPhotoUrl,
          symptomsCovered: selectedSymptoms.toList(),
          diseasesCovered: selectedDiseases.toList(),
          consultationMode: selectedConsultationMode.value,
          status: practiceType.value == 'clinic' ? 'active' : 'pending',
          practiceType: practiceType.value,
          clinicName: practiceType.value == 'clinic' ? clinicNameController.text.trim() : null,
          createdAt: DateTime.now(),
          latitude: latitude.value,
          longitude: longitude.value,
        );

        final String doctorId = await _firestoreService.createDoctor(doctor);

        // 3. Create User Document
        final userModel = UserModel(
          uid: uid,
          name: nameController.text.trim(),
          mobile: mobileController.text.trim(),
          email: emailController.text.trim(),
          role: 'doctor',
          status: practiceType.value == 'clinic' ? 'active' : 'pending',
          doctorId: doctorId,
          hospitalId: finalHospitalId,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUser(userModel);

        // 4. Create Join Requests (Only for Hospital path)
        if (practiceType.value == 'hospital') {
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
          AppSnackBar.show('Registration successful! Please wait for admin approval.');
        } else {
          AppSnackBar.show('Registration successful! Your clinic profile is ready.');
        }

        Get.offAllNamed(AppRoutes.login, arguments: {'role': LoginRole.doctor});
      }
    } catch (e) {
      AppSnackBar.show(e.toString());
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
