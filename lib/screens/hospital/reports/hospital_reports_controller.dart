import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/appointment_model.dart';

class HospitalReportsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = true.obs;
  final totalAppointments = 0.obs;
  final totalRevenue = 0.0.obs;
  final doctorWiseStats = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    generateHospitalReport();
  }

  Future<void> generateHospitalReport() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final hospital = await _firestoreService.getHospitalByAdminUid(user.uid);
      if (hospital != null) {
        // Fetching all appointments for this hospital by passing null date
        // ✅ Fix: Added 'date:' label and passing null to get all appointments for the hospital
        final appts = await _firestoreService.getHospitalAppointments(hospital.hospitalId, date: null);
        
        totalAppointments.value = appts.length;
        
        double revenue = 0;
        Map<String, int> docStats = {};

        for (var a in appts) {
          if (a.paymentStatus == 'Paid' || a.paymentStatus == 'Success') {
            revenue += a.fee;
          }
          // Increment count for each doctor
          docStats[a.doctorId] = (docStats[a.doctorId] ?? 0) + 1;
        }
        
        totalRevenue.value = revenue;
        doctorWiseStats.value = docStats;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate report');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
