import '../../shared/models/location_sample.dart';

import 'distance_service.dart';

class RouteDeviationDetector {
  final DistanceService distanceService;
  final double deviationThresholdMeters;

  const RouteDeviationDetector({
    this.distanceService = const DistanceService(),
    this.deviationThresholdMeters = 500.0,
  });

  /// Evaluates if user has deviated significantly from destination vector or expected route
  bool isDeviated({
    required LocationSample currentSample,
    required LocationSample? previousSample,
    required double destinationLat,
    required double destinationLng,
  }) {
    if (previousSample == null) return false;

    final double prevDist = distanceService.calculateDistanceMeters(
      startLatitude: previousSample.latitude,
      startLongitude: previousSample.longitude,
      endLatitude: destinationLat,
      endLongitude: destinationLng,
    );

    final double currDist = distanceService.calculateDistanceMeters(
      startLatitude: currentSample.latitude,
      startLongitude: currentSample.longitude,
      endLatitude: destinationLat,
      endLongitude: destinationLng,
    );

    // If distance increased by more than threshold while traveling at significant speed
    final double distDelta = currDist - prevDist;
    if (distDelta > deviationThresholdMeters && currentSample.speed > 5.0) {
      return true;
    }

    return false;
  }
}
