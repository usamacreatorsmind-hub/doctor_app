class PatientProfileModel {
  // ── Step 1 — Personal ──
  final String? profilePhoto;
  final String? dob;
  final String? gender;
  final String? bloodGroup;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;

  // ── Step 2 — Medical ──
  final List<String> medicalHistory;
  final List<String> currentMedications;
  final List<String> allergies;

  // ── Step 3 — Emergency ──
  final String? emergencyContactName;
  final String? emergencyContactNumber;
  final String? emergencyContactRelation;
  final String? insuranceProvider;
  final String? insurancePolicyNumber;

  // ── Meta ──
  final bool isProfileComplete;

  const PatientProfileModel({
    this.profilePhoto,
    this.dob,
    this.gender,
    this.bloodGroup,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.medicalHistory = const [],
    this.currentMedications = const [],
    this.allergies = const [],
    this.emergencyContactName,
    this.emergencyContactNumber,
    this.emergencyContactRelation,
    this.insuranceProvider,
    this.insurancePolicyNumber,
    this.isProfileComplete = false,
  });

  // ── Convert to Map (Firebase ready) ──
  Map<String, dynamic> toMap() {
    return {
      'profilePhoto': profilePhoto,
      'dob': dob,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'medicalHistory': medicalHistory,
      'currentMedications': currentMedications,
      'allergies': allergies,
      'emergencyContactName': emergencyContactName,
      'emergencyContactNumber': emergencyContactNumber,
      'emergencyContactRelation': emergencyContactRelation,
      'insuranceProvider': insuranceProvider,
      'insurancePolicyNumber': insurancePolicyNumber,
      'isProfileComplete': isProfileComplete,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  // ── Copy with ──
  PatientProfileModel copyWith({
    String? profilePhoto,
    String? dob,
    String? gender,
    String? bloodGroup,
    String? address,
    String? city,
    String? state,
    String? pincode,
    List<String>? medicalHistory,
    List<String>? currentMedications,
    List<String>? allergies,
    String? emergencyContactName,
    String? emergencyContactNumber,
    String? emergencyContactRelation,
    String? insuranceProvider,
    String? insurancePolicyNumber,
    bool? isProfileComplete,
  }) {
    return PatientProfileModel(
      profilePhoto: profilePhoto ?? this.profilePhoto,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      currentMedications: currentMedications ?? this.currentMedications,
      allergies: allergies ?? this.allergies,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactNumber: emergencyContactNumber ?? this.emergencyContactNumber,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insurancePolicyNumber: insurancePolicyNumber ?? this.insurancePolicyNumber,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }
}
