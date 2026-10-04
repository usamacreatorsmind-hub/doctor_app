
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

ImageProvider? getImageProvider(String? url) {
  if (url == null || url.trim().isEmpty) return null;
  final cleanUrl = url.trim();
  if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
    return NetworkImage(cleanUrl);
  } else if (cleanUrl.startsWith('file://')) {
    final path = cleanUrl.replaceFirst('file://', '');
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
  } else {
    final file = File(cleanUrl);
    if (file.existsSync()) {
      return FileImage(file);
    }
  }
  return null;
}

class AppSnackBar {
  static void show(String message) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class LauncherHelper {
  static const String privacyPolicyUrl = "https://privacy.creatorsmind.co.in/ayuveda-care-app-privacy-policy/";
  static const String termsConditionsUrl = "https://privacy.creatorsmind.co.in/terms-conditions-for-ayuveda-care/";

  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppSnackBar.show('Could not launch $url');
    }
  }

  static void launchPrivacyPolicy() => launchURL(privacyPolicyUrl);
  static void launchTermsConditions() => launchURL(termsConditionsUrl);
}