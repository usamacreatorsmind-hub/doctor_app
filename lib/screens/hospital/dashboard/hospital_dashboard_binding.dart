import 'package:get/get.dart';
import 'hospital_dashboard_controller.dart';

class HospitalDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HospitalDashboardController>(() => HospitalDashboardController());
  }
}
