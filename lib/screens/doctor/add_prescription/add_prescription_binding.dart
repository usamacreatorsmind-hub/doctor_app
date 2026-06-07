import 'package:get/get.dart';
import 'add_prescription_controller.dart';

class AddPrescriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddPrescriptionController>(() => AddPrescriptionController());
  }
}
