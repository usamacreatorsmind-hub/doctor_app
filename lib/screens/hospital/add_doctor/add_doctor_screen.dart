// File: lib/screens/hospital/add_doctor/add_doctor_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'add_doctor_controller.dart';

class AddDoctorScreen extends GetView<AddDoctorController> {
  const AddDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Register New Doctor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
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
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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

                      _buildChipSection(
                        'Qualifications (Multiple)',
                        controller.availableQualifications,
                        controller.selectedQualifications,
                        Colors.blueGrey,
                        Icons.school_outlined,
                      ),
                      const SizedBox(height: 20),

                      _buildChipSection(
                        'Specializations (Multiple)',
                        controller.availableSpecializations,
                        controller.selectedSpecializations,
                        AppColors.primary,
                        Icons.verified_user_outlined,
                      ),
                      const SizedBox(height: 20),

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
                      _buildInputField(
                        label: 'Slot Booking Charge (Online Payment)',
                        hint: 'e.g. 50',
                        icon: Icons.payments_outlined,
                        controller: controller.bookingFeeController,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Note: This is the only part patients pay online to book a slot.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
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

                      _buildInputField(
                        label: 'Biography',
                        hint: 'Tell patients about background...',
                        icon: Icons.description_outlined,
                        controller: controller.bioController,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                      _sectionTitle('Security (For Doctor Login)'),
                      const SizedBox(height: 12),
                      _buildPasswordField(),

                      const SizedBox(height: 30),
                      _buildRegisterButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)),
            child: const Icon(Icons.person_add_alt_1_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text(
            'Staff Registration',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text('Add a new doctor to your hospital', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
    Widget? suffix,
    bool obscureText = false,
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
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: _inputDecoration(hint, icon).copyWith(prefixText: prefix, suffixIcon: suffix),
        ),
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
          if (availableList.isEmpty) return const Text('Fetching...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary));
          final unselected = availableList.where((item) => !selectedList.contains(item)).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: InputDecorator(
                  decoration: _inputDecoration('Select ${title.split(' ').first}', icon),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: null,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: activeColor),
                      hint: Text('Choose ${title.split(' ').first}', style: const TextStyle(fontSize: 14, color: AppColors.textHint)),
                      items: unselected
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item, style: const TextStyle(fontSize: 14)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) controller.toggleSelection(selectedList, val);
                      },
                    ),
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

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              _selectionOption('male', Icons.male, controller.selectedGender.value == 'male', (val) => controller.selectGender(val)),
              const SizedBox(width: 12),
              _selectionOption('female', Icons.female, controller.selectedGender.value == 'female', (val) => controller.selectGender(val)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _selectionOption(String val, IconData icon, bool isSelected, Function(String) onTap, {String? label}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(val),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label ?? val.capitalizeFirst!,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => _buildInputField(
        label: 'Create Initial Password',
        hint: 'Min 6 characters',
        icon: controller.isPasswordHidden.value ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
        controller: controller.passwordController,
        validator: controller.validatePassword,
        obscureText: controller.isPasswordHidden.value,
        suffix: IconButton(
          icon: Icon(
            controller.isPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveDoctor,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('Add Doctor to Hospital', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.7)),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
