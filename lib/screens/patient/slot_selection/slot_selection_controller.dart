import 'package:get/get.dart';
import '../../../models/doctor_model.dart';
import '../../../models/doctor_schedule_model.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../utils/app_routes.dart';
import 'package:intl/intl.dart';

import '../../../utils/helper.dart';

class SlotSelectionController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  late DoctorModel doctor;
  final isLoading = false.obs;
  final selectedDate = Rxn<DateTime>();
  final selectedTimeSlot = Rxn<String>();
  final availableTimeSlots = <String>[].obs;
  final doctorSchedules = <DoctorScheduleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['doctor'] != null) {
      doctor = args['doctor'];
      selectedDate.value = DateTime.now();
      _loadDoctorSchedules();
    } else {
      Get.back();
      AppSnackBar.show('Doctor details not found');

    }
  }

  Future<void> _loadDoctorSchedules() async {
    isLoading.value = true;
    update();
    try {
      doctorSchedules.value = await _firestoreService.getDoctorSchedules(doctor.doctorId);
      _generateAvailableSlots();
    } catch (e) {
      AppSnackBar.show('Failed to load doctor schedules: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _generateAvailableSlots();
  }

  Future<void> _generateAvailableSlots() async {
    availableTimeSlots.clear();
    selectedTimeSlot.value = null;
    
    if (selectedDate.value == null || doctorSchedules.isEmpty) {
      update();
      return;
    }

    final todayStr = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
    final dayOfWeek = DateFormat('EEEE').format(selectedDate.value!);

    final scheduleForSelectedDay = doctorSchedules.firstWhereOrNull(
      (s) => s.day.toLowerCase() == dayOfWeek.toLowerCase(),
    );

    if (scheduleForSelectedDay == null) {
      update();
      return;
    }

    try {
      final bookedSlots = await _firestoreService.getBookedSlots(doctor.doctorId, todayStr);

      DateTime startTime = DateFormat('HH:mm').parse(scheduleForSelectedDay.startTime);
      DateTime endTime = DateFormat('HH:mm').parse(scheduleForSelectedDay.endTime);
      final slotDuration = scheduleForSelectedDay.slotDurationMins;

      while (startTime.isBefore(endTime)) {
        final slot = DateFormat('hh:mm a').format(startTime);
        if (!bookedSlots.contains(slot)) {
          availableTimeSlots.add(slot);
        }
        startTime = startTime.add(Duration(minutes: slotDuration));
      }
    } catch (e) {
      print("Error generating slots: $e");
    }

    update();
  }

  void selectTimeSlot(String slot) {
    selectedTimeSlot.value = slot;
    update();
  }

  void goToBookingConfirmation() {
    if (selectedDate.value == null || selectedTimeSlot.value == null) {
      AppSnackBar.show('Please select a date and time slot.');
      return;
    }
    Get.toNamed(AppRoutes.bookingConfirm, arguments: {
      'doctor': doctor,
      'selectedDate': selectedDate.value!.toIso8601String().split('T')[0],
      'selectedTimeSlot': selectedTimeSlot.value,
    });
  }
}
