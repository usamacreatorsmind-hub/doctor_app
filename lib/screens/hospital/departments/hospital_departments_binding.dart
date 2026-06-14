import 'package:get/get.dart';
import 'hospital_departments_controller.dart';

class HospitalDepartmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HospitalDepartmentsController>(() => HospitalDepartmentsController());
  }
}
