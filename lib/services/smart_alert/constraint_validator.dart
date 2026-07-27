import '../../shared/models/alarm_configuration.dart';
import '../../shared/models/journey.dart';

import 'direction_service.dart';

class AlertConstraintValidator {
  const AlertConstraintValidator();

  bool validateConstraints({
    required Journey journey,
    required double distanceRemainingMeters,
    required Duration etaDuration,
    required DirectionState directionState,
    required double currentSpeedKmh,
  }) {
    // Constraint 1: Journey must be active and not completed/cancelled/already triggered
    if (journey.status == JourneyStatus.idle ||
        journey.status == JourneyStatus.completed ||
        journey.status == JourneyStatus.cancelled ||
        journey.status == JourneyStatus.alarmTriggered ||
        journey.status == JourneyStatus.alarmEscalated) {
      return false;
    }

    final AlarmConfiguration config = journey.alertConfiguration;

    // Constraint 2: Mode-based threshold checks
    switch (config.mode) {
      case AlarmMode.distanceBeforeArrival:
        final double targetMeters = config.leadDistanceKm * 1000.0;
        if (distanceRemainingMeters > targetMeters) return false;
        break;

      case AlarmMode.timeBeforeArrival:
        final Duration targetEta = Duration(minutes: config.leadMinutes);
        if (etaDuration > targetEta && distanceRemainingMeters > 1500) return false;
        break;

      case AlarmMode.smartAlert:
        // Smart mode evaluates dynamically, but minimum distance threshold is 2000m or ETA <= leadMinutes
        final Duration targetEta = Duration(minutes: config.leadMinutes);
        final double targetMeters = config.leadDistanceKm * 1000.0;
        final bool meetsDistance = distanceRemainingMeters <= targetMeters;
        final bool meetsTime = etaDuration <= targetEta;

        if (!meetsDistance && !meetsTime) {
          return false;
        }
        break;
    }

    // Constraint 3: Direction check - avoid triggering if moving sharply away
    if (directionState == DirectionState.awayFromDestination && distanceRemainingMeters > 800) {
      return false;
    }

    return true;
  }
}
