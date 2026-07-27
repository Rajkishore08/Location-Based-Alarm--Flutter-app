import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/models/journey.dart';
import '../../shared/models/journey_feedback.dart';
import '../../shared/models/saved_place.dart';

class LocalStorageService {
  static const String _activeJourneyKey = 'active_journey';
  static const String _journeyHistoryKey = 'journey_history';
  static const String _savedPlacesKey = 'saved_places';
  static const String _feedbackKey = 'journey_feedback';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // Active Journey Recovery
  Future<void> saveActiveJourney(Journey journey) async {
    final String jsonStr = jsonEncode(journey.toJson());
    await _prefs.setString(_activeJourneyKey, jsonStr);
  }

  Journey? getActiveJourney() {
    final String? jsonStr = _prefs.getString(_activeJourneyKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(jsonStr);
      return Journey.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearActiveJourney() async {
    await _prefs.remove(_activeJourneyKey);
  }

  // Journey History
  Future<void> saveJourneyToHistory(Journey journey) async {
    final List<Journey> history = getJourneyHistory();
    history.insert(0, journey);
    final String jsonStr = jsonEncode(history.map((j) => j.toJson()).toList());
    await _prefs.setString(_journeyHistoryKey, jsonStr);
  }

  List<Journey> getJourneyHistory() {
    final String? jsonStr = _prefs.getString(_journeyHistoryKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => Journey.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // Saved Places (User Defined)
  Future<void> savePlace(SavedPlace place) async {
    final List<SavedPlace> places = getSavedPlaces();
    places.removeWhere((p) => p.id == place.id);
    places.insert(0, place);
    final String jsonStr = jsonEncode(places.map((p) => p.toJson()).toList());
    await _prefs.setString(_savedPlacesKey, jsonStr);
  }

  List<SavedPlace> getSavedPlaces() {
    final String? jsonStr = _prefs.getString(_savedPlacesKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => SavedPlace.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteSavedPlace(String id) async {
    final List<SavedPlace> places = getSavedPlaces();
    places.removeWhere((p) => p.id == id);
    final String jsonStr = jsonEncode(places.map((p) => p.toJson()).toList());
    await _prefs.setString(_savedPlacesKey, jsonStr);
  }

  // Feedback History
  Future<void> saveFeedback(JourneyFeedback feedback) async {
    final List<JourneyFeedback> history = getFeedbackHistory();
    history.add(feedback);
    final String jsonStr = jsonEncode(history.map((f) => f.toJson()).toList());
    await _prefs.setString(_feedbackKey, jsonStr);
  }

  List<JourneyFeedback> getFeedbackHistory() {
    final String? jsonStr = _prefs.getString(_feedbackKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => JourneyFeedback.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
