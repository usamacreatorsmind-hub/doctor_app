import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/appointment_model.dart';
import '../../../models/doctor_model.dart';
import '../../../utils/helper.dart';

class HospitalReportsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = true.obs;
  
  // Summary Stats
  final totalAppointments = 0.obs;
  final totalRevenue = 0.0.obs;
  
  // Distribution Stats
  final doctorWiseStats = <String, int>{}.obs;
  final deptWiseStats = <String, int>{}.obs;
  final statusSummary = <String, int>{}.obs;
  
  // For mapping ID to Name in reports
  final doctorNames = <String, String>{}.obs;

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
        // Fetch all doctors to get their departments and names
        final doctors = await _firestoreService.getDoctorsByHospital(hospital.hospitalId);
        Map<String, String> docIdToName = {};
        Map<String, List<String>> docIdToDepts = {};
        
        for (var d in doctors) {
          docIdToName[d.doctorId] = d.doctorName;
          docIdToDepts[d.doctorId] = d.specialization; // Using specialization as department here or map to hospital departments
        }
        doctorNames.assignAll(docIdToName);

        // Fetch all appointments
        final appts = await _firestoreService.getHospitalAppointments(hospital.hospitalId);
        
        totalAppointments.value = appts.length;
        
        double revenue = 0;
        Map<String, int> dStats = {};
        Map<String, int> deptStats = {};
        Map<String, int> sSummary = {
          'Pending': 0,
          'Confirmed': 0,
          'Completed': 0,
          'Cancelled': 0,
        };

        for (var a in appts) {
          // Revenue
          if (a.paymentStatus == 'Paid' || a.paymentStatus == 'Success') {
            revenue += a.fee;
          }
          
          // Status Summary
          sSummary[a.status] = (sSummary[a.status] ?? 0) + 1;

          // Doctor Stats
          final docName = docIdToName[a.doctorId] ?? 'Unknown Doctor';
          dStats[docName] = (dStats[docName] ?? 0) + 1;
          
          // Department Stats (from doctor's first specialization for simplicity)
          final depts = docIdToDepts[a.doctorId];
          if (depts != null && depts.isNotEmpty) {
            final dept = depts.first;
            deptStats[dept] = (deptStats[dept] ?? 0) + 1;
          } else {
            deptStats['General'] = (deptStats['General'] ?? 0) + 1;
          }
        }
        
        totalRevenue.value = revenue;
        doctorWiseStats.assignAll(dStats);
        deptWiseStats.assignAll(deptStats);
        statusSummary.assignAll(sSummary);
      }
    } catch (e) {
      AppSnackBar.show('Failed to generate report: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
