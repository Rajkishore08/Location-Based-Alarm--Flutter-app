import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../shared/models/alarm_configuration.dart';
import '../../shared/models/destination.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/destination_card.dart';

class SmartAlarmSetupScreen extends ConsumerStatefulWidget {
  final Destination destination;

  const SmartAlarmSetupScreen({super.key, required this.destination});

  @override
  ConsumerState<SmartAlarmSetupScreen> createState() => _SmartAlarmSetupScreenState();
}

class _SmartAlarmSetupScreenState extends ConsumerState<SmartAlarmSetupScreen> {
  AlarmMode _selectedMode = AlarmMode.smartAlert;
  int _leadMinutes = 5;
  double _leadDistanceKm = 1.0;
  bool _vibrationEnabled = true;
  bool _gradualVolume = true;
  String _selectedSound = 'Gentle Chime';

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Smart Alarm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.containerMargin, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Summary Header
            DestinationCard(
              destination: widget.destination,
              onTap: () {},
              isSelected: true,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Mode Selector
            Text(
              'SELECT ALARM TRIGGER MODE',
              style: AppTypography.labelMd.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            _buildModeTile(
              mode: AlarmMode.smartAlert,
              title: 'Adaptive Smart Alert (Recommended)',
              subtitle: 'Continuously evaluates ETA, speed, and trajectory to wake you at the perfect lead time.',
              icon: Icons.auto_awesome_rounded,
            ),
            const SizedBox(height: AppSpacing.md),

            _buildModeTile(
              mode: AlarmMode.timeBeforeArrival,
              title: 'Time Before Arrival',
              subtitle: 'Triggers alarm a fixed number of minutes before estimated arrival time.',
              icon: Icons.timer_rounded,
            ),
            const SizedBox(height: AppSpacing.md),

            _buildModeTile(
              mode: AlarmMode.distanceBeforeArrival,
              title: 'Distance Before Arrival',
              subtitle: 'Triggers alarm when physical distance remaining drops below chosen threshold.',
              icon: Icons.straighten_rounded,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Mode Parameter Controls
            if (_selectedMode == AlarmMode.smartAlert || _selectedMode == AlarmMode.timeBeforeArrival) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alert Lead Time',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '$_leadMinutes Minutes',
                    style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              Slider(
                value: _leadMinutes.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                label: '$_leadMinutes mins',
                activeColor: AppColors.primaryContainer,
                onChanged: (val) => setState(() => _leadMinutes = val.round()),
              ),
            ],

            if (_selectedMode == AlarmMode.distanceBeforeArrival) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alert Distance Radius',
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                    ),
                  ),
                  Text(
                    '${_leadDistanceKm.toStringAsFixed(1)} km',
                    style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              Slider(
                value: _leadDistanceKm,
                min: 0.5,
                max: 10.0,
                divisions: 19,
                label: '${_leadDistanceKm.toStringAsFixed(1)} km',
                activeColor: AppColors.primaryContainer,
                onChanged: (val) => setState(() => _leadDistanceKm = val),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Alarm Preferences & Sound
            Text(
              'ALARM PREFERENCES',
              style: AppTypography.labelMd.copyWith(
                color: isDark ? AppColors.primaryFixed : AppColors.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            SwitchListTile(
              title: const Text('Vibration Pattern'),
              subtitle: const Text('Vibrate device upon alarm activation'),
              value: _vibrationEnabled,
              activeThumbColor: AppColors.primaryContainer,
              onChanged: (val) => setState(() => _vibrationEnabled = val),
            ),

            SwitchListTile(
              title: const Text('Gradual Volume Increase'),
              subtitle: const Text('Softly fade in alarm sound to prevent sudden shock'),
              value: _gradualVolume,
              activeThumbColor: AppColors.primaryContainer,
              onChanged: (val) => setState(() => _gradualVolume = val),
            ),

            ListTile(
              title: const Text('Alarm Tone'),
              subtitle: Text(_selectedSound),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                setState(() {
                  _selectedSound = _selectedSound == 'Gentle Chime' ? 'Transit Chime' : 'Gentle Chime';
                });
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            AppPrimaryButton(
              text: 'Start Smart Journey',
              icon: Icons.navigation_rounded,
              onPressed: () {
                final config = AlarmConfiguration(
                  mode: _selectedMode,
                  leadMinutes: _leadMinutes,
                  leadDistanceKm: _leadDistanceKm,
                  isVibrationEnabled: _vibrationEnabled,
                  soundTone: _selectedSound,
                  gradualVolume: _gradualVolume,
                );

                ref.read(activeJourneyProvider.notifier).startJourney(
                      widget.destination,
                      config: config,
                    );

                context.go('/journey-started');
              },
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTile({
    required AlarmMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedMode == mode;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      borderRadius: AppRadius.borderXl,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryContainer.withValues(alpha: 0.3) : AppColors.surfaceContainerHigh)
              : (isDark ? const Color(0xFF1E2638) : AppColors.surfaceContainerLow),
          borderRadius: AppRadius.borderXl,
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryContainer : AppColors.outline,
              size: 28,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.inverseOnSurface : AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMd.copyWith(
                      color: isDark ? AppColors.outlineVariant : AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primaryContainer : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
