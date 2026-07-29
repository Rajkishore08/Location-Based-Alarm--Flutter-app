import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../shared/models/destination.dart';
import '../../shared/models/saved_place.dart';
import '../search/places_service.dart';

class VoiceCommandResult {
  final bool success;
  final String userQuery;
  final String aiResponse;
  final Destination? targetDestination;
  final double leadDistanceMeters;
  final bool isCancelCommand;

  VoiceCommandResult({
    required this.success,
    required this.userQuery,
    required this.aiResponse,
    this.targetDestination,
    this.leadDistanceMeters = 1500,
    this.isCancelCommand = false,
  });
}

class VoiceAssistantService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final PlacesService _placesService;

  bool _isInitialized = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  VoiceAssistantService({PlacesService? placesService})
      : _placesService = placesService ?? PlacesService();

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _isInitialized = await _speech.initialize(
        onError: (val) => debugPrint('STT Error: $val'),
        onStatus: (val) => debugPrint('STT Status: $val'),
      );

      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('VoiceAssistantService init error: $e');
    }
  }

  /// Start listening to user voice input
  Future<void> listen({
    required Function(String text) onResult,
    required VoidCallback onComplete,
  }) async {
    await initialize();
    if (!_isInitialized && !kIsWeb) return;

    _isListening = true;
    try {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            _isListening = false;
            onComplete();
          }
        },
      );
    } catch (e) {
      _isListening = false;
      onComplete();
    }
  }

  /// Stop speech listening
  Future<void> stopListening() async {
    _isListening = false;
    try {
      await _speech.stop();
    } catch (_) {}
  }

  /// Speaks text via TTS engine
  Future<void> speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// Parse natural voice commands into actionable alarm intents
  Future<VoiceCommandResult> processVoiceCommand({
    required String voiceInput,
    required List<SavedPlace> savedPlaces,
  }) async {
    final String cleanInput = voiceInput.trim().toLowerCase();
    if (cleanInput.isEmpty) {
      const response = "I couldn't hear any command. Please try speaking again!";
      await speak(response);
      return VoiceCommandResult(success: false, userQuery: voiceInput, aiResponse: response);
    }

    // Cancel / Stop command check
    if (cleanInput.contains('cancel') || cleanInput.contains('stop') || cleanInput.contains('disable')) {
      const response = "Yeah! Active location alarm has been canceled. Safe travels!";
      await speak(response);
      return VoiceCommandResult(
        success: true,
        userQuery: voiceInput,
        aiResponse: response,
        isCancelCommand: true,
      );
    }

    // Extract lead distance if mentioned (e.g., "1 km", "2 km", "500 meters")
    double leadDistanceMeters = 1500;
    if (cleanInput.contains('500') || cleanInput.contains('half km')) {
      leadDistanceMeters = 500;
    } else if (cleanInput.contains('1 km') || cleanInput.contains('one km') || cleanInput.contains('1km')) {
      leadDistanceMeters = 1000;
    } else if (cleanInput.contains('2 km') || cleanInput.contains('two km') || cleanInput.contains('2km')) {
      leadDistanceMeters = 2000;
    } else if (cleanInput.contains('3 km') || cleanInput.contains('three km') || cleanInput.contains('3km')) {
      leadDistanceMeters = 3000;
    } else if (cleanInput.contains('5 km') || cleanInput.contains('five km') || cleanInput.contains('5km')) {
      leadDistanceMeters = 5000;
    }

    // Search matching saved place first (Home, Office, Work, etc.)
    SavedPlace? matchedSavedPlace;
    for (final place in savedPlaces) {
      final placeName = place.name.toLowerCase();
      final destName = place.destination.name.toLowerCase();
      final category = place.category.toLowerCase();

      if (cleanInput.contains(placeName) ||
          cleanInput.contains(destName) ||
          cleanInput.contains(category) ||
          (category == 'work' && (cleanInput.contains('office') || cleanInput.contains('job'))) ||
          (category == 'home' && (cleanInput.contains('house') || cleanInput.contains('my place')))) {
        matchedSavedPlace = place;
        break;
      }
    }

    if (matchedSavedPlace != null) {
      final double distKm = leadDistanceMeters / 1000.0;
      final response = "Yeah! All set done for your ${matchedSavedPlace.name} location. Smart alert set for ${distKm.toStringAsFixed(1)} km before arrival!";
      await speak(response);
      return VoiceCommandResult(
        success: true,
        userQuery: voiceInput,
        aiResponse: response,
        targetDestination: matchedSavedPlace.destination,
        leadDistanceMeters: leadDistanceMeters,
      );
    }

    // If not in saved places, perform dynamic Nominatim location search
    String searchQuery = cleanInput
        .replaceAll('set', '')
        .replaceAll('alarm', '')
        .replaceAll('reminder', '')
        .replaceAll('alert', '')
        .replaceAll('for', '')
        .replaceAll('to', '')
        .replaceAll('when i reach', '')
        .replaceAll('buddy', '')
        .replaceAll('hey', '')
        .trim();

    if (searchQuery.isNotEmpty) {
      final searchResults = await _placesService.searchDestinations(searchQuery);
      if (searchResults.isNotEmpty) {
        final target = searchResults.first;
        final double distKm = leadDistanceMeters / 1000.0;
        final response = "Yeah! All set done for ${target.name}. Smart alert configured for ${distKm.toStringAsFixed(1)} km lead distance!";
        await speak(response);
        return VoiceCommandResult(
          success: true,
          userQuery: voiceInput,
          aiResponse: response,
          targetDestination: target,
          leadDistanceMeters: leadDistanceMeters,
        );
      }
    }

    const fallbackResponse = "I couldn't identify that location. Try saying 'Hey buddy set alarm for Home' or 'Set alert for Office'!";
    await speak(fallbackResponse);
    return VoiceCommandResult(
      success: false,
      userQuery: voiceInput,
      aiResponse: fallbackResponse,
    );
  }
}
