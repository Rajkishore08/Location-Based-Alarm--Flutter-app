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
import '../../shared/widgets/app_buttons.dart';
import '../home/widgets/interactive_map_view.dart';

class DestinationDetailsScreen extends ConsumerStatefulWidget {
  final Destination destination;

  const DestinationDetailsScreen({super.key, required this.destination});

  @override
  ConsumerState<DestinationDetailsScreen> createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends ConsumerState<DestinationDetailsScreen> {
  LocationSample? _userLocation;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final activeSample = ref.read(activeJourneyProvider).currentSample;
    final loc = activeSample ?? await ref.read(locationServiceProvider).getCurrentLocation();
    if (mounted) {
      setState(() => _userLocation = loc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final activeState = ref.watch(activeJourneyProvider);
    final LocationSample sample = activeState.currentSample ??
        _userLocation ??
        LocationSample(
          latitude: 13.0827,
          longitude: 80.2707,
          speed: 12.0,
          heading: 180.0,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        );

    final double liveDistMeters = const DistanceService().calculateDistanceMeters(
      startLatitude: sample.latitude,
      startLongitude: sample.longitude,
      endLatitude: widget.destination.latitude,
      endLongitude: widget.destination.longitude,
    );
    final double distKm = liveDistMeters / 1000.0;
    final int etaMins = (distKm / 0.75).round(); // Estimated travel time at transit speeds

    return Scaffold(
      body: Stack(
        children: [
          // Top Map Layer (45% height)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                InteractiveMapView(
                  currentSample: sample,
                  destination: widget.destination,
                  isNightMode: isDark,
                  onRecenter: _fetchLocation,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: CircleAvatar(
                      backgroundColor: isDark ? AppColors.glassDarkBg : Colors.white,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Sheet (60% height)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.60,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.inverseSurface : AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grabber bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        borderRadius: AppRadius.borderFull,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Header Tags
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: AppRadius.borderFull,
                        ),
                        child: Text(
                          'CURRENT DESTINATION',
                          style: AppTypography.labelMd.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('4.8', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    widget.destination.name,
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.destination.address,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.outline),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Bento 3-column Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildBentoCard(
                          context,
                          icon: Icons.straighten_rounded,
                          iconColor: AppColors.primary,
                          label: 'Distance',
                          value: '${distKm.toStringAsFixed(1)} km',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildBentoCard(
                          context,
                          icon: Icons.schedule_rounded,
                          iconColor: AppColors.tertiary,
                          label: 'ETA',
                          value: '~$etaMins min',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildBentoCard(
                          context,
                          icon: Icons.event_available_rounded,
                          iconColor: AppColors.secondary,
                          label: 'Arrival',
                          value: '${DateTime.now().add(Duration(minutes: etaMins)).hour}:${DateTime.now().add(Duration(minutes: etaMins)).minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Quick Info Bar
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
                      borderRadius: AppRadius.borderXl,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Optimal route calculated',
                                style: AppTypography.bodyLg.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'Live GPS tracking from your location active.',
                                style: AppTypography.bodyMd.copyWith(fontSize: 12, color: AppColors.outline),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Buttons
                  AppPrimaryButton(
                    text: 'Set Destination Alarm',
                    icon: Icons.notification_important_rounded,
                    onPressed: () {
                      context.push('/alarm-setup', extra: widget.destination);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppSecondaryButton(
                    text: 'Save Place',
                    icon: Icons.bookmark_add_rounded,
                    onPressed: () {
                      context.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.borderXl,
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.labelMd.copyWith(color: AppColors.outline, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.statsSm.copyWith(
              fontSize: 14,
              color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
