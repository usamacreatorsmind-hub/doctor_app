import 'package:get/get.dart';
import 'patient_records_controller.dart';

class PatientRecordsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientRecordsController>(() => PatientRecordsController());
  }
}
