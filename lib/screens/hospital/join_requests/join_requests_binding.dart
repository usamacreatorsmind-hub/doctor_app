import 'package:get/get.dart';
import 'join_requests_controller.dart';

class JoinRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinRequestsController>(() => JoinRequestsController());
  }
}
