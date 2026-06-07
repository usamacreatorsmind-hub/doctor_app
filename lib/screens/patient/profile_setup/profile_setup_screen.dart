import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'profile_setup_controller.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileSetupController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──
                _buildHeader(controller),
                
                // ── Step Content ──
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(controller.currentStep.value),
                      child: _buildStepContent(context, controller),
                    ),
                  ),
                ),

                // ── Bottom Buttons ──
                _buildBottomButtons(controller),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ProfileSetupController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Complete Your Profile',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              GestureDetector(
                onTap: () => controller.onSkip(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Skip for now', style: TextStyle(fontSize: 11, color: Colors.white70)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(controller.steps.length, (index) {
              final bool isDone = index < controller.currentStep.value;
              final bool isActive = index == controller.currentStep.value;
              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone || isActive ? Colors.white : Colors.white.withValues(alpha: 0.25),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check_rounded, size: 16, color: AppColors.primary)
                            : Text('${index + 1}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? AppColors.primary : Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        controller.steps[index]['title']!,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? Colors.white : Colors.white60),
                      ),
                    ),
                    if (index < controller.steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: isDone ? Colors.white : Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: controller.progressValue,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, ProfileSetupController controller) {
    switch (controller.currentStep.value) {
      case 0:
        return _Step1Personal(controller: controller, context: context);
      case 1:
        return _Step2Medical(controller: controller);
      case 2:
        return _Step3Emergency(controller: controller);
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomButtons(ProfileSetupController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        border: Border(top: BorderSide(color: AppColors.primaryBorder, width: 0.5)),
      ),
      child: Row(
        children: [
          if (controller.currentStep.value > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: () => controller.onBackStep(),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          if (controller.currentStep.value > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.isSaving.value ? null : () => controller.onNextStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: AppColors.primaryBorder,
              ),
              child: controller.isSaving.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.nextBtnLabel, style: AppTextStyles.btnPrimary),
                        const SizedBox(width: 6),
                        Icon(
                          controller.currentStep.value == controller.steps.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// STEP 1 — PERSONAL DETAILS
// ──────────────────────────────────────────
class _Step1Personal extends StatelessWidget {
  final ProfileSetupController controller;
  final BuildContext context;
  const _Step1Personal({required this.controller, required this.context});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: controller.step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhotoSection(controller),
            const SizedBox(height: 20),
            _buildDobField(context, controller),
            const SizedBox(height: 14),
            _buildGenderSelector(controller),
            const SizedBox(height: 14),
            _buildBloodGroupSelector(controller),
            const SizedBox(height: 14),
            _buildInputField(label: 'Address', hint: 'House no, Street, Area', icon: Icons.home_outlined, controller: controller.addressController, maxLines: 2),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _buildInputField(label: 'City', hint: 'Your city', icon: Icons.location_city_outlined, controller: controller.cityController)),
                const SizedBox(width: 12),
                Expanded(child: _buildInputField(label: 'State', hint: 'Your state', icon: Icons.map_outlined, controller: controller.stateController)),
              ],
            ),
            const SizedBox(height: 14),
            _buildInputField(label: 'Pincode', hint: '6-digit pincode', icon: Icons.pin_drop_outlined, controller: controller.pincodeController, keyboardType: TextInputType.number, maxLength: 6, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(ProfileSetupController controller) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primarySurface, border: Border.all(color: AppColors.primaryBorder, width: 1.5)),
            child: const Icon(Icons.person_rounded, size: 44, color: AppColors.primary),
          ),
          Positioned(bottom: 0, right: 0,
            child: Container(
              width: 28, height: 28,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              child: const Icon(Icons.camera_alt_rounded, size: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDobField(BuildContext context, ProfileSetupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Date of Birth *'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => controller.pickDob(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller.dobController,
              validator: (v) => v == null || v.isEmpty ? 'Date of birth is required' : null,
              style: _inputStyle,
              decoration: _inputDeco('DD/MM/YYYY', Icons.calendar_today_rounded),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ProfileSetupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Gender *'),
        const SizedBox(height: 8),
        Row(
          children: controller.genders.map((gender) {
            final bool isSelected = controller.selectedGender.value == gender;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: gender != controller.genders.last ? 10 : 0),
                child: GestureDetector(
                  onTap: () => controller.selectGender(gender),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primarySurface : AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder, width: isSelected ? 1.8 : 1),
                    ),
                    child: Column(
                      children: [
                        Icon(gender == 'Male' ? Icons.male_rounded : gender == 'Female' ? Icons.female_rounded : Icons.person_outline_rounded,
                            size: 22, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                        const SizedBox(height: 4),
                        Text(gender, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBloodGroupSelector(ProfileSetupController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Blood Group'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: controller.bloodGroups.map((bg) {
            final bool isSelected = controller.selectedBloodGroup.value == bg;
            return GestureDetector(
              onTap: () => controller.selectBloodGroup(bg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder),
                ),
                child: Text(bg, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : AppColors.textSecondary)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────
// STEP 2 — MEDICAL INFO
// ──────────────────────────────────────────
class _Step2Medical extends StatelessWidget {
  final ProfileSetupController controller;
  const _Step2Medical({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            title: 'Medical History',
            subtitle: 'Select or add past diseases',
            icon: Icons.history_edu_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Wrap(
                  spacing: 8, runSpacing: 8,
                  children: controller.commonDiseases.map((disease) {
                    final bool isSelected = controller.medicalHistoryList.contains(disease);
                    return GestureDetector(
                      onTap: () => controller.toggleMedicalHistory(disease),
                      child: _chip(disease, isSelected),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 12),
                _addItemRow(controller: controller.medicalHistoryController, hint: 'Add other disease...', onAdd: () => controller.addCustomMedicalHistory()),
                Obx(() => controller.medicalHistoryList.isNotEmpty ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 6, runSpacing: 6,
                    children: controller.medicalHistoryList.where((d) => !controller.commonDiseases.contains(d)).map((item) => _removableChip(item, () => controller.removeMedicalHistory(item))).toList(),
                  ),
                ) : const SizedBox()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Current Medications',
            subtitle: 'Medicines you take regularly',
            icon: Icons.medication_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _addItemRow(controller: controller.medicationController, hint: 'e.g. Metformin 500mg', onAdd: () => controller.addMedication()),
                const SizedBox(height: 10),
                Obx(() => Wrap(
                  spacing: 6, runSpacing: 6,
                  children: controller.currentMedications.map((item) => _removableChip(item, () => controller.removeMedication(item))).toList(),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Allergies',
            subtitle: 'Select or add known allergies',
            icon: Icons.warning_amber_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Wrap(
                  spacing: 8, runSpacing: 8,
                  children: controller.commonAllergies.map((allergy) {
                    final bool isSelected = controller.allergiesList.contains(allergy);
                    return GestureDetector(
                      onTap: () => controller.toggleAllergy(allergy),
                      child: _chip(allergy, isSelected, activeColor: const Color(0xFFFF6F00), activeBg: const Color(0xFFFFF3E0)),
                    );
                  }).toList(),
                )),
                const SizedBox(height: 12),
                _addItemRow(controller: controller.allergyController, hint: 'Add other allergy...', onAdd: () => controller.addCustomAllergy()),
                Obx(() => Wrap(
                  spacing: 6, runSpacing: 6,
                  children: controller.allergiesList.where((a) => !controller.commonAllergies.contains(a)).map((item) => _removableChip(item, () => controller.removeAllergy(item), color: const Color(0xFFFF6F00))).toList(),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// STEP 3 — EMERGENCY & INSURANCE
// ──────────────────────────────────────────
class _Step3Emergency extends StatelessWidget {
  final ProfileSetupController controller;
  const _Step3Emergency({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionCard(
            title: 'Emergency Contact',
            subtitle: 'Who to contact in emergency',
            icon: Icons.emergency_outlined,
            child: Column(
              children: [
                _buildInputField(label: 'Contact Name', hint: 'Full name', icon: Icons.person_outline_rounded, controller: controller.emergencyNameController),
                const SizedBox(height: 12),
                _buildInputField(label: 'Mobile Number', hint: '10-digit number', icon: Icons.phone_outlined, controller: controller.emergencyNumberController, keyboardType: TextInputType.phone, maxLength: 10, prefix: '+91 '),
                const SizedBox(height: 12),
                _fieldLabel('Relation'),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                  spacing: 8, runSpacing: 8,
                  children: controller.relations.map((rel) => GestureDetector(
                    onTap: () => controller.selectRelation(rel),
                    child: _chip(rel, controller.selectedRelation.value == rel),
                  )).toList(),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Insurance Details',
            subtitle: 'Optional — helps with claims',
            icon: Icons.health_and_safety_outlined,
            isOptional: true,
            child: Column(
              children: [
                _buildInputField(label: 'Insurance Provider', hint: 'e.g. Star Health', icon: Icons.business_outlined, controller: controller.insuranceProviderController),
                const SizedBox(height: 12),
                _buildInputField(label: 'Policy Number', hint: 'Enter policy number', icon: Icons.numbers_outlined, controller: controller.insurancePolicyController),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primaryBorder, width: 0.5)),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text('Your information is private and secure.', style: TextStyle(fontSize: 12, color: AppColors.primary, height: 1.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────
// SHARED HELPER WIDGETS
// ──────────────────────────────────────────

Widget _sectionCard({required String title, required String subtitle, required IconData icon, required Widget child, bool isOptional = false}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgWhite, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBorder, width: 0.5)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: AppColors.primary)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (isOptional) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)), child: const Text('Optional', style: TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)))]
              ]),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]))
          ],
        ),
        const SizedBox(height: 14),
        const Divider(color: AppColors.primaryBorder, height: 1),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

Widget _buildInputField({required String label, required String hint, required IconData icon, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, int maxLines = 1, int? maxLength, String? prefix, List<TextInputFormatter>? inputFormatters}) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _fieldLabel(label),
    const SizedBox(height: 6),
    TextFormField(
      controller: controller, keyboardType: keyboardType, maxLines: maxLines, maxLength: maxLength, inputFormatters: inputFormatters,
      style: _inputStyle, decoration: _inputDeco(hint, icon, prefix: prefix, counterText: maxLength != null ? '' : null),
    ),
  ]);
}

Widget _addItemRow({required TextEditingController controller, required String hint, required VoidCallback onAdd}) {
  return Row(children: [
    Expanded(child: TextFormField(controller: controller, style: _inputStyle, decoration: InputDecoration(hintText: hint, filled: true, fillColor: AppColors.bgPage, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primaryBorder))))),
    const SizedBox(width: 8),
    GestureDetector(onTap: onAdd, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.add_rounded, color: Colors.white, size: 22))),
  ]);
}

Widget _chip(String label, bool isSelected, {Color? activeColor, Color? activeBg}) {
  return AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: isSelected ? (activeBg ?? AppColors.primarySurface) : AppColors.bgWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? (activeColor ?? AppColors.primary) : AppColors.primaryBorder, width: isSelected ? 1.5 : 1)), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? (activeColor ?? AppColors.primary) : AppColors.textSecondary)));
}

Widget _removableChip(String label, VoidCallback onRemove, {Color color = AppColors.primary}) {
  return Container(padding: const EdgeInsets.fromLTRB(10, 5, 6, 5), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primaryBorder)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)), const SizedBox(width: 4), GestureDetector(onTap: onRemove, child: Icon(Icons.close_rounded, size: 14, color: color))]));
}

Widget _fieldLabel(String label) { return Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)); }
TextStyle get _inputStyle => const TextStyle(fontSize: 14, color: AppColors.textPrimary);
InputDecoration _inputDeco(String hint, IconData icon, {String? prefix, String? counterText}) {
  return InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.primary, size: 20), prefixText: prefix, counterText: counterText, filled: true, fillColor: AppColors.bgWhite, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryBorder)));
}
