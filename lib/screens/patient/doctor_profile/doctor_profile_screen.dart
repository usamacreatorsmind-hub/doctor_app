import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import 'doctor_profile_controller.dart';
import 'package:intl/intl.dart';

class DoctorProfileScreen extends GetView<DoctorProfileController> {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorBasicInfo(),
                  const SizedBox(height: 24),
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Biography'),
                  const SizedBox(height: 8),
                  Text(
                    controller.doctor.biography ?? 'No biography available.',
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Specialization'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: controller.doctor.specialization.map((s) => _chip(s)).toList(),
                  ),
                  if (controller.doctor.languagesKnown.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('Languages Known'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: controller.doctor.languagesKnown.map((l) => _chip(l)).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildReviewsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: (controller.doctor.photoUrl != null && controller.doctor.photoUrl!.isNotEmpty)
            ? Image.network(controller.doctor.photoUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.primarySurface,
                child: const Icon(Icons.person, size: 120, color: AppColors.primary),
              ),
      ),
    );
  }

  Widget _buildDoctorBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.doctor.doctorName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('${controller.doctor.qualification.join(", ")} - ${controller.doctor.specialization.join(", ")}', 
                    style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
              child: Text(controller.doctor.consultationMode, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
          children: [
            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(controller.hospitalName.value.isEmpty ? 'Loading hospital...' : controller.hospitalName.value, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
        )),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem('Experience', '${controller.doctor.experience}Yrs', Icons.work_history_rounded, Colors.blue),
        _statItem('Rating', controller.doctor.rating.toString(), Icons.star_rounded, Colors.orange),
        _statItem('Reviews', controller.doctor.totalReviews.toString(), Icons.reviews_rounded, Colors.green),
      ],
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Container(
      width: Get.width * 0.28,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5))),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _chip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.primaryBorder),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Patient Reviews'),
            Obx(() => Text(
              '${controller.reviews.length} reviews',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isReviewsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.reviews.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
              ),
              child: const Center(
                child: Text('No reviews yet. Be the first to rate!', 
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.reviews.length > 3 ? 3 : controller.reviews.length, // Show top 3
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final review = controller.reviews[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBorder.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review.patientName ?? 'Patient', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            Text(review.rating.toString(), 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(review.createdAt),
                      style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                    ),
                    if (review.comment != null && review.comment!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(review.comment!, 
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                    ],
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Consultation Fee', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              Text('₹${controller.doctor.consultationFee.toInt()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Obx(() => ElevatedButton(
              onPressed: controller.isAdminView.value 
                ? controller.onViewSchedule 
                : controller.onBookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                controller.isAdminView.value ? 'View Schedule' : 'Book Appointment', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            )),
          ),
        ],
      ),
    );
  }
}
