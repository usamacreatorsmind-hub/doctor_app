import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────
// Firestore Path: doctor_schedules/{scheduleId}
// ─────────────────────────────────────────
class DoctorScheduleModel {
  final String scheduleId;
  final String doctorId;
  final String hospitalId;
  final String day;             // Monday | Tuesday... | Sunday
  final String startTime;       // e.g. "10:00"
  final String endTime;         // e.g. "14:00"
  final int slotDurationMins;   // 10 | 15 | 30
  final String? breakStartTime; // e.g. "13:00"
  final String? breakEndTime;   // e.g. "13:30"
  final int maxPatients;
  final String availabilityStatus; // available | unavailable
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DoctorScheduleModel({
    required this.scheduleId,
    required this.doctorId,
    required this.hospitalId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.slotDurationMins,
    this.breakStartTime,
    this.breakEndTime,
    required this.maxPatients,
    required this.availabilityStatus,
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

  factory DoctorScheduleModel.fromMap(Map<String, dynamic> map, String id) {
    final breakTime = map['breakTime'] as Map<String, dynamic>?;

    return DoctorScheduleModel(
      scheduleId: id,
      doctorId: map['doctorId'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      slotDurationMins: map['slotDuration'] ?? map['slotDurationMins'] ?? 15,
      breakStartTime: breakTime?['start'],
      breakEndTime: breakTime?['end'],
      maxPatients: map['maxPatients'] ?? 20,
      availabilityStatus: map['availabilityStatus'] ?? 'available',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTimeNullable(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'hospitalId': hospitalId,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'slotDuration': slotDurationMins,
      'breakTime': {
        'start': breakStartTime ?? '',
        'end': breakEndTime ?? '',
      },
      'maxPatients': maxPatients,
      'availabilityStatus': availabilityStatus,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  List<String> generateSlots() {
    if (startTime.isEmpty || endTime.isEmpty) return [];
    
    final slots = <String>[];
    try {
      final start = _parseTime(startTime);
      final end = _parseTime(endTime);
      final breakStart = (breakStartTime != null && breakStartTime!.isNotEmpty) ? _parseTime(breakStartTime!) : null;
      final breakEnd = (breakEndTime != null && breakEndTime!.isNotEmpty) ? _parseTime(breakEndTime!) : null;

      DateTime current = start;
      while (current.isBefore(end)) {
        final slotEnd = current.add(Duration(minutes: slotDurationMins));
        
        // Skip if within break time
        if (breakStart != null && breakEnd != null) {
          if ((current.isAfter(breakStart) || current.isAtSameMomentAs(breakStart)) && 
              current.isBefore(breakEnd)) {
            current = breakEnd;
            continue;
          }
        }
        
        if (slotEnd.isAfter(end)) break;
        slots.add('${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}');
        current = slotEnd;
      }
    } catch (e) {
      print("Error generating slots: $e");
    }
    return slots;
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }
}
