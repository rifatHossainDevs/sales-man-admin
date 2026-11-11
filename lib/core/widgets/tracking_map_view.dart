import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_colors.dart';

class TrackingMapMarker {
  final String id;
  final LatLng point;
  final String label;
  final String initials;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const TrackingMapMarker({
    required this.id,
    required this.point,
    required this.label,
    required this.initials,
    required this.color,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });
}

/// Shared OpenStreetMap canvas used by live tracking and route history.
/// The public OSM tile endpoint is configured for development/demo use; select
/// a suitable hosted tile provider for production traffic and comply with its
/// terms. Keep the visible OSM attribution when using OSM data/tiles.
class TrackingMapView extends StatefulWidget {
  final MapController controller;
  final LatLng initialCenter;
  final List<TrackingMapMarker> markers;
  final List<LatLng> routePoints;
  final VoidCallback? onTileError;
  final Widget? tileLayerOverride;
  final String semanticsLabel;

  const TrackingMapView({
    super.key,
    required this.controller,
    required this.initialCenter,
    this.markers = const [],
    this.routePoints = const [],
    this.onTileError,
    this.tileLayerOverride,
    this.semanticsLabel = 'OpenStreetMap with salesman locations',
  });

  @override
  State<TrackingMapView> createState() => _TrackingMapViewState();
}

class _TrackingMapViewState extends State<TrackingMapView> {
  late LatLng _center;
  double _zoom = 12;
  bool _tileError = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initialCenter;
  }

  @override
  void didUpdateWidget(covariant TrackingMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCenter != widget.initialCenter) {
      _center = widget.initialCenter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.controller.move(_center, _zoom);
      });
    }
  }

  List<LatLng> get _allPoints => [
    ...widget.markers.map((marker) => marker.point),
    ...widget.routePoints,
  ];

  void fitMarkers() {
    final points = _allPoints;
    if (points.isEmpty) return;
    if (points.length == 1) {
      _center = points.single;
      _zoom = 15;
      widget.controller.move(_center, _zoom);
      return;
    }
    widget.controller.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(56),
      ),
    );
  }

  void _setTileError() {
    if (_tileError) return;
    if (mounted) setState(() => _tileError = true);
    widget.onTileError?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: widget.controller,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 12,
                minZoom: 3,
                maxZoom: 19,
                backgroundColor: const Color(0xFFE8EDF1),
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onPositionChanged: (camera, _) {
                  _center = camera.center;
                  _zoom = camera.zoom;
                },
              ),
              children: [
                widget.tileLayerOverride ??
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'sales_man_admin',
                      maxNativeZoom: 19,
                      maxZoom: 19,
                      panBuffer: 0,
                      keepBuffer: 2,
                      errorTileCallback: (_, _, _) => _setTileError(),
                    ),
                if (widget.routePoints.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: widget.routePoints,
                        color: AppColors.primary,
                        strokeWidth: 4,
                        borderColor: Colors.white,
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                if (widget.markers.isNotEmpty)
                  MarkerLayer(
                    markers: widget.markers
                        .map(
                          (marker) => Marker(
                            key: ValueKey(marker.id),
                            point: marker.point,
                            width: marker.isSelected ? 52 : 44,
                            height: marker.isSelected ? 62 : 54,
                            alignment: Alignment.bottomCenter,
                            child: Tooltip(
                              message: marker.label,
                              child: GestureDetector(
                                onTap: marker.onTap,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: marker.isSelected ? 42 : 34,
                                      height: marker.isSelected ? 42 : 34,
                                      decoration: BoxDecoration(
                                        color: marker.color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: marker.isSelected ? 3 : 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x330F172A),
                                            blurRadius: 8,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: marker.icon == null
                                          ? Text(
                                              marker.initials,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : Icon(
                                              marker.icon,
                                              color: Colors.white,
                                              size: 17,
                                            ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_rounded,
                                      size: 18,
                                      color: marker.color,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                const SimpleAttributionWidget(
                  alignment: Alignment.bottomRight,
                  source: Text('© OpenStreetMap contributors'),
                ),
              ],
            ),
            Positioned(
              top: 14,
              right: 14,
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Zoom in',
                      onPressed: () => widget.controller.move(
                        _center,
                        (_zoom + 1).clamp(3, 19).toDouble(),
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                    const SizedBox(height: 1, child: Divider(height: 1)),
                    IconButton(
                      tooltip: 'Zoom out',
                      onPressed: () => widget.controller.move(
                        _center,
                        (_zoom - 1).clamp(3, 19).toDouble(),
                      ),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    const SizedBox(height: 1, child: Divider(height: 1)),
                    IconButton(
                      tooltip: 'Fit all markers',
                      onPressed: fitMarkers,
                      icon: const Icon(
                        Icons.center_focus_strong_rounded,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_tileError)
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .94),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 15,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Map tiles are unavailable. Check your connection.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
