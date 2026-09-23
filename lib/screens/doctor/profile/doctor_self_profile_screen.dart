// File: lib/screens/doctor/profile/doctor_self_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/helper.dart';
import 'doctor_self_profile_controller.dart';
import '../../../services/pdf_service.dart';

class DoctorSelfProfileScreen extends GetView<DoctorSelfProfileController> {
  const DoctorSelfProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.bgPage,
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.primary,
          elevation: 0,
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: const Icon(Icons.notifications_none_rounded), onPressed: () => Get.toNamed(AppRoutes.notifications)),
            Obx(
              () => IconButton(
                icon: Icon(controller.isEditing.value ? Icons.close : Icons.edit_rounded, color: Colors.white),
                onPressed: controller.toggleEdit,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.doctorProfile.value == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                      child: controller.isEditing.value ? _buildEditForm() : _buildProfileDetails(),
                    ),
                  ],
                ),
              ),
              if (controller.isEditing.value) Positioned(bottom: 20, left: 20, right: 20, child: _buildSaveButton()),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final profile = controller.doctorProfile.value;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Obx(
            () => GestureDetector(
              onTap: controller.isEditing.value ? () => controller.showImagePickerBottomSheet(context) : null,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage: controller.pickedImage.value != null
                          ? FileImage(controller.pickedImage.value!) as ImageProvider
                          : (profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty)
                          ? NetworkImage(profile.photoUrl!)
                          : null,
                      child: (controller.pickedImage.value == null && (profile?.photoUrl == null || profile!.photoUrl!.isEmpty))
                          ? const Icon(Icons.person, color: Colors.grey, size: 55)
                          : null,
                    ),
                  ),
                  if (controller.isEditing.value)
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile?.doctorName ?? 'Doctor Name',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(
                profile?.specialization.join(', ') ?? 'Specialization',
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBorder.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    final profile = controller.doctorProfile.value;
    if (profile == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (profile.doctorId.isEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your professional profile is incomplete. Please edit to add qualifications and specializations.',
                    style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

        _buildQrCodeSection(profile.uid, profile.doctorName),

        _buildSectionCard(
          title: 'Professional Overview',
          child: Column(
            children: [
              _infoTile(Icons.school_rounded, 'Qualification', profile.qualification.join(', ')),
              _infoTile(Icons.work_history_rounded, 'Experience', '${profile.experience} Years'),
              _infoTile(Icons.currency_rupee_rounded, 'Consultation Fee', '₹${profile.consultationFee.toInt()}'),
            ],
          ),
        ),

        _buildSectionCard(
          title: 'Contact Details',
          child: Column(
            children: [
              _infoTile(Icons.phone_android_rounded, 'Mobile', profile.mobileNumber),
              _infoTile(Icons.email_rounded, 'Email', profile.email),
              if (profile.practiceType == 'clinic')
                _infoTile(Icons.home_work_rounded, 'My Clinic', profile.clinicName ?? 'N/A')
              else
                _buildHospitalViewChips('Associated Hospitals', profile.hospitalIds),
            ],
          ),
        ),

        _buildSectionCard(
          title: 'Practice Location & Address',
          child: Obx(() {
            final addr = controller.fetchedAddress.value;
            final lat = controller.latitude.value;
            final lng = controller.longitude.value;

            final displayAddr = addr.isNotEmpty
                ? addr
                : (lat != null && lng != null
                    ? 'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'
                    : 'Location not captured yet');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile(
                  Icons.location_on_rounded,
                  'Address Details',
                  displayAddr,
                ),
              ],
            );
          }),
        ),

        _buildSectionCard(
          title: 'Expertise & Skills',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildViewChips('Specializations', profile.specialization, AppColors.primary),
              const SizedBox(height: 16),
              _buildViewChips('Symptoms Covered', profile.symptomsCovered, Colors.orange),
              const SizedBox(height: 16),
              _buildViewChips('Diseases Covered', profile.diseasesCovered, Colors.redAccent),
              const SizedBox(height: 16),
              _buildViewChips('Languages Known', profile.languagesKnown, Colors.teal),
            ],
          ),
        ),

        _buildSectionCard(
          title: 'Biography',
          child: Text(
            profile.biography ?? 'No biography added yet. Update your profile to tell patients about your background.',
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 13),
          ),
        ),



        _buildSectionCard(
          title: 'Legal & Support',
          child: Column(
            children: [
              _clickableInfoTile(Icons.privacy_tip_rounded, 'Privacy Policy', 'Our data practices', LauncherHelper.launchPrivacyPolicy),
              _clickableInfoTile(Icons.description_rounded, 'Terms & Conditions', 'App usage terms', LauncherHelper.launchTermsConditions),
            ],
          ),
        ),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.signOut,
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Logout Account', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalViewChips(String title, List<String> hIds) {
    if (hIds.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: hIds.map((id) {
            final hName = controller.hospitals.firstWhereOrNull((h) => h.hospitalId == id)?.hospitalName ?? id;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_hospital_rounded, color: Colors.blueGrey, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    hName,
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildViewChips(String title, List<String> items, Color color) {
    final filteredItems = items.where((i) => i.isNotEmpty).toList();
    if (filteredItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredItems
              .map(
                (i) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Text(
                    i,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Personal Info',
          child: Column(
            children: [
              _buildTextField('Full Name', controller.nameController, Icons.person_outline_rounded),
              _buildTextField('Mobile Number', controller.mobileController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),
            ],
          ),
        ),

        _buildSectionCard(
          title: 'Professional Details',
          child: Column(
            children: [
              _buildChipSection(
                'Qualifications (Multiple)',
                controller.availableQualifications,
                controller.selectedQualifications,
                Colors.blueGrey,
                Icons.school_outlined,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Experience (Years)',
                      controller.experienceController,
                      Icons.work_history_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      'Fee (₹)',
                      controller.feeController,
                      Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        _buildSectionCard(
          title: 'Practice Location',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isEditing.value)
                ElevatedButton.icon(
                  onPressed: controller.getCurrentLocation,
                  icon: const Icon(Icons.my_location_rounded, size: 18),
                  label: const Text('Capture Current Location 📍', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hospitalIcon,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              Obx(() {
                final lat = controller.latitude.value;
                final lng = controller.longitude.value;
                final addr = controller.fetchedAddress.value;

                if (lat == null || lng == null) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10, bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Captured Location Details:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      if (addr.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          addr,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Coordinates: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              if (controller.doctorProfile.value?.practiceType == 'clinic')
                _buildTextField('Clinic Name', controller.clinicNameController, Icons.local_pharmacy_outlined)
              else
                _buildHospitalSelection(),
            ],
          ),
        ),

        _buildSectionCard(
          title: 'Specializations & Skills',
          child: Column(
            children: [
              _buildChipSection(
                'Specializations (Multiple)',
                controller.availableSpecializations,
                controller.selectedSpecializations,
                AppColors.primary,
                Icons.verified_user_outlined,
              ),
              const SizedBox(height: 20),
              _buildChipSection(
                'Symptoms Covered',
                controller.availableSymptoms,
                controller.selectedSymptoms,
                Colors.orange,
                Icons.sick_outlined,
              ),
              const SizedBox(height: 20),
              _buildChipSection(
                'Diseases Covered',
                controller.availableDiseases,
                controller.selectedDiseases,
                Colors.redAccent,
                Icons.bug_report_outlined,
              ),
              const SizedBox(height: 20),
              _buildChipSection(
                'Languages Known',
                controller.availableLanguages,
                controller.selectedLanguages,
                Colors.teal,
                Icons.translate_rounded,
              ),
            ],
          ),
        ),

        _buildSectionCard(
          title: 'Biography',
          child: _buildTextField('Bio', controller.bioController, Icons.description_outlined, maxLines: 4),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _clickableInfoTile(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _inputDecoration(label, icon),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
      filled: true,
      fillColor: AppColors.bgPage.withOpacity(0.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildHospitalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Hospitals (Multiple)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.hospitals.isEmpty) {
            return const Text('No hospitals found', style: TextStyle(fontSize: 12, color: AppColors.textSecondary));
          }

          final unselected = controller.hospitals.where((h) => !controller.selectedHospitalIds.contains(h.hospitalId)).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDecorator(
                decoration: _inputDecoration('Select Hospital', Icons.local_hospital_rounded),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: null,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                    hint: const Text('Choose Hospital', style: TextStyle(fontSize: 14, color: AppColors.textHint)),
                    items: unselected.map((h) {
                      return DropdownMenuItem(
                        value: h.hospitalId,
                        child: Text(h.hospitalName, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.toggleSelection(controller.selectedHospitalIds, val);
                    },
                  ),
                ),
              ),
              if (controller.selectedHospitalIds.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.selectedHospitalIds.map((id) {
                    final h = controller.hospitals.firstWhereOrNull((h) => h.hospitalId == id);
                    return Chip(
                      label: Text(h?.hospitalName ?? id, style: const TextStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: AppColors.primary,
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onDeleted: () => controller.toggleSelection(controller.selectedHospitalIds, id),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildChipSection(String title, RxList<String> availableList, RxList<String> selectedList, Color activeColor, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (availableList.isEmpty) {
            return const Text('Fetching...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary));
          }

          final unselected = availableList.where((item) => !selectedList.contains(item)).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDecorator(
                decoration: _inputDecoration('Select ${title.split(' ').first}', icon),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: null,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: activeColor),
                    hint: Text('Choose ${title.split(' ').first}', style: const TextStyle(fontSize: 14, color: AppColors.textHint)),
                    items: unselected.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.toggleSelection(selectedList, val);
                    },
                  ),
                ),
              ),
              if (selectedList.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedList.map((item) {
                    return Chip(
                      label: Text(item, style: const TextStyle(fontSize: 12, color: Colors.white)),
                      backgroundColor: activeColor,
                      deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onDeleted: () => controller.toggleSelection(selectedList, item),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildQrCodeSection(String uid, String doctorName) {
    final profile = controller.doctorProfile.value;
    final String specText = profile?.specialization.join(', ') ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, Colors.blue.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Digital Clinic Pass',
                    style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    doctorName,
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.print_rounded, color: Colors.white),
                onPressed: () => PdfService.printDoctorQrPoster(doctorName: doctorName, specialization: specText, uid: uid),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: QrImageView(
              data: uid,
              version: QrVersions.auto,
              size: 140.0,
              gapless: false,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primary),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'SCAN TO BOOK APPOINTMENT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5)),
      ),
    );
  }
}
