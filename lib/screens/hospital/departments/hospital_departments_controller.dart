import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/hospital_model.dart';
import '../../../utils/helper.dart';

class HospitalDepartmentsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final hospital = Rxn<HospitalModel>();
  final departments = <String>[].obs;
  
  final departmentController = TextEditingController();

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
      final myHospital = await _firestoreService.getHospitalByAdminUid(user.uid);
      if (myHospital != null) {
        hospital.value = myHospital;
        departments.assignAll(myHospital.departments);
      }
    } catch (e) {
      AppSnackBar.show('Failed to load departments');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> addDepartment() async {
    final name = departmentController.text.trim();
    if (name.isEmpty) return;
    
    if (departments.contains(name)) {
      AppSnackBar.show('Department already exists');
      return;
    }

    departments.add(name);
    departmentController.clear();
    await _updateFirestore();
  }

  Future<void> editDepartment(int index, String newName) async {
    if (newName.isEmpty || departments.contains(newName)) return;
    departments[index] = newName;
    await _updateFirestore();
  }

  Future<void> deleteDepartment(int index) async {
    departments.removeAt(index);
    await _updateFirestore();
  }

  Future<void> _updateFirestore() async {
    if (hospital.value == null) return;
    
    try {
      await _firestoreService.updateHospital(
        hospital.value!.hospitalId, 
        {'departments': departments.toList()}
      );
      // Update local hospital model
      hospital.value = hospital.value!.copyWith(departments: departments.toList());
    } catch (e) {
      AppSnackBar.show('Failed to update departments');
    }
  }

  void showEditDialog(int index) {
    final editCtrl = TextEditingController(text: departments[index]);
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Department'),
        content: TextField(
          controller: editCtrl,
          decoration: const InputDecoration(hintText: 'Department Name'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              editDepartment(index, editCtrl.text.trim());
              Get.back();
            }, 
            child: const Text('Update')
          ),
        ],
      )
    );
  }

  @override
  void onClose() {
    departmentController.dispose();
    super.onClose();
  }
}
