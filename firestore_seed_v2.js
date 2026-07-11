/**
 * ============================================================
 *  Doctor Appointment Management System
 *  Firestore Seed Script v2 — FIXED for firebase-admin v14
 *
 *  Run: node firestore_seed_v2_fixed.js
 * ============================================================
 */

// ✅ firebase-admin v14 import style
const { initializeApp, cert }                    = require("firebase-admin/app");
const { getFirestore, Timestamp, FieldValue }    = require("firebase-admin/firestore");
const { getAuth }                                = require("firebase-admin/auth");
const serviceAccount                             = require("./serviceAccountKey.json");

initializeApp({ credential: cert(serviceAccount) });

const db  = getFirestore();
const auth = getAuth();
const now  = Timestamp.now();

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
const SPECIALIZATION_MASTER    = "specialization_master";
const QUALIFICATION_MASTER     = "qualification_master";

// ============================================================
//  HOSPITALS
// ============================================================
const hospitals = [
  {
    id: "hospital_001",
    data: {
      hospitalId: "hospital_001", hospitalName: "City Care Hospital",
      registrationNo: "REG/MH/2018/004521", address: "45, MG Road, Sector 12",
      city: "Ghaziabad", state: "Uttar Pradesh", pincode: "201001",
      contactNumber: "0120-4567890", email: "info@cityhospital.com",
      website: "https://www.cityhospital.com", logo: "",
      departments: ["Cardiology","ENT","Orthopedics","Neurology","General"],
      workingHours: { open: "08:00", close: "21:00" },
      emergencyAvailable: true, adminUserId: "",
      status: "active", createdBy: "super_admin",
      createdAt: now, updatedAt: now,
    },
  },
  {
    id: "hospital_002",
    data: {
      hospitalId: "hospital_002", hospitalName: "Sunrise Medical Center",
      registrationNo: "REG/UP/2020/001122", address: "12, Rajpur Road",
      city: "Noida", state: "Uttar Pradesh", pincode: "201301",
      contactNumber: "0120-9876543", email: "contact@sunrisemedical.com",
      website: "https://www.sunrisemedical.com", logo: "",
      departments: ["Dermatology","Gynecology","Pediatrics","Ophthalmology"],
      workingHours: { open: "09:00", close: "20:00" },
      emergencyAvailable: false, adminUserId: "",
      status: "active", createdBy: "super_admin",
      createdAt: now, updatedAt: now,
    },
  },
];

// ============================================================
//  DOCTORS
// ============================================================
const doctors = [
  {
    id: "doctor_001",
    data: {
      doctorId: "doctor_001", userId: "",
      doctorName: "Dr. Amit Verma", qualification: "MBBS, MD (Cardiology)",
      specialization: ["Cardiology","General Medicine"],
      hospitalIds: ["hospital_001","hospital_002"],
      symptomsCovered: ["Chest pain","Shortness of breath","Palpitations","Dizziness"],
      diseasesCovered: ["Heart Attack","Hypertension","Arrhythmia","Heart Failure"],
      languagesKnown: ["Hindi","English"],
      experience: 12, consultationFee: 800, mobileNumber: "9988776655",
      email: "amit.verma@cityhospital.com", gender: "male",
      biography: "Senior cardiologist with 12 years of experience.",
      photo: "", consultationMode: "both",
      rating: 4.8, totalReviews: 124, status: "active",
      createdAt: now, updatedAt: now,
    },
  },
  {
    id: "doctor_002",
    data: {
      doctorId: "doctor_002", userId: "",
      doctorName: "Dr. Neha Singh", qualification: "MBBS, MS (ENT)",
      specialization: ["ENT","Pediatric ENT"],
      hospitalIds: ["hospital_001"],
      symptomsCovered: ["Ear pain","Hearing loss","Sore throat","Nasal congestion"],
      diseasesCovered: ["Tonsillitis","Sinusitis","Otitis","Nasal Polyps"],
      languagesKnown: ["Hindi","English","Punjabi"],
      experience: 8, consultationFee: 600, mobileNumber: "9977665544",
      email: "neha.singh@cityhospital.com", gender: "female",
      biography: "ENT specialist with 8 years of clinical experience.",
      photo: "", consultationMode: "offline",
      rating: 4.5, totalReviews: 89, status: "active",
      createdAt: now, updatedAt: now,
    },
  },
];

// ============================================================
//  DOCTOR HOSPITAL REQUESTS
// ============================================================
const doctorHospitalRequests = [
  {
    id: "req_001",
    data: {
      requestId: "req_001", doctorId: "doctor_001", hospitalId: "hospital_001",
      doctorName: "Dr. Amit Verma", doctorEmail: "amit.verma@cityhospital.com",
      specialization: ["Cardiology","General Medicine"],
      status: "approved", requestedAt: now, respondedAt: now, respondedBy: "", notes: "",
    },
  },
  {
    id: "req_002",
    data: {
      requestId: "req_002", doctorId: "doctor_001", hospitalId: "hospital_002",
      doctorName: "Dr. Amit Verma", doctorEmail: "amit.verma@cityhospital.com",
      specialization: ["Cardiology","General Medicine"],
      status: "approved", requestedAt: now, respondedAt: now, respondedBy: "", notes: "",
    },
  },
  {
    id: "req_003",
    data: {
      requestId: "req_003", doctorId: "doctor_002", hospitalId: "hospital_001",
      doctorName: "Dr. Neha Singh", doctorEmail: "neha.singh@cityhospital.com",
      specialization: ["ENT","Pediatric ENT"],
      status: "approved", requestedAt: now, respondedAt: now, respondedBy: "", notes: "",
    },
  },
  {
    id: "req_004",
    data: {
      requestId: "req_004", doctorId: "doctor_002", hospitalId: "hospital_002",
      doctorName: "Dr. Neha Singh", doctorEmail: "neha.singh@cityhospital.com",
      specialization: ["ENT","Pediatric ENT"],
      status: "pending", requestedAt: now, respondedAt: null, respondedBy: "", notes: "",
    },
  },
];

// ============================================================
//  DOCTOR SCHEDULES
// ============================================================
const doctorSchedules = [
  {
    id: "schedule_001",
    data: {
      scheduleId: "schedule_001", doctorId: "doctor_001", hospitalId: "hospital_001",
      day: "Monday", startTime: "10:00", endTime: "13:00", slotDuration: 15,
      breakTime: { start: "13:00", end: "14:00" },
      maxPatients: 12, availabilityStatus: "available", createdAt: now, updatedAt: now,
    },
  },
  {
    id: "schedule_002",
    data: {
      scheduleId: "schedule_002", doctorId: "doctor_001", hospitalId: "hospital_002",
      day: "Wednesday", startTime: "15:00", endTime: "18:00", slotDuration: 15,
      breakTime: { start: "17:00", end: "17:15" },
      maxPatients: 10, availabilityStatus: "available", createdAt: now, updatedAt: now,
    },
  },
  {
    id: "schedule_003",
    data: {
      scheduleId: "schedule_003", doctorId: "doctor_002", hospitalId: "hospital_001",
      day: "Tuesday", startTime: "09:00", endTime: "12:00", slotDuration: 30,
      breakTime: { start: "12:00", end: "13:00" },
      maxPatients: 6, availabilityStatus: "available", createdAt: now, updatedAt: now,
    },
  },
];

// ============================================================
//  PATIENTS
// ============================================================
const patients = [
  {
    id: "patient_001",
    data: {
      patientId: "patient_001", userId: "", fullName: "Sunita Gupta",
      dob: Timestamp.fromDate(new Date("1990-06-15")),
      gender: "female", bloodGroup: "B+", mobile: "9812345678",
      email: "sunita.gupta@gmail.com", address: "23, Lal Kuan, Ghaziabad, UP - 201001",
      emergencyContact: "9812340000", medicalHistory: ["Hypertension","Thyroid"],
      allergies: ["Penicillin"],
      insuranceDetails: {
        provider: "Star Health Insurance", policyNo: "STR/2024/0045678",
        validTill: Timestamp.fromDate(new Date("2025-12-31")),
      },
      profilePhoto: "", createdAt: now, updatedAt: now,
    },
  },
  {
    id: "patient_002",
    data: {
      patientId: "patient_002", userId: "", fullName: "Rohit Agarwal",
      dob: Timestamp.fromDate(new Date("1985-03-22")),
      gender: "male", bloodGroup: "O+", mobile: "9834567890",
      email: "rohit.agarwal@gmail.com", address: "7, Sector 5, Noida, UP - 201301",
      emergencyContact: "9834560000", medicalHistory: ["Diabetes Type 2"],
      allergies: [],
      insuranceDetails: {
        provider: "HDFC ERGO", policyNo: "HE/2023/0078912",
        validTill: Timestamp.fromDate(new Date("2026-03-31")),
      },
      profilePhoto: "", createdAt: now, updatedAt: now,
    },
  },
];

// ============================================================
//  APPOINTMENTS
// ============================================================
const appointments = [
  {
    id: "appt_001",
    data: {
      appointmentId: "appt_001", patientId: "patient_001",
      doctorId: "doctor_001", hospitalId: "hospital_001",
      appointmentDate: "2025-07-10", timeSlot: "10:00",
      consultationType: "offline",
      symptoms: "Chest pain and shortness of breath since 3 days",
      status: "confirmed", paymentStatus: "paid",
      transactionId: "TXN202507100001", fee: 800,
      notes: "Patient has history of hypertension",
      createdAt: now, updatedAt: now,
    },
  },
  {
    id: "appt_002",
    data: {
      appointmentId: "appt_002", patientId: "patient_002",
      doctorId: "doctor_002", hospitalId: "hospital_001",
      appointmentDate: "2025-07-11", timeSlot: "09:30",
      consultationType: "offline",
      symptoms: "Sore throat and ear pain for 5 days",
      status: "pending", paymentStatus: "unpaid",
      transactionId: "", fee: 600, notes: "",
      createdAt: now, updatedAt: now,
    },
  },
];

// ============================================================
//  PAYMENTS
// ============================================================
const payments = [
  {
    id: "pay_001",
    data: {
      paymentId: "pay_001", appointmentId: "appt_001",
      patientId: "patient_001", amount: 800, paymentMethod: "UPI",
      transactionId: "TXN202507100001", paymentDate: now,
      status: "success", invoiceUrl: "", createdAt: now, updatedAt: now,
    },
  },
];

// ============================================================
//  PRESCRIPTIONS
// ============================================================
const prescriptions = [
  {
    id: "presc_001",
    data: {
      prescriptionId: "presc_001", appointmentId: "appt_001",
      doctorId: "doctor_001", patientId: "patient_001", hospitalId: "hospital_001",
      doctorRemarks: "Patient has mild angina. Advised rest and medication.",
      medicines: [
        { name: "Aspirin 75mg",      dosage: "1 tablet", frequency: "Once daily", duration: "30 days", notes: "After breakfast" },
        { name: "Atorvastatin 10mg", dosage: "1 tablet", frequency: "Once daily", duration: "30 days", notes: "At night" },
      ],
      tests: ["ECG","Lipid Profile","CBC"],
      followUpDate: "2025-08-10", createdAt: now, updatedAt: now,
    },
  },
];

// ============================================================
//  NOTIFICATIONS
// ============================================================
const notifications = [
  {
    id: "notif_001",
    data: {
      notificationId: "notif_001", userId: "",
      title: "Appointment Confirmed",
      message: "Your appointment with Dr. Amit Verma on 10 July at 10:00 AM is confirmed.",
      type: "appointment_confirmation", channel: "push",
      isRead: false, createdAt: now,
    },
  },
];

// ============================================================
//  REVIEWS RATINGS
// ============================================================
const reviewsRatings = [
  {
    id: "review_001",
    data: {
      reviewId: "review_001", appointmentId: "appt_001",
      patientId: "patient_001", doctorId: "doctor_001", hospitalId: "hospital_001",
      rating: 5, review: "Dr. Amit was very thorough. Highly recommended!",
      createdAt: now, updatedAt: now,
    },
  },
];

// ============================================================
//  SYMPTOMS MASTER
// ============================================================
const symptomsMaster = [
  { id: "sym_001", data: { symptomId: "sym_001", name: "Chest Pain",          relatedSpecializations: ["Cardiology"],               createdAt: now } },
  { id: "sym_002", data: { symptomId: "sym_002", name: "Shortness of Breath", relatedSpecializations: ["Cardiology","Pulmonology"],  createdAt: now } },
  { id: "sym_003", data: { symptomId: "sym_003", name: "Ear Pain",            relatedSpecializations: ["ENT"],                      createdAt: now } },
  { id: "sym_004", data: { symptomId: "sym_004", name: "Sore Throat",         relatedSpecializations: ["ENT","General"],            createdAt: now } },
  { id: "sym_005", data: { symptomId: "sym_005", name: "Fever",               relatedSpecializations: ["General","Pediatrics"],     createdAt: now } },
  { id: "sym_006", data: { symptomId: "sym_006", name: "Joint Pain",          relatedSpecializations: ["Orthopedics"],              createdAt: now } },
  { id: "sym_007", data: { symptomId: "sym_007", name: "Skin Rash",           relatedSpecializations: ["Dermatology"],              createdAt: now } },
  { id: "sym_008", data: { symptomId: "sym_008", name: "Blurred Vision",      relatedSpecializations: ["Ophthalmology"],            createdAt: now } },
];

// ============================================================
//  DISEASE MASTER
// ============================================================
const diseaseMaster = [
  { id: "dis_001", data: { diseaseId: "dis_001", name: "Heart Attack",   relatedSpecializations: ["Cardiology"],               createdAt: now } },
  { id: "dis_002", data: { diseaseId: "dis_002", name: "Hypertension",   relatedSpecializations: ["Cardiology","General"],     createdAt: now } },
  { id: "dis_003", data: { diseaseId: "dis_003", name: "Tonsillitis",    relatedSpecializations: ["ENT"],                     createdAt: now } },
  { id: "dis_004", data: { diseaseId: "dis_004", name: "Sinusitis",      relatedSpecializations: ["ENT"],                     createdAt: now } },
  { id: "dis_005", data: { diseaseId: "dis_005", name: "Diabetes",       relatedSpecializations: ["Endocrinology","General"], createdAt: now } },
  { id: "dis_006", data: { diseaseId: "dis_006", name: "Asthma",         relatedSpecializations: ["Pulmonology"],             createdAt: now } },
  { id: "dis_007", data: { diseaseId: "dis_007", name: "Cataract",       relatedSpecializations: ["Ophthalmology"],           createdAt: now } },
  { id: "dis_008", data: { diseaseId: "dis_008", name: "Osteoarthritis", relatedSpecializations: ["Orthopedics"],             createdAt: now } },
];

// ============================================================
//  SPECIALIZATION MASTER
// ============================================================
const specializationMaster = [
  { id: "spec_001",  data: { specializationId: "spec_001",  name: "Cardiology",           status: "active", createdAt: now } },
  { id: "spec_002",  data: { specializationId: "spec_002",  name: "ENT",                  status: "active", createdAt: now } },
  { id: "spec_003",  data: { specializationId: "spec_003",  name: "General Medicine",     status: "active", createdAt: now } },
  { id: "spec_004",  data: { specializationId: "spec_004",  name: "Orthopedics",          status: "active", createdAt: now } },
  { id: "spec_005",  data: { specializationId: "spec_005",  name: "Dermatology",          status: "active", createdAt: now } },
  { id: "spec_006",  data: { specializationId: "spec_006",  name: "Gynecology",           status: "active", createdAt: now } },
  { id: "spec_007",  data: { specializationId: "spec_007",  name: "Pediatrics",           status: "active", createdAt: now } },
  { id: "spec_008",  data: { specializationId: "spec_008",  name: "Neurology",            status: "active", createdAt: now } },
  { id: "spec_009",  data: { specializationId: "spec_009",  name: "Ophthalmology",        status: "active", createdAt: now } },
  { id: "spec_010",  data: { specializationId: "spec_010",  name: "Pulmonology",          status: "active", createdAt: now } },
  { id: "spec_011",  data: { specializationId: "spec_011",  name: "Endocrinology",        status: "active", createdAt: now } },
  { id: "spec_012",  data: { specializationId: "spec_012",  name: "Psychiatry",           status: "active", createdAt: now } },
  { id: "spec_013",  data: { specializationId: "spec_013",  name: "Urology",              status: "active", createdAt: now } },
  { id: "spec_014",  data: { specializationId: "spec_014",  name: "Dentistry",            status: "active", createdAt: now } },
  { id: "spec_015",  data: { specializationId: "spec_015",  name: "Pediatric ENT",        status: "active", createdAt: now } },
  { id: "spec_016",  data: { specializationId: "spec_016",  name: "Gastroenterology",     status: "active", createdAt: now } },
  { id: "spec_017",  data: { specializationId: "spec_017",  name: "Nephrology",           status: "active", createdAt: now } },
  { id: "spec_018",  data: { specializationId: "spec_018",  name: "Oncology",             status: "active", createdAt: now } },
  { id: "spec_019",  data: { specializationId: "spec_019",  name: "Rheumatology",         status: "active", createdAt: now } },
  { id: "spec_020",  data: { specializationId: "spec_020",  name: "Physiotherapy",        status: "active", createdAt: now } },
  { id: "spec_021",  data: { specializationId: "spec_021",  name: "Ayurveda",             status: "active", createdAt: now } },
  { id: "spec_022",  data: { specializationId: "spec_022",  name: "Homeopathy",           status: "active", createdAt: now } },
  { id: "spec_023",  data: { specializationId: "spec_023",  name: "Nutrition & Dietetics",status: "active", createdAt: now } },
  { id: "spec_024",  data: { specializationId: "spec_024",  name: "Plastic Surgery",      status: "active", createdAt: now } },
  { id: "spec_025",  data: { specializationId: "spec_025",  name: "Other",                status: "active", createdAt: now } },
];

// ============================================================
//  QUALIFICATION MASTER
// ============================================================
const qualificationMaster = [
  { id: "qual_001", data: { qualificationId: "qual_001", name: "MBBS",              status: "active", createdAt: now } },
  { id: "qual_002", data: { qualificationId: "qual_002", name: "MD",                status: "active", createdAt: now } },
  { id: "qual_003", data: { qualificationId: "qual_003", name: "MS",                status: "active", createdAt: now } },
  { id: "qual_004", data: { qualificationId: "qual_004", name: "DM",                status: "active", createdAt: now } },
  { id: "qual_005", data: { qualificationId: "qual_005", name: "MCh",               status: "active", createdAt: now } },
  { id: "qual_006", data: { qualificationId: "qual_006", name: "DNB",               status: "active", createdAt: now } },
  { id: "qual_007", data: { qualificationId: "qual_007", name: "FCPS",              status: "active", createdAt: now } },
  { id: "qual_008", data: { qualificationId: "qual_008", name: "MRCP",              status: "active", createdAt: now } },
  { id: "qual_009", data: { qualificationId: "qual_009", name: "FRCS",              status: "active", createdAt: now } },
  { id: "qual_010", data: { qualificationId: "qual_010", name: "PhD (Medical)",     status: "active", createdAt: now } },
  { id: "qual_011", data: { qualificationId: "qual_011", name: "Diploma (Medical)", status: "active", createdAt: now } },
  { id: "qual_012", data: { qualificationId: "qual_012", name: "BAMS",              status: "active", createdAt: now } },
  { id: "qual_013", data: { qualificationId: "qual_013", name: "MD (Ayurveda)",     status: "active", createdAt: now } },
  { id: "qual_014", data: { qualificationId: "qual_014", name: "BHMS",              status: "active", createdAt: now } },
  { id: "qual_015", data: { qualificationId: "qual_015", name: "MD (Homeopathy)",   status: "active", createdAt: now } },
  { id: "qual_016", data: { qualificationId: "qual_016", name: "BUMS",              status: "active", createdAt: now } },
  { id: "qual_017", data: { qualificationId: "qual_017", name: "BDS",               status: "active", createdAt: now } },
  { id: "qual_018", data: { qualificationId: "qual_018", name: "MDS",               status: "active", createdAt: now } },
  { id: "qual_019", data: { qualificationId: "qual_019", name: "BPT",               status: "active", createdAt: now } },
  { id: "qual_020", data: { qualificationId: "qual_020", name: "MPT",               status: "active", createdAt: now } },
  { id: "qual_021", data: { qualificationId: "qual_021", name: "GNM",               status: "active", createdAt: now } },
  { id: "qual_022", data: { qualificationId: "qual_022", name: "B.Sc Nursing",      status: "active", createdAt: now } },
  { id: "qual_023", data: { qualificationId: "qual_023", name: "B.Pharm",           status: "active", createdAt: now } },
  { id: "qual_024", data: { qualificationId: "qual_024", name: "Pharm.D",           status: "active", createdAt: now } },
  { id: "qual_025", data: { qualificationId: "qual_025", name: "Fellowship",        status: "active", createdAt: now } },
  { id: "qual_026", data: { qualificationId: "qual_026", name: "Other",             status: "active", createdAt: now } },
];

// ============================================================
//  AUTH USERS
// ============================================================
const usersToCreate = [
  {
    email: "rahul.superadmin@dams.com", password: "Test@1234",
    firestoreData: {
      name: "Rahul Sharma", mobile: "9876543210",
      email: "rahul.superadmin@dams.com", role: "super_admin",
      status: "active", hospitalId: null, hospitalIds: null,
      doctorId: null, patientId: null, createdAt: now, updatedAt: now,
    },
  },
  {
    email: "priya.admin@cityhospital.com", password: "Test@1234",
    firestoreData: {
      name: "Priya Mehta", mobile: "9123456780",
      email: "priya.admin@cityhospital.com", role: "hospital_admin",
      status: "active", hospitalId: "hospital_001", hospitalIds: null,
      doctorId: null, patientId: null, createdAt: now, updatedAt: now,
    },
    isHospitalAdmin: true, linkedHospitalId: "hospital_001",
  },
  {
    email: "amit.verma@cityhospital.com", password: "Test@1234",
    firestoreData: {
      name: "Dr. Amit Verma", mobile: "9988776655",
      email: "amit.verma@cityhospital.com", role: "doctor",
      status: "active", hospitalId: null,
      hospitalIds: ["hospital_001","hospital_002"],
      doctorId: "doctor_001", patientId: null, createdAt: now, updatedAt: now,
    },
    isDoctorProfile: true, linkedDoctorId: "doctor_001",
  },
  {
    email: "neha.singh@cityhospital.com", password: "Test@1234",
    firestoreData: {
      name: "Dr. Neha Singh", mobile: "9977665544",
      email: "neha.singh@cityhospital.com", role: "doctor",
      status: "active", hospitalId: null,
      hospitalIds: ["hospital_001"],
      doctorId: "doctor_002", patientId: null, createdAt: now, updatedAt: now,
    },
    isDoctorProfile: true, linkedDoctorId: "doctor_002",
  },
  {
    email: "sunita.gupta@gmail.com", password: "Test@1234",
    firestoreData: {
      name: "Sunita Gupta", mobile: "9812345678",
      email: "sunita.gupta@gmail.com", role: "patient",
      status: "active", hospitalId: null, hospitalIds: null,
      doctorId: null, patientId: "patient_001", createdAt: now, updatedAt: now,
    },
    isPatientProfile: true, linkedPatientId: "patient_001",
  },
  {
    email: "rohit.agarwal@gmail.com", password: "Test@1234",
    firestoreData: {
      name: "Rohit Agarwal", mobile: "9834567890",
      email: "rohit.agarwal@gmail.com", role: "patient",
      status: "active", hospitalId: null, hospitalIds: null,
      doctorId: null, patientId: "patient_002", createdAt: now, updatedAt: now,
    },
    isPatientProfile: true, linkedPatientId: "patient_002",
  },
  // ✅ Receptionist
  {
    email: "kavita.receptionist@cityhospital.com", password: "Test@1234",
    firestoreData: {
      name: "Kavita Deshmukh", mobile: "9898989898",
      email: "kavita.receptionist@cityhospital.com", role: "receptionist",
      status: "active", hospitalId: "hospital_001", hospitalIds: null,
      doctorId: null, patientId: null, createdAt: now, updatedAt: now,
    },
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
  console.log(`   ✅ ${name} → ${docs.length} docs`);
}

async function purgeCollection(name) {
  const snap = await db.collection(name).get();
  if (snap.empty) return;
  const batch = db.batch();
  snap.docs.forEach((d) => batch.delete(d.ref));
  await batch.commit();
  console.log(`   🗑️  ${name} → ${snap.size} deleted`);
}

// ============================================================
//  MAIN
// ============================================================
async function main() {
  console.log("🚀 Doctor App — FIXED Seed Script (firebase-admin v14)");
  console.log("=".repeat(55));

  console.log("\n🗑️  Step 1: Purging old data...");
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
  await purgeCollection(SPECIALIZATION_MASTER);
  await purgeCollection(QUALIFICATION_MASTER);

  console.log("\n📦 Step 2: Seeding collections...");
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
  await seedCollection(SPECIALIZATION_MASTER,    specializationMaster);
  await seedCollection(QUALIFICATION_MASTER,     qualificationMaster);

  console.log("\n👤 Step 3: Auth + users...\n");
  for (const user of usersToCreate) {
    console.log(`📧 ${user.email} [${user.firestoreData.role}]`);
    let uid;
    try {
      const u = await auth.createUser({
        email: user.email, password: user.password,
        displayName: user.firestoreData.name, emailVerified: true,
      });
      uid = u.uid;
      console.log(`   ✅ Auth created → ${uid}`);
    } catch (e) {
      if (e.code === "auth/email-already-exists") {
        uid = (await auth.getUserByEmail(user.email)).uid;
        console.log(`   ℹ️  Auth exists  → ${uid}`);
      } else { console.log(`   ❌ ${e.message}`); continue; }
    }

    await db.collection(USERS).doc(uid).set({ ...user.firestoreData, userId: uid });
    console.log(`   ✅ users/${uid} saved`);

    if (user.isDoctorProfile) {
      await db.collection(DOCTORS).doc(user.linkedDoctorId).update({ userId: uid, updatedAt: now });
      console.log(`   🩺 doctors/${user.linkedDoctorId} updated`);
    }
    if (user.isPatientProfile) {
      await db.collection(PATIENTS).doc(user.linkedPatientId).update({ userId: uid, updatedAt: now });
      console.log(`   🙍 patients/${user.linkedPatientId} updated`);
    }
    if (user.isHospitalAdmin) {
      await db.collection(HOSPITALS).doc(user.linkedHospitalId).update({ adminUserId: uid, updatedAt: now });
      console.log(`   🏨 hospitals/${user.linkedHospitalId} updated`);
    }
    console.log();
  }

  console.log("=".repeat(55));
  console.log("\n📋 LOGIN CREDENTIALS (Password: Test@1234):\n");
  console.log("Super Admin    → rahul.superadmin@dams.com");
  console.log("Hospital Admin → priya.admin@cityhospital.com");
  console.log("Doctor 1       → amit.verma@cityhospital.com");
  console.log("Doctor 2       → neha.singh@cityhospital.com");
  console.log("Patient 1      → sunita.gupta@gmail.com");
  console.log("Patient 2      → rohit.agarwal@gmail.com");
  console.log("Receptionist   → kavita.receptionist@cityhospital.com");
  console.log("\n🎉 Setup complete!\n");
  process.exit(0);
}

main().catch((e) => { console.error("❌", e.message); process.exit(1); });