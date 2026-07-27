import 'package:flutter_test/flutter_test.dart';
import 'package:smart_route_alert/services/smart_alert/distance_service.dart';

void main() {
  group('DistanceService Haversine Calculations', () {
    const distanceService = DistanceService();

    test('Calculates distance between Guindy and Chennai Central correctly', () {
      // Guindy: 13.0067, 80.2020
      // Chennai Central: 13.0827, 80.2707
      final double distanceMeters = distanceService.calculateDistanceMeters(
        startLatitude: 13.0067,
        startLongitude: 80.2020,
        endLatitude: 13.0827,
        endLongitude: 80.2707,
      );

      final double distanceKm = distanceMeters / 1000.0;

      // Distance should be approximately ~11.1 km
      expect(distanceKm, greaterThan(10.0));
      expect(distanceKm, lessThan(12.5));
    });

    test('Calculates zero distance for identical coordinates', () {
      final double dist = distanceService.calculateDistanceMeters(
        startLatitude: 13.0827,
        startLongitude: 80.2707,
        endLatitude: 13.0827,
        endLongitude: 80.2707,
      );

      expect(dist, equals(0.0));
    });
  });
}
