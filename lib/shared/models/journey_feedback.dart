enum AlertTimingFeedback {
  tooEarly,
  perfect,
  tooLate,
}

class JourneyFeedback {
  final String journeyId;
  final AlertTimingFeedback timing;
  final String? note;
  final DateTime timestamp;

  const JourneyFeedback({
    required this.journeyId,
    required this.timing,
    this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'journeyId': journeyId,
        'timing': timing.name,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      };

  factory JourneyFeedback.fromJson(Map<String, dynamic> json) => JourneyFeedback(
        journeyId: json['journeyId'] as String,
        timing: AlertTimingFeedback.values.firstWhere(
          (e) => e.name == json['timing'],
          orElse: () => AlertTimingFeedback.perfect,
        ),
        note: json['note'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
