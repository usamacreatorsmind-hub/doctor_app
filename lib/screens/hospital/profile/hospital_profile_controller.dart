import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/hospital_model.dart';

class HospitalProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final hospital = Rxn<HospitalModel>();

  // Controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final emergencyAvailable = false.obs;

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
      final hospitals = await _firestoreService.getAllHospitals();
      final myHospital = hospitals.firstWhereOrNull((h) => h.adminUid == user.uid);
      
      if (myHospital != null) {
        hospital.value = myHospital;
        nameController.text = myHospital.hospitalName;
        addressController.text = myHospital.address;
        cityController.text = myHospital.city;
        stateController.text = myHospital.state;
        pincodeController.text = myHospital.pincode;
        contactController.text = myHospital.contactNumber;
        emailController.text = myHospital.email;
        websiteController.text = myHospital.website ?? '';
        emergencyAvailable.value = myHospital.emergencyAvailable;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;
    if (hospital.value == null) return;

    isLoading.value = true;
    update();

    try {
      final updateData = {
        'hospitalName': nameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'contactNumber': contactController.text.trim(),
        'email': emailController.text.trim(),
        'website': websiteController.text.trim(),
        'emergencyAvailable': emergencyAvailable.value,
      };

      await _firestoreService.updateHospital(hospital.value!.hospitalId, updateData);
      Get.snackbar('Success', 'Hospital profile updated successfully', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Update failed: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    contactController.dispose();
    emailController.dispose();
    websiteController.dispose();
    super.onClose();
  }
}
