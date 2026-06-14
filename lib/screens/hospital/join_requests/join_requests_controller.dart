import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../utils/helper.dart';

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
      AppSnackBar.show('Failed to load requests: $e');
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
      AppSnackBar.show('Request ${status == 'approved' ? 'Approved' : 'Rejected'}');
      loadRequests();
    } catch (e) {
      AppSnackBar.show('Failed to respond to request: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
