import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Repository/FirestoreService.dart';
import '../../../models/payment_model.dart';
import '../../../utils/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../utils/helper.dart';

class PaymentController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String appointmentId;
  late double amount;
  late String doctorName;
  late String date;
  late String time;

  final isLoading = false.obs;
  final selectedPaymentMethod = 'UPI'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null &&
        args['appointmentId'] != null &&
        args['amount'] != null &&
        args['doctorName'] != null &&
        args['date'] != null &&
        args['time'] != null) {
      appointmentId = args['appointmentId'];
      amount = args['amount'];
      doctorName = args['doctorName'];
      date = args['date'];
      time = args['time'];
    } else {
      Get.back();
      AppSnackBar.show('Payment details missing');
    }
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    update();
  }

  Future<void> processPayment() async {
    if (_auth.currentUser == null) {
      AppSnackBar.show('User not logged in');
      return;
    }

    isLoading.value = true;
    update();

    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Assume payment is successful for now
      final payment = PaymentModel(
        paymentId: '', // Firestore will generate
        appointmentId: appointmentId,
        patientId: _auth.currentUser!.uid,
        amount: amount,
        paymentMethod: selectedPaymentMethod.value,
        transactionId: 'TRX${DateTime.now().millisecondsSinceEpoch}', // Dummy transaction ID
        paymentDate: DateTime.now().toIso8601String(),
        status: 'Success', createdAt: DateTime.now(),
      );

      await _firestoreService.createPayment(payment);

      // Update appointment status to 'Confirmed' and 'Paid'
      await _firestoreService.updateAppointment(appointmentId, {
        'status': 'Confirmed',
        'paymentStatus': 'Paid',
        'transactionId': payment.transactionId,
      });
      AppSnackBar.show('Payment successful');
      Get.offNamed(AppRoutes.bookingSuccess, arguments: {
        'doctorName': doctorName,
        'date': date,
        'time': time,
      });
    } catch (e) {
      AppSnackBar.show('Failed to process payment: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
