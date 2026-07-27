enum AlarmMode {
  smartAlert,
  timeBeforeArrival,
  distanceBeforeArrival,
}

class AlarmConfiguration {
  final AlarmMode mode;
  final int leadMinutes; // e.g. 2, 5, 10, 15 mins
  final double leadDistanceKm; // e.g. 0.5, 1.0, 2.0, 5.0 km
  final bool isVibrationEnabled;
  final String soundTone;
  final bool gradualVolume;
  final bool repeatUntilAwake;

  const AlarmConfiguration({
    this.mode = AlarmMode.smartAlert,
    this.leadMinutes = 5,
    this.leadDistanceKm = 1.0,
    this.isVibrationEnabled = true,
    this.soundTone = 'Gentle Chime',
    this.gradualVolume = true,
    this.repeatUntilAwake = true,
  });

  AlarmConfiguration copyWith({
    AlarmMode? mode,
    int? leadMinutes,
    double? leadDistanceKm,
    bool? isVibrationEnabled,
    String? soundTone,
    bool? gradualVolume,
    bool? repeatUntilAwake,
  }) {
    return AlarmConfiguration(
      mode: mode ?? this.mode,
      leadMinutes: leadMinutes ?? this.leadMinutes,
      leadDistanceKm: leadDistanceKm ?? this.leadDistanceKm,
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      soundTone: soundTone ?? this.soundTone,
      gradualVolume: gradualVolume ?? this.gradualVolume,
      repeatUntilAwake: repeatUntilAwake ?? this.repeatUntilAwake,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'leadMinutes': leadMinutes,
        'leadDistanceKm': leadDistanceKm,
        'isVibrationEnabled': isVibrationEnabled,
        'soundTone': soundTone,
        'gradualVolume': gradualVolume,
        'repeatUntilAwake': repeatUntilAwake,
      };

  factory AlarmConfiguration.fromJson(Map<String, dynamic> json) => AlarmConfiguration(
        mode: AlarmMode.values.firstWhere(
          (e) => e.name == json['mode'],
          orElse: () => AlarmMode.smartAlert,
        ),
        leadMinutes: json['leadMinutes'] as int? ?? 5,
        leadDistanceKm: (json['leadDistanceKm'] as num? ?? 1.0).toDouble(),
        isVibrationEnabled: json['isVibrationEnabled'] as bool? ?? true,
        soundTone: json['soundTone'] as String? ?? 'Gentle Chime',
        gradualVolume: json['gradualVolume'] as bool? ?? true,
        repeatUntilAwake: json['repeatUntilAwake'] as bool? ?? true,
      );
}
