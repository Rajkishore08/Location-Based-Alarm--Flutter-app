enum SmartAlertStatus {
  monitoring,
  trackingNormally,
  recalculating,
  routeDeviation,
  destinationNear,
  triggerAlert,
  arrived,
}

class SmartAlertDecision {
  final bool shouldTrigger;
  final double confidence; // 0.0 to 1.0
  final DateTime? recommendedAlertTime;
  final double recommendedAlertDistanceMeters;
  final String reason;
  final SmartAlertStatus status;
  final double distanceScore;
  final double etaScore;
  final double directionScore;
  final double speedScore;

  const SmartAlertDecision({
    required this.shouldTrigger,
    required this.confidence,
    this.recommendedAlertTime,
    required this.recommendedAlertDistanceMeters,
    required this.reason,
    required this.status,
    this.distanceScore = 1.0,
    this.etaScore = 1.0,
    this.directionScore = 1.0,
    this.speedScore = 1.0,
  });

  factory SmartAlertDecision.initial() {
    return const SmartAlertDecision(
      shouldTrigger: false,
      confidence: 1.0,
      recommendedAlertDistanceMeters: 1000,
      reason: 'Journey initialized. Continuous monitoring active.',
      status: SmartAlertStatus.monitoring,
    );
  }
}
