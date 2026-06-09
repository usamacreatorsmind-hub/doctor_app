import 'package:cloud_firestore/cloud_firestore.dart';

class HospitalModel {
  final String hospitalId;
  final String adminUserId;
  final String hospitalName;
  final String registrationNo;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String contactNumber;
  final String email;
  final String? website;
  final String? logo;
  final List<String> departments;
  final Map<String, String> workingHours; // { "open": "09:00 AM", "close": "08:00 PM" }
  final bool emergencyAvailable;
  final String status;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HospitalModel({
    required this.hospitalId,
    required this.adminUserId,
    required this.hospitalName,
    required this.registrationNo,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.contactNumber,
    required this.email,
    this.website,
    this.logo,
    required this.departments,
    required this.workingHours,
    required this.emergencyAvailable,
    required this.status,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory HospitalModel.fromMap(Map<String, dynamic> map, String id) {
    return HospitalModel(
      hospitalId: id,
      adminUserId: map['adminUserId'] ?? map['adminUid'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      registrationNo: map['registrationNo'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      email: map['email'] ?? '',
      website: map['website'],
      logo: map['logo'] ?? map['logoUrl'],
      departments: List<String>.from(map['departments'] ?? []),
      workingHours: Map<String, String>.from(map['workingHours'] ?? {'open': '09:00 AM', 'close': '08:00 PM'}),
      emergencyAvailable: map['emergencyAvailable'] ?? false,
      status: map['status'] ?? 'active',
      createdBy: map['createdBy'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hospitalId': hospitalId,
      'adminUserId': adminUserId,
      'adminUid': adminUserId,
      'hospitalName': hospitalName,
      'registrationNo': registrationNo,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'contactNumber': contactNumber,
      'email': email,
      'website': website,
      'logo': logo,
      'departments': departments,
      'workingHours': workingHours,
      'emergencyAvailable': emergencyAvailable,
      'status': status,
      'createdBy': createdBy,
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
    String? logo,
    List<String>? departments,
    Map<String, String>? workingHours,
    bool? emergencyAvailable,
    String? status,
  }) {
    return HospitalModel(
      hospitalId: hospitalId,
      adminUserId: adminUserId,
      hospitalName: hospitalName ?? this.hospitalName,
      registrationNo: registrationNo ?? this.registrationNo,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      logo: logo ?? this.logo,
      departments: departments ?? this.departments,
      workingHours: workingHours ?? this.workingHours,
      emergencyAvailable: emergencyAvailable ?? this.emergencyAvailable,
      status: status ?? this.status,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
