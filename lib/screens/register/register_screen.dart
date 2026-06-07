import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          body: SafeArea(
            child: SingleChildScrollView(
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
                          _sectionTitle('Personal Info'),
                          const SizedBox(height: 12),

                          _buildInputField(
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outline_rounded,
                            controller: controller.nameController,
                            validator: controller.validateName,
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(child: _buildDobField(context, controller)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildBloodGroupDropdown(controller)),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _buildGenderSelector(controller),
                          const SizedBox(height: 20),

                          _sectionTitle('Contact Info'),
                          const SizedBox(height: 12),

                          _buildMobileField(controller),
                          const SizedBox(height: 14),

                          _buildInputField(
                            label: 'Email Address',
                            hint: 'Enter email address',
                            icon: Icons.mail_outline_rounded,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: controller.validateEmail,
                          ),
                          const SizedBox(height: 20),

                          _sectionTitle('Security'),
                          const SizedBox(height: 12),

                          _buildPasswordField(controller),
                          const SizedBox(height: 24),

                          _buildRegisterButton(controller),
                          const SizedBox(height: 14),

                          Center(
                            child: GestureDetector(
                              onTap: controller.goToLogin,
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                  children: [
                                    TextSpan(
                                      text: 'Login',
                                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            width: 66, height: 66,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.18)),
            child: const Icon(Icons.person_add_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text('Create Account', style: AppTextStyles.heading2),
          const SizedBox(height: 5),
          const Text('Register as a new patient', style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  Widget _buildInputField({
    required String label, required String hint, required IconData icon,
    required TextEditingController controller, TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: _inputTextStyle,
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  Widget _buildDobField(BuildContext context, RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date of Birth', style: _labelStyle),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => controller.pickDob(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller.dobController,
              style: _inputTextStyle,
              readOnly: true,
              decoration: _inputDecoration('DD/MM/YYYY', Icons.calendar_today_rounded),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodGroupDropdown(RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Blood Group', style: _labelStyle),
        const SizedBox(height: 6),
        Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedBloodGroup.value,
          style: _inputTextStyle,
          decoration: _inputDecoration('Select', Icons.water_drop_outlined),
          items: controller.bloodGroups.map((bg) => DropdownMenuItem<String>(value: bg, child: Text(bg))).toList(),
          onChanged: (val) { if (val != null) controller.selectBloodGroup(val); },
        )),
      ],
    );
  }

  Widget _buildGenderSelector(RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: _labelStyle),
        const SizedBox(height: 8),
        Obx(() => Row(
          children: [
            _genderCard(controller, Gender.male, Icons.male_rounded, 'Male'),
            const SizedBox(width: 10),
            _genderCard(controller, Gender.female, Icons.female_rounded, 'Female'),
            const SizedBox(width: 10),
            _genderCard(controller, Gender.other, Icons.person_outline_rounded, 'Other'),
          ],
        )),
      ],
    );
  }

  Widget _genderCard(RegisterController c, Gender gender, IconData icon, String label) {
    final bool isSelected = c.selectedGender.value == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => c.selectGender(gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.bgWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder, width: isSelected ? 1.8 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, size: 22, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField(RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mobile Number', style: _labelStyle),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          validator: controller.validateMobile,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _inputTextStyle,
          decoration: _inputDecoration('Enter 10-digit number', Icons.phone_android_rounded).copyWith(
            counterText: '',
            prefixText: '+91 ',
            prefixStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(RegisterController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: _labelStyle),
        const SizedBox(height: 6),
        Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: controller.isPasswordHidden.value,
          validator: controller.validatePassword,
          style: _inputTextStyle,
          decoration: _inputDecoration('Create a strong password', Icons.lock_outline_rounded).copyWith(
            suffixIcon: GestureDetector(
              onTap: controller.togglePasswordVisibility,
              child: Icon(controller.isPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildRegisterButton(RegisterController controller) {
    return Obx(() => SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.onRegisterPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor: AppColors.primaryBorder,
        ),
        child: controller.isLoading.value
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_reg_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Register & Send OTP', style: AppTextStyles.btnPrimary),
                ],
              ),
      ),
    ));
  }

  TextStyle get _labelStyle => const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  TextStyle get _inputTextStyle => const TextStyle(fontSize: 14, color: AppColors.textPrimary);

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textHint),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true, fillColor: AppColors.bgWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder, width: 1.5)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder, width: 1.5)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }
}
