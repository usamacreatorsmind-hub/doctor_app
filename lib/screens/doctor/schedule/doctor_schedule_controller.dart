import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/doctor_schedule_model.dart';

class DoctorScheduleController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final schedules = <DoctorScheduleModel>[].obs;
  final isReadOnly = false.obs;
  String? targetDoctorId;
  String? targetHospitalId;
  
  final List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      targetDoctorId = args['doctorId'];
      isReadOnly.value = args['isReadOnly'] ?? false;
    }
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    isLoading.value = true;
    update();

    try {
      String? doctorId = targetDoctorId;
      
      // If no targetDoctorId, assume it's the logged-in doctor viewing their own schedule
      if (doctorId == null) {
        final user = _auth.currentUser;
        if (user != null) {
          final myDoctor = await _firestoreService.getDoctorByUid(user.uid);
          doctorId = myDoctor?.doctorId;
          targetHospitalId = myDoctor?.hospitalId;
        }
      }

      if (doctorId != null) {
        final results = await _firestoreService.getDoctorSchedules(doctorId);
        schedules.value = results;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load schedules: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> updateSchedule(String day, String startTime, String endTime, int duration) async {
    if (isReadOnly.value) return;
    
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final myDoctor = await _firestoreService.getDoctorByUid(user.uid);
      if (myDoctor == null) return;

      final existing = schedules.firstWhereOrNull((s) => s.day == day);

      if (existing != null) {
        await _firestoreService.updateSchedule(existing.scheduleId, {
          'startTime': startTime,
          'endTime': endTime,
          'slotDuration': duration,
        });
      } else {
        final newSchedule = DoctorScheduleModel(
          scheduleId: '',
          doctorId: myDoctor.doctorId,
          hospitalId: myDoctor.hospitalId,
          day: day,
          startTime: startTime,
          endTime: endTime,
          slotDurationMins: duration,
          breakStartTime: '13:00',
          breakEndTime: '14:00',
          maxPatients: 20,
          availabilityStatus: 'available',
          createdAt: DateTime.now(),
        );
        await _firestoreService.createSchedule(newSchedule);
      }
      await loadSchedules();
      Get.snackbar('Success', 'Schedule for $day updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update: $e');
    }
  }
}
