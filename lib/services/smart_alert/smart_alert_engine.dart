import '../../shared/models/journey.dart';
import '../../shared/models/location_sample.dart';
import '../../shared/models/smart_alert_decision.dart';
import 'constraint_validator.dart';
import 'direction_service.dart';
import 'distance_service.dart';
import 'eta_service.dart';
import 'route_deviation_detector.dart';
import 'speed_service.dart';

class SmartAlertEngine {
  final DistanceService distanceService;
  final SpeedService speedService;
  final DirectionService directionService;
  final EtaService etaService;
  final AlertConstraintValidator constraintValidator;
  final RouteDeviationDetector deviationDetector;

  SmartAlertEngine({
    this.distanceService = const DistanceService(),
    SpeedService? speedService,
    this.directionService = const DirectionService(),
    this.etaService = const EtaService(),
    this.constraintValidator = const AlertConstraintValidator(),
    this.deviationDetector = const RouteDeviationDetector(),
  }) : speedService = speedService ?? SpeedService();

  SmartAlertDecision evaluate({
    required Journey journey,
    required LocationSample currentSample,
    LocationSample? previousSample,
  }) {
    speedService.addSample(currentSample);

    final double distanceRemainingMeters = distanceService.calculateDistanceMeters(
      startLatitude: currentSample.latitude,
      startLongitude: currentSample.longitude,
      endLatitude: journey.destination.latitude,
      endLongitude: journey.destination.longitude,
    );

    final double currentSpeedMs = speedService.getCurrentSpeedMs();
    final double averageSpeedMs = speedService.getAverageSpeedMs();
    final double currentSpeedKmh = currentSpeedMs * 3.6;

    final EtaResult etaResult = etaService.calculateEta(
      distanceRemainingMeters: distanceRemainingMeters,
      currentSpeedMs: currentSpeedMs,
      averageSpeedMs: averageSpeedMs,
    );

    final DirectionState directionState = directionService.evaluateDirection(
      previousSample: previousSample,
      currentSample: currentSample,
      destinationLat: journey.destination.latitude,
      destinationLng: journey.destination.longitude,
    );

    // Route deviation detection
    final bool isDeviated = deviationDetector.isDeviated(
      currentSample: currentSample,
      previousSample: previousSample,
      destinationLat: journey.destination.latitude,
      destinationLng: journey.destination.longitude,
    );

    // Score Calculations (0.0 to 1.0)
    // Distance score: higher as remaining distance approaches target lead distance
    final double targetDistanceMeters = journey.alertConfiguration.leadDistanceKm * 1000.0;
    double distanceScore = (1.0 - (distanceRemainingMeters / (targetDistanceMeters * 2))).clamp(0.0, 1.0);

    // ETA score: higher as ETA duration approaches target lead minutes
    final double targetEtaSeconds = journey.alertConfiguration.leadMinutes * 60.0;
    final double currentEtaSeconds = etaResult.etaDuration.inSeconds.toDouble();
    double etaScore = (1.0 - (currentEtaSeconds / (targetEtaSeconds * 2))).clamp(0.0, 1.0);

    // Direction score
    double directionScore;
    switch (directionState) {
      case DirectionState.towardDestination:
        directionScore = 1.0;
        break;
      case DirectionState.stationary:
        directionScore = 0.7;
        break;
      case DirectionState.unknown:
        directionScore = 0.5;
        break;
      case DirectionState.awayFromDestination:
        directionScore = 0.1;
        break;
    }

    // Speed score (valid movement confidence)
    double speedScore = (currentSpeedKmh / 50.0).clamp(0.2, 1.0);

    // Combined confidence score
    final double confidence =
        (0.35 * distanceScore + 0.35 * etaScore + 0.15 * directionScore + 0.15 * speedScore)
            .clamp(0.0, 1.0);

    // Constraint Validation
    final bool constraintsSatisfied = constraintValidator.validateConstraints(
      journey: journey,
      distanceRemainingMeters: distanceRemainingMeters,
      etaDuration: etaResult.etaDuration,
      directionState: directionState,
      currentSpeedKmh: currentSpeedKmh,
    );

    final bool shouldTrigger = constraintsSatisfied && confidence >= 0.65;

    // Status Determination
    SmartAlertStatus status;
    String reason;

    if (distanceRemainingMeters <= 50) {
      status = SmartAlertStatus.arrived;
      reason = 'Destination reached!';
    } else if (shouldTrigger) {
      status = SmartAlertStatus.triggerAlert;
      reason =
          'Destination imminent! Distance: ${(distanceRemainingMeters / 1000).toStringAsFixed(1)}km, ETA: ${etaResult.etaDuration.inMinutes}m';
    } else if (isDeviated) {
      status = SmartAlertStatus.routeDeviation;
      reason = 'Route deviation detected. Recalculating trajectory...';
    } else if (distanceRemainingMeters <= targetDistanceMeters * 1.5) {
      status = SmartAlertStatus.destinationNear;
      reason = 'Approaching destination within ${(distanceRemainingMeters / 1000).toStringAsFixed(1)}km';
    } else {
      status = SmartAlertStatus.trackingNormally;
      reason = 'Tracking normally. Speed: ${currentSpeedKmh.toStringAsFixed(0)} km/h';
    }

    return SmartAlertDecision(
      shouldTrigger: shouldTrigger,
      confidence: confidence,
      recommendedAlertTime: etaResult.estimatedArrivalTime,
      recommendedAlertDistanceMeters: distanceRemainingMeters,
      reason: reason,
      status: status,
      distanceScore: distanceScore,
      etaScore: etaScore,
      directionScore: directionScore,
      speedScore: speedScore,
    );
  }
}
