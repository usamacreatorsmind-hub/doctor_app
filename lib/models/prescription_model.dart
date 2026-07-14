// ─────────────────────────────────────────
// Firestore Path: prescriptions/{prescriptionId}
// ─────────────────────────────────────────
import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionModel {
  final String prescriptionId;
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String doctorRemarks;
  final List<MedicineModel> medicines;
  final List<String> tests;
  final String? followUpDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Display only / Stored for snapshotting
  final String? doctorName;
  final String? specialization;

  const PrescriptionModel({
    required this.prescriptionId,
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.doctorRemarks,
    required this.medicines,
    required this.tests,
    this.followUpDate,
    required this.createdAt,
    this.updatedAt,
    this.doctorName,
    this.specialization,
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

  factory PrescriptionModel.fromMap(Map<String, dynamic> map, String id) {
    // Handle specialization as String or List
    String? spec;
    if (map['specialization'] is List) {
      spec = (map['specialization'] as List).join(', ');
    } else {
      spec = map['specialization']?.toString();
    }

    return PrescriptionModel(
      prescriptionId: id,
      appointmentId: map['appointmentId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorRemarks: map['doctorRemarks'] ?? '',
      medicines: (map['medicines'] as List<dynamic>? ?? [])
          .map((m) => MedicineModel.fromMap(m as Map<String, dynamic>))
          .toList(),
      tests: List<String>.from(map['tests'] ?? []),
      followUpDate: map['followUpDate'],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTimeNullable(map['updatedAt']),
      doctorName: map['doctorName'],
      specialization: spec,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorRemarks': doctorRemarks,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'tests': tests,
      'followUpDate': followUpDate,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
      'doctorName': doctorName,
      'specialization': specialization,
    };
  }

  PrescriptionModel copyWith({
    String? prescriptionId,
    String? doctorName,
    String? specialization,
  }) {
    return PrescriptionModel(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      appointmentId: appointmentId,
      doctorId: doctorId,
      patientId: patientId,
      doctorRemarks: doctorRemarks,
      medicines: medicines,
      tests: tests,
      followUpDate: followUpDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      doctorName: doctorName ?? this.doctorName,
      specialization: specialization ?? this.specialization,
    );
  }
}

class MedicineModel {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? notes;

  const MedicineModel({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.notes,
  });

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      duration: map['duration'] ?? '',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'notes': notes,
    };
  }
}
