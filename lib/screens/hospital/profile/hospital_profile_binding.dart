import 'package:get/get.dart';
import 'hospital_profile_controller.dart';

class HospitalProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HospitalProfileController>(() => HospitalProfileController());
  }
}
