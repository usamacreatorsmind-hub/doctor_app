import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'doctor_register_controller.dart';

class DoctorRegisterScreen extends GetView<DoctorRegisterController> {
  const DoctorRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Obx(() {
          if (controller.isMasterLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Personal & Contact Info'),
                        const SizedBox(height: 12),
                        _buildInputField(
                          label: 'Full Name',
                          hint: 'Dr. John Doe',
                          icon: Icons.person_outline_rounded,
                          controller: controller.nameController,
                          validator: controller.validateName,
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          label: 'Email Address',
                          hint: 'doctor@example.com',
                          icon: Icons.mail_outline_rounded,
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.validateEmail,
                        ),
                        const SizedBox(height: 14),
                        _buildInputField(
                          label: 'Mobile Number',
                          hint: '10-digit number',
                          icon: Icons.phone_android_rounded,
                          controller: controller.mobileController,
                          keyboardType: TextInputType.phone,
                          prefix: '+91 ',
                          validator: controller.validateMobile,
                        ),
                        const SizedBox(height: 14),
                        _buildGenderSelector(),

                        const SizedBox(height: 24),
                        _sectionTitle('Professional Details'),
                        const SizedBox(height: 12),

                        _buildHospitalSelection(),
                        const SizedBox(height: 14),

                        _buildInputField(
                          label: 'Qualification',
                          hint: 'MBBS, MD (Cardiology)',
                          icon: Icons.school_outlined,
                          controller: controller.qualificationController,
                          validator: (v) => (v == null || v.isEmpty) ? 'Enter qualification' : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                label: 'Experience (Years)',
                                hint: 'e.g. 10',
                                icon: Icons.work_history_outlined,
                                controller: controller.experienceController,
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInputField(
                                label: 'Consultation Fee',
                                hint: 'e.g. 500',
                                icon: Icons.currency_rupee_rounded,
                                controller: controller.feeController,
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildModeSelector(),
                        const SizedBox(height: 20),

                        _buildChipSection(
                          'Specializations',
                          controller.availableSpecializations,
                          controller.selectedSpecializations,
                          AppColors.primary,
                        ),
                        const SizedBox(height: 20),

                        _buildChipSection(
                          'Symptoms Covered',
                          controller.availableSymptoms,
                          controller.selectedSymptoms,
                          Colors.orange,
                        ),
                        const SizedBox(height: 20),

                        _buildChipSection(
                          'Diseases Covered',
                          controller.availableDiseases,
                          controller.selectedDiseases,
                          Colors.redAccent,
                        ),
                        const SizedBox(height: 20),

                        _buildChipSection(
                          'Languages Known',
                          controller.availableLanguages,
                          controller.selectedLanguages,
                          Colors.teal,
                        ),
                        const SizedBox(height: 20),

                        _buildInputField(
                          label: 'Biography',
                          hint: 'Tell patients about your background...',
                          icon: Icons.description_outlined,
                          controller: controller.bioController,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),
                        _sectionTitle('Security'),
                        const SizedBox(height: 12),
                        _buildPasswordFieldFix(),

                        const SizedBox(height: 30),
                        _buildRegisterButton(),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: RichText(
                              text: const TextSpan(
                                text: 'Already registered? ',
                                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                children: [
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.18),
            ),
            child: const Icon(Icons.medical_services_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text('Doctor Registration', style: AppTextStyles.heading2),
          const SizedBox(height: 5),
          const Text('Create your professional profile', style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? prefix,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: _inputDecoration(hint, icon).copyWith(prefixText: prefix),
        ),
      ],
    );
  }

  Widget _buildHospitalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Hospitals (Multiple)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.hospitals.isEmpty) {
            return const Text(
              'No hospitals found',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            );
          }
          return Wrap(
            spacing: 8,
            runSpacing: 0,
            children: controller.hospitals.map((h) {
              final isSelected = controller.selectedHospitalIds.contains(h.hospitalId);
              return FilterChip(
                label: Text(
                  h.hospitalName,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => controller.toggleHospital(h.hospitalId),
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.primaryBorder),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildChipSection(
    String title,
    RxList<String> availableList,
    RxList<String> selectedList,
    Color activeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (availableList.isEmpty) {
            return const Text(
              'Loading data...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            );
          }
          return Wrap(
            spacing: 8,
            runSpacing: 0,
            children: availableList.map((item) {
              final isSelected = selectedList.contains(item);
              return FilterChip(
                label: Text(
                  item,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => controller.toggleSelection(selectedList, item),
                selectedColor: activeColor,
                checkmarkColor: Colors.white,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isSelected ? activeColor : AppColors.primaryBorder),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              _choiceCard(
                'Male',
                'male',
                Icons.male_rounded,
                controller.selectedGender.value == 'male',
                () => controller.selectGender('male'),
              ),
              const SizedBox(width: 10),
              _choiceCard(
                'Female',
                'female',
                Icons.female_rounded,
                controller.selectedGender.value == 'female',
                () => controller.selectGender('female'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation Mode',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              _choiceCard(
                'Online',
                'Online',
                Icons.videocam_outlined,
                controller.selectedConsultationMode.value == 'Online',
                () => controller.selectMode('Online'),
              ),
              const SizedBox(width: 8),
              _choiceCard(
                'Offline',
                'Offline',
                Icons.person_outline,
                controller.selectedConsultationMode.value == 'Offline',
                () => controller.selectMode('Offline'),
              ),
              const SizedBox(width: 8),
              _choiceCard(
                'Both',
                'Both',
                Icons.devices_other_outlined,
                controller.selectedConsultationMode.value == 'Both',
                () => controller.selectMode('Both'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _choiceCard(
    String label,
    String value,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.primaryBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordFieldFix() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            obscureText: controller.isPasswordHidden.value,
            validator: controller.validatePassword,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: _inputDecoration('Min 6 characters', Icons.lock_outline_rounded).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordHidden.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.onRegisterPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Complete Registration',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBorder),
      ),
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
}
