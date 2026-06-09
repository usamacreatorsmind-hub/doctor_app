import 'package:get/get.dart';
import 'doctor_register_controller.dart';

class DoctorRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorRegisterController>(() => DoctorRegisterController());
  }
}
