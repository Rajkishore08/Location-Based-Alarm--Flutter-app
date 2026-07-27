import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../services/smart_alert/distance_service.dart';
import '../../shared/models/destination.dart';
import '../../shared/models/location_sample.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/location_search_bar.dart';
import '../../shared/widgets/smart_alert_card.dart';
import '../saved_places/widgets/map_location_picker_modal.dart';
import '../simulation/simulation_drawer.dart';
import 'widgets/interactive_map_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  LocationSample? _currentGpsLocation;
  bool _isMapNightMode = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    final loc = await ref.read(locationServiceProvider).getCurrentLocation();
    if (mounted) {
      setState(() {
        _currentGpsLocation = loc;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final activeJourneyState = ref.watch(activeJourneyProvider);
    final savedPlaces = ref.watch(savedPlacesProvider);
    final alarmService = ref.watch(alarmServiceProvider);

    final LocationSample currentSample = activeJourneyState.currentSample ??
        _currentGpsLocation ??
        LocationSample(
          latitude: 13.0827,
          longitude: 80.2707,
          speed: 0,
          heading: 0,
          accuracy: 5,
          timestamp: DateTime.now(),
        );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.borderLg,
              ),
              child: const Icon(Icons.alarm_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Smart Route Alert',
              style: AppTypography.headlineMd.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMapNightMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppColors.primary,
            ),
            tooltip: _isMapNightMode ? 'Switch Map to Light Mode' : 'Switch Map to Dark Mode',
            onPressed: () {
              setState(() => _isMapNightMode = !_isMapNightMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
            tooltip: 'Test Alarm Sound & Vibration',
            onPressed: () {
              alarmService.triggerAlarm(
                destinationName: 'Test Location',
                distanceMeters: 500,
                etaText: '1 min',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🔊 Playing Test Alarm Sound & Vibration!'),
                  action: SnackBarAction(
                    label: 'STOP',
                    onPressed: () => alarmService.stopAlarm(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report_outlined, color: AppColors.primary),
            tooltip: 'Journey Simulator',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const SimulationDrawer(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header & Current GPS Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome traveler',
                      style: AppTypography.headlineLgMobile.copyWith(
                        color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Where are you travelling today?',
                      style: AppTypography.bodyLg.copyWith(
                        color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _fetchCurrentLocation,
                  borderRadius: AppRadius.borderFull,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.12),
                      borderRadius: AppRadius.borderFull,
                      border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.my_location_rounded, size: 14, color: AppColors.primaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          '${currentSample.latitude.toStringAsFixed(3)}, ${currentSample.longitude.toStringAsFixed(3)}',
                          style: AppTypography.labelMd.copyWith(
                            fontSize: 10,
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Active Journey Card
            if (activeJourneyState.journey != null) ...[
              GestureDetector(
                onTap: () => context.push('/journey'),
                child: SmartAlertCard(
                  statusText: activeJourneyState.journey!.status.name,
                  mainTitle: activeJourneyState.journey!.destination.name,
                  etaText: activeJourneyState.journey!.estimatedArrival != null
                      ? 'ETA ${activeJourneyState.journey!.estimatedArrival!.hour}:${activeJourneyState.journey!.estimatedArrival!.minute.toString().padLeft(2, '0')}'
                      : 'Active',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Location Search Bar (Triggers Worldwide Search)
            LocationSearchBar(
              readOnly: true,
              onTap: () => context.push('/search'),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Map Header & Theme Toggle Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isMapNightMode ? 'MAP PREVIEW (DARK MODE)' : 'MAP PREVIEW (LIGHT MODE)',
                  style: AppTypography.labelMd.copyWith(
                    color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isMapNightMode = !_isMapNightMode),
                  child: Row(
                    children: [
                      Icon(
                        _isMapNightMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isMapNightMode ? 'Light Map' : 'Dark Map',
                        style: AppTypography.labelMd.copyWith(color: AppColors.primary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderXl,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppRadius.borderXl,
                child: InteractiveMapView(
                  currentSample: currentSample,
                  destination: activeJourneyState.journey?.destination,
                  isNightMode: _isMapNightMode || isDark,
                  onRecenter: _fetchCurrentLocation,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Saved Places Header & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR SAVED LOCATIONS',
                  style: AppTypography.labelMd.copyWith(
                    color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/saved'),
                  child: Text(
                    'Manage Places',
                    style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            if (savedPlaces.isEmpty) ...[
              // Empty State Prompting User to Set Home & Work
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const MapLocationPickerModal(),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
                    borderRadius: AppRadius.borderXl,
                    border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_location_alt_rounded, color: AppColors.primaryContainer),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set your Home & Work locations',
                              style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Tap to pick or search your exact location on the map.',
                              style: AppTypography.bodyMd.copyWith(color: AppColors.outline, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryContainer),
                    ],
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: savedPlaces.length,
                  separatorBuilder: (_, index) => const SizedBox(width: AppSpacing.md),
                  itemBuilder: (context, idx) {
                    final place = savedPlaces[idx];
                    final double liveDistMeters = const DistanceService().calculateDistanceMeters(
                      startLatitude: currentSample.latitude,
                      startLongitude: currentSample.longitude,
                      endLatitude: place.destination.latitude,
                      endLongitude: place.destination.longitude,
                    );
                    final updatedDest = place.destination.copyWith(distanceMeters: liveDistMeters);

                    return _buildQuickPlaceChip(context, place.name, updatedDest);
                  },
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _navIndex,
        onTap: (idx) {
          setState(() => _navIndex = idx);
          if (idx == 1) context.push('/history');
          if (idx == 2) context.push('/saved');
          if (idx == 3) context.push('/profile');
        },
      ),
    );
  }

  Widget _buildQuickPlaceChip(BuildContext context, String label, Destination destination) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double distKm = (destination.distanceMeters ?? 0) / 1000.0;

    return InkWell(
      onTap: () {
        context.push('/destination', extra: destination);
      },
      borderRadius: AppRadius.borderXl,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isDark ? AppColors.glassBorderDark : AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  label.toLowerCase().contains('home')
                      ? Icons.home_rounded
                      : (label.toLowerCase().contains('work') ? Icons.work_rounded : Icons.location_on_rounded),
                  color: AppColors.primaryContainer,
                  size: 24,
                ),
                Text(
                  '${distKm.toStringAsFixed(1)}km',
                  style: AppTypography.labelMd.copyWith(fontSize: 10, color: AppColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.bodyLg.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
