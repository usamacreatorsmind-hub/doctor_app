import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String doctorId;
  final String uid;
  final String hospitalId;
  final List<String> hospitalIds;
  final String doctorName;
  final List<String> qualification;
  final List<String> specialization;
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
    required this.hospitalIds,
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
    List<String> quals = [];
    if (map['qualification'] is List) {
      quals = List<String>.from(map['qualification']);
    } else if (map['qualification'] != null && map['qualification'].toString().isNotEmpty) {
      quals = map['qualification'].toString().split(',').map((e) => e.trim()).toList();
    }

    List<String> specs = [];
    if (map['specialization'] is List) {
      specs = List<String>.from(map['specialization']);
    } else if (map['specialization'] != null) {
      specs = [map['specialization'].toString()];
    }

    List<String> hIds = [];
    if (map['hospitalIds'] is List) {
      hIds = List<String>.from(map['hospitalIds']);
    } else if (map['hospitalId'] != null) {
      hIds = [map['hospitalId'].toString()];
    }

    String primaryHId = map['hospitalId'] ?? (hIds.isNotEmpty ? hIds.first : '');

    return DoctorModel(
      doctorId: id,
      uid: map['uid'] ?? map['userId'] ?? '',
      hospitalId: primaryHId,
      hospitalIds: hIds,
      doctorName: map['doctorName'] ?? '',
      qualification: quals,
      specialization: specs,
      experience: int.tryParse(map['experience']?.toString() ?? '0') ?? 0,
      consultationFee: double.tryParse(map['consultationFee']?.toString() ?? '0.0') ?? 0.0,
      mobileNumber: map['mobileNumber'] ?? '',
      email: map['email'] ?? '',
      gender: map['gender'] ?? '',
      languagesKnown: List<String>.from(map['languagesKnown'] ?? []),
      biography: map['biography'],
      photoUrl: map['photoUrl'] ?? map['photo'],
      symptomsCovered: List<String>.from(map['symptomsCovered'] ?? []),
      diseasesCovered: List<String>.from(map['diseasesCovered'] ?? []),
      consultationMode: map['consultationMode'] ?? 'Offline',
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
      'userId': uid,
      'hospitalId': hospitalId,
      'hospitalIds': hospitalIds,
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
      'photo': photoUrl,
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

  DoctorModel copyWith({
    String? hospitalId,
    List<String>? hospitalIds,
    String? status,
  }) {
    return DoctorModel(
      doctorId: doctorId,
      uid: uid,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalIds: hospitalIds ?? this.hospitalIds,
      doctorName: doctorName,
      qualification: qualification,
      specialization: specialization,
      experience: experience,
      consultationFee: consultationFee,
      mobileNumber: mobileNumber,
      email: email,
      gender: gender,
      languagesKnown: languagesKnown,
      biography: biography,
      photoUrl: photoUrl,
      symptomsCovered: symptomsCovered,
      diseasesCovered: diseasesCovered,
      consultationMode: consultationMode,
      rating: rating,
      totalReviews: totalReviews,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}