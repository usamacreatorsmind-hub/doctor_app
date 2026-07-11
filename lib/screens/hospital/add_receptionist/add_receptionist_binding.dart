import 'package:get/get.dart';
import 'add_receptionist_controller.dart';

class AddReceptionistBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddReceptionistController>(() => AddReceptionistController());
  }
}
