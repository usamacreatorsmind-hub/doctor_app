import 'package:get/get.dart';
import 'doctor_reports_controller.dart';

class DoctorReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorReportsController>(() => DoctorReportsController());
  }
}
