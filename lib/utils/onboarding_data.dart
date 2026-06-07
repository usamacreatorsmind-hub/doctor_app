class OnboardingModel {
  final String title;
  final String subtitle;
  final List<OnboardingFeature> features;

  const OnboardingModel({
    required this.title,
    required this.subtitle,
    required this.features,
  });
}

class OnboardingFeature {
  final String icon;
  final String title;
  final String subtitle;

  const OnboardingFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

final List<OnboardingModel> onboardingData = [
  OnboardingModel(
    title: 'Find the Right Doctor',
    subtitle: 'Search doctors by name, symptom,\ndisease or specialization',
    features: [
      OnboardingFeature(icon: 'search',   title: 'Smart Search',       subtitle: 'Find doctors by symptom or disease'),
      OnboardingFeature(icon: 'hospital', title: 'Multiple Hospitals',  subtitle: 'Explore doctors across hospitals'),
      OnboardingFeature(icon: 'star',     title: 'Ratings & Reviews',   subtitle: 'Choose trusted, top-rated doctors'),
    ],
  ),
  OnboardingModel(
    title: 'Book Appointments Easily',
    subtitle: 'Pick a date, choose a time slot,\nand confirm in seconds',
    features: [
      OnboardingFeature(icon: 'clock',   title: 'Live Slot Availability', subtitle: 'See real-time open slots'),
      OnboardingFeature(icon: 'phone',   title: 'Online & Offline Mode',  subtitle: 'Consult from home or visit clinic'),
      OnboardingFeature(icon: 'bell',    title: 'Reminders & Alerts',     subtitle: 'Never miss your appointment'),
    ],
  ),
  OnboardingModel(
    title: 'Your Health Records',
    subtitle: 'Prescriptions, history & reports —\nall in one place',
    features: [
      OnboardingFeature(icon: 'file',   title: 'Digital Prescriptions', subtitle: 'Get prescriptions instantly after visit'),
      OnboardingFeature(icon: 'card',   title: 'Secure Payments',       subtitle: 'UPI, Card & Net Banking supported'),
      OnboardingFeature(icon: 'shield', title: 'Safe & Private',        subtitle: 'Your data is fully encrypted & secure'),
    ],
  ),
];
