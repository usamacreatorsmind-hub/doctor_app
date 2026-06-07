import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────
// Firestore Path: reviews/{reviewId}
// ─────────────────────────────────────────
class ReviewModel {
  final String reviewId;
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final double rating;      // 1.0 to 5.0
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Display only
  final String? patientName;

  const ReviewModel({
    required this.reviewId,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.patientName,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _parseDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      reviewId: id,
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTimeNullable(map['updatedAt']),
      patientName: map['patientName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
