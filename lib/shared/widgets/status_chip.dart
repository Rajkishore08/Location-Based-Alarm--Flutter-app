import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../models/smart_alert_decision.dart';

class StatusChip extends StatelessWidget {
  final SmartAlertStatus status;

  const StatusChip({super.key, required this.status});

  Color _getBgColor() {
    switch (status) {
      case SmartAlertStatus.monitoring:
      case SmartAlertStatus.trackingNormally:
        return AppColors.surfaceContainerHigh;
      case SmartAlertStatus.destinationNear:
        return AppColors.secondaryContainer;
      case SmartAlertStatus.recalculating:
      case SmartAlertStatus.routeDeviation:
        return AppColors.warning.withValues(alpha: 0.2);
      case SmartAlertStatus.triggerAlert:
      case SmartAlertStatus.arrived:
        return AppColors.errorContainer;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case SmartAlertStatus.monitoring:
      case SmartAlertStatus.trackingNormally:
        return AppColors.primary;
      case SmartAlertStatus.destinationNear:
        return Colors.white;
      case SmartAlertStatus.recalculating:
      case SmartAlertStatus.routeDeviation:
        return AppColors.warning;
      case SmartAlertStatus.triggerAlert:
      case SmartAlertStatus.arrived:
        return AppColors.onErrorContainer;
    }
  }

  String _getLabel() {
    switch (status) {
      case SmartAlertStatus.monitoring:
        return 'MONITORING';
      case SmartAlertStatus.trackingNormally:
        return 'TRACKING NORMALLY';
      case SmartAlertStatus.destinationNear:
        return 'DESTINATION NEAR';
      case SmartAlertStatus.recalculating:
        return 'RECALCULATING';
      case SmartAlertStatus.routeDeviation:
        return 'ROUTE DEVIATION';
      case SmartAlertStatus.triggerAlert:
        return 'ALARM TRIGGERED';
      case SmartAlertStatus.arrived:
        return 'ARRIVED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: _getBgColor(),
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        _getLabel(),
        style: AppTypography.labelMd.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
