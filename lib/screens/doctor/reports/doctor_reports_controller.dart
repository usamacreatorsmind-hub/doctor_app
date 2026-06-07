import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/appointment_model.dart';

class DoctorReportsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = true.obs;
  final totalAppointments = 0.obs;
  final completedAppointments = 0.obs;
  final totalEarnings = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    calculateReports();
  }

  Future<void> calculateReports() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final doctor = await _firestoreService.getDoctorByUid(user.uid);
      if (doctor != null) {
        // ✅ Fixed: Added 'date:' named parameter
        final allAppts = await _firestoreService.getDoctorAppointments(doctor.doctorId, date: null);
        
        totalAppointments.value = allAppts.length;
        completedAppointments.value = allAppts.where((a) => a.status == 'Completed').length;
        
        double earnings = 0;
        for (var a in allAppts) {
          if (a.status == 'Completed' && (a.paymentStatus == 'Paid' || a.paymentStatus == 'Success')) {
            earnings += a.fee;
          }
        }
        totalEarnings.value = earnings;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to calculate reports');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
