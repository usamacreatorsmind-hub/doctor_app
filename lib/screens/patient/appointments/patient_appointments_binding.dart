import 'package:get/get.dart';
import 'patient_appointments_controller.dart';

class PatientAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientAppointmentsController>(() => PatientAppointmentsController());
  }
}
