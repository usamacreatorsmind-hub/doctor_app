import 'package:get/get.dart';
import 'hospital_appointments_controller.dart';

class HospitalAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HospitalAppointmentsController>(() => HospitalAppointmentsController());
  }
}
