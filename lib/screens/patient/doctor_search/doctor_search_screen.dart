import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../models/doctor_model.dart';
import '../../../widgets/animated_search_hint.dart';
import 'doctor_search_controller.dart';

class DoctorSearchScreen extends GetView<DoctorSearchController> {
  const DoctorSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text('Find Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 8),
              _buildSpecializationFilters(),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.searchResults.isEmpty) {
                    return _buildEmptyState();
                  }
                  return SafeArea(
                    child: ListView.separated(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 10),
                      itemCount: controller.searchResults.length + (controller.hasMore.value ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index < controller.searchResults.length) {
                          return _DoctorResultCard(
                            doctor: controller.searchResults[index],
                            onTap: () => controller.goToDoctorProfile(controller.searchResults[index]),
                            matchTerm: controller.searchQuery.value,
                          );
                        }

                        return controller.hasMore.value
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
          _buildSuggestionsOverlay(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Obx(() {
      if (!controller.isSuggestionsVisible.value || controller.suggestions.isEmpty) {
        return const SizedBox.shrink();
      }
      return Positioned(
        top: 60, // Below search bar
        left: 16,
        right: 16,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 250),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            border: Border.all(color: AppColors.primaryBorder),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: controller.suggestions.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final suggestion = controller.suggestions[index];
              return ListTile(
                leading: const Icon(Icons.history_rounded, size: 20, color: AppColors.textHint),
                title: Text(suggestion, style: const TextStyle(fontSize: 14)),
                onTap: () => controller.selectSuggestion(suggestion),
                dense: true,
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    final hints = [
      'Search Doctor',
      'Search Disease',
      'Search Hospital',
      'Search Symptoms',
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Obx(() {
        final isQueryEmpty = controller.searchQuery.value.isEmpty;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: isQueryEmpty ? '' : null,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: IconButton(icon: const Icon(Icons.clear_rounded), onPressed: controller.clearFilters),
                filled: true,
                fillColor: AppColors.bgPage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            if (isQueryEmpty)
              Positioned(
                left: 48,
                right: 48,
                child: IgnorePointer(
                  child: AnimatedSearchHint(
                    hints: hints,
                    textStyle: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSpecializationFilters() {
    IconData getSpecIcon(String name) {
      final n = name.toLowerCase();
      if (n.isEmpty || n.contains('all')) return Icons.grid_view_rounded;
      if (n.contains('ayurveda') || n.contains('ayur')) return Icons.nature_people_rounded;
      if (n.contains('cardiology') || n.contains('heart')) return Icons.favorite_rounded;
      if (n.contains('ent') || n.contains('ear') || n.contains('nose')) return Icons.hearing_rounded;
      if (n.contains('pediatric') || n.contains('child') || n.contains('baby')) return Icons.child_care_rounded;
      if (n.contains('general') || n.contains('physician')) return Icons.medical_services_rounded;
      if (n.contains('dermatology') || n.contains('skin')) return Icons.clean_hands_rounded;
      if (n.contains('ortho') || n.contains('bone')) return Icons.accessibility_new_rounded;
      if (n.contains('dental') || n.contains('teeth')) return Icons.clean_hands_rounded;
      return Icons.health_and_safety_rounded;
    }

    return Container(
      height: 100, // Increased height for vertical layout
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: controller.specializations.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final bool isAll = index == 0;
          final String title = isAll ? 'All' : controller.specializations[index - 1];

          return Obx(() {
            final bool isSelected = isAll
                ? controller.selectedSpecialization.value == ''
                : controller.selectedSpecialization.value == title;

            final IconData icon = getSpecIcon(isAll ? 'all' : title);

            return GestureDetector(
              onTap: () {
                if (isAll) {
                  controller.clearFilters();
                } else {
                  controller.onSpecializationFilter(title);
                }
              },
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.primaryBorder.withOpacity(0.6), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 24),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 65,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No doctors found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DoctorResultCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;
  final String matchTerm;
  const _DoctorResultCard({required this.doctor, required this.onTap, this.matchTerm = ''});

  @override
  Widget build(BuildContext context) {
    String? matchedTag;
    if (matchTerm.isNotEmpty) {
      final term = matchTerm.toLowerCase();
      final symMatch = doctor.symptomsCovered.firstWhereOrNull((s) => s.toLowerCase().contains(term));
      final disMatch = doctor.diseasesCovered.firstWhereOrNull((d) => d.toLowerCase().contains(term));
      if (symMatch != null) {
        matchedTag = "Treats: $symMatch";
      } else if (disMatch != null) {
        matchedTag = "Specialist: $disMatch";
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    image: doctor.photoUrl != null ? DecorationImage(image: NetworkImage(doctor.photoUrl!), fit: BoxFit.cover) : null,
                  ),
                  child: doctor.photoUrl == null ? const Icon(Icons.person_rounded, color: AppColors.primary, size: 40) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.doctorName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        doctor.specialization.join(', '),
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(doctor.rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' (${doctor.totalReviews})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${doctor.experience} yrs exp', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(
                            '₹${doctor.consultationFee.toInt()}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (matchedTag != null) ...[
              const Divider(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      matchedTag,
                      style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


