import 'package:get/get.dart';
import 'slot_selection_controller.dart';

class SlotSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SlotSelectionController>(() => SlotSelectionController());
  }
}
