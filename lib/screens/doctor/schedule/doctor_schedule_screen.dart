import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'doctor_schedule_controller.dart';

class DoctorScheduleScreen extends GetView<DoctorScheduleController> {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Manage Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.weekDays.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final day = controller.weekDays[index];
            final schedule = controller.schedules.firstWhereOrNull((s) => s.day == day);
            return _buildDayCard(context, day, schedule);
          },
        );
      }),
    );
  }

  Widget _buildDayCard(BuildContext context, String day, dynamic schedule) {
    bool isAvailable = schedule != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Switch(
                value: isAvailable,
                onChanged: (val) {
                  if (val) {
                    _showEditDialog(context, day, schedule);
                  } else {
                    // Logic to disable/delete schedule
                  }
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (isAvailable) ...[
            const Divider(height: 24),
            Row(
              children: [
                _infoChip(Icons.access_time_rounded, '${schedule.startTime} - ${schedule.endTime}'),
                const SizedBox(width: 8),
                _infoChip(Icons.timer_outlined, '${schedule.slotDuration} min/slot'),
              ],
            ),
          ] else
            const Text('Not available', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String day, dynamic schedule) {
    String startTime = schedule?.startTime ?? "09:00";
    String endTime = schedule?.endTime ?? "17:00";
    int duration = schedule?.slotDuration ?? 15;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set Schedule for $day', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _timePickerField('Start Time', startTime, (val) => startTime = val)),
                const SizedBox(width: 12),
                Expanded(child: _timePickerField('End Time', endTime, (val) => endTime = val)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Slot Duration (Minutes)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: duration,
              items: [15, 20, 30, 45, 60].map((e) => DropdownMenuItem(value: e, child: Text('$e mins'))).toList(),
              onChanged: (val) => duration = val!,
              decoration: InputDecoration(
                filled: true, fillColor: AppColors.bgPage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  controller.updateSchedule(day, startTime, endTime, duration);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: const Text('Save Schedule'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timePickerField(String label, String initialValue, Function(String) onSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(context: Get.context!, initialTime: TimeOfDay.now());
            if (time != null) {
              onSelected("${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}");
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(color: AppColors.bgPage, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(initialValue, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
