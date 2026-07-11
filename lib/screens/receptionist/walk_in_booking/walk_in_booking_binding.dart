import 'package:get/get.dart';
import 'walk_in_booking_controller.dart';

class WalkInBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalkInBookingController>(() => WalkInBookingController());
  }
}
