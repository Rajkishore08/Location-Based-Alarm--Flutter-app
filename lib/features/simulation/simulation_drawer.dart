import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/providers/app_providers.dart';

class SimulationDrawer extends ConsumerWidget {
  const SimulationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simState = ref.watch(simulationProvider);
    final activeJourneyState = ref.watch(activeJourneyProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.inverseSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.bug_report_rounded, color: AppColors.inversePrimary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Journey Simulator (Debug)',
                    style: AppTypography.headlineMd.copyWith(color: AppColors.primaryFixed),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Simulate GPS progress & traffic conditions without moving physical location.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.outlineVariant),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (activeJourneyState.journey == null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: AppRadius.borderLg,
              ),
              child: Text(
                'Please select a destination and start a journey first to simulate travel.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.warning),
              ),
            )
          else ...[
            Text(
              'PRESET SCENARIOS',
              style: AppTypography.labelMd.copyWith(color: AppColors.primaryFixed),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildScenarioChip(ref, simState, 'BUS NORMAL', Icons.directions_bus_rounded),
                _buildScenarioChip(ref, simState, 'TRAIN FAST', Icons.train_rounded),
                _buildScenarioChip(ref, simState, 'HEAVY TRAFFIC', Icons.traffic_rounded),
                _buildScenarioChip(ref, simState, 'ROUTE DEVIATION', Icons.alt_route_rounded),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (simState.isSimulating) ...[
              LinearProgressIndicator(
                value: simState.progress,
                backgroundColor: Colors.white24,
                color: AppColors.secondaryContainer,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Simulating ${simState.scenario}...',
                    style: AppTypography.bodyMd.copyWith(color: Colors.white),
                  ),
                  Text(
                    '${(simState.progress * 100).toStringAsFixed(0)}%',
                    style: AppTypography.labelMd.copyWith(color: AppColors.inversePrimary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () {
                  ref.read(simulationProvider.notifier).stopSimulation();
                },
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Stop Simulation'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildScenarioChip(
      WidgetRef ref, SimulationState simState, String scenario, IconData icon) {
    final bool isSelected = simState.isSimulating && simState.scenario == scenario;

    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.inversePrimary),
      label: Text(scenario),
      selected: isSelected,
      selectedColor: AppColors.primaryContainer,
      backgroundColor: Colors.white10,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.inverseOnSurface,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        ref.read(simulationProvider.notifier).startSimulation(scenario);
      },
    );
  }
}
