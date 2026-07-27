import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/models/destination.dart';
import '../../shared/models/journey.dart';
import '../../shared/models/saved_place.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _getUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // User Profile Document Sync
  Future<void> saveUserProfile(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    await userRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'isAnonymous': user.isAnonymous,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Save User Journey History
  Future<void> saveUserJourney(Journey journey) async {
    final uid = _getUserId();
    if (uid == null) return;

    final journeyRef = _db.collection('users').doc(uid).collection('journeys').doc(journey.id);
    await journeyRef.set({
      'id': journey.id,
      'destinationName': journey.destination.name,
      'destinationAddress': journey.destination.address,
      'latitude': journey.destination.latitude,
      'longitude': journey.destination.longitude,
      'status': journey.status.name,
      'startLatitude': journey.startLocation?.latitude,
      'startLongitude': journey.startLocation?.longitude,
      'startTime': journey.startedAt.toIso8601String(),
      'distanceRemainingMeters': journey.distanceRemainingMeters,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Stream User Journeys History
  Stream<List<Map<String, dynamic>>> streamUserJourneys() {
    final uid = _getUserId();
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('journeys')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Save User Saved Place
  Future<void> saveUserPlace(SavedPlace place) async {
    final uid = _getUserId();
    if (uid == null) return;

    final placeRef = _db.collection('users').doc(uid).collection('saved_places').doc(place.id);
    await placeRef.set({
      'id': place.id,
      'name': place.name,
      'category': place.category,
      'destinationName': place.destination.name,
      'address': place.destination.address,
      'latitude': place.destination.latitude,
      'longitude': place.destination.longitude,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Delete Saved Place
  Future<void> deleteUserPlace(String placeId) async {
    final uid = _getUserId();
    if (uid == null) return;

    await _db.collection('users').doc(uid).collection('saved_places').doc(placeId).delete();
  }

  // Stream User Saved Places
  Stream<List<SavedPlace>> streamUserSavedPlaces() {
    final uid = _getUserId();
    if (uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(uid)
        .collection('saved_places')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return SavedPlace(
                id: data['id'] ?? doc.id,
                name: data['name'] ?? 'Saved Place',
                category: data['category'] ?? 'other',
                createdAt: DateTime.now(),
                destination: Destination(
                  id: data['id'] ?? doc.id,
                  name: data['destinationName'] ?? data['name'] ?? 'Destination',
                  address: data['address'] ?? '',
                  latitude: (data['latitude'] as num?)?.toDouble() ?? 13.0827,
                  longitude: (data['longitude'] as num?)?.toDouble() ?? 80.2707,
                ),
              );
            }).toList());
  }
}
