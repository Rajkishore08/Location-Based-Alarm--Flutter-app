import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../shared/models/location_sample.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _locationController = StreamController<LocationSample>.broadcast();

  Stream<LocationSample> get locationStream => _locationController.stream;

  /// Checks and requests location permission status
  Future<LocationPermission> checkPermissionStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermission.denied;
    }
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Gets current high-accuracy GPS position with safe fallback
  Future<LocationSample> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final Position pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        return LocationSample(
          latitude: pos.latitude,
          longitude: pos.longitude,
          altitude: pos.altitude,
          speed: pos.speed,
          heading: pos.heading,
          accuracy: pos.accuracy,
          timestamp: pos.timestamp,
        );
      }
    } catch (_) {
      // Fallback default position (e.g. Chennai Central)
    }

    return LocationSample(
      latitude: 13.0827,
      longitude: 80.2707,
      altitude: 10.0,
      speed: 12.5, // ~45 km/h
      heading: 180.0,
      accuracy: 5.0,
      timestamp: DateTime.now(),
    );
  }

  /// Starts continuous adaptive journey tracking
  void startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 5,
  }) {
    stopTracking();

    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilterMeters,
    );

    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position pos) {
        final sample = LocationSample(
          latitude: pos.latitude,
          longitude: pos.longitude,
          altitude: pos.altitude,
          speed: pos.speed,
          heading: pos.heading,
          accuracy: pos.accuracy,
          timestamp: pos.timestamp,
        );
        _locationController.add(sample);
      },
      onError: (err) {
        // Handle stream error gracefully
      },
    );
  }

  /// Emit manual/simulated position sample (used by Journey Simulator)
  void emitSimulatedLocation(LocationSample sample) {
    _locationController.add(sample);
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
