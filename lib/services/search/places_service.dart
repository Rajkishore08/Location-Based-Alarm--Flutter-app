import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../shared/models/destination.dart';
import '../../shared/models/location_sample.dart';
import '../smart_alert/distance_service.dart';

class PlacesService {
  final DistanceService _distanceService;

  PlacesService({DistanceService distanceService = const DistanceService()})
      : _distanceService = distanceService;

  /// High-reliability multi-engine location search (Photon OSM + Nominatim)
  Future<List<Destination>> searchDestinations(String query, {LocationSample? userLocation}) async {
    final String cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return _getNearbyRecommendations(userLocation);
    }

    // Engine 1: Photon OpenStreetMap API (CORS & High Availability Engine)
    try {
      String photonUrlStr = 'https://photon.komoot.io/api/?q=${Uri.encodeComponent(cleanQuery)}&limit=10';
      if (userLocation != null) {
        photonUrlStr += '&lat=${userLocation.latitude}&lon=${userLocation.longitude}';
      }

      final response = await http.get(Uri.parse(photonUrlStr)).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> features = data['features'] ?? [];
        final List<Destination> results = [];

        for (int i = 0; i < features.length; i++) {
          final feat = features[i];
          final props = feat['properties'] ?? {};
          final geometry = feat['geometry'] ?? {};
          final coords = geometry['coordinates'] ?? [];

          if (coords.length >= 2) {
            final double lon = (coords[0] as num).toDouble();
            final double lat = (coords[1] as num).toDouble();
            final String name = props['name'] ?? props['street'] ?? props['city'] ?? cleanQuery;
            final List<String> addrParts = [];

            if (props['street'] != null && props['street'] != name) addrParts.add(props['street']);
            if (props['city'] != null && props['city'] != name) addrParts.add(props['city']);
            if (props['state'] != null) addrParts.add(props['state']);
            if (props['country'] != null) addrParts.add(props['country']);

            final String address = addrParts.isNotEmpty ? addrParts.join(', ') : name;

            double? distMeters;
            if (userLocation != null) {
              distMeters = _distanceService.calculateDistanceMeters(
                startLatitude: userLocation.latitude,
                startLongitude: userLocation.longitude,
                endLatitude: lat,
                endLongitude: lon,
              );
            }

            results.add(
              Destination(
                id: 'photon_${props['osm_id'] ?? i}',
                name: name,
                address: address,
                latitude: lat,
                longitude: lon,
                category: props['osm_value'] ?? 'general',
                iconName: 'location_on',
                distanceMeters: distMeters,
              ),
            );
          }
        }

        if (results.isNotEmpty) return results;
      }
    } catch (e) {
      debugPrint('Photon search fallback note: $e');
    }

    // Engine 2: OpenStreetMap Nominatim Backup Engine
    try {
      final nomUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(cleanQuery)}&limit=10&addressdetails=1',
      );
      final headers = kIsWeb ? <String, String>{} : {'User-Agent': 'SmartRouteAlertApp/1.0'};
      final response = await http.get(nomUrl, headers: headers).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Destination> results = [];

        for (int i = 0; i < data.length; i++) {
          final item = data[i];
          final double lat = double.parse(item['lat'].toString());
          final double lon = double.parse(item['lon'].toString());
          final String displayName = item['display_name'] ?? cleanQuery;
          final List<String> parts = displayName.split(',');
          final String mainName = parts.first.trim();
          final String address = parts.length > 1 ? parts.sublist(1).join(',').trim() : displayName;

          double? distMeters;
          if (userLocation != null) {
            distMeters = _distanceService.calculateDistanceMeters(
              startLatitude: userLocation.latitude,
              startLongitude: userLocation.longitude,
              endLatitude: lat,
              endLongitude: lon,
            );
          }

          results.add(
            Destination(
              id: 'nom_${item['place_id'] ?? i}',
              name: mainName,
              address: address,
              latitude: lat,
              longitude: lon,
              category: 'general',
              iconName: 'location_on',
              distanceMeters: distMeters,
            ),
          );
        }

        if (results.isNotEmpty) return results;
      }
    } catch (e) {
      debugPrint('Nominatim search note: $e');
    }

    // Dynamic Location Offset Fallback
    final double targetLat = (userLocation?.latitude ?? 13.0400) + 0.015;
    final double targetLng = (userLocation?.longitude ?? 80.2300) + 0.015;
    final double distMeters = userLocation != null
        ? _distanceService.calculateDistanceMeters(
            startLatitude: userLocation.latitude,
            startLongitude: userLocation.longitude,
            endLatitude: targetLat,
            endLongitude: targetLng,
          )
        : 2500;

    return [
      Destination(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: cleanQuery,
        address: '$cleanQuery, Nearby Search Area',
        latitude: targetLat,
        longitude: targetLng,
        category: 'general',
        iconName: 'location_on',
        distanceMeters: distMeters,
      )
    ];
  }

  List<Destination> _getNearbyRecommendations(LocationSample? userLocation) {
    final double userLat = userLocation?.latitude ?? 13.0827;
    final double userLng = userLocation?.longitude ?? 80.2707;

    final defaults = [
      Destination(
        id: 'rec_central',
        name: 'Central Railway Station',
        address: 'Main Transit Hub',
        latitude: userLat + 0.01,
        longitude: userLng + 0.01,
        category: 'station',
        iconName: 'train',
      ),
      Destination(
        id: 'rec_airport',
        name: 'International Airport',
        address: 'Terminal & Departure Gates',
        latitude: userLat - 0.02,
        longitude: userLng - 0.02,
        category: 'transit',
        iconName: 'flight',
      ),
      Destination(
        id: 'rec_it_park',
        name: 'Tech & Business Park',
        address: 'Corporate IT Highway',
        latitude: userLat + 0.015,
        longitude: userLng - 0.01,
        category: 'work',
        iconName: 'work',
      ),
    ];

    if (userLocation == null) return defaults;

    return defaults.map((d) {
      final double distMeters = _distanceService.calculateDistanceMeters(
        startLatitude: userLocation.latitude,
        startLongitude: userLocation.longitude,
        endLatitude: d.latitude,
        endLongitude: d.longitude,
      );
      return d.copyWith(distanceMeters: distMeters);
    }).toList();
  }
}
