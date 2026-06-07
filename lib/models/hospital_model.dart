import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────
// Firestore Path: hospitals/{hospitalId}
// ─────────────────────────────────────────
class HospitalModel {
  final String hospitalId;
  final String adminUid;       // linked user uid
  final String hospitalName;
  final String registrationNo;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String contactNumber;
  final String email;
  final String? website;
  final String? logoUrl;
  final List<String> departments;
  final String workingHoursStart; // e.g. "09:00"
  final String workingHoursEnd;   // e.g. "21:00"
  final bool emergencyAvailable;
  final String status;            // active | inactive
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HospitalModel({
    required this.hospitalId,
    required this.adminUid,
    required this.hospitalName,
    required this.registrationNo,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactNumber,
    required this.email,
    this.website,
    this.logoUrl,
    required this.departments,
    required this.workingHoursStart,
    required this.workingHoursEnd,
    required this.emergencyAvailable,
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

  factory HospitalModel.fromMap(Map<String, dynamic> map, String id) {
    return HospitalModel(
      hospitalId: id,
      adminUid: map['adminUid'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      registrationNo: map['registrationNo'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      email: map['email'] ?? '',
      website: map['website'],
      logoUrl: map['logoUrl'],
      departments: List<String>.from(map['departments'] ?? []),
      workingHoursStart: map['workingHoursStart'] ?? '09:00',
      workingHoursEnd: map['workingHoursEnd'] ?? '21:00',
      emergencyAvailable: map['emergencyAvailable'] ?? false,
      status: map['status'] ?? 'active',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTimeNullable(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminUid': adminUid,
      'hospitalName': hospitalName,
      'registrationNo': registrationNo,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contactNumber': contactNumber,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'departments': departments,
      'workingHoursStart': workingHoursStart,
      'workingHoursEnd': workingHoursEnd,
      'emergencyAvailable': emergencyAvailable,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  HospitalModel copyWith({
    String? hospitalName,
    String? registrationNo,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? contactNumber,
    String? email,
    String? website,
    String? logoUrl,
    List<String>? departments,
    String? workingHoursStart,
    String? workingHoursEnd,
    bool? emergencyAvailable,
    String? status,
  }) {
    return HospitalModel(
      hospitalId: hospitalId,
      adminUid: adminUid,
      hospitalName: hospitalName ?? this.hospitalName,
      registrationNo: registrationNo ?? this.registrationNo,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      departments: departments ?? this.departments,
      workingHoursStart: workingHoursStart ?? this.workingHoursStart,
      workingHoursEnd: workingHoursEnd ?? this.workingHoursEnd,
      emergencyAvailable: emergencyAvailable ?? this.emergencyAvailable,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
