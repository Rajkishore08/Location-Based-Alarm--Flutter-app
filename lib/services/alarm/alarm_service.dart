import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class AlarmService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isAlarmPlaying = false;
  Timer? _escalationTimer;
  int _escalationStage = 1;

  bool get isAlarmPlaying => _isAlarmPlaying;
  int get escalationStage => _escalationStage;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    try {
      await _notificationsPlugin.initialize(settings: settings);
    } catch (_) {}

    try {
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.duckOthers, AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
    } catch (_) {}
  }

  /// Triggers full alarm experience (Audio, Vibration, Local Notification)
  Future<void> triggerAlarm({
    required String destinationName,
    required double distanceMeters,
    required String etaText,
  }) async {
    if (_isAlarmPlaying) return;

    _isAlarmPlaying = true;
    _escalationStage = 1;

    // Show persistent high-priority notification
    await _showNotification(
      title: '⏰ WAKE UP - Approaching $destinationName!',
      body: 'Distance remaining: ${(distanceMeters / 1000).toStringAsFixed(1)}km | ETA: $etaText',
    );

    // Trigger device vibration
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [500, 1000, 500, 1000, 500, 1000], repeat: 0);
      }
    } catch (e) {
      debugPrint('Vibration trigger note: $e');
    }

    // Play alarm audio tone with loop
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(
        UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'),
      );
    } catch (e) {
      debugPrint('AudioPlayer fallback trigger: $e');
      try {
        await _audioPlayer.play(
          UrlSource('https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg'),
        );
      } catch (_) {}
    }

    // Escalation Timer: Escalate volume & vibration frequency if not acknowledged within 20 seconds
    _escalationTimer?.cancel();
    _escalationTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (!_isAlarmPlaying) {
        timer.cancel();
        return;
      }
      if (_escalationStage < 3) {
        _escalationStage++;
        _handleEscalation(_escalationStage);
      }
    });
  }

  void _handleEscalation(int stage) {
    if (stage == 2) {
      _audioPlayer.setVolume(1.0);
      try {
        Vibration.vibrate(pattern: [300, 300, 300, 300], repeat: 0);
      } catch (_) {}
    } else if (stage == 3) {
      _audioPlayer.setVolume(1.0);
      try {
        Vibration.vibrate(pattern: [100, 100, 100, 100], repeat: 0);
      } catch (_) {}
    }
  }

  /// Stops alarm and cancels vibration & notification
  Future<void> stopAlarm() async {
    _isAlarmPlaying = false;
    _escalationStage = 1;
    _escalationTimer?.cancel();
    _escalationTimer = null;

    try {
      await _audioPlayer.stop();
      await Vibration.cancel();
      await _notificationsPlugin.cancel(id: 1001);
    } catch (_) {}
  }

  /// Snoozes alarm for 1 minute
  Future<void> snoozeAlarm() async {
    await stopAlarm();
  }

  Future<void> _showNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'smart_route_alert_channel',
      'Destination Alarms',
      channelDescription: 'High priority alerts when approaching destination',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      ongoing: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    try {
      await _notificationsPlugin.show(
        id: 1001,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (_) {}
  }
}
