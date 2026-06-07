

import 'package:doctor_app/utils/app_routes.dart' show AppRoutes;
import 'package:get/get.dart';


class SplashController extends GetxController {

  @override
  void onInit() {
    super.onInit();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed(AppRoutes.onboarding);
    });
  }
}
