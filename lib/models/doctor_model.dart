import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String doctorId;
  final String uid;
  final String hospitalId;
  final String doctorName;
  final String qualification;
  final String specialization;
  final int experience;
  final double consultationFee;
  final String mobileNumber;
  final String email;
  final String gender;
  final List<String> languagesKnown;
  final String? biography;
  final String? photoUrl;
  final List<String> symptomsCovered;
  final List<String> diseasesCovered;
  final String consultationMode;
  final double rating;
  final int totalReviews;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DoctorModel({
    required this.doctorId,
    required this.uid,
    required this.hospitalId,
    required this.doctorName,
    required this.qualification,
    required this.specialization,
    required this.experience,
    required this.consultationFee,
    required this.mobileNumber,
    required this.email,
    required this.gender,
    required this.languagesKnown,
    this.biography,
    this.photoUrl,
    required this.symptomsCovered,
    required this.diseasesCovered,
    required this.consultationMode,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.status,
    required this.createdAt,
    this.updatedAt,
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

  factory DoctorModel.fromMap(Map<String, dynamic> map, String id) {
    return DoctorModel(
      doctorId: id,
      uid: map['uid'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      qualification: map['qualification'] ?? '',
      specialization: map['specialization'] ?? '',
      experience: int.tryParse(map['experience']?.toString() ?? '0') ?? 0,
      consultationFee: double.tryParse(map['consultationFee']?.toString() ?? '0.0') ?? 0.0,
      mobileNumber: map['mobileNumber'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      languagesKnown: List<String>.from(map['languagesKnown'] ?? []),
      biography: map['biography'],
      photoUrl: map['photoUrl'],
      symptomsCovered: List<String>.from(map['symptomsCovered'] ?? []),
      diseasesCovered: List<String>.from(map['diseasesCovered'] ?? []),
      consultationMode: map['consultationMode'] ?? 'Both',
      rating: double.tryParse(map['rating']?.toString() ?? '0.0') ?? 0.0,
      totalReviews: int.tryParse(map['totalReviews']?.toString() ?? '0') ?? 0,
      status: (map['status']?.toString() ?? 'active').toLowerCase(),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTimeNullable(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'hospitalId': hospitalId,
      'doctorName': doctorName,
      'qualification': qualification,
      'specialization': specialization,
      'experience': experience,
      'consultationFee': consultationFee,
      'mobileNumber': mobileNumber,
      'email': email,
      'gender': gender,
      'languagesKnown': languagesKnown,
      'biography': biography,
      'photoUrl': photoUrl,
      'symptomsCovered': symptomsCovered,
      'diseasesCovered': diseasesCovered,
      'consultationMode': consultationMode,
      'rating': rating,
      'totalReviews': totalReviews,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
