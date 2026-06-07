import 'package:get/get.dart';
import 'doctor_dashboard_controller.dart';

class DoctorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorDashboardController>(() => DoctorDashboardController());
  }
}
