import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'walk_in_booking_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../models/doctor_model.dart';

class WalkInBookingScreen extends GetView<WalkInBookingController> {
  const WalkInBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Walk-in Booking'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Obx(() {
        return Column(
          children: [
            _buildStepper(),
            Expanded(
              child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildCurrentStepView(context)),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(child: _buildBottomBar()),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      color: Colors.white,
      child: Row(
        children: [_stepIndicator(0, 'Search'), _stepLine(0), _stepIndicator(1, 'Register'), _stepLine(1), _stepIndicator(2, 'Booking')],
      ),
    );
  }

  Widget _stepIndicator(int index, String label) {
    bool isCompleted = controller.currentStep.value > index;
    bool isActive = controller.currentStep.value == index;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : (isCompleted ? Colors.green : Colors.grey.shade300),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppColors.primary : Colors.grey)),
      ],
    );
  }

  Widget _stepLine(int index) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: controller.currentStep.value > index ? Colors.green : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildCurrentStepView(BuildContext context) {
    switch (controller.currentStep.value) {
      case 0:
        return _buildSearchStep();
      case 1:
        return _buildRegisterStep(context);
      case 2:
        return _buildBookingStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSearchStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Find Patient', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'Enter patient\'s 10-digit mobile number to search or register.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controller.mobileController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            hintText: '9XXXXXXXXX',
            prefixIcon: const Icon(Icons.phone_android_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Patient Registration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _textField(controller.nameController, 'Full Name', Icons.person_outline),
        const SizedBox(height: 16),
        _textField(controller.emailController, 'Email Address', Icons.email_outlined),
        const SizedBox(height: 16),
        _textField(controller.mobileController, 'Mobile Number', Icons.phone_android, enabled: false),
        const SizedBox(height: 20),
        const Text(
          'Gender',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        _buildGenderSelector(),
        const SizedBox(height: 20),
        _buildDOBField(context),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Obx(
      () => Row(
        children: [
          _genderOption('male', Icons.male),
          const SizedBox(width: 12),
          _genderOption('female', Icons.female),
          const SizedBox(width: 12),
          _genderOption('other', Icons.transgender),
        ],
      ),
    );
  }

  Widget _genderOption(String val, IconData icon) {
    bool isSelected = controller.selectedGender.value == val;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedGender.value = val,
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
                val.capitalizeFirst!,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDOBField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.dobController.text = date.toIso8601String().split('T')[0];
            }
          },
          child: IgnorePointer(child: _textField(controller.dobController, 'Select Date', Icons.calendar_today_outlined)),
        ),
      ],
    );
  }

  Widget _buildBookingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_circle_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Account: ${controller.foundPatient?.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildBookingForSelection(),
        const SizedBox(height: 20),
        Obx(() => controller.isForSelf.value ? const SizedBox.shrink() : _buildFamilyMemberForm()),
        Obx(() => controller.isForSelf.value ? const SizedBox.shrink() : const SizedBox(height: 20)),
        const Text('Select Doctor', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        controller.doctors.length == 1
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services_outlined, size: 18, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Dr. ${controller.doctors[0].doctorName}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              )
            : DropdownButtonFormField<DoctorModel>(
                value: controller.selectedDoctor.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: controller.doctors.map((doc) {
                  return DropdownMenuItem(value: doc, child: Text(doc.doctorName));
                }).toList(),
                onChanged: controller.onDoctorSelected,
                hint: const Text('Choose a doctor'),
              ),
        if (controller.selectedDoctor.value != null) ...[
          const SizedBox(height: 24),
          const Text('Select Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildHorizontalDateSelector(),
          const SizedBox(height: 24),
          Obx(
            () => Text(
              'Available Slots on ${DateFormat('MMM dd, yyyy').format(controller.selectedDate.value)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          _buildTimeSlotGrid(),
          const SizedBox(height: 24),
          _textField(controller.symptomsController, 'Symptoms / Reason', Icons.note_add_outlined, maxLines: 3),
        ],
      ],
    );
  }

  Widget _buildHorizontalDateSelector() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final dayName = DateFormat('EEE').format(date);
          final dayOfMonth = DateFormat('dd').format(date);

          return Obx(() {
            final isSelected = controller.selectedDate.value.day == date.day && controller.selectedDate.value.month == date.month;

            return GestureDetector(
              onTap: () => controller.selectDate(date),
              child: Container(
                width: 55,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dayName, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textSecondary)),
                    Text(
                      dayOfMonth,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    return Obx(() {
      if (controller.availableSlots.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: const Text(
            'No slots available for this day. Please try another date.',
            style: TextStyle(color: Colors.orange, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.availableSlots.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
        ),
        itemBuilder: (context, index) {
          final slot = controller.availableSlots[index];
          final bool isBooked = controller.bookedSlots.contains(slot);

          return Obx(() {
            final bool isSelected = controller.selectedSlot.value == slot;
            return GestureDetector(
              onTap: isBooked ? null : () => controller.selectedSlot.value = slot,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : (isBooked ? Colors.grey.shade100 : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? AppColors.primary : (isBooked ? Colors.grey.shade200 : AppColors.primaryBorder)),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isBooked ? Colors.grey : AppColors.textPrimary),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildBookingForSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking for',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _selectionChip(
                    label: 'Account Holder',
                    isSelected: controller.isForSelf.value,
                    onTap: () => controller.isForSelf.value = true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectionChip(
                    label: 'Family Member',
                    isSelected: !controller.isForSelf.value,
                    onTap: () => controller.isForSelf.value = false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectionChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyMemberForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Family Member Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const Divider(height: 24),
          _textField(controller.otherNameController, 'Family Member Name', Icons.person_outline),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _textField(controller.otherAgeController, 'Age', Icons.calendar_today_outlined, keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _dropdownField(
                    label: 'Gender',
                    value: controller.selectedOtherGender.value,
                    items: controller.genders,
                    onChanged: (val) => controller.selectedOtherGender.value = val!,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(
            () => _dropdownField(
              label: 'Relationship',
              value: controller.selectedRelationship.value,
              items: controller.relationships,
              onChanged: (val) => controller.selectedRelationship.value = val!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({required String label, required String value, required List<String> items, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.primaryBorder, width: 0.5)),
      ),
      child: controller.isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _onNextPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  controller.currentStep.value == 2 ? 'Confirm Booking' : 'Continue',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }

  void _onNextPressed() {
    switch (controller.currentStep.value) {
      case 0:
        controller.searchPatient();
        break;
      case 1:
        controller.registerAndContinue();
        break;
      case 2:
        controller.bookAppointment();
        break;
    }
  }
}
