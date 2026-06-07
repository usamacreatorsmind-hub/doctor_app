import 'package:get/get.dart';
import 'hospital_reports_controller.dart';

class HospitalReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HospitalReportsController>(() => HospitalReportsController());
  }
}
