import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'hospital_profile_controller.dart';

class HospitalProfileScreen extends GetView<HospitalProfileController> {
  const HospitalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Hospital Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: controller.updateProfile,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('General Information'),
                const SizedBox(height: 16),
                _buildTextField(controller.nameController, 'Hospital Name', Icons.business_rounded),
                const SizedBox(height: 12),
                _buildTextField(controller.contactController, 'Contact Number', Icons.phone_rounded, keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                _buildTextField(controller.emailController, 'Official Email', Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _buildTextField(controller.websiteController, 'Website (Optional)', Icons.language_rounded),
                
                const SizedBox(height: 24),
                _buildSectionTitle('Location Details'),
                const SizedBox(height: 16),
                _buildTextField(controller.addressController, 'Full Address', Icons.location_on_rounded),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildTextField(controller.cityController, 'City', Icons.location_city_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(controller.pincodeController, 'Pincode', Icons.pin_drop_rounded, keyboardType: TextInputType.number)),
                  ],
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Services'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryBorder)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emergency Service', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('24/7 Availability', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      Obx(() => Switch(
                        value: controller.emergencyAvailable.value,
                        onChanged: (val) => controller.emergencyAvailable.value = val,
                        activeColor: AppColors.primary,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildLogoutButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary));
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (v) => v!.isEmpty ? 'Field required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Get.offAllNamed('/role-selection'),
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: const Text('Logout Account', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
