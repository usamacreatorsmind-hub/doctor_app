import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Repository/FirestoreService.dart';
import '../../models/notification_model.dart';
import '../../utils/helper.dart';

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

    try {
      // Wiring real-time stream from Firestore
      notifications.bindStream(
        _firestoreService.getUserNotifications(user.uid).handleError((error) {
          print("Error in notifications stream: $error");
          isLoading.value = false;
        }),
      );

      // Set loading to false once we get the first snapshot
      notifications.listen(
        (data) {
          if (isLoading.value) isLoading.value = false;
        },
        onError: (error) {
          print("Error in notifications listener: $error");
          isLoading.value = false;
        },
      );
    } catch (e) {
      print("Error initializing notifications stream: $e");
      isLoading.value = false;
    }
  }

  void markAsRead(String id) async {
    try {
      await _firestoreService.markNotificationRead(id);
    } catch (e) {
      AppSnackBar.show('Failed to mark as read: $e');
    }
  }

  void markAllRead() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestoreService.markAllNotificationsRead(user.uid);
      } catch (e) {
        AppSnackBar.show('Failed to mark all as read: $e');
      }
    }
  }
}
