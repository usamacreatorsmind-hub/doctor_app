import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/doctor_model.dart';
import '../../../models/review_model.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../utils/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/helper.dart';

class DoctorProfileController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  late DoctorModel doctor;
  final isLoading = false.obs;
  final hospitalName = ''.obs;
  final isAdminView = false.obs;
  final hospitalLatLng = Rxn<Map<String, double>>();
  
  // Reviews List
  final reviews = <ReviewModel>[].obs;
  final isReviewsLoading = false.obs;
  final reviewsKey = GlobalKey();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['doctor'] != null) {
      doctor = args['doctor'];
      isAdminView.value = args['isAdmin'] ?? false;
      _loadInitialData();
    } else {
      Get.back();
    }
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    update();
    await Future.wait([
      _loadHospitalDetails(),
      _loadReviews(),
    ]);
    isLoading.value = false;
    update();
  }

  Future<void> _loadHospitalDetails() async {
    try {
      final hospital = await _firestoreService.getHospital(doctor.hospitalId);
      if (hospital != null) {
        hospitalName.value = hospital.hospitalName;
        if (hospital.latitude != null && hospital.longitude != null) {
          hospitalLatLng.value = {'lat': hospital.latitude!, 'lng': hospital.longitude!};
        }
      }
    } catch (e) {
      print("Error loading hospital: $e");
    }
  }

  Future<void> onNavigateDirections() async {
    double? lat;
    double? lng;

    // 1. Check doctor's personal clinic location first
    if (doctor.latitude != null && doctor.longitude != null) {
      lat = doctor.latitude;
      lng = doctor.longitude;
    } 
    // 2. Fallback to hospital location
    else if (hospitalLatLng.value != null) {
      lat = hospitalLatLng.value!['lat'];
      lng = hospitalLatLng.value!['lng'];
    }

    if (lat != null && lng != null) {
      final String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving";
      final Uri uri = Uri.parse(googleMapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        AppSnackBar.show("Could not launch Google Maps");
      }
    } else {
      AppSnackBar.show("Location coordinates not available for this provider.");
    }
  }

  Future<void> _loadReviews() async {
    isReviewsLoading.value = true;
    try {
      final fetchedReviews = await _firestoreService.getDoctorReviews(doctor.doctorId);
      
      // Enhance reviews with patient names
      final enhancedReviews = await Future.wait(fetchedReviews.map((r) async {
        final patient = await _firestoreService.getUser(r.patientId);
        return ReviewModel(
          reviewId: r.reviewId,
          doctorId: r.doctorId,
          patientId: r.patientId,
          appointmentId: r.appointmentId,
          rating: r.rating,
          comment: r.comment,
          createdAt: r.createdAt,
          patientName: patient?.name ?? 'Patient',
        );
      }));
      
      reviews.assignAll(enhancedReviews);
    } catch (e) {
      print("Error loading reviews: $e");
    } finally {
      isReviewsLoading.value = false;
    }
  }

  void onBookAppointment() {
    Get.toNamed(AppRoutes.slotSelection, arguments: {'doctor': doctor});
  }

  void scrollToReviews() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void onViewSchedule() {
    Get.toNamed(AppRoutes.doctorSchedule, arguments: {'doctorId': doctor.doctorId, 'isReadOnly': true});
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
