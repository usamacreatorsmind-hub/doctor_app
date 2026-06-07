class AppRoutes {
  // Auth
  static const String splash           = '/splash';
  static const String onboarding       = '/onboarding';
  static const String roleSelection    = '/role-selection';
  static const String login            = '/login';
  static const String otpVerification  = '/otp-verification';
  static const String register         = '/register';
  static const String forgotPassword   = '/forgot-password';
  static const String resetPassword    = '/reset-password';

  // Patient
  static const String profileSetup       = '/profile-setup';
  static const String patientDashboard    = '/patient-dashboard';
  static const String patientAppointments = '/patient-appointments';
  static const String patientProfile      = '/patient-profile';
  static const String patientRecords      = '/patient-records';
  static const String notifications       = '/notifications';

  // Doctor Search & Booking
  static const String doctorSearch  = '/doctor-search';
  static const String doctorProfile = '/doctor-profile';
  static const String slotSelection = '/slot-selection';
  static const String bookingConfirm = '/booking-confirm';
  static const String payment        = '/payment';
  static const String bookingSuccess = '/booking-success';

  // Doctor
  static const String doctorDashboard = '/doctor-dashboard';
  static const String doctorSchedule  = '/doctor-schedule';
  static const String addPrescription = '/add-prescription';
  static const String doctorReports    = '/doctor-reports';

  // Hospital Admin
  static const String hospitalDashboard = '/hospital-dashboard';
  static const String addDoctor         = '/add-doctor';
  static const String hospitalAppointments = '/hospital-appointments';
  static const String hospitalProfile      = '/hospital-profile';
  static const String hospitalReports      = '/hospital-reports';
}
