class EtaResult {
  final Duration etaDuration;
  final DateTime estimatedArrivalTime;
  final double confidence; // 0.0 to 1.0

  const EtaResult({
    required this.etaDuration,
    required this.estimatedArrivalTime,
    required this.confidence,
  });
}

class EtaService {
  const EtaService();

  EtaResult calculateEta({
    required double distanceRemainingMeters,
    required double currentSpeedMs,
    required double averageSpeedMs,
    double defaultFallbackSpeedKmh = 35.0, // fallback transit speed ~35km/h
  }) {
    final double defaultSpeedMs = defaultFallbackSpeedKmh / 3.6;

    // Smoothed effective speed: weighted blend of current and rolling average speed
    double effectiveSpeedMs;
    double confidence;

    if (averageSpeedMs > 1.5) {
      effectiveSpeedMs = 0.6 * averageSpeedMs + 0.4 * currentSpeedMs;
      confidence = 0.9;
    } else if (currentSpeedMs > 1.5) {
      effectiveSpeedMs = currentSpeedMs;
      confidence = 0.75;
    } else {
      effectiveSpeedMs = defaultSpeedMs;
      confidence = 0.5;
    }

    if (effectiveSpeedMs <= 0.1) {
      effectiveSpeedMs = defaultSpeedMs;
    }

    final double secondsRemaining = distanceRemainingMeters / effectiveSpeedMs;
    final Duration etaDuration = Duration(seconds: secondsRemaining.round());
    final DateTime estimatedArrivalTime = DateTime.now().add(etaDuration);

    return EtaResult(
      etaDuration: etaDuration,
      estimatedArrivalTime: estimatedArrivalTime,
      confidence: confidence,
    );
  }
}
