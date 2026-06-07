import 'package:get/get.dart';
import 'booking_success_controller.dart';

class BookingSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingSuccessController>(() => BookingSuccessController());
  }
}
