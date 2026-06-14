import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_app/Repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/doctor_model.dart';
import '../../../models/appointment_model.dart';
import '../../../models/notification_model.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/helper.dart';

class DoctorDashboardController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthRepository _authRepository = AuthRepository();
  
  final scrollController = ScrollController();
  
  final isLoading = false.obs;
  final isAppointmentsLoading = false.obs;
  final isLoadMore = false.obs;
  
  final doctorProfile = Rxn<DoctorModel>();
  final appointments = <AppointmentModel>[].obs;
  
  // Pagination
  DocumentSnapshot? lastDocument;
  final hasMore = true.obs;
  final int limit = 10;
  
  // Reactive selected date string
  final selectedDate = "".obs;
  
  // Stable list of dates for the selector (Next 14 days)
  final dateList = <DateTime>[].obs;

  @override
  void onInit() {
    super.onInit();
    _generateDates();
    selectedDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        loadMoreAppointments();
      }
    });
    
    loadDashboardData();
  }

  void _generateDates() {
    final now = DateTime.now();
    dateList.assignAll(List.generate(14, (i) => now.add(Duration(days: i))));
  }

  Future<void> loadDashboardData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final profile = await _firestoreService.getDoctorByUid(user.uid);
      if (profile != null) {
        doctorProfile.value = profile;
        await loadAppointments(selectedDate.value);
      } else {
        AppSnackBar.show('Doctor profile not found in database.');
      }
    } catch (e) {
      AppSnackBar.show('Failed to load dashboard: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> loadAppointments(String date) async {
    selectedDate.value = date;
    
    if (doctorProfile.value == null) return;
    
    isAppointmentsLoading.value = true;
    lastDocument = null;
    hasMore.value = true;
    appointments.clear();
    update();
    
    try {
      final doctorId = doctorProfile.value!.doctorId;
      final result = await _firestoreService.getDoctorAppointmentsPaginated(
        doctorId, 
        date: date,
        limit: limit,
      );
      
      final results = result['docs'] as List<AppointmentModel>;
      lastDocument = result['lastDoc'] as DocumentSnapshot?;
      hasMore.value = result['hasMore'] as bool;
      
      List<AppointmentModel> enhancedAppts = [];
      for (var appt in results) {
        try {
          final patientData = await _firestoreService.getUser(appt.patientId);
          enhancedAppts.add(appt.copyWith(
            patientName: patientData?.name ?? 'Patient',
          ));
        } catch (e) {
          enhancedAppts.add(appt.copyWith(patientName: 'Patient'));
        }
      }
      
      appointments.assignAll(enhancedAppts);
    } catch (e) {
      AppSnackBar.show('Failed to load appointments: $e');
    } finally {
      isAppointmentsLoading.value = false;
      update();
    }
  }

  Future<void> loadMoreAppointments() async {
    if (isLoadMore.value || !hasMore.value || doctorProfile.value == null) return;

    isLoadMore.value = true;
    update();

    try {
      final result = await _firestoreService.getDoctorAppointmentsPaginated(
        doctorProfile.value!.doctorId,
        date: selectedDate.value,
        lastDocument: lastDocument,
        limit: limit,
      );

      final results = result['docs'] as List<AppointmentModel>;
      lastDocument = result['lastDoc'] as DocumentSnapshot?;
      hasMore.value = result['hasMore'] as bool;

      List<AppointmentModel> enhancedAppts = [];
      for (var appt in results) {
        try {
          final patientData = await _firestoreService.getUser(appt.patientId);
          enhancedAppts.add(appt.copyWith(
            patientName: patientData?.name ?? 'Patient',
          ));
        } catch (e) {
          enhancedAppts.add(appt.copyWith(patientName: 'Patient'));
        }
      }
      
      appointments.addAll(enhancedAppts);
    } catch (e) {
      print("Error loading more appointments: $e");
    } finally {
      isLoadMore.value = false;
      update();
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestoreService.updateAppointmentStatus(appointmentId, status);
      
      final appt = appointments.firstWhereOrNull((a) => a.appointmentId == appointmentId);
      if (appt != null) {
        await _firestoreService.createNotification(NotificationModel(
          notificationId: '',
          userId: appt.patientId,
          title: 'Appointment $status',
          message: 'Your appointment on ${appt.appointmentDate} has been $status by Dr. ${doctorProfile.value?.doctorName}',
          type: 'appointment',
          channel: 'app',
          isRead: false,
          createdAt: DateTime.now(),
        ));
      }

      await loadAppointments(selectedDate.value);
      AppSnackBar.show('Appointment $status');
    } catch (e) {
      AppSnackBar.show('Failed to update status: $e');
    }
  }

  Future<void> onRefresh() async => await loadDashboardData();

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _authRepository.signOut();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
