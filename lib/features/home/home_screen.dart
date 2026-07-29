import 'dart:async';
import 'dart:ui';
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
import '../voice_assistant/widgets/voice_assistant_modal.dart';
import 'widgets/interactive_map_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  LocationSample? _currentGpsLocation;
  final bool _isMapNightMode = true;

  StreamSubscription<LocationSample>? _locationSub;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _subscribeToLocation();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  void _subscribeToLocation() {
    final locationService = ref.read(locationServiceProvider);
    _locationSub = locationService.locationStream.listen((loc) {
      if (mounted) {
        setState(() {
          _currentGpsLocation = loc;
        });
      }
    });
  }

  Future<void> _fetchCurrentLocation() async {
    final loc = await ref.read(locationServiceProvider).getCurrentLocation();
    if (mounted) {
      setState(() {
        _currentGpsLocation = loc;
      });
    }
  }

  void _openVoiceAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceAssistantModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Ambient Radial Glow
            Positioned(
              top: -80,
              left: MediaQuery.of(context).size.width * 0.15,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      blurRadius: 120,
                      spreadRadius: 60,
                    ),
                  ],
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP AREA: Floating Greeting Header & Status Row
                  _buildTopHeaderRow(currentSample),

                  const SizedBox(height: AppSpacing.lg),

                  // 2. AI COMMAND CARD (Perplexity & Raycast Inspired)
                  _buildAiCommandCenterCard(),

                  const SizedBox(height: AppSpacing.lg),

                  // 3. ACTIVE TRIP SUMMARY OVERLAY CARD (If Active Journey Exists)
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

                  // 4. FLOATING DESTINATION SEARCH FIELD WITH RECENT CHIPS
                  LocationSearchBar(
                    readOnly: true,
                    onTap: () => context.push('/search'),
                    onMicTap: _openVoiceAssistant,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Search History Chips (Vector Icons)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildRecentChip('Central Station', Icons.train_rounded),
                        _buildRecentChip('Airport Gate 3', Icons.flight_takeoff_rounded),
                        _buildRecentChip('Cyber IT Park', Icons.business_rounded),
                        _buildRecentChip('Tech University', Icons.school_rounded),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 5. HERO MAP SECTION WITH FLOATING CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HERO MAP NAVIGATION',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const SimulationDrawer(),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up_rounded, color: AppColors.success, size: 18),
                            onPressed: () {
                              alarmService.triggerAlarm(
                                destinationName: 'Test Location',
                                distanceMeters: 500,
                                etaText: '1 min',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.thinBorder, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: InteractiveMapView(
                        currentSample: currentSample,
                        destination: activeJourneyState.journey?.destination,
                        isNightMode: _isMapNightMode,
                        onRecenter: _fetchCurrentLocation,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 6. AI SMART SUGGESTIONS SECTION
                  Text(
                    'AI SMART INSIGHTS',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildAiInsightCard(
                          icon: Icons.bolt_rounded,
                          title: 'Leave in 15 mins',
                          subtitle: 'Faster 2.4 km route detected',
                          color: AppColors.success,
                        ),
                        _buildAiInsightCard(
                          icon: Icons.thunderstorm_rounded,
                          title: 'Rain expected near destination',
                          subtitle: 'Pack umbrella before leaving',
                          color: AppColors.warning,
                        ),
                        _buildAiInsightCard(
                          icon: Icons.local_cafe_rounded,
                          title: 'Coffee stop on route',
                          subtitle: 'Starbucks 1.2 km ahead',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // 7. SAVED PLACES ELEGANT CARDS GRID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SAVED LOCATIONS',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/saved'),
                        child: Text(
                          'Manage Places',
                          style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (savedPlaces.isEmpty) ...[
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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.thinBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_location_alt_rounded, color: AppColors.primary),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Set Home & Office Locations',
                                    style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  Text(
                                    'Tap to pick or search your exact location on the map.',
                                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      height: 120,
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

                          return _buildSavedPlaceCard(context, place.name, updatedDest);
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 90),
                ],
              ),
            ),
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

  Widget _buildTopHeaderRow(LocationSample currentSample) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Good Morning Raj',
                  style: AppTypography.hero.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.waving_hand_rounded, color: AppColors.warning, size: 22),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.success, blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.wb_sunny_rounded, size: 14, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  'AI Engine Active  •  28°C Clear',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.thinBorder),
              ),
              child: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1.5),
                ),
                child: const Center(
                  child: Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAiCommandCenterCard() {
    return GestureDetector(
      onTap: _openVoiceAssistant,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md + 4),
            decoration: BoxDecoration(
              gradient: AppColors.glassCardGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glowingBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 14),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'AI Command Center',
                            style: AppTypography.cardTitle.copyWith(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'READY',
                              style: AppTypography.caption.copyWith(
                                fontSize: 9,
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Speak: "Wake me before my stop" or "Alert near Office"',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.mic_rounded, color: AppColors.primary, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        avatar: Icon(icon, size: 14, color: AppColors.primary),
        label: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surfaceSecondary,
        side: const BorderSide(color: AppColors.thinBorder),
      ),
    );
  }

  Widget _buildAiInsightCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaceCard(BuildContext context, String label, Destination destination) {
    final double distKm = (destination.distanceMeters ?? 0) / 1000.0;

    return InkWell(
      onTap: () {
        context.push('/destination', extra: destination);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 145,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.thinBorder),
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
                  color: AppColors.primary,
                  size: 24,
                ),
                Text(
                  '${distKm.toStringAsFixed(1)}km',
                  style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
