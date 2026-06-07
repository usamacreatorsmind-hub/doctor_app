import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                child: Form(
                  key: controller.formKey,
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStepRow(),
                      const SizedBox(height: 22),

                      // Method Toggle
                      _buildMethodToggle(),
                      const SizedBox(height: 22),

                      if (controller.linkSent.value)
                        _buildSuccessState()
                      else ...[
                        controller.selectedMethod.value == ResetMethod.email
                            ? _buildEmailForm()
                            : _buildOtpForm(),
                        const SizedBox(height: 16),
                        _buildInfoBox(),
                        const SizedBox(height: 22),
                        _buildSendButton(),
                        const SizedBox(height: 12),
                        _buildBackButton(),
                      ],
                    ],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)),
            child: const Icon(Icons.lock_open_rounded, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text('Forgot Password?', style: AppTextStyles.heading2),
          const SizedBox(height: 5),
          const Text('Reset your account password', style: AppTextStyles.body),
        ],
      ),
    );
  }

  Widget _buildStepRow() {
    return Row(children: [_dot(true), _line(false), _dot(false), _line(false), _dot(false)]);
  }

  Widget _dot(bool filled) => Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: filled ? AppColors.primary : AppColors.primaryBorder));
  Widget _line(bool filled) => Expanded(child: Container(height: 2, color: filled ? AppColors.primary : AppColors.primaryBorder));

  Widget _buildMethodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.primaryBorder)),
      child: Row(
        children: [
          _methodPill(ResetMethod.email, Icons.mail_outline_rounded, 'Via Email'),
          _methodPill(ResetMethod.otp, Icons.phone_android_rounded, 'Via OTP'),
        ],
      ),
    );
  }

  Widget _methodPill(ResetMethod method, IconData icon, String label) {
    final bool active = controller.selectedMethod.value == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectMethod(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: active ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(18)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registered Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.emailCtrl,
          keyboardType: TextInputType.emailAddress,
          validator: controller.validateEmail,
          decoration: _inputDecoration('Enter registered email', Icons.mail_outline_rounded),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Registered Mobile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.mobileCtrl,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          validator: controller.validateMobile,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _inputDecoration('Enter 10-digit number', Icons.phone_android_rounded).copyWith(prefixText: '+91 ', counterText: ''),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    final isEmail = controller.selectedMethod.value == ResetMethod.email;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryBorder)),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(isEmail ? 'A reset link will be sent to your email.' : 'An OTP will be sent to your mobile.', style: const TextStyle(fontSize: 12, color: AppColors.primary))),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.onSendPressed,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: controller.isLoading.value ? const CircularProgressIndicator(color: Colors.white) : const Text('Send'),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 40),
          const SizedBox(height: 10),
          const Text('Success!', style: TextStyle(fontWeight: FontWeight.bold)),
          const Text('Please check your email/phone for instructions.'),
          const SizedBox(height: 20),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton(onPressed: controller.goBack, child: const Text('Back to Login'));
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true, fillColor: AppColors.bgWhite,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
    );
  }
}
