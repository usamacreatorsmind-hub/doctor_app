import 'package:get/get.dart';
import 'doctor_schedule_controller.dart';

class DoctorScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoctorScheduleController>(() => DoctorScheduleController());
  }
}
