import 'destination.dart';

import 'alarm_configuration.dart';
import 'journey_feedback.dart';
import 'location_sample.dart';

enum JourneyStatus {
  idle,
  started,
  tracking,
  recalculating,
  routeDeviation,
  approaching,
  alarmTriggered,
  alarmEscalated,
  snoozed,
  completed,
  cancelled,
}

class Journey {
  final String id;
  final Destination destination;
  final LocationSample? startLocation;
  final LocationSample? currentLocation;
  final DateTime startedAt;
  final DateTime? completedAt;
  final double distanceTravelledMeters;
  final double distanceRemainingMeters;
  final DateTime? estimatedArrival;
  final double currentSpeedKmh;
  final double averageSpeedKmh;
  final AlarmConfiguration alertConfiguration;
  final DateTime? alertTriggeredAt;
  final double? alertTriggeredDistanceMeters;
  final Duration? alertTriggeredEta;
  final JourneyStatus status;
  final JourneyFeedback? feedback;

  const Journey({
    required this.id,
    required this.destination,
    this.startLocation,
    this.currentLocation,
    required this.startedAt,
    this.completedAt,
    this.distanceTravelledMeters = 0.0,
    this.distanceRemainingMeters = 0.0,
    this.estimatedArrival,
    this.currentSpeedKmh = 0.0,
    this.averageSpeedKmh = 0.0,
    this.alertConfiguration = const AlarmConfiguration(),
    this.alertTriggeredAt,
    this.alertTriggeredDistanceMeters,
    this.alertTriggeredEta,
    this.status = JourneyStatus.idle,
    this.feedback,
  });

  Journey copyWith({
    String? id,
    Destination? destination,
    LocationSample? startLocation,
    LocationSample? currentLocation,
    DateTime? startedAt,
    DateTime? completedAt,
    double? distanceTravelledMeters,
    double? distanceRemainingMeters,
    DateTime? estimatedArrival,
    double? currentSpeedKmh,
    double? averageSpeedKmh,
    AlarmConfiguration? alertConfiguration,
    DateTime? alertTriggeredAt,
    double? alertTriggeredDistanceMeters,
    Duration? alertTriggeredEta,
    JourneyStatus? status,
    JourneyFeedback? feedback,
  }) {
    return Journey(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      startLocation: startLocation ?? this.startLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      distanceTravelledMeters: distanceTravelledMeters ?? this.distanceTravelledMeters,
      distanceRemainingMeters: distanceRemainingMeters ?? this.distanceRemainingMeters,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      alertConfiguration: alertConfiguration ?? this.alertConfiguration,
      alertTriggeredAt: alertTriggeredAt ?? this.alertTriggeredAt,
      alertTriggeredDistanceMeters: alertTriggeredDistanceMeters ?? this.alertTriggeredDistanceMeters,
      alertTriggeredEta: alertTriggeredEta ?? this.alertTriggeredEta,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'destination': destination.toJson(),
        'startLocation': startLocation?.toJson(),
        'currentLocation': currentLocation?.toJson(),
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'distanceTravelledMeters': distanceTravelledMeters,
        'distanceRemainingMeters': distanceRemainingMeters,
        'estimatedArrival': estimatedArrival?.toIso8601String(),
        'currentSpeedKmh': currentSpeedKmh,
        'averageSpeedKmh': averageSpeedKmh,
        'alertConfiguration': alertConfiguration.toJson(),
        'alertTriggeredAt': alertTriggeredAt?.toIso8601String(),
        'alertTriggeredDistanceMeters': alertTriggeredDistanceMeters,
        'alertTriggeredEtaInSeconds': alertTriggeredEta?.inSeconds,
        'status': status.name,
        'feedback': feedback?.toJson(),
      };

  factory Journey.fromJson(Map<String, dynamic> json) => Journey(
        id: json['id'] as String,
        destination: Destination.fromJson(json['destination'] as Map<String, dynamic>),
        startLocation: json['startLocation'] != null
            ? LocationSample.fromJson(json['startLocation'] as Map<String, dynamic>)
            : null,
        currentLocation: json['currentLocation'] != null
            ? LocationSample.fromJson(json['currentLocation'] as Map<String, dynamic>)
            : null,
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
        distanceTravelledMeters: (json['distanceTravelledMeters'] as num? ?? 0.0).toDouble(),
        distanceRemainingMeters: (json['distanceRemainingMeters'] as num? ?? 0.0).toDouble(),
        estimatedArrival:
            json['estimatedArrival'] != null ? DateTime.parse(json['estimatedArrival'] as String) : null,
        currentSpeedKmh: (json['currentSpeedKmh'] as num? ?? 0.0).toDouble(),
        averageSpeedKmh: (json['averageSpeedKmh'] as num? ?? 0.0).toDouble(),
        alertConfiguration: json['alertConfiguration'] != null
            ? AlarmConfiguration.fromJson(json['alertConfiguration'] as Map<String, dynamic>)
            : const AlarmConfiguration(),
        alertTriggeredAt:
            json['alertTriggeredAt'] != null ? DateTime.parse(json['alertTriggeredAt'] as String) : null,
        alertTriggeredDistanceMeters: json['alertTriggeredDistanceMeters'] != null
            ? (json['alertTriggeredDistanceMeters'] as num).toDouble()
            : null,
        alertTriggeredEta: json['alertTriggeredEtaInSeconds'] != null
            ? Duration(seconds: json['alertTriggeredEtaInSeconds'] as int)
            : null,
        status: JourneyStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => JourneyStatus.idle,
        ),
        feedback: json['feedback'] != null
            ? JourneyFeedback.fromJson(json['feedback'] as Map<String, dynamic>)
            : null,
      );
}
