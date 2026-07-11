import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'add_receptionist_controller.dart';

class AddReceptionistScreen extends GetView<AddReceptionistController> {
  const AddReceptionistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Add Receptionist'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Staff Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                controller.doctorId != null 
                    ? 'Create a new receptionist account for your clinic.'
                    : 'Create a new receptionist account for your hospital.',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                controller: controller.nameController,
                label: 'Full Name',
                icon: Icons.person_outline_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: controller.emailController,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: controller.mobileController,
                label: 'Mobile Number',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: controller.validateMobile,
              ),
              const SizedBox(height: 16),

              Obx(() => _buildTextField(
                controller: controller.passwordController,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: controller.isPasswordHidden.value,
                validator: controller.validatePassword,
                suffixIcon: IconButton(
                  onPressed: controller.togglePasswordVisibility,
                  icon: Icon(
                    controller.isPasswordHidden.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                  ),
                ),
              )),
              
              const SizedBox(height: 40),
              
              Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.addReceptionist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 22),
        suffixIcon: suffixIcon,
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryBorder.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryBorder.withOpacity(0.5)),
        ),
      ),
    );
  }
}
