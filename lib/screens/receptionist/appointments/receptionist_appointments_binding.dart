import 'package:get/get.dart';
import 'receptionist_appointments_controller.dart';

class ReceptionistAppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReceptionistAppointmentsController>(() => ReceptionistAppointmentsController());
  }
}
