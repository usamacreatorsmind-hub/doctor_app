import 'package:get/get.dart';
import 'doctor_self_profile_controller.dart';

class DoctorSelfProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorSelfProfileController>(() => DoctorSelfProfileController());
  }
}
