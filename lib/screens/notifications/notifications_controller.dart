import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Repository/FirestoreService.dart';
import '../../models/notification_model.dart';

class NotificationsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = true.obs;
  final notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initNotificationStream();
  }

  void _initNotificationStream() {
    final user = _auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    // Wiring real-time stream from Firestore
    notifications.bindStream(_firestoreService.getUserNotifications(user.uid));
    
    // Set loading to false once we get the first snapshot
    notifications.listen((data) {
      if (isLoading.value) isLoading.value = false;
    });
  }

  void markAsRead(String id) async {
    try {
      await _firestoreService.markNotificationRead(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark as read');
    }
  }

  void markAllRead() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestoreService.markAllNotificationsRead(user.uid);
      } catch (e) {
        Get.snackbar('Error', 'Failed to mark all as read');
      }
    }
  }
}
