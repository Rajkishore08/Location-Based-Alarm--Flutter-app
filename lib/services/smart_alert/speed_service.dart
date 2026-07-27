import '../../shared/models/location_sample.dart';

class SpeedService {
  final int windowSize;
  final List<LocationSample> _window = [];

  SpeedService({this.windowSize = 5});

  void addSample(LocationSample sample) {
    _window.add(sample);
    if (_window.length > windowSize) {
      _window.removeAt(0);
    }
  }

  void clear() {
    _window.clear();
  }

  /// Current speed in m/s filtered for spikes
  double getCurrentSpeedMs() {
    if (_window.isEmpty) return 0.0;

    final LocationSample latest = _window.last;
    // Reject negative or implausibly high speeds (> 300 m/s ~ 1080 km/h)
    if (latest.speed < 0 || latest.speed > 300) {
      return getAverageSpeedMs();
    }
    return latest.speed;
  }

  double getCurrentSpeedKmh() => getCurrentSpeedMs() * 3.6;

  /// Rolling average speed in m/s across sample window
  double getAverageSpeedMs() {
    if (_window.isEmpty) return 0.0;

    final validSamples = _window.where((s) => s.speed >= 0 && s.speed <= 300).toList();
    if (validSamples.isEmpty) return 0.0;

    final double sum = validSamples.fold(0.0, (prev, s) => prev + s.speed);
    return sum / validSamples.length;
  }

  double getAverageSpeedKmh() => getAverageSpeedMs() * 3.6;

  /// Returns true if the user is stationary (speed < 0.8 m/s ~ 3 km/h)
  bool isStationary() {
    return getAverageSpeedMs() < 0.8;
  }
}
