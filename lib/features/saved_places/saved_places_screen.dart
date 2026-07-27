import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/destination_card.dart';
import 'widgets/map_location_picker_modal.dart';

class SavedPlacesScreen extends ConsumerWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(savedPlacesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Places'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Alarm Destinations',
              style: AppTypography.headlineLgMobile,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap any saved place to quickly configure a Smart Alarm, or tap + Add Place to pick on map.',
              style: AppTypography.bodyLg.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: places.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_rounded, size: 64, color: AppColors.outlineVariant),
                          const SizedBox(height: AppSpacing.md),
                          Text('No saved places yet', style: AppTypography.headlineMd),
                          const SizedBox(height: 4),
                          Text('Tap "+ Add Place" to pick Home, Work or any spot on map.', style: AppTypography.bodyMd),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: places.length,
                      separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, idx) {
                        final place = places[idx];
                        return Dismissible(
                          key: Key(place.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            ref.read(savedPlacesProvider.notifier).deletePlace(place.id);
                            ref.read(firestoreServiceProvider).deleteUserPlace(place.id);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: AppRadius.borderXl,
                            ),
                            child: const Icon(Icons.delete_rounded, color: Colors.white),
                          ),
                          child: DestinationCard(
                            destination: place.destination,
                            onTap: () {
                              context.push('/destination', extra: place.destination);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const MapLocationPickerModal(),
          );
        },
        backgroundColor: AppColors.primaryContainer,
        icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
        label: const Text('Add / Pick Place', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 2,
        onTap: (idx) {
          if (idx == 0) context.go('/home');
          if (idx == 1) context.go('/history');
          if (idx == 3) context.go('/profile');
        },
      ),
    );
  }
}
