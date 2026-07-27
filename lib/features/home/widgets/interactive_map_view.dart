import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/models/location_sample.dart';

class InteractiveMapView extends StatefulWidget {
  final LocationSample currentSample;
  final Destination? destination;
  final LatLng? pickedPosition;
  final Function(LatLng)? onTapPosition;
  final bool isNightMode;
  final VoidCallback? onRecenter;

  const InteractiveMapView({
    super.key,
    required this.currentSample,
    this.destination,
    this.pickedPosition,
    this.onTapPosition,
    this.isNightMode = false,
    this.onRecenter,
  });

  @override
  State<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class _InteractiveMapViewState extends State<InteractiveMapView> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final LatLng currentPos = LatLng(widget.currentSample.latitude, widget.currentSample.longitude);

    final String tileUrl = widget.isNightMode
        ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png'
        : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';

    final List<Marker> markers = [
      Marker(
        point: currentPos,
        width: 44,
        height: 44,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 16),
          ),
        ),
      ),
    ];

    final List<Polyline> polylines = [];

    // Destination Marker
    if (widget.destination != null) {
      final LatLng destPos = LatLng(widget.destination!.latitude, widget.destination!.longitude);
      markers.add(
        Marker(
          point: destPos,
          width: 44,
          height: 44,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
          ),
        ),
      );

      polylines.add(
        Polyline(
          points: [currentPos, destPos],
          strokeWidth: 5.0,
          color: widget.isNightMode ? AppColors.inversePrimary : AppColors.primaryContainer,
        ),
      );
    }

    // Custom Picked Position Pin
    if (widget.pickedPosition != null) {
      markers.add(
        Marker(
          point: widget.pickedPosition!,
          width: 48,
          height: 48,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.pin_drop_rounded, color: Colors.white, size: 28),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.pickedPosition ?? currentPos,
            initialZoom: 14.5,
            onTap: (tapPosition, point) {
              widget.onTapPosition?.call(point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: tileUrl,
              userAgentPackageName: 'com.smartroutealert.app',
              maxZoom: 19,
            ),
            if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
            MarkerLayer(markers: markers),
          ],
        ),

        // Map Control Floating Actions (Zoom In, Recenter)
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'map_recenter_${identityHashCode(this)}',
                backgroundColor: widget.isNightMode ? AppColors.glassDarkBg : Colors.white,
                foregroundColor: widget.isNightMode ? AppColors.inversePrimary : AppColors.primary,
                onPressed: () {
                  _mapController.move(currentPos, 15.0);
                  widget.onRecenter?.call();
                },
                child: const Icon(Icons.my_location_rounded),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'map_zoom_in_${identityHashCode(this)}',
                backgroundColor: widget.isNightMode ? AppColors.glassDarkBg : Colors.white,
                foregroundColor: widget.isNightMode ? AppColors.inversePrimary : AppColors.primary,
                onPressed: () {
                  _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                },
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
