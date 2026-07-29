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

  /// Gets current high-accuracy GPS position with instant last known location fallback
  Future<LocationSample> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        // Fast instant fetch from last known position first
        final Position? lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          // Asynchronously trigger fresh high accuracy fix
          Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 4),
            ),
          ).then((highPos) {
            _locationController.add(LocationSample(
              latitude: highPos.latitude,
              longitude: highPos.longitude,
              altitude: highPos.altitude,
              speed: highPos.speed,
              heading: highPos.heading,
              accuracy: highPos.accuracy,
              timestamp: highPos.timestamp,
            ));
          }).catchError((_) {});

          return LocationSample(
            latitude: lastPos.latitude,
            longitude: lastPos.longitude,
            altitude: lastPos.altitude,
            speed: lastPos.speed,
            heading: lastPos.heading,
            accuracy: lastPos.accuracy,
            timestamp: lastPos.timestamp,
          );
        }

        final Position pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 4),
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
    } catch (_) {}

    return LocationSample(
      latitude: 0.0,
      longitude: 0.0,
      altitude: 0.0,
      speed: 0.0,
      heading: 0.0,
      accuracy: 10.0,
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
      onError: (err) {},
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
