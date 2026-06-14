import 'package:get/get.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/helper.dart';

class BookingSuccessController extends GetxController {
  late String doctorName;
  late String date;
  late String time;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['doctorName'] != null && args['date'] != null && args['time'] != null) {
      doctorName = args['doctorName'];
      date = args['date'];
      time = args['time'];
    } else {
      Get.offAllNamed(AppRoutes.patientDashboard); // Go to dashboard if details are missing
      AppSnackBar.show('Booking success details missing');

    }
  }

  void goToDashboard() {
    Get.offAllNamed(AppRoutes.patientDashboard);
  }
}
