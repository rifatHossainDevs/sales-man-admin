import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/tracking_map_view.dart';
import '../../../data/models/route_history_point.dart';
import '../../../data/services/location_tracking_service.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/route_history_viewmodel.dart';

class RouteHistoryView extends StatelessWidget {
  final LocationTrackingService? locationService;
  final Widget? tileLayerOverride;

  const RouteHistoryView({
    super.key,
    this.locationService,
    this.tileLayerOverride,
  });

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => RouteHistoryViewModel(locationService: locationService),
    child: _RouteHistoryContent(tileLayerOverride: tileLayerOverride),
  );
}

class _RouteHistoryContent extends StatefulWidget {
  final Widget? tileLayerOverride;

  const _RouteHistoryContent({this.tileLayerOverride});

  @override
  State<_RouteHistoryContent> createState() => _RouteHistoryContentState();
}

class _RouteHistoryContentState extends State<_RouteHistoryContent> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RouteHistoryViewModel>();
    final desktop = ResponsiveLayout.isDesktop(context);
    final firstPoint = model.points.isEmpty ? null : model.points.first;
    final center = firstPoint == null
        ? const LatLng(23.8103, 90.4125)
        : LatLng(firstPoint.latitude, firstPoint.longitude);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(child: AppSidebar(activeRoute: AppRouter.routeHistory)),
      body: Row(
        children: [
          if (desktop) const AppSidebar(activeRoute: AppRouter.routeHistory),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Route History',
                  subtitle: 'Review a salesman’s route and recorded stops',
                ),
                Expanded(
                  child: model.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : model.errorMessage != null
                      ? _errorState(model.errorMessage!)
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _filters(context, model),
                              const SizedBox(height: 16),
                              if (model.hasRoute) ...[
                                _summary(model),
                                const SizedBox(height: 16),
                                if (desktop)
                                  SizedBox(
                                    height: 570,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: _map(model, center),
                                        ),
                                        const SizedBox(width: 18),
                                        SizedBox(
                                          width: 330,
                                          child: _timeline(model.points),
                                        ),
                                      ],
                                    ),
                                  )
                                else ...[
                                  SizedBox(
                                    height: 420,
                                    child: _map(model, center),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 430,
                                    child: _timeline(model.points),
                                  ),
                                ],
                              ] else
                                _emptyState(model),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context, RouteHistoryViewModel model) => Wrap(
    spacing: 12,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          initialValue: model.selectedSalesmanId,
          isExpanded: true,
          decoration: _inputDecoration(
            'Select salesman',
            Icons.person_outline_rounded,
          ),
          items: model.salesmen
              .map(
                (s) => DropdownMenuItem(
                  value: s.id,
                  child: Text(s.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: model.selectSalesman,
        ),
      ),
      OutlinedButton.icon(
        onPressed: () => _pickDate(context, model),
        icon: const Icon(Icons.calendar_today_outlined, size: 17),
        label: Text(_formatDate(model.selectedDate)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.cardBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: AppColors.textPrimary,
        ),
      ),
    ],
  );

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      );

  Future<void> _pickDate(
    BuildContext context,
    RouteHistoryViewModel model,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: model.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Choose route date',
    );
    if (date != null) await model.selectDate(date);
  }

  Widget _summary(RouteHistoryViewModel model) {
    final points = model.points;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _summaryCard(
          'Route distance',
          model.distanceKm == null
              ? '—'
              : '${model.distanceKm!.toStringAsFixed(2)} km',
          Icons.route_rounded,
        ),
        _summaryCard(
          'Recorded points',
          '${points.length}',
          Icons.place_outlined,
        ),
        _summaryCard(
          'Start time',
          _formatTime(points.first.recordedAt),
          Icons.play_circle_outline_rounded,
        ),
        _summaryCard(
          'End time',
          _formatTime(points.last.recordedAt),
          Icons.stop_circle_outlined,
        ),
        _summaryCard(
          'Duration',
          _formatDuration(model.routeDuration),
          Icons.schedule_rounded,
        ),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon) => Container(
    constraints: const BoxConstraints(minWidth: 145),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _map(RouteHistoryViewModel model, LatLng center) {
    final points = model.points;
    final markers = <TrackingMapMarker>[];
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final isStart = i == 0;
      final isEnd = i == points.length - 1;
      markers.add(
        TrackingMapMarker(
          id: 'route-point-$i',
          point: LatLng(point.latitude, point.longitude),
          label:
              '${isStart
                  ? 'Start · '
                  : isEnd
                  ? 'End · '
                  : ''}${point.placeName} · ${_formatTime(point.recordedAt)}',
          initials: '${i + 1}',
          color: isStart
              ? AppColors.success
              : isEnd
              ? AppColors.danger
              : AppColors.primary,
          icon: isStart
              ? Icons.play_arrow_rounded
              : isEnd
              ? Icons.stop_rounded
              : null,
        ),
      );
    }
    return TrackingMapView(
      controller: _mapController,
      initialCenter: center,
      markers: markers,
      routePoints: points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList(growable: false),
      tileLayerOverride: widget.tileLayerOverride,
      semanticsLabel: 'OpenStreetMap showing the selected salesman route',
    );
  }

  Widget _timeline(List<RouteHistoryPoint> points) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Route stops',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.timeline_rounded, size: 18, color: AppColors.primary),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: points.length,
            itemBuilder: (context, index) {
              final point = points[index];
              final first = index == 0;
              final last = index == points.length - 1;
              return _routePoint(point, index, first, last);
            },
          ),
        ),
      ],
    ),
  );

  Widget _routePoint(
    RouteHistoryPoint point,
    int index,
    bool first,
    bool last,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          child: Column(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: first
                      ? AppColors.successBg
                      : last
                      ? AppColors.dangerBg
                      : AppColors.infoBg,
                  shape: BoxShape.circle,
                ),
                child: first
                    ? const Icon(
                        Icons.play_arrow_rounded,
                        size: 13,
                        color: AppColors.success,
                      )
                    : last
                    ? const Icon(
                        Icons.stop_rounded,
                        size: 12,
                        color: AppColors.danger,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              if (!last)
                Container(width: 1, height: 36, color: AppColors.cardBorder),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                first
                    ? 'Start · ${point.placeName}'
                    : last
                    ? 'End · ${point.placeName}'
                    : point.placeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(point.recordedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _emptyState(RouteHistoryViewModel model) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 280),
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.cardBorder),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.infoBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.route_outlined,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'No route data for this selection',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${model.selectedSalesman?.name ?? 'This salesman'} has no recorded route on ${_formatDate(model.selectedDate)}.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    ),
  );

  Widget _errorState(String message) => Center(
    child: Text(
      message,
      style: const TextStyle(color: AppColors.textSecondary),
    ),
  );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';

  String _month(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    return '$hour:${date.minute.toString().padLeft(2, '0')} ${date.hour < 12 ? 'AM' : 'PM'}';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '—';
    return '${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m';
  }
}
