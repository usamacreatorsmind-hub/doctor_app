import 'package:get/get.dart';
import 'doctor_search_controller.dart';

class DoctorSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorSearchController>(() => DoctorSearchController());
  }
}
