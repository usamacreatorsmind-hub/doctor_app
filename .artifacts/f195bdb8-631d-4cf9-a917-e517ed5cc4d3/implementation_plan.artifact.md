# Add Privacy Policy and Terms & Conditions to Profile Screens

Add links to Privacy Policy and Terms & Conditions in all user profile screens (Patient, Doctor, Hospital, and Receptionist).

## Proposed Changes

### [Component: Utils]

#### [MODIFY] [helper.dart](file:///Users/mohdusama/Desktop/Usama Flutter Projects/doctor_app/lib/utils/helper.dart)
Add a helper class `LauncherHelper` to handle URL launching using `url_launcher`.

### [Component: Patient]

#### [MODIFY] [patient_profile_screen.dart](file:///Users/mohdusama/Desktop/Usama Flutter Projects/doctor_app/lib/screens/patient/patient_profile/patient_profile_screen.dart)
Add a "Legal" section with "Privacy Policy" and "Terms & Conditions" before the logout button.

### [Component: Doctor]

#### [MODIFY] [doctor_self_profile_screen.dart](file:///Users/mohdusama/Desktop/Usama Flutter Projects/doctor_app/lib/screens/doctor/profile/doctor_self_profile_screen.dart)
Add "Privacy Policy" and "Terms & Conditions" tiles to the profile details.

### [Component: Hospital]

#### [MODIFY] [hospital_profile_screen.dart](file:///Users/mohdusama/Desktop/Usama Flutter Projects/doctor_app/lib/screens/hospital/profile/hospital_profile_screen.dart)
Add a "Legal & Policies" section with the links.

### [Component: Receptionist]

#### [MODIFY] [receptionist_dashboard_screen.dart](file:///Users/mohdusama/Desktop/Usama Flutter Projects/doctor_app/lib/screens/receptionist/dashboard/receptionist_dashboard_screen.dart)
Add a "Legal" section at the end of the scrollable area.

## URLs
- **Privacy Policy**: https://privacy.creatorsmind.co.in/ayuveda-care-app-privacy-policy/
- **Terms & Conditions**: https://privacy.creatorsmind.co.in/terms-conditions-for-ayuveda-care/

## Verification Plan

### Manual Verification
- Log in as each user type (Patient, Doctor, Hospital, Receptionist).
- Navigate to the profile screen (or dashboard for Receptionist).
- Tap on "Privacy Policy" and verify it opens the correct URL in the browser.
- Tap on "Terms & Conditions" and verify it opens the correct URL in the browser.
