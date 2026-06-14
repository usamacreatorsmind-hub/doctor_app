import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/doctor_model.dart';
import '../../../models/appointment_model.dart';
import '../../../models/notification_model.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/helper.dart';

class BookingConfirmController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late DoctorModel doctor;
  late String selectedDateStr;
  late String selectedTimeSlot;

  final isLoading = false.obs;
  final hospitalName = ''.obs;
  final consultationType = 'Offline'.obs;
  final patientSymptoms = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['doctor'] != null) {
      doctor = args['doctor'];
      selectedDateStr = args['selectedDate'];
      selectedTimeSlot = args['selectedTimeSlot'];
      _loadHospitalName();
    } else {
      Get.back();
    }
  }

  Future<void> _loadHospitalName() async {
    final h = await _firestoreService.getHospital(doctor.hospitalId);
    if (h != null) hospitalName.value = h.hospitalName;
  }

  void selectConsultationType(String type) => consultationType.value = type;
  void updatePatientSymptoms(String s) => patientSymptoms.value = s;

  Future<void> confirmBooking() async {
    if (_auth.currentUser == null) return;
    isLoading.value = true;
    update();

    try {
      final appt = AppointmentModel(
        appointmentId: '', 
        patientId: _auth.currentUser!.uid,
        doctorId: doctor.doctorId,
        hospitalId: doctor.hospitalId,
        appointmentDate: selectedDateStr,
        timeSlot: selectedTimeSlot,
        consultationType: consultationType.value,
        symptoms: patientSymptoms.value,
        status: 'Pending',
        paymentStatus: 'Unpaid',
        fee: doctor.consultationFee,
        createdAt: DateTime.now(),
      );

      final apptId = await _firestoreService.createAppointment(appt);

      // ✅ Fixed: Added required 'channel' field to NotificationModel
      await _firestoreService.createNotification(
        NotificationModel(
          notificationId: '',
          userId: doctor.uid,
          title: 'New Appointment',
          message: 'A new appointment has been booked for $selectedDateStr',
          type: 'appointment',
          channel: 'app',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );

      Get.offNamed(AppRoutes.payment, arguments: {
        'appointmentId': apptId,
        'amount': doctor.consultationFee,
        'doctorName': doctor.doctorName,
        'date': selectedDateStr,
        'time': selectedTimeSlot,
      });
    } catch (e) {
      AppSnackBar.show('Booking failed: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
