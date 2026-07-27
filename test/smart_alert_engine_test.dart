import 'package:flutter_test/flutter_test.dart';
import 'package:smart_route_alert/services/smart_alert/smart_alert_engine.dart';
import 'package:smart_route_alert/shared/models/alarm_configuration.dart';
import 'package:smart_route_alert/shared/models/destination.dart';
import 'package:smart_route_alert/shared/models/journey.dart';
import 'package:smart_route_alert/shared/models/location_sample.dart';
import 'package:smart_route_alert/shared/models/smart_alert_decision.dart';

void main() {
  group('SmartAlertEngine Integration Tests', () {
    late SmartAlertEngine engine;

    setUp(() {
      engine = SmartAlertEngine();
    });

    test('Does not trigger alarm when far from destination', () {
      const destination = Destination(
        id: 'central',
        name: 'Chennai Central',
        address: 'Central',
        latitude: 13.0827,
        longitude: 80.2707,
      );

      final journey = Journey(
        id: 'test_1',
        destination: destination,
        startedAt: DateTime.now(),
        status: JourneyStatus.tracking,
        alertConfiguration: const AlarmConfiguration(
          mode: AlarmMode.smartAlert,
          leadDistanceKm: 1.0,
          leadMinutes: 5,
        ),
      );

      // Current sample 15km away
      final sample = LocationSample(
        latitude: 12.9892,
        longitude: 80.2484,
        speed: 15.0, // ~54 km/h
        heading: 0.0,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      final decision = engine.evaluate(journey: journey, currentSample: sample);

      expect(decision.shouldTrigger, isFalse);
      expect(decision.status, equals(SmartAlertStatus.trackingNormally));
    });

    test('Triggers alarm when within target lead distance and approaching', () {
      const destination = Destination(
        id: 'central',
        name: 'Chennai Central',
        address: 'Central',
        latitude: 13.0827,
        longitude: 80.2707,
      );

      final journey = Journey(
        id: 'test_2',
        destination: destination,
        startedAt: DateTime.now(),
        status: JourneyStatus.tracking,
        alertConfiguration: const AlarmConfiguration(
          mode: AlarmMode.smartAlert,
          leadDistanceKm: 1.0,
          leadMinutes: 5,
        ),
      );

      // Current sample ~500m from destination
      final sample = LocationSample(
        latitude: 13.0820,
        longitude: 80.2700,
        speed: 10.0,
        heading: 45.0,
        accuracy: 5.0,
        timestamp: DateTime.now(),
      );

      final prevSample = LocationSample(
        latitude: 13.0780,
        longitude: 80.2650,
        speed: 10.0,
        heading: 45.0,
        accuracy: 5.0,
        timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
      );

      final decision = engine.evaluate(
        journey: journey,
        currentSample: sample,
        previousSample: prevSample,
      );

      expect(decision.shouldTrigger, isTrue);
      expect(decision.status, equals(SmartAlertStatus.triggerAlert));
    });
  });
}
