class LocationSample {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed; // m/s
  final double heading; // degrees
  final double accuracy; // meters
  final DateTime timestamp;

  const LocationSample({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
    required this.speed,
    required this.heading,
    required this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'speed': speed,
        'heading': heading,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LocationSample.fromJson(Map<String, dynamic> json) => LocationSample(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        altitude: (json['altitude'] as num? ?? 0.0).toDouble(),
        speed: (json['speed'] as num).toDouble(),
        heading: (json['heading'] as num).toDouble(),
        accuracy: (json['accuracy'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
