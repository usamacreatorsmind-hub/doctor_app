import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/review_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/doctor_model.dart';

class DoctorReviewsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final reviews = <ReviewModel>[].obs;
  final doctorProfile = Rxn<DoctorModel>();

  @override
  void onInit() {
    super.onInit();
    loadReviews();
  }

  Future<void> loadReviews() async {
    final user = _auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    update();

    try {
      final profile = await _firestoreService.getDoctorByUid(user.uid);
      if (profile != null) {
        doctorProfile.value = profile;
        final fetchedReviews = await _firestoreService.getDoctorReviews(profile.doctorId);
        
        // Enhance reviews with patient names
        final enhancedReviews = await Future.wait(fetchedReviews.map((r) async {
          final patientData = await _firestoreService.getUser(r.patientId);
          return ReviewModel(
            reviewId: r.reviewId,
            doctorId: r.doctorId,
            patientId: r.patientId,
            appointmentId: r.appointmentId,
            rating: r.rating,
            comment: r.comment,
            createdAt: r.createdAt,
            patientName: patientData?.name ?? 'Patient',
          );
        }));

        reviews.assignAll(enhancedReviews);
      }
    } catch (e) {
      print("Error loading doctor reviews: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
