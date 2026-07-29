import 'dart:ui';
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
    this.isNightMode = true,
    this.onRecenter,
  });

  @override
  State<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class _InteractiveMapViewState extends State<InteractiveMapView> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant InteractiveMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentSample.latitude != widget.currentSample.latitude ||
        oldWidget.currentSample.longitude != widget.currentSample.longitude) {
      if (widget.currentSample.latitude != 0.0 && widget.currentSample.longitude != 0.0) {
        _mapController.move(LatLng(widget.currentSample.latitude, widget.currentSample.longitude), _mapController.camera.zoom);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double lat = widget.currentSample.latitude == 0.0 ? 13.0827 : widget.currentSample.latitude;
    final double lng = widget.currentSample.longitude == 0.0 ? 80.2707 : widget.currentSample.longitude;
    final LatLng currentPos = LatLng(lat, lng);

    final String tileUrl = widget.isNightMode
        ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png'
        : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png';

    final List<Marker> markers = [
      // Live Animated Pulsing User Location Marker
      Marker(
        point: currentPos,
        width: 72,
        height: 72,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.success,
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ];

    final List<Polyline> polylines = [];

    // Destination Pin & Live Route Polyline
    if (widget.destination != null) {
      final LatLng destPos = LatLng(widget.destination!.latitude, widget.destination!.longitude);
      markers.add(
        Marker(
          point: destPos,
          width: 150,
          height: 64,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, blurRadius: 10),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flag_rounded, color: AppColors.danger, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      widget.destination!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.location_on_rounded, color: AppColors.danger, size: 28),
            ],
          ),
        ),
      );

      // Glowing Polyline
      polylines.add(
        Polyline(
          points: [currentPos, destPos],
          strokeWidth: 6.0,
          color: AppColors.primary,
        ),
      );
      polylines.add(
        Polyline(
          points: [currentPos, destPos],
          strokeWidth: 2.5,
          color: AppColors.success,
        ),
      );
    }

    // Custom Picked Location Marker
    if (widget.pickedPosition != null) {
      markers.add(
        Marker(
          point: widget.pickedPosition!,
          width: 52,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primary,
                  blurRadius: 16,
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
              fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.smartroutealert.app',
              maxZoom: 19,
            ),
            if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
            MarkerLayer(markers: markers),
          ],
        ),

        // Live ETA & Traffic Status Chip (Top Left)
        Positioned(
          left: 16,
          top: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.thinBorder),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 12),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.success, blurRadius: 6)],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'TRAFFIC SMOOTH  •  ${(widget.currentSample.speed * 3.6).toStringAsFixed(0)} km/h',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Floating Map Controls (Top Right)
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'map_recenter_${identityHashCode(this)}',
                backgroundColor: AppColors.surfaceSecondary,
                foregroundColor: AppColors.primary,
                elevation: 4,
                onPressed: () {
                  widget.onRecenter?.call();
                  if (lat != 0.0 && lng != 0.0) {
                    _mapController.move(currentPos, 15.0);
                  }
                },
                child: const Icon(Icons.gps_fixed_rounded),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'map_zoom_in_${identityHashCode(this)}',
                backgroundColor: AppColors.surfaceSecondary,
                foregroundColor: AppColors.primary,
                elevation: 4,
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
