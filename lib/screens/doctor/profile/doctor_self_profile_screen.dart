// File: lib/screens/doctor/profile/doctor_self_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_routes.dart';
import '../../../utils/helper.dart';
import 'doctor_self_profile_controller.dart';

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
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    if (controller.doctorProfile.value?.doctorId.isEmpty ?? false)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.orange),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Your professional profile is incomplete. Please edit to add qualifications and specializations.',
                                style: TextStyle(fontSize: 12, color: Colors.orange),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: controller.isEditing.value ? _buildEditForm() : _buildProfileDetails(),
                    ),
                    const SizedBox(height: 100),
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

  Widget _buildProfileHeader() {
    final profile = controller.doctorProfile.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Obx(
            () => Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white24,
                  backgroundImage: controller.pickedImage.value != null
                      ? FileImage(controller.pickedImage.value!) as ImageProvider
                      : (profile?.photoUrl != null && profile!.photoUrl!.isNotEmpty)
                      ? NetworkImage(profile.photoUrl!)
                      : null,
                  child: (controller.pickedImage.value == null && (profile?.photoUrl == null || profile!.photoUrl!.isEmpty))
                      ? const Icon(Icons.person, color: Colors.white, size: 55)
                      : null,
                ),
                if (controller.isEditing.value)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile?.doctorName ?? 'Doctor Name',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(profile?.specialization.join(', ') ?? 'Specialization', style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
        _infoTile(Icons.school_outlined, 'Qualification', profile.qualification.join(', ')),
        _infoTile(Icons.work_history_outlined, 'Experience', '${profile.experience} Years'),
        _infoTile(Icons.currency_rupee_rounded, 'Consultation Fee', '₹${profile.consultationFee}'),
        _infoTile(Icons.phone_android_rounded, 'Mobile', profile.mobileNumber),
        _infoTile(Icons.email_outlined, 'Email', profile.email),
        if (profile.practiceType == 'clinic')
          _infoTile(Icons.home_work_outlined, 'My Clinic', profile.clinicName ?? 'N/A')
        else
          _buildHospitalViewChips('Associated Hospitals', profile.hospitalIds),
        const SizedBox(height: 20),
        _buildViewChips('Specializations', profile.specialization, AppColors.primary),
        const SizedBox(height: 20),
        _buildViewChips('Languages Known', profile.languagesKnown, Colors.teal),

        const SizedBox(height: 20),
        _buildViewChips('Symptoms Covered', profile.symptomsCovered, Colors.orange),
        const SizedBox(height: 20),
        _buildViewChips('Diseases Covered', profile.diseasesCovered, Colors.redAccent),

        const SizedBox(height: 20),
        const Text('Biography', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Text(profile.biography ?? 'No biography added', style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
        ),

        const SizedBox(height: 24),
        const Text('Legal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _clickableInfoTile(Icons.privacy_tip_outlined, 'Privacy Policy', 'View privacy practices', LauncherHelper.launchPrivacyPolicy),
        _clickableInfoTile(Icons.description_outlined, 'Terms & Conditions', 'View terms of use', LauncherHelper.launchTermsConditions),

        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.signOut,
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            label: const Text('Logout', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalViewChips(String title, List<String> hIds) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: hIds.map((id) {
            final hName = controller.hospitals.firstWhereOrNull((h) => h.hospitalId == id)?.hospitalName ?? id;
            return Chip(
              label: Text(hName, style: const TextStyle(fontSize: 11, color: Colors.white)),
              backgroundColor: Colors.blueGrey,
              side: BorderSide.none,
              avatar: const Icon(Icons.local_hospital, color: Colors.white, size: 14),
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
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: filteredItems
              .map(
                (i) => Chip(
                  label: Text(i, style: const TextStyle(fontSize: 11, color: Colors.white)),
                  backgroundColor: color.withOpacity(0.8),
                  side: BorderSide.none,
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
        _buildTextField('Full Name', controller.nameController, Icons.person_outline),
        const SizedBox(height: 12),

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
              child: _buildTextField('Fee (₹)', controller.feeController, Icons.currency_rupee_rounded, keyboardType: TextInputType.number),
            ),
          ],
        ),
        _buildTextField('Mobile Number', controller.mobileController, Icons.phone_android_rounded, keyboardType: TextInputType.phone),

        const SizedBox(height: 12),
        if (controller.doctorProfile.value?.practiceType == 'clinic')
          _buildTextField('Clinic Name', controller.clinicNameController, Icons.local_pharmacy_outlined)
        else
          _buildHospitalSelection(),
        const SizedBox(height: 20),

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
        const SizedBox(height: 20),

        _buildTextField('Biography', controller.bioController, Icons.description_outlined, maxLines: 4),
      ],
    );
  }

  Widget _buildHospitalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Hospitals (Multiple)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _clickableInfoTile(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
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
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: _inputDecoration(label, icon),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        child: controller.isLoading.value
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
