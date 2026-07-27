import 'dart:math';

class DistanceService {
  const DistanceService();

  /// Calculates geodesic distance between two coordinate points in meters using Haversine formula
  double calculateDistanceMeters({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    const double earthRadiusMeters = 6371000.0; // Earth mean radius

    final double dLat = _toRadians(endLatitude - startLatitude);
    final double dLon = _toRadians(endLongitude - startLongitude);

    final double lat1Rad = _toRadians(startLatitude);
    final double lat2Rad = _toRadians(endLatitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  double calculateDistanceKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return calculateDistanceMeters(
          startLatitude: startLatitude,
          startLongitude: startLongitude,
          endLatitude: endLatitude,
          endLongitude: endLongitude,
        ) /
        1000.0;
  }

  /// Calculates bearing from start to destination in degrees (0 to 360)
  double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final double lat1 = _toRadians(startLatitude);
    final double lat2 = _toRadians(endLatitude);
    final double dLon = _toRadians(endLongitude - startLongitude);

    final double y = sin(dLon) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    final double radians = atan2(y, x);
    final double degrees = (radians * 180.0 / pi + 360.0) % 360.0;
    return degrees;
  }

  double _toRadians(double degree) => degree * pi / 180.0;
}
