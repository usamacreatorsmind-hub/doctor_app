import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import 'otp_controller.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtpController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Blue Header ──
                  _buildHeader(controller),

                  // ── Body ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step Indicator
                        _buildStepIndicator(),
                        const SizedBox(height: 24),

                        // Title
                        const Text('Enter Verification Code',
                            style: TextStyle( fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
                        const SizedBox(height: 6),
                        const Text(
                          'A 6-digit OTP has been sent to your\nregistered mobile number',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.6),
                        ),
                        const SizedBox(height: 28),

                        // OTP Boxes (Updated to 6)
                        _buildOtpBoxes(controller),
                        const SizedBox(height: 20),

                        // Timer / Resend
                        _buildResendSection(controller),
                        const SizedBox(height: 28),

                        // Verify Button
                        _buildVerifyButton(controller),
                        const SizedBox(height: 12),

                        // Change Number
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: (){
                              Get.back();
                            },
                            icon: const Icon(Icons.arrow_back_rounded, size: 18),
                            label: const Text('Change Mobile Number',
                                style: AppTextStyles.btnSecondary),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildHeader(OtpController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 28),
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
            child: const Icon(Icons.phone_android_rounded,
                size: 30, color: Colors.white),
          ),
          const SizedBox(height: 14),
          const Text('OTP Verification', style: AppTextStyles.heading2),
          const SizedBox(height: 5),
          Text(
            'Code sent to +91 ${controller.mobileNumber}',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepDot(filled: true),
        _stepLine(filled: true),
        _stepDot(filled: true),
        _stepLine(filled: false),
        _stepDot(filled: false),
      ],
    );
  }

  Widget _stepDot({required bool filled}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppColors.primary : AppColors.primaryBorder,
      ),
    );
  }

  Widget _stepLine({required bool filled}) {
    return Expanded(
      child: Container(
        height: 2,
        color: filled ? AppColors.primary : AppColors.primaryBorder,
      ),
    );
  }

  Widget _buildOtpBoxes(OtpController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) { // Changed 4 to 6
        return _OtpBox(
          controller: controller.otpControllers[index],
          focusNode: controller.focusNodes[index],
          onChanged: (val) => controller.onDigitEntered(index, val),
          onBackspace: () => controller.onBackspace(index),
        );
      }),
    );
  }

  Widget _buildResendSection(OtpController controller) {
    return Obx(() => Center(
          child: controller.canResend.value
              ? GestureDetector(
                  onTap: controller.resendOtp,
                  child: RichText(
                    text: const TextSpan(
                      text: "Didn't receive? ",
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'Resend OTP',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RichText(
                  text: TextSpan(
                    text: 'Resend OTP in ',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: controller.timerDisplay,
                        style: const TextStyle(
                          color: Color(0xFFE65100),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
        ));
  }

  Widget _buildVerifyButton(OtpController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
                controller.isOtpComplete && !controller.isLoading.value
                    ? controller.verifyOtp
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              disabledBackgroundColor: AppColors.primaryBorder,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 20),
                      SizedBox(width: 8),
                      const Text('Verify OTP', style: AppTextStyles.btnPrimary),
                    ],
                  ),
          ),
        ));
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48, // Reduced width slightly to fit 6 boxes
      height: 60,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: controller.text.isNotEmpty
              ? AppColors.primarySurface
              : AppColors.bgWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: controller.text.isNotEmpty
                  ? AppColors.primary
                  : AppColors.primaryBorder,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: controller.text.isNotEmpty
                  ? AppColors.primary
                  : AppColors.primaryBorder,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
