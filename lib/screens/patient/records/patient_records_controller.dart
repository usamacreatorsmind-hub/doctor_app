import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/prescription_model.dart';

class PatientRecordsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = true.obs;
  final prescriptions = <PrescriptionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final results = await _firestoreService.getPatientPrescriptions(user.uid);
      prescriptions.value = results;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load medical records');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> onRefresh() async => await loadRecords();
}
