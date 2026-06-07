import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/hospital_model.dart';
import '../models/doctor_model.dart';
import '../models/doctor_schedule_model.dart';
import '../models/appointment_model.dart';
import '../models/payment_model.dart';
import '../models/prescription_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';
import '../models/patient_profile_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final _db = FirebaseFirestore.instance;

  // ── Collection References ──
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _hospitals => _db.collection('hospitals');
  CollectionReference get _doctors => _db.collection('doctors');
  CollectionReference get _schedules => _db.collection('doctor_schedules');
  CollectionReference get _appointments => _db.collection('appointments');
  CollectionReference get _payments => _db.collection('payments');
  CollectionReference get _prescriptions => _db.collection('prescriptions');
  CollectionReference get _reviews => _db.collection('reviews');
  CollectionReference get _notifications => _db.collection('notifications');

  // ════════════════════════════════════════
  // USERS & PROFILE
  // ════════════════════════════════════════

  Future<void> createUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snap = await _users.where('email', isEqualTo: email).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromMap(snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }

  Future<void> migrateUserToUid(String oldId, UserModel user) async {
    if (oldId != user.uid) {
      final batch = _db.batch();
      batch.delete(_users.doc(oldId));
      batch.set(_users.doc(user.uid), user.toMap());
      await batch.commit();
    } else {
      await _users.doc(user.uid).set(user.toMap());
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _users.doc(uid).update(data);
  }

  Future<void> savePatientProfile(String uid, PatientProfileModel profile) async {
    await _users.doc(uid).collection('profile').doc('details').set(profile.toMap());
  }

  Future<PatientProfileModel?> getPatientProfile(String uid) async {
    final doc = await _users.doc(uid).collection('profile').doc('details').get();
    if (!doc.exists) return null;
    return PatientProfileModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // ════════════════════════════════════════
  // HOSPITALS & DOCTORS
  // ════════════════════════════════════════

  Future<String> createHospital(HospitalModel hospital) async {
    final doc = await _hospitals.add(hospital.toMap());
    return doc.id;
  }

  Future<HospitalModel?> getHospital(String hospitalId) async {
    final doc = await _hospitals.doc(hospitalId).get();
    if (!doc.exists) return null;
    return HospitalModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<HospitalModel?> getHospitalByAdminUid(String adminUid) async {
    final snap = await _hospitals.where('adminUid', isEqualTo: adminUid).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return HospitalModel.fromMap(
      snap.docs.first.data() as Map<String, dynamic>,
      snap.docs.first.id,
    );
  }

  Future<List<HospitalModel>> getAllHospitals() async {
    final snap = await _hospitals.where('status', isEqualTo: 'active').get();
    return snap.docs
        .map((d) => HospitalModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> updateHospital(String hospitalId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _hospitals.doc(hospitalId).update(data);
  }

  Future<String> createDoctor(DoctorModel doctor) async {
    final doc = await _doctors.add(doctor.toMap());
    return doc.id;
  }

  Future<DoctorModel?> getDoctor(String doctorId) async {
    final doc = await _doctors.doc(doctorId).get();
    if (!doc.exists) return null;
    return DoctorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<DoctorModel?> getDoctorByUid(String uid) async {
    final snap = await _doctors.where('uid', isEqualTo: uid).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return DoctorModel.fromMap(snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }

  Future<List<DoctorModel>> getDoctorsByHospital(String hospitalId) async {
    final snap = await _doctors
        .where('hospitalId', isEqualTo: hospitalId)
        .where('status', isEqualTo: 'active')
        .get();
    return snap.docs
        .map((d) => DoctorModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<List<DoctorModel>> searchDoctors({String? specialization, String? name}) async {
    Query query = _doctors.where('status', isEqualTo: 'active');
    if (specialization != null && specialization.isNotEmpty) {
      query = query.where('specialization', isEqualTo: specialization);
    }

    final snap = await query.get();
    List<DoctorModel> results = snap.docs
        .map((d) => DoctorModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    if (name != null && name.isNotEmpty) {
      final term = name.toLowerCase();
      results = results.where((d) {
        return d.doctorName.toLowerCase().contains(term) ||
            d.specialization.toLowerCase().contains(term);
      }).toList();
    }
    return results;
  }

  Future<List<DoctorModel>> getTopDoctors({int limit = 10}) async {
    try {
      final snap = await _doctors.where('status', whereIn: ['active', 'Active']).get();
      List<DoctorModel> list = snap.docs
          .map((d) => DoctorModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      list.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
      return list.take(limit).toList();
    } catch (e) {
      print("Firestore Error (getTopDoctors): $e");
      return [];
    }
  }

  Future<void> updateDoctor(String doctorId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _doctors.doc(doctorId).update(data);
  }

  // ════════════════════════════════════════
  // SCHEDULES & APPOINTMENTS
  // ════════════════════════════════════════

  Future<String> createSchedule(DoctorScheduleModel schedule) async {
    final doc = await _schedules.add(schedule.toMap());
    return doc.id;
  }

  Future<List<DoctorScheduleModel>> getDoctorSchedules(String doctorId) async {
    final snap = await _schedules
        .where('doctorId', isEqualTo: doctorId)
        .where('availabilityStatus', isEqualTo: 'available')
        .get();
    return snap.docs
        .map((d) => DoctorScheduleModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
  }

  Future<void> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _schedules.doc(scheduleId).update(data);
  }

  Future<String> createAppointment(AppointmentModel appt) async {
    final doc = await _appointments.add(appt.toMap());
    return doc.id;
  }

  Future<AppointmentModel?> getAppointment(String appointmentId) async {
    final doc = await _appointments.doc(appointmentId).get();
    if (!doc.exists) return null;
    return AppointmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<List<AppointmentModel>> getPatientAppointments(String patientId) async {
    try {
      final snap = await _appointments.where('patientId', isEqualTo: patientId).get();
      final list = snap.docs
          .map((d) => AppointmentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      print("Error in getPatientAppointments: $e");
      return [];
    }
  }

  Future<List<AppointmentModel>> getDoctorAppointments(String doctorId, {String? date}) async {
    try {
      // Index Error Fix: Fetch all by doctorId, then filter by date in memory if provided.
      // This is the SAFEST way to avoid Index errors.
      final snap = await _appointments.where('doctorId', isEqualTo: doctorId).get();
      
      var list = snap.docs
          .map((d) => AppointmentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      
      if (date != null && date.isNotEmpty) {
        list = list.where((a) => a.appointmentDate == date).toList();
      }
      
      // Memory sorting by date string
      list.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      return list;
    } catch (e) {
      print("Error in getDoctorAppointments: $e");
      return [];
    }
  }

  Future<List<AppointmentModel>> getHospitalAppointments(String hospitalId, {String? date}) async {
    try {
      final snap = await _appointments.where('hospitalId', isEqualTo: hospitalId).get();
      var list = snap.docs
          .map((d) => AppointmentModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
          
      if (date != null && date.isNotEmpty) {
        list = list.where((a) => a.appointmentDate == date).toList();
      }

      list.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      return list;
    } catch (e) {
      print("Error in getHospitalAppointments: $e");
      return [];
    }
  }

  Future<List<String>> getBookedSlots(String doctorId, String date) async {
    try {
      final snap = await _appointments
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isEqualTo: date)
          .get();
          
      return snap.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .where((data) => data['status'] != 'Cancelled')
          .map((data) => data['timeSlot'] as String)
          .toList();
    } catch (e) {
      print("Error in getBookedSlots: $e");
      return [];
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _appointments.doc(appointmentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _appointments.doc(appointmentId).update(data);
  }

  // ════════════════════════════════════════
  // PAYMENTS & PRESCRIPTIONS
  // ════════════════════════════════════════

  Future<String> createPayment(PaymentModel payment) async {
    final doc = await _payments.add(payment.toMap());
    return doc.id;
  }

  Future<String> createPrescription(PrescriptionModel p) async {
    final doc = await _prescriptions.add(p.toMap());
    return doc.id;
  }

  Future<List<PrescriptionModel>> getPatientPrescriptions(String patientId) async {
    try {
      final snap = await _prescriptions.where('patientId', isEqualTo: patientId).get();
      final list = snap.docs
          .map((d) => PrescriptionModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      print("Error in getPatientPrescriptions: $e");
      return [];
    }
  }

  // ════════════════════════════════════════
  // NOTIFICATIONS (Real-time wiring)
  // ════════════════════════════════════════

  Future<String> createNotification(NotificationModel n) async {
    final doc = await _notifications.add(n.toMap());
    return doc.id;
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => NotificationModel.fromMap(d.data() as Map<String, dynamic>, d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> markNotificationRead(String id) async =>
      await _notifications.doc(id).update({'isRead': true});

  Future<void> markAllNotificationsRead(String userId) async {
    final snap = await _notifications
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
