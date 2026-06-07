import 'package:get/get.dart';
import '../../../models/doctor_model.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../utils/app_routes.dart';

class DoctorProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  late DoctorModel doctor;
  final isLoading = false.obs;
  final hospitalName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['doctor'] != null) {
      doctor = args['doctor'];
      _loadHospitalDetails();
    } else {
      Get.back();
    }
  }

  Future<void> _loadHospitalDetails() async {
    try {
      final hospital = await _firestoreService.getHospital(doctor.hospitalId);
      if (hospital != null) {
        hospitalName.value = hospital.hospitalName;
      }
    } catch (e) {
      print("Error loading hospital: $e");
    }
  }

  void onBookAppointment() {
    Get.toNamed(AppRoutes.slotSelection, arguments: {'doctor': doctor});
  }
}
