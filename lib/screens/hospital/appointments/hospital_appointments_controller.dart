import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/appointment_model.dart';

class HospitalAppointmentsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  late String hospitalId;
  final isLoading = false.obs;
  final appointments = <AppointmentModel>[].obs;
  final selectedDate = DateTime.now().toIso8601String().split('T')[0].obs;

  @override
  void onInit() {
    super.onInit();
    hospitalId = Get.arguments?['hospitalId'] ?? '';
    if (hospitalId.isNotEmpty) {
      loadAppointments(selectedDate.value);
    } else {
      Get.back();
      Get.snackbar('Error', 'Hospital ID not found');
    }
  }

  Future<void> loadAppointments(String date) async {
    selectedDate.value = date;
    isLoading.value = true;
    update();

    try {
      final results = await _firestoreService.getHospitalAppointments(hospitalId, date: date);
      
      // ✅ Wiring: Fetch Patient Names for display
      List<AppointmentModel> enhancedAppts = [];
      for (var appt in results) {
        final patientData = await _firestoreService.getUser(appt.patientId);
        enhancedAppts.add(appt.copyWith(patientName: patientData?.name ?? 'Patient'));
      }
      appointments.value = enhancedAppts;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load appointments: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> onRefresh() async {
    await loadAppointments(selectedDate.value);
  }
}
