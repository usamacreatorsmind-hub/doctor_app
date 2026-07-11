import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import 'slot_selection_controller.dart';

class SlotSelectionScreen extends GetView<SlotSelectionController> {
  const SlotSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Select Slot', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector
            _buildDateSelector(),

            // Available Slots
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      'Available Slots on ${controller.selectedDate.value != null ? DateFormat('MMM dd, yyyy').format(controller.selectedDate.value!) : ''}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    )),
                    const SizedBox(height: 12),
                    Expanded(child: _buildTimeSlotGrid()),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(child: _buildBottomAction()),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 70,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 14, // Next 14 days
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final date = DateTime.now().add(Duration(days: index));
            final dayName = DateFormat('EEE').format(date);
            final dayOfMonth = DateFormat('dd').format(date);

            // Each item is wrapped in Obx to react to selectedDate changes
            return Obx(() {
              final isSelected = controller.selectedDate.value != null && 
                  controller.selectedDate.value!.day == date.day && 
                  controller.selectedDate.value!.month == date.month;

              return GestureDetector(
                onTap: () => controller.selectDate(date),
                child: Container(
                  width: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder, width: isSelected ? 1.5 : 1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dayName, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : AppColors.textSecondary)),
                      Text(dayOfMonth, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
                    ],
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid() {
    return Obx(() {
      if (controller.availableTimeSlots.isEmpty) {
        return const Center(
          child: Text('No slots available for this day or doctor.',
              style: TextStyle(color: AppColors.textSecondary)),
        );
      }
      return GridView.builder(
        itemCount: controller.availableTimeSlots.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, index) {
          final slot = controller.availableTimeSlots[index];
          
          // Each slot is wrapped in Obx to react to selectedTimeSlot changes
          return Obx(() {
            final isSelected = controller.selectedTimeSlot.value == slot;
            return GestureDetector(
              onTap: () => controller.selectTimeSlot(slot),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildBottomAction() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.selectedTimeSlot.value != null
                  ? controller.goToBookingConfirmation
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue to Book',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ));
  }
}
