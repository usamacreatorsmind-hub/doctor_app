import 'dart:io';
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
        title: const Text(
          'Hospital Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.hospital.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    _buildLogoPicker(),
                    const SizedBox(height: 32),
                    _buildSectionCard(
                      title: 'Basic Information',
                      children: [
                        _buildTextField(
                          controller.nameController,
                          'Hospital Name *',
                          Icons.business_rounded,
                          validator: (v) => v!.isEmpty ? 'Name required' : null,
                        ),
                        _buildTextField(
                          controller.regNoController,
                          'Registration Number *',
                          Icons.app_registration_rounded,
                          validator: (v) => v!.isEmpty ? 'Reg No required' : null,
                        ),
                      ],
                    ),
                    _buildSectionCard(
                      title: 'Contact Information',
                      children: [
                        _buildTextField(
                          controller.contactController,
                          'Contact Number *',
                          Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.isEmpty ? 'Phone required' : null,
                        ),
                        _buildTextField(
                          controller.emailController,
                          'Email *',
                          Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.isEmpty ? 'Email required' : null,
                        ),
                        _buildTextField(
                          controller.websiteController,
                          'Website',
                          Icons.language_rounded,
                          keyboardType: TextInputType.url,
                        ),
                      ],
                    ),
                    _buildSectionCard(
                      title: 'Address',
                      children: [
                        _buildTextField(
                          controller.addressController,
                          'Full Address *',
                          Icons.location_on_rounded,
                          validator: (v) => v!.isEmpty ? 'Address required' : null,
                        ),
                        _buildTextField(
                          controller.cityController,
                          'City *',
                          Icons.location_city_rounded,
                          validator: (v) => v!.isEmpty ? 'City required' : null,
                        ),
                        _buildTextField(
                          controller.stateController,
                          'State *',
                          Icons.map_rounded,
                          validator: (v) => v!.isEmpty ? 'State required' : null,
                        ),

                        _buildTextField(
                          controller.pincodeController,
                          'Pincode *',
                          Icons.pin_drop_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Pincode required' : null,
                        ),
                      ],
                    ),
                    _buildSectionCard(
                      title: 'Departments',
                      children: [
                        _buildDepartmentMultiSelect(),
                        const SizedBox(height: 12),
                        _buildCustomDepartmentInput(),
                      ],
                    ),
                    _buildSectionCard(
                      title: 'Working Hours & Services',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimePicker(
                                context,
                                'Opening Time',
                                controller.openingTime,
                                true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTimePicker(
                                context,
                                'Closing Time',
                                controller.closingTime,
                                false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSwitchTile(
                          'Emergency Services (24/7)',
                          controller.emergencyAvailable,
                        ),
                        _buildDropdownField('Status', controller.selectedStatus, [
                          'active',
                          'inactive',
                        ]),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildLogoPicker() {
    return Center(
      child: Stack(
        children: [
          Obx(() {
            ImageProvider? image;
            if (controller.logoPath.value != null) {
              image = FileImage(File(controller.logoPath.value!));
            } else if (controller.logoUrl.value != null && controller.logoUrl.value!.isNotEmpty) {
              image = NetworkImage(controller.logoUrl.value!);
            }

            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: image != null ? DecorationImage(image: image, fit: BoxFit.cover) : null,
              ),
              child: image == null
                  ? const Icon(Icons.local_hospital_rounded, size: 60, color: AppColors.primary)
                  : null,
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.pickLogo,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.bgPage.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, RxString value, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(
        () => DropdownButtonFormField<String>(
          value: value.value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => value.value = val!,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.bgPage.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentMultiSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Departments *',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.allDepartments.map((dept) {
              final isSelected = controller.selectedDepartments.contains(dept);
              return GestureDetector(
                onTap: () => controller.toggleDepartment(dept),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    dept,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Obx(() {
          final customDepts = controller.selectedDepartments
              .where((d) => !controller.allDepartments.contains(d))
              .toList();
          if (customDepts.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: customDepts
                  .map(
                    (dept) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(dept, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => controller.toggleDepartment(dept),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomDepartmentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.customDeptController,
            decoration: InputDecoration(
              hintText: 'Add Custom Department',
              hintStyle: const TextStyle(fontSize: 13),
              filled: true,
              fillColor: AppColors.bgPage.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: controller.addCustomDepartment,
          icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 32),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context, String label, RxString timeObs, bool isOpening) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => controller.selectTime(context, isOpening),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgPage.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Obx(
                  () => Text(
                    timeObs.value,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, RxBool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Obx(
        () => SwitchListTile(
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          value: value.value,
          onChanged: (val) => value.value = val,
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: controller.saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
