import '../../shared/models/location_sample.dart';

import 'distance_service.dart';

enum DirectionState {
  towardDestination,
  awayFromDestination,
  stationary,
  unknown,
}

class DirectionService {
  final DistanceService distanceService;

  const DirectionService({this.distanceService = const DistanceService()});

  DirectionState evaluateDirection({
    required LocationSample? previousSample,
    required LocationSample currentSample,
    required double destinationLat,
    required double destinationLng,
  }) {
    if (previousSample == null) {
      return DirectionState.unknown;
    }

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

    final double distDelta = prevDist - currDist;

    // Movement threshold: 2 meters
    if (distDelta.abs() < 2.0 && currentSample.speed < 1.0) {
      return DirectionState.stationary;
    }

    if (distDelta > 0.5) {
      return DirectionState.towardDestination;
    } else if (distDelta < -0.5) {
      return DirectionState.awayFromDestination;
    }

    return DirectionState.unknown;
  }
}
