/**
 * ============================================================
 * Doctor Appointment Management System
 * Firestore Seed Script v2 (Comprehensive Array Fields Update)
 *
 * Updated Fields to Array [] for Doctors & Requests:
 * - specialization (Multiple Specializations)
 * - hospitalIds (Multiple Linked Hospitals)
 * - symptomsCovered (Multiple Symptoms)
 * - diseasesCovered (Multiple Diseases)
 * - languagesKnown (Multiple Languages)
 *
 * Run: node firestore_seed_v2.js
 * ============================================================
 */

const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db   = admin.firestore();
const auth = admin.auth();
const now  = admin.firestore.Timestamp.now();

// ============================================================
//  COLLECTION NAMES
// ============================================================
const USERS                    = "users";
const HOSPITALS                = "hospitals";
const DOCTORS                  = "doctors";
const DOCTOR_SCHEDULES         = "doctor_schedules";
const DOCTOR_HOSPITAL_REQUESTS = "doctor_hospital_requests";
const PATIENTS                 = "patients";
const APPOINTMENTS             = "appointments";
const PAYMENTS                 = "payments";
const PRESCRIPTIONS            = "prescriptions";
const NOTIFICATIONS            = "notifications";
const REVIEWS_RATINGS          = "reviews_ratings";
const SYMPTOMS_MASTER          = "symptoms_master";
const DISEASE_MASTER           = "disease_master";

// ============================================================
//  COLLECTION 2: hospitals
// ============================================================
const hospitals = [
  {
    id: "hospital_001",
    data: {
      hospitalId:         "hospital_001",
      hospitalName:       "City Care Hospital",
      registrationNo:     "REG/MH/2018/004521",
      address:            "45, MG Road, Sector 12",
      city:               "Ghaziabad",
      state:              "Uttar Pradesh",
      pincode:            "201001",
      contactNumber:      "0120-4567890",
      email:              "info@cityhospital.com",
      website:            "https://www.cityhospital.com",
      logo:               "",
      departments:        ["Cardiology", "ENT", "Orthopedics", "Neurology", "General"],
      workingHours:       { open: "08:00", close: "21:00" },
      emergencyAvailable: true,
      adminUserId:        "",
      status:             "active",
      createdBy:          "super_admin",
      createdAt:          now,
      updatedAt:          now,
    },
  },
  {
    id: "hospital_002",
    data: {
      hospitalId:         "hospital_002",
      hospitalName:       "Sunrise Medical Center",
      registrationNo:     "REG/UP/2020/001122",
      address:            "12, Rajpur Road",
      city:               "Noida",
      state:              "Uttar Pradesh",
      pincode:            "201301",
      contactNumber:      "0120-9876543",
      email:              "contact@sunrisemedical.com",
      website:            "https://www.sunrisemedical.com",
      logo:               "",
      departments:        ["Dermatology", "Gynecology", "Pediatrics", "Ophthalmology"],
      workingHours:       { open: "09:00", close: "20:00" },
      emergencyAvailable: false,
      adminUserId:        "",
      status:             "active",
      createdBy:          "super_admin",
      createdAt:          now,
      updatedAt:          now,
    },
  },
];

// ============================================================
//  COLLECTION 3: doctors (UPDATED WITH MULTIPLE LISTS/ARRAYS)
// ============================================================
const doctors = [
  {
    id: "doctor_001",
    data: {
      doctorId:         "doctor_001",
      userId:           "",
      doctorName:       "Dr. Amit Verma",
      qualification:    "MBBS, MD (Cardiology)",
      specialization:   ["Cardiology", "General Medicine"],          // ✅ Multiple Specializations List
      hospitalIds:      ["hospital_001", "hospital_002"],            // ✅ Multiple Hospitals List
      symptomsCovered:  ["Chest pain", "Shortness of breath", "Palpitations", "Dizziness"], // ✅ Multiple Symptoms List
      diseasesCovered:  ["Heart Attack", "Hypertension", "Arrhythmia", "Heart Failure"],   // ✅ Multiple Diseases List
      languagesKnown:   ["Hindi", "English"],                        // ✅ Multiple Languages List
      experience:       12,
      consultationFee:  800,
      mobileNumber:     "9988776655",
      email:            "amit.verma@cityhospital.com",
      gender:           "male",
      biography:        "Senior cardiologist with 12 years of experience.",
      photo:            "",
      consultationMode: "both",
      rating:           4.8,
      totalReviews:     124,
      status:           "active",
      createdAt:        now,
      updatedAt:        now,
    },
  },
  {
    id: "doctor_002",
    data: {
      doctorId:         "doctor_002",
      userId:           "",
      doctorName:       "Dr. Neha Singh",
      qualification:    "MBBS, MS (ENT)",
      specialization:   ["ENT", "Pediatric ENT"],                     // ✅ Multiple Specializations List
      hospitalIds:      ["hospital_001"],                            // ✅ Multiple Hospitals List
      symptomsCovered:  ["Ear pain", "Hearing loss", "Sore throat", "Nasal congestion"], // ✅ Multiple Symptoms List
      diseasesCovered:  ["Tonsillitis", "Sinusitis", "Otitis", "Nasal Polyps"],           // ✅ Multiple Diseases List
      languagesKnown:   ["Hindi", "English", "Punjabi"],             // ✅ Multiple Languages List
      experience:       8,
      consultationFee:  600,
      mobileNumber:     "9977665544",
      email:            "neha.singh@cityhospital.com",
      gender:           "female",
      biography:        "ENT specialist with 8 years of clinical experience.",
      photo:            "",
      consultationMode: "offline",
      rating:           4.5,
      totalReviews:     89,
      status:           "active",
      createdAt:        now,
      updatedAt:        now,
    },
  },
];

// ============================================================
//  COLLECTION 4: doctor_hospital_requests (UPDATED WITH ARRAYS)
// ============================================================
const doctorHospitalRequests = [
  {
    id: "req_001",
    data: {
      requestId:   "req_001",
      doctorId:    "doctor_001",
      hospitalId:  "hospital_001",
      doctorName:  "Dr. Amit Verma",
      doctorEmail: "amit.verma@cityhospital.com",
      specialization: ["Cardiology", "General Medicine"],            // ✅ Array format
      status:      "approved",
      requestedAt: now,
      respondedAt: now,
      respondedBy: "",
      notes:       "",
    },
  },
  {
    id: "req_002",
    data: {
      requestId:   "req_002",
      doctorId:    "doctor_001",
      hospitalId:  "hospital_002",
      doctorName:  "Dr. Amit Verma",
      doctorEmail: "amit.verma@cityhospital.com",
      specialization: ["Cardiology", "General Medicine"],            // ✅ Array format
      status:      "approved",
      requestedAt: now,
      respondedAt: now,
      respondedBy: "",
      notes:       "",
    },
  },
  {
    id: "req_003",
    data: {
      requestId:   "req_003",
      doctorId:    "doctor_002",
      hospitalId:  "hospital_001",
      doctorName:  "Dr. Neha Singh",
      doctorEmail: "neha.singh@cityhospital.com",
      specialization: ["ENT", "Pediatric ENT"],                       // ✅ Array format
      status:      "approved",
      requestedAt: now,
      respondedAt: now,
      respondedBy: "",
      notes:       "",
    },
  },
  {
    id: "req_004",
    data: {
      requestId:   "req_004",
      doctorId:    "doctor_002",
      hospitalId:  "hospital_002",
      doctorName:  "Dr. Neha Singh",
      doctorEmail: "neha.singh@cityhospital.com",
      specialization: ["ENT", "Pediatric ENT"],                       // ✅ Array format
      status:      "pending",
      requestedAt: now,
      respondedAt: null,
      respondedBy: "",
      notes:       "",
    },
  },
];

// ============================================================
//  COLLECTION 5: doctor_schedules
// ============================================================
const doctorSchedules = [
  {
    id: "schedule_001",
    data: {
      scheduleId:         "schedule_001",
      doctorId:           "doctor_001",
      hospitalId:         "hospital_001",
      day:                "Monday",
      startTime:          "10:00",
      endTime:            "13:00",
      slotDuration:       15,
      breakTime:          { start: "13:00", end: "14:00" },
      maxPatients:        12,
      availabilityStatus: "available",
      createdAt:          now,
      updatedAt:          now,
    },
  },
  {
    id: "schedule_002",
    data: {
      scheduleId:         "schedule_002",
      doctorId:           "doctor_001",
      hospitalId:         "hospital_002",
      day:                "Wednesday",
      startTime:          "15:00",
      endTime:            "18:00",
      slotDuration:       15,
      breakTime:          { start: "17:00", end: "17:15" },
      maxPatients:        10,
      availabilityStatus: "available",
      createdAt:          now,
      updatedAt:          now,
    },
  },
  {
    id: "schedule_003",
    data: {
      scheduleId:         "schedule_003",
      doctorId:           "doctor_002",
      hospitalId:         "hospital_001",
      day:                "Tuesday",
      startTime:          "09:00",
      endTime:            "12:00",
      slotDuration:       30,
      breakTime:          { start: "12:00", end: "13:00" },
      maxPatients:        6,
      availabilityStatus: "available",
      createdAt:          now,
      updatedAt:          now,
    },
  },
];

// ============================================================
//  COLLECTION 6: patients
// ============================================================
const patients = [
  {
    id: "patient_001",
    data: {
      patientId:        "patient_001",
      userId:           "",
      fullName:         "Sunita Gupta",
      dob:              admin.firestore.Timestamp.fromDate(new Date("1990-06-15")),
      gender:           "female",
      bloodGroup:       "B+",
      mobile:           "9812345678",
      email:            "sunita.gupta@gmail.com",
      address:          "23, Lal Kuan, Ghaziabad, UP - 201001",
      emergencyContact: "9812340000",
      medicalHistory:   ["Hypertension", "Thyroid"],
      allergies:        ["Penicillin"],
      insuranceDetails: {
        provider:  "Star Health Insurance",
        policyNo:  "STR/2024/0045678",
        validTill: admin.firestore.Timestamp.fromDate(new Date("2025-12-31")),
      },
      profilePhoto: "",
      createdAt:    now,
      updatedAt:    now,
    },
  },
  {
    id: "patient_002",
    data: {
      patientId:        "patient_002",
      userId:           "",
      fullName:         "Rohit Agarwal",
      dob:              admin.firestore.Timestamp.fromDate(new Date("1985-03-22")),
      gender:           "male",
      bloodGroup:       "O+",
      mobile:           "9834567890",
      email:            "rohit.agarwal@gmail.com",
      address:          "7, Sector 5, Noida, UP - 201301",
      emergencyContact: "9834560000",
      medicalHistory:   ["Diabetes Type 2"],
      allergies:        [],
      insuranceDetails: {
        provider:  "HDFC ERGO",
        policyNo:  "HE/2023/0078912",
        validTill: admin.firestore.Timestamp.fromDate(new Date("2026-03-31")),
      },
      profilePhoto: "",
      createdAt:    now,
      updatedAt:    now,
    },
  },
];

// ============================================================
//  COLLECTION 7: appointments
// ============================================================
const appointments = [
  {
    id: "appt_001",
    data: {
      appointmentId:    "appt_001",
      patientId:        "patient_001",
      doctorId:         "doctor_001",
      hospitalId:       "hospital_001",
      appointmentDate:  "2025-07-10",
      timeSlot:         "10:00",
      consultationType: "offline",
      symptoms:         "Chest pain and shortness of breath since 3 days",
      status:           "confirmed",
      paymentStatus:    "paid",
      transactionId:    "TXN202507100001",
      fee:              800,
      notes:            "Patient has history of hypertension",
      createdAt:        now,
      updatedAt:        now,
    },
  },
  {
    id: "appt_002",
    data: {
      appointmentId:    "appt_002",
      patientId:        "patient_002",
      doctorId:         "doctor_002",
      hospitalId:       "hospital_001",
      appointmentDate:  "2025-07-11",
      timeSlot:         "09:30",
      consultationType: "offline",
      symptoms:         "Sore throat and ear pain for 5 days",
      status:           "pending",
      paymentStatus:    "unpaid",
      transactionId:    "",
      fee:              600,
      notes:            "",
      createdAt:        now,
      updatedAt:        now,
    },
  },
];

// ============================================================
//  COLLECTION 8: payments
// ============================================================
const payments = [
  {
    id: "pay_001",
    data: {
      paymentId:     "pay_001",
      appointmentId: "appt_001",
      patientId:     "patient_001",
      amount:        800,
      paymentMethod: "UPI",
      transactionId: "TXN202507100001",
      paymentDate:   now,
      status:        "success",
      invoiceUrl:    "",
      createdAt:     now,
      updatedAt:     now,
    },
  },
];

// ============================================================
//  COLLECTION 9: prescriptions
// ============================================================
const prescriptions = [
  {
    id: "presc_001",
    data: {
      prescriptionId: "presc_001",
      appointmentId:  "appt_001",
      doctorId:       "doctor_001",
      patientId:      "patient_001",
      hospitalId:     "hospital_001",
      doctorRemarks:  "Patient has mild angina. Advised rest and medication.",
      medicines: [
        { name: "Aspirin 75mg",      dosage: "1 tablet", frequency: "Once daily", duration: "30 days", notes: "After breakfast" },
        { name: "Atorvastatin 10mg", dosage: "1 tablet", frequency: "Once daily", duration: "30 days", notes: "At night" },
      ],
      tests:        ["ECG", "Lipid Profile", "CBC"],
      followUpDate: "2025-08-10",
      createdAt:    now,
      updatedAt:    now,
    },
  },
];

// ============================================================
//  COLLECTION 10: notifications
// ============================================================
const notifications = [
  {
    id: "notif_001",
    data: {
      notificationId: "notif_001",
      userId:         "",
      title:          "Appointment Confirmed",
      message:        "Your appointment with Dr. Amit Verma on 10 July at 10:00 AM is confirmed.",
      type:           "appointment_confirmation",
      channel:        "push",
      isRead:         false,
      createdAt:      now,
    },
  },
];

// ============================================================
//  COLLECTION 11: reviews_ratings
// ============================================================
const reviewsRatings = [
  {
    id: "review_001",
    data: {
      reviewId:      "review_001",
      appointmentId: "appt_001",
      patientId:     "patient_001",
      doctorId:      "doctor_001",
      hospitalId:    "hospital_001",
      rating:        5,
      review:        "Dr. Amit was very thorough. Highly recommended!",
      createdAt:     now,
      updatedAt:     now,
    },
  },
];

// ============================================================
//  COLLECTION 12: symptoms_master
// ============================================================
const symptomsMaster = [
  { id: "sym_001", data: { symptomId: "sym_001", name: "Chest Pain",          relatedSpecializations: ["Cardiology"],               createdAt: now } },
  { id: "sym_002", data: { symptomId: "sym_002", name: "Shortness of Breath", relatedSpecializations: ["Cardiology", "Pulmonology"], createdAt: now } },
  { id: "sym_003", data: { symptomId: "sym_003", name: "Ear Pain",            relatedSpecializations: ["ENT"],                      createdAt: now } },
  { id: "sym_004", data: { symptomId: "sym_004", name: "Sore Throat",         relatedSpecializations: ["ENT", "General"],           createdAt: now } },
  { id: "sym_005", data: { symptomId: "sym_005", name: "Fever",               relatedSpecializations: ["General", "Pediatrics"],    createdAt: now } },
  { id: "sym_006", data: { symptomId: "sym_006", name: "Joint Pain",          relatedSpecializations: ["Orthopedics"],              createdAt: now } },
  { id: "sym_007", data: { symptomId: "sym_007", name: "Skin Rash",           relatedSpecializations: ["Dermatology"],              createdAt: now } },
  { id: "sym_008", data: { symptomId: "sym_008", name: "Blurred Vision",      relatedSpecializations: ["Ophthalmology"],            createdAt: now } },
];

// ============================================================
//  COLLECTION 13: disease_master
// ============================================================
const diseaseMaster = [
  { id: "dis_001", data: { diseaseId: "dis_001", name: "Heart Attack",   relatedSpecializations: ["Cardiology"],               createdAt: now } },
  { id: "dis_002", data: { diseaseId: "dis_002", name: "Hypertension",   relatedSpecializations: ["Cardiology", "General"],    createdAt: now } },
  { id: "dis_003", data: { diseaseId: "dis_003", name: "Tonsillitis",    relatedSpecializations: ["ENT"],                      createdAt: now } },
  { id: "dis_004", data: { diseaseId: "dis_004", name: "Sinusitis",      relatedSpecializations: ["ENT"],                      createdAt: now } },
  { id: "dis_005", data: { diseaseId: "dis_005", name: "Diabetes",       relatedSpecializations: ["Endocrinology", "General"], createdAt: now } },
  { id: "dis_006", data: { diseaseId: "dis_006", name: "Asthma",         relatedSpecializations: ["Pulmonology"],              createdAt: now } },
  { id: "dis_007", data: { diseaseId: "dis_007", name: "Cataract",       relatedSpecializations: ["Ophthalmology"],            createdAt: now } },
  { id: "dis_008", data: { diseaseId: "dis_008", name: "Osteoarthritis", relatedSpecializations: ["Orthopedics"],              createdAt: now } },
];

// ============================================================
//  AUTH USERS (UPDATED WITH DOCTOR LINKED FIELDS)
// ============================================================
const usersToCreate = [
  {
    email: "rahul.superadmin@dams.com", password: "Test@1234",
    firestoreData: {
      name:       "Rahul Sharma",
      mobile:     "9876543210",
      email:      "rahul.superadmin@dams.com",
      role:       "super_admin",
      status:     "active",
      hospitalId: null,
      hospitalIds:null,
      doctorId:   null,
      patientId:  null,
      createdAt:  now,
      updatedAt:  now,
    },
  },
  {
    email: "priya.admin@cityhospital.com", password: "Test@1234",
    firestoreData: {
      name:       "Priya Mehta",
      mobile:     "9123456780",
      email:      "priya.admin@cityhospital.com",
      role:       "hospital_admin",
      status:     "active",
      hospitalId: "hospital_001",
      hospitalIds:null,
      doctorId:   null,
      patientId:  null,
      createdAt:  now,
      updatedAt:  now,
    },
    isHospitalAdmin:  true,
    linkedHospitalId: "hospital_001",
  },
  {
    email: "amit.verma@cityhospital.com", password: "Test@1234",
    firestoreData: {
      name:       "Dr. Amit Verma",
      mobile:     "9988776655",
      email:      "amit.verma@cityhospital.com",
      role:       "doctor",
      status:     "active",
      hospitalId: null,
      hospitalIds:["hospital_001", "hospital_002"],                 // ✅ Hospital list inside users as well
      doctorId:   "doctor_001",
      patientId:  null,
      createdAt:  now,
      updatedAt:  now,
    },
    isDoctorProfile: true,
    linkedDoctorId:  "doctor_001",
  },
  {
    email: "neha.singh@cityhospital.com", password: "Test@1234",
    firestoreData: {
      name:       "Dr. Neha Singh",
      mobile:     "9977665544",
      email:      "neha.singh@cityhospital.com",
      role:       "doctor",
      status:     "active",
      hospitalId: null,
      hospitalIds:["hospital_001"],                                 // ✅ Hospital list
      doctorId:   "doctor_002",
      patientId:  null,
      createdAt:  now,
      updatedAt:  now,
    },
    isDoctorProfile: true,
    linkedDoctorId:  "doctor_002",
  },
  {
    email: "sunita.gupta@gmail.com", password: "Test@1234",
    firestoreData: {
      name:       "Sunita Gupta",
      mobile:     "9812345678",
      email:      "sunita.gupta@gmail.com",
      role:       "patient",
      status:     "active",
      hospitalId: null,
      hospitalIds:null,
      doctorId:   null,
      patientId:  "patient_001",
      createdAt:  now,
      updatedAt:  now,
    },
    isPatientProfile: true,
    linkedPatientId:  "patient_001",
  },
  {
    email: "rohit.agarwal@gmail.com", password: "Test@1234",
    firestoreData: {
      name:       "Rohit Agarwal",
      mobile:     "9834567890",
      email:      "rohit.agarwal@gmail.com",
      role:       "patient",
      status:     "active",
      hospitalId: null,
      hospitalIds:null,
      doctorId:   null,
      patientId:  "patient_002",
      createdAt:  now,
      updatedAt:  now,
    },
    isPatientProfile: true,
    linkedPatientId:  "patient_002",
  },
];

// ============================================================
//  HELPERS
// ============================================================
async function seedCollection(name, docs) {
  const batch = db.batch();
  for (const doc of docs) {
    batch.set(db.collection(name).doc(doc.id), doc.data);
  }
  await batch.commit();
  console.log(`   ✅ ${name} → ${docs.length} docs inserted`);
}

async function purgeCollection(name) {
  const snap = await db.collection(name).get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  console.log(`   🗑️  ${name} → ${snap.size} docs deleted`);
}

// ============================================================
//  MAIN EXECUTION
// ============================================================
async function main() {
  console.log("🚀 Doctor App v2 — Full Seed File (All Multiple Selection Arrays Active)");
  console.log("=".repeat(65));

  console.log("\n🗑️  Step 1: Cleaning previous Firestore collections...");
  await purgeCollection(USERS);
  await purgeCollection(HOSPITALS);
  await purgeCollection(DOCTORS);
  await purgeCollection(DOCTOR_SCHEDULES);
  await purgeCollection(DOCTOR_HOSPITAL_REQUESTS);
  await purgeCollection(PATIENTS);
  await purgeCollection(APPOINTMENTS);
  await purgeCollection(PAYMENTS);
  await purgeCollection(PRESCRIPTIONS);
  await purgeCollection(NOTIFICATIONS);
  await purgeCollection(REVIEWS_RATINGS);
  await purgeCollection(SYMPTOMS_MASTER);
  await purgeCollection(DISEASE_MASTER);

  console.log("\n📦 Step 2: Seeding fresh collections data with Arrays...");
  await seedCollection(HOSPITALS,                hospitals);
  await seedCollection(DOCTORS,                  doctors);
  await seedCollection(DOCTOR_HOSPITAL_REQUESTS, doctorHospitalRequests);
  await seedCollection(DOCTOR_SCHEDULES,         doctorSchedules);
  await seedCollection(PATIENTS,                 patients);
  await seedCollection(APPOINTMENTS,             appointments);
  await seedCollection(PAYMENTS,                 payments);
  await seedCollection(PRESCRIPTIONS,            prescriptions);
  await seedCollection(NOTIFICATIONS,            notifications);
  await seedCollection(REVIEWS_RATINGS,          reviewsRatings);
  await seedCollection(SYMPTOMS_MASTER,          symptomsMaster);
  await seedCollection(DISEASE_MASTER,           diseaseMaster);

  console.log("\n👤 Step 3: Creating Authentication Profiles and linking users...");

  for (const user of usersToCreate) {
    console.log(`📧 ${user.email} [${user.firestoreData.role}]`);
    let uid;

    try {
      const authUser = await auth.createUser({
        email:         user.email,
        password:      user.password,
        displayName:   user.firestoreData.name,
        emailVerified: true,
      });
      uid = authUser.uid;
      console.log(`   ✅ Auth created → UID: ${uid}`);
    } catch (err) {
      if (err.code === "auth/email-already-exists") {
        const existing = await auth.getUserByEmail(user.email);
        uid = existing.uid;
        console.log(`   ℹ️  Auth exists  → UID: ${uid}`);
      } else {
        console.log(`   ❌ Auth error: ${err.message}`);
        continue;
      }
    }

    await db.collection(USERS).doc(uid).set({
      ...user.firestoreData,
      userId: uid,
    });
    console.log(`   ✅ users/${uid} entry created`);

    if (user.isDoctorProfile) {
      await db.collection(DOCTORS).doc(user.linkedDoctorId).update({
        userId: uid, updatedAt: now,
      });
      console.log(`   🩺 doctors/${user.linkedDoctorId} → userId reference set`);
    }

    if (user.isPatientProfile) {
      await db.collection(PATIENTS).doc(user.linkedPatientId).update({
        userId: uid, updatedAt: now,
      });
      console.log(`   🙍 patients/${user.linkedPatientId} → userId reference set`);
    }

    if (user.isHospitalAdmin) {
      await db.collection(HOSPITALS).doc(user.linkedHospitalId).update({
        adminUserId: uid, updatedAt: now,
      });
      console.log(`   🏨 hospitals/${user.linkedHospitalId} → adminUserId reference set`);
    }

    console.log();
  }

  console.log("=".repeat(65));
  console.log("\n🎉 Database fully configured! All core filtering values are saved as clean lists.");
  process.exit(0);
}

main().catch((err) => {
  console.error("\n❌ Execution Error:", err.message);
  process.exit(1);
});