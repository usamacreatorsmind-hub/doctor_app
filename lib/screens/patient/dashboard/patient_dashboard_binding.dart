import 'package:get/get.dart';
import 'patient_dashboard_controller.dart';
import '../doctor_search/doctor_search_controller.dart';
import '../appointments/patient_appointments_controller.dart';
import '../patient_profile/patient_profile_controller.dart';

class PatientDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientDashboardController>(() => PatientDashboardController());
    Get.lazyPut<DoctorSearchController>(() => DoctorSearchController());
    Get.lazyPut<PatientAppointmentsController>(() => PatientAppointmentsController());
    Get.lazyPut<PatientProfileController>(() => PatientProfileController());
  }
}
