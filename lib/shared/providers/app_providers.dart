import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/alarm/alarm_service.dart';
import '../../services/auth/auth_service.dart';
import '../../services/database/firestore_service.dart';
import '../../services/location/location_service.dart';
import '../../services/search/places_service.dart';
import '../../services/smart_alert/distance_service.dart';
import '../../services/smart_alert/smart_alert_engine.dart';
import '../../services/storage/local_storage_service.dart';

import '../models/alarm_configuration.dart';
import '../models/destination.dart';
import '../models/journey.dart';
import '../models/journey_feedback.dart';
import '../models/location_sample.dart';
import '../models/saved_place.dart';
import '../models/smart_alert_decision.dart';

// Service Providers
final storageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in ProviderScope');
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final alarmServiceProvider = Provider<AlarmService>((ref) {
  return AlarmService();
});

final placesServiceProvider = Provider<PlacesService>((ref) {
  return PlacesService();
});

final smartAlertEngineProvider = Provider<SmartAlertEngine>((ref) {
  return SmartAlertEngine();
});

// Saved Places Notifier
class SavedPlacesNotifier extends Notifier<List<SavedPlace>> {
  @override
  List<SavedPlace> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getSavedPlaces();
  }

  void loadPlaces() {
    final storage = ref.read(storageServiceProvider);
    state = storage.getSavedPlaces();
  }

  Future<void> addPlace(SavedPlace place) async {
    final storage = ref.read(storageServiceProvider);
    await storage.savePlace(place);
    loadPlaces();
  }

  Future<void> deletePlace(String id) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteSavedPlace(id);
    loadPlaces();
  }
}

final savedPlacesProvider = NotifierProvider<SavedPlacesNotifier, List<SavedPlace>>(SavedPlacesNotifier.new);

// History Notifier
class JourneyHistoryNotifier extends Notifier<List<Journey>> {
  @override
  List<Journey> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getJourneyHistory();
  }

  void loadHistory() {
    final storage = ref.read(storageServiceProvider);
    state = storage.getJourneyHistory();
  }

  Future<void> addJourney(Journey journey) async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveJourneyToHistory(journey);
    loadHistory();
  }
}

final journeyHistoryProvider = NotifierProvider<JourneyHistoryNotifier, List<Journey>>(JourneyHistoryNotifier.new);

// Active Journey State & Notifier
class ActiveJourneyState {
  final Journey? journey;
  final SmartAlertDecision? decision;
  final LocationSample? currentSample;
  final bool isTracking;

  const ActiveJourneyState({
    this.journey,
    this.decision,
    this.currentSample,
    this.isTracking = false,
  });

  ActiveJourneyState copyWith({
    Journey? journey,
    SmartAlertDecision? decision,
    LocationSample? currentSample,
    bool? isTracking,
  }) {
    return ActiveJourneyState(
      journey: journey ?? this.journey,
      decision: decision ?? this.decision,
      currentSample: currentSample ?? this.currentSample,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}

class ActiveJourneyNotifier extends Notifier<ActiveJourneyState> {
  StreamSubscription<LocationSample>? _locationSub;

  @override
  ActiveJourneyState build() {
    ref.onDispose(() => _locationSub?.cancel());
    final storage = ref.read(storageServiceProvider);
    final restored = storage.getActiveJourney();
    if (restored != null && restored.status != JourneyStatus.completed && restored.status != JourneyStatus.cancelled) {
      Future.microtask(() => startJourney(restored.destination, config: restored.alertConfiguration, restoredJourney: restored));
    }
    return const ActiveJourneyState();
  }

  Future<void> startJourney(Destination destination, {AlarmConfiguration? config, Journey? restoredJourney}) async {
    final locationService = ref.read(locationServiceProvider);
    final storage = ref.read(storageServiceProvider);

    final LocationSample startSample = await locationService.getCurrentLocation();
    final String journeyId = restoredJourney?.id ?? 'jny_${DateTime.now().millisecondsSinceEpoch}';

    final initialJourney = restoredJourney ??
        Journey(
          id: journeyId,
          destination: destination,
          startLocation: startSample,
          currentLocation: startSample,
          startedAt: DateTime.now(),
          distanceRemainingMeters: const DistanceService().calculateDistanceMeters(
            startLatitude: startSample.latitude,
            startLongitude: startSample.longitude,
            endLatitude: destination.latitude,
            endLongitude: destination.longitude,
          ),
          alertConfiguration: config ?? const AlarmConfiguration(),
          status: JourneyStatus.tracking,
        );

    state = ActiveJourneyState(
      journey: initialJourney,
      currentSample: startSample,
      isTracking: true,
      decision: SmartAlertDecision.initial(),
    );

    await storage.saveActiveJourney(initialJourney);

    _locationSub?.cancel();
    locationService.startTracking();
    _locationSub = locationService.locationStream.listen((sample) {
      _onLocationUpdated(sample);
    });
  }

  void _onLocationUpdated(LocationSample sample) {
    if (state.journey == null || !state.isTracking) return;

    final engine = ref.read(smartAlertEngineProvider);
    final storage = ref.read(storageServiceProvider);
    final Journey currentJourney = state.journey!;
    final LocationSample? prevSample = state.currentSample;

    final SmartAlertDecision decision = engine.evaluate(
      journey: currentJourney,
      currentSample: sample,
      previousSample: prevSample,
    );

    final double distRemaining = decision.recommendedAlertDistanceMeters;
    final double distTravelled = currentJourney.startLocation != null
        ? const DistanceService().calculateDistanceMeters(
            startLatitude: currentJourney.startLocation!.latitude,
            startLongitude: currentJourney.startLocation!.longitude,
            endLatitude: sample.latitude,
            endLongitude: sample.longitude,
          )
        : 0.0;

    JourneyStatus nextStatus = currentJourney.status;
    if (decision.status == SmartAlertStatus.triggerAlert && currentJourney.status != JourneyStatus.alarmTriggered) {
      nextStatus = JourneyStatus.alarmTriggered;
      _triggerAlarm(currentJourney, distRemaining, decision.reason);
    } else if (decision.status == SmartAlertStatus.routeDeviation) {
      nextStatus = JourneyStatus.routeDeviation;
    } else if (decision.status == SmartAlertStatus.destinationNear) {
      nextStatus = JourneyStatus.approaching;
    } else if (decision.status == SmartAlertStatus.arrived) {
      nextStatus = JourneyStatus.completed;
      stopJourney();
      return;
    }

    final updatedJourney = currentJourney.copyWith(
      currentLocation: sample,
      distanceRemainingMeters: distRemaining,
      distanceTravelledMeters: distTravelled,
      estimatedArrival: decision.recommendedAlertTime,
      currentSpeedKmh: sample.speed * 3.6,
      status: nextStatus,
    );

    state = state.copyWith(
      journey: updatedJourney,
      currentSample: sample,
      decision: decision,
    );

    storage.saveActiveJourney(updatedJourney);
  }

  Future<void> _triggerAlarm(Journey journey, double distanceMeters, String reason) async {
    final alarmService = ref.read(alarmServiceProvider);
    final String etaStr = journey.estimatedArrival != null
        ? '${journey.estimatedArrival!.hour.toString().padLeft(2, '0')}:${journey.estimatedArrival!.minute.toString().padLeft(2, '0')}'
        : 'Immediate';

    await alarmService.triggerAlarm(
      destinationName: journey.destination.name,
      distanceMeters: distanceMeters,
      etaText: etaStr,
    );
  }

  Future<void> snoozeAlarm() async {
    final alarmService = ref.read(alarmServiceProvider);
    await alarmService.snoozeAlarm();
    if (state.journey != null) {
      final updated = state.journey!.copyWith(status: JourneyStatus.snoozed);
      state = state.copyWith(journey: updated);
    }
  }

  Future<void> acknowledgeAlarm() async {
    final alarmService = ref.read(alarmServiceProvider);
    final storage = ref.read(storageServiceProvider);
    await alarmService.stopAlarm();

    if (state.journey != null) {
      final updated = state.journey!.copyWith(
        status: JourneyStatus.completed,
        completedAt: DateTime.now(),
      );
      state = state.copyWith(journey: updated);
      await ref.read(journeyHistoryProvider.notifier).addJourney(updated);
      await storage.clearActiveJourney();
    }
  }

  Future<void> stopJourney() async {
    final alarmService = ref.read(alarmServiceProvider);
    final locationService = ref.read(locationServiceProvider);
    final storage = ref.read(storageServiceProvider);

    await alarmService.stopAlarm();
    _locationSub?.cancel();
    locationService.stopTracking();

    if (state.journey != null) {
      final completed = state.journey!.copyWith(
        status: JourneyStatus.completed,
        completedAt: DateTime.now(),
      );
      await ref.read(journeyHistoryProvider.notifier).addJourney(completed);
      await storage.clearActiveJourney();
    }

    state = const ActiveJourneyState();
  }

  Future<void> submitFeedback(AlertTimingFeedback timing) async {
    final storage = ref.read(storageServiceProvider);
    if (state.journey != null) {
      final feedback = JourneyFeedback(
        journeyId: state.journey!.id,
        timing: timing,
        timestamp: DateTime.now(),
      );
      await storage.saveFeedback(feedback);
    }
  }
}

final activeJourneyProvider = NotifierProvider<ActiveJourneyNotifier, ActiveJourneyState>(ActiveJourneyNotifier.new);

// Journey Simulator Notifier
class SimulationState {
  final bool isSimulating;
  final String scenario;
  final double progress;

  const SimulationState({
    this.isSimulating = false,
    this.scenario = 'BUS NORMAL',
    this.progress = 0.0,
  });

  SimulationState copyWith({
    bool? isSimulating,
    String? scenario,
    double? progress,
  }) {
    return SimulationState(
      isSimulating: isSimulating ?? this.isSimulating,
      scenario: scenario ?? this.scenario,
      progress: progress ?? this.progress,
    );
  }
}

class SimulationNotifier extends Notifier<SimulationState> {
  Timer? _simTimer;

  @override
  SimulationState build() {
    ref.onDispose(() => _simTimer?.cancel());
    return const SimulationState();
  }

  void startSimulation(String scenario) {
    stopSimulation();
    state = SimulationState(isSimulating: true, scenario: scenario, progress: 0.0);

    const int totalSteps = 20;
    int currentStep = 0;

    _simTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      currentStep++;
      final double progress = currentStep / totalSteps;

      if (currentStep >= totalSteps) {
        stopSimulation();
        return;
      }

      state = state.copyWith(progress: progress);

      final activeState = ref.read(activeJourneyProvider);
      if (activeState.journey != null) {
        final startLat = activeState.journey!.startLocation?.latitude ?? 13.0827;
        final startLng = activeState.journey!.startLocation?.longitude ?? 80.2707;
        final destLat = activeState.journey!.destination.latitude;
        final destLng = activeState.journey!.destination.longitude;

        double currentLat = startLat + (destLat - startLat) * progress;
        double currentLng = startLng + (destLng - startLng) * progress;
        double speedMs = 12.0;

        if (scenario == 'TRAIN FAST') speedMs = 25.0;
        if (scenario == 'HEAVY TRAFFIC') speedMs = 3.0;
        if (scenario == 'ROUTE DEVIATION' && currentStep > 8 && currentStep < 14) {
          currentLat += 0.02;
        }

        final simSample = LocationSample(
          latitude: currentLat,
          longitude: currentLng,
          speed: speedMs,
          heading: 180.0,
          accuracy: 5.0,
          timestamp: DateTime.now(),
        );

        ref.read(locationServiceProvider).emitSimulatedLocation(simSample);
      }
    });
  }

  void stopSimulation() {
    _simTimer?.cancel();
    _simTimer = null;
    state = const SimulationState();
  }
}

final simulationProvider = NotifierProvider<SimulationNotifier, SimulationState>(SimulationNotifier.new);
