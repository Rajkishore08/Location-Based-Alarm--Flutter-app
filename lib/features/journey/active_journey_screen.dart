import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../shared/models/journey.dart';
import '../../shared/models/location_sample.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/journey_bottom_sheet.dart';
import '../../shared/widgets/smart_alert_card.dart';
import '../home/widgets/interactive_map_view.dart';
import '../simulation/simulation_drawer.dart';

class ActiveJourneyScreen extends ConsumerStatefulWidget {
  const ActiveJourneyScreen({super.key});

  @override
  ConsumerState<ActiveJourneyScreen> createState() => _ActiveJourneyScreenState();
}

class _ActiveJourneyScreenState extends ConsumerState<ActiveJourneyScreen> {
  bool _forceDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeJourneyProvider);
    final journey = activeState.journey;

    // Check if alarm triggered -> navigate to full screen alarm
    if (journey != null && (journey.status == JourneyStatus.alarmTriggered || journey.status == JourneyStatus.alarmEscalated)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/alarm');
      });
    }

    final bool isDark = _forceDarkTheme || Theme.of(context).brightness == Brightness.dark;
    final LocationSample sample = activeState.currentSample ??
        LocationSample(
          latitude: 13.0827,
          longitude: 80.2707,
          speed: 12.0,
          heading: 180.0,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        );

    final double distKm = (journey?.distanceRemainingMeters ?? 1000) / 1000.0;
    final String etaString = journey?.estimatedArrival != null
        ? '${journey!.estimatedArrival!.hour.toString().padLeft(2, '0')}:${journey.estimatedArrival!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Scaffold(
      backgroundColor: isDark ? AppColors.inverseSurface : AppColors.background,
      body: Stack(
        children: [
          // Background Interactive Map Layer
          InteractiveMapView(
            currentSample: sample,
            destination: journey?.destination,
            isNightMode: isDark,
          ),

          // Top Header Overlay (Title, Theme Toggle, Debug Simulator)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.onSurface),
                    onPressed: () => context.go('/home'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _forceDarkTheme ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: isDark ? AppColors.primaryFixed : AppColors.primary,
                        ),
                        tooltip: 'Toggle Night Mode',
                        onPressed: () {
                          setState(() => _forceDarkTheme = !_forceDarkTheme);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.bug_report_outlined, color: AppColors.primary),
                        tooltip: 'Simulator',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const SimulationDrawer(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Upper Smart Alert Card
          Positioned(
            top: 100,
            left: AppSpacing.containerMargin,
            right: AppSpacing.containerMargin,
            child: SmartAlertCard(
              statusText: 'SMART ALERT ACTIVE (${journey?.status.name ?? 'monitoring'})',
              mainTitle: 'Waking you at ${distKm.toStringAsFixed(1)}km',
              etaText: 'ETA $etaString',
            ),
          ),

          // Draggable Bottom Sheet Layer
          if (journey != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: JourneyBottomSheet(
                journey: journey,
                onStopJourney: () async {
                  await ref.read(activeJourneyProvider.notifier).stopJourney();
                  if (context.mounted) context.go('/home');
                },
                onDetailsTap: () => context.push('/journey/status'),
              ),
            ),
        ],
      ),
    );
  }
}
