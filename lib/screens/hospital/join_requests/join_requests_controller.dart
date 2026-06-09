import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';

class JoinRequestsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final isLoading = false.obs;
  final requests = <Map<String, dynamic>>[].obs;
  late String hospitalId;

  @override
  void onInit() {
    super.onInit();
    hospitalId = Get.arguments['hospitalId'] ?? '';
    loadRequests();
  }

  Future<void> loadRequests() async {
    if (hospitalId.isEmpty) return;
    isLoading.value = true;
    update();
    try {
      requests.assignAll(await _firestoreService.getHospitalJoinRequests(hospitalId));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load requests: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> respondToRequest(Map<String, dynamic> request, String status) async {
    try {
      isLoading.value = true;
      update();
      
      await _firestoreService.respondToJoinRequest(
        requestId: request['id'],
        doctorId: request['doctorId'],
        hospitalId: hospitalId,
        status: status,
      );

      Get.snackbar('Success', 'Request ${status == 'approved' ? 'Approved' : 'Rejected'}');
      loadRequests();
    } catch (e) {
      Get.snackbar('Error', 'Action failed: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
