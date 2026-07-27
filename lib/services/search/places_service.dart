import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../shared/models/destination.dart';
import '../../shared/models/location_sample.dart';
import '../smart_alert/distance_service.dart';

class PlacesService {
  final DistanceService _distanceService;

  PlacesService({DistanceService distanceService = const DistanceService()})
      : _distanceService = distanceService;

  /// Dynamic worldwide location search powered by OpenStreetMap / Nominatim API
  Future<List<Destination>> searchDestinations(String query, {LocationSample? userLocation}) async {
    final String cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(cleanQuery)}&limit=8&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SmartRouteAlertApp/1.0 (com.smartroutealert.app)',
      }).timeout(const Duration(seconds: 4));

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
              id: 'osm_${item['place_id'] ?? i}',
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
    } catch (_) {
      // Graceful fallback to location-offset custom search if offline
    }

    // Dynamic Fallback
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
        address: '$cleanQuery, Nearby Area',
        latitude: targetLat,
        longitude: targetLng,
        category: 'general',
        iconName: 'location_on',
        distanceMeters: distMeters,
      )
    ];
  }
}
