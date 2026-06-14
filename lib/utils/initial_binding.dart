import 'package:get/get.dart';
import '../services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NotificationService(), permanent: true);
  }
}