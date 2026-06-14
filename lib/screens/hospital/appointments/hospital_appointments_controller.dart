import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/appointment_model.dart';
import '../../../models/doctor_model.dart';
import '../../../utils/helper.dart';

class HospitalAppointmentsController extends GetxController with GetSingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();

  late String hospitalId;
  late TabController tabController;

  final isLoading = false.obs;
  final allAppointments = <AppointmentModel>[].obs;
  final filteredAppointments = <AppointmentModel>[].obs;
  final hospitalDoctors = <DoctorModel>[].obs;

  // Filters
  final searchQuery = ''.obs;
  final selectedDoctorId = ''.obs;
  final selectedDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(_handleTabSelection);
    
    hospitalId = Get.arguments?['hospitalId'] ?? '';
    if (hospitalId.isNotEmpty) {
      loadInitialData();
    } else {
      Get.back();
      AppSnackBar.show('Hospital details missing');
    }
  }

  void _handleTabSelection() {
    if (!tabController.indexIsChanging) {
      applyFilters();
    }
  }

  Future<void> loadInitialData() async {
    isLoading.value = true;
    update();

    try {
      // Load doctors for filtering
      final docs = await _firestoreService.getDoctorsByHospital(hospitalId);
      hospitalDoctors.assignAll(docs);

      // Load all appointments
      final results = await _firestoreService.getHospitalAppointments(hospitalId);
      
      List<AppointmentModel> enhancedAppts = [];
      for (var appt in results) {
        final patientData = await _firestoreService.getUser(appt.patientId);
        final doctor = hospitalDoctors.firstWhereOrNull((d) => d.doctorId == appt.doctorId);
        
        enhancedAppts.add(appt.copyWith(
          patientName: patientData?.name ?? 'Patient',
          doctorName: doctor?.doctorName ?? 'Doctor',
        ));
      }
      allAppointments.assignAll(enhancedAppts);
      applyFilters();
    } catch (e) {
      AppSnackBar.show('Failed to load appointments: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  void applyFilters() {
    List<AppointmentModel> results = List.from(allAppointments);

    // 1. Filter by Tab (Status/Timeline)
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T')[0];

    switch (tabController.index) {
      case 0: // Today's
        results = results.where((a) => a.appointmentDate == todayStr).toList();
        break;
      case 1: // Upcoming
        results = results.where((a) {
          final apptDate = DateTime.tryParse(a.appointmentDate) ?? now;
          return apptDate.isAfter(now) && (a.status == 'Confirmed' || a.status == 'Pending');
        }).toList();
        break;
      case 2: // Completed
        results = results.where((a) => a.status == 'Completed').toList();
        break;
      case 3: // Cancelled
        results = results.where((a) => a.status == 'Cancelled').toList();
        break;
      case 4: // Missed
        results = results.where((a) {
          final apptDate = DateTime.tryParse(a.appointmentDate) ?? now;
          return apptDate.isBefore(now) && a.appointmentDate != todayStr && (a.status == 'Confirmed' || a.status == 'Pending');
        }).toList();
        break;
    }

    // 2. Filter by Doctor
    if (selectedDoctorId.value.isNotEmpty) {
      results = results.where((a) => a.doctorId == selectedDoctorId.value).toList();
    }

    // 3. Filter by Date (Additional filter)
    if (selectedDate.value != null) {
      final dateStr = selectedDate.value!.toIso8601String().split('T')[0];
      results = results.where((a) => a.appointmentDate == dateStr).toList();
    }

    // 4. Search Query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      results = results.where((a) {
        return (a.patientName?.toLowerCase().contains(query) ?? false) ||
               (a.doctorName?.toLowerCase().contains(query) ?? false) ||
               a.appointmentId.toLowerCase().contains(query);
      }).toList();
    }

    filteredAppointments.assignAll(results);
  }

  void onSearch(String val) {
    searchQuery.value = val;
    applyFilters();
  }

  void clearFilters() {
    selectedDoctorId.value = '';
    selectedDate.value = null;
    searchQuery.value = '';
    applyFilters();
  }

  Future<void> onRefresh() async {
    await loadInitialData();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
