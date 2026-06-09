import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../Repository/auth_repository.dart';
import '../../../models/hospital_model.dart';
import '../../../utils/helper.dart';
import '../../../utils/app_routes.dart';

class HospitalProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthRepository _authRepository = AuthRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final hospital = Rxn<HospitalModel>();

  // Basic Information
  final nameController = TextEditingController();
  final regNoController = TextEditingController();

  // Contact Information
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();

  // Address
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // Hospital Details
  final selectedDepartments = <String>[].obs;
  final customDeptController = TextEditingController();

  // Working Hours
  final openingTime = '09:00 AM'.obs;
  final closingTime = '08:00 PM'.obs;

  // Others
  final emergencyAvailable = false.obs;
  final selectedStatus = 'active'.obs;

  // Logo
  final logoPath = Rxn<String>();
  final logoUrl = Rxn<String>();

  final allDepartments = [
    'Cardiology',
    'ENT',
    'Orthopedics',
    'Neurology',
    'General Medicine',
    'Pediatrics',
    'Gynecology',
    'Dermatology',
    'Ophthalmology',
  ];

  @override
  void onInit() {
    super.onInit();
    loadHospitalData();
  }

  Future<void> loadHospitalData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      // 1. Try fetching by adminUid
      var myHospital = await _firestoreService.getHospitalByAdminUid(user.uid);

      // 2. Fallback: Search by adminUserId directly (Seed script support)
      if (myHospital == null) {
        final snap = await FirebaseFirestore.instance
            .collection('hospitals')
            .where('adminUserId', isEqualTo: user.uid)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          myHospital = HospitalModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
        }
      }

      if (myHospital != null) {
        hospital.value = myHospital;
        _populateFields(myHospital);
      }
    } catch (e) {
      debugPrint("Error loading hospital data: $e");
      Get.snackbar('Error', 'Failed to load hospital data');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void _populateFields(HospitalModel data) {
    nameController.text = data.hospitalName;
    regNoController.text = data.registrationNo;
    contactController.text = data.contactNumber;
    emailController.text = data.email;
    websiteController.text = data.website ?? '';
    addressController.text = data.address;
    cityController.text = data.city;
    stateController.text = data.state;
    pincodeController.text = data.pincode;

    selectedDepartments.assignAll(data.departments);
    openingTime.value = data.workingHours['open'] ?? '09:00 AM';
    closingTime.value = data.workingHours['close'] ?? '08:00 PM';

    emergencyAvailable.value = data.emergencyAvailable;
    selectedStatus.value = data.status;
    logoUrl.value = data.logo;
  }

  Future<void> pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      logoPath.value = image.path;
      update();
    }
  }

  Future<void> selectTime(BuildContext context, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? _parseTime(openingTime.value) : _parseTime(closingTime.value),
    );
    if (picked != null) {
      if (isOpening) {
        openingTime.value = picked.format(context);
      } else {
        closingTime.value = picked.format(context);
      }
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return const TimeOfDay(hour: 9, minute: 0);
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1].split(' ')[0]);
      if (timeStr.toLowerCase().contains('pm') && hour < 12) hour += 12;
      if (timeStr.toLowerCase().contains('am') && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  void toggleDepartment(String dept) {
    if (selectedDepartments.contains(dept)) {
      selectedDepartments.remove(dept);
    } else {
      selectedDepartments.add(dept);
    }
  }

  void addCustomDepartment() {
    final dept = customDeptController.text.trim();
    if (dept.isNotEmpty && !selectedDepartments.contains(dept)) {
      selectedDepartments.add(dept);
      customDeptController.clear();
    }
  }

  Future<String?> _uploadLogo(String hospitalId) async {
    if (logoPath.value == null) return logoUrl.value;
    try {
      final ref = _storage.ref().child('hospitals/$hospitalId/logo.jpg');
      await ref.putFile(File(logoPath.value!));
      return await ref.getDownloadURL();
    } catch (e) {
      return logoUrl.value;
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedDepartments.isEmpty) {
      AppSnackBar.show("Please select at least one department");
      return;
    }

    isLoading.value = true;
    update();

    try {
      final user = _auth.currentUser;
      final hId = hospital.value?.hospitalId ?? '';

      if (user == null || hId.isEmpty) {
        throw Exception("Hospital ID not found or user is null");
      }

      final finalLogoUrl = await _uploadLogo(hId);

      final updatedHospital = HospitalModel(
        hospitalId: hId,
        adminUserId: user.uid,
        hospitalName: nameController.text.trim(),
        registrationNo: regNoController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        pincode: pincodeController.text.trim(),
        contactNumber: contactController.text.trim(),
        email: emailController.text.trim(),
        website: websiteController.text.trim(),
        logo: finalLogoUrl,
        departments: selectedDepartments.toList(),
        workingHours: {'open': openingTime.value, 'close': closingTime.value},
        emergencyAvailable: emergencyAvailable.value,
        status: selectedStatus.value,
        createdBy: hospital.value?.createdBy ?? 'hospital_admin',
        createdAt: hospital.value?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateHospital(hId, updatedHospital.toMap());
      hospital.value = updatedHospital;

      ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully")));

      Future.delayed(const Duration(seconds: 1), () {
        Get.back();
      });
    } catch (e, stackTrace) {
      debugPrint("Error saving profile: $e");
      debugPrint("Stack Trace: $stackTrace");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authRepository.signOut();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    regNoController.dispose();
    contactController.dispose();
    emailController.dispose();
    websiteController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    customDeptController.dispose();
    super.onClose();
  }
}
