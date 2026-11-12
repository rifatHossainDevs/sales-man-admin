import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_layout.dart';
import '../../../core/widgets/app_sidebar.dart';
import '../../../core/widgets/app_topbar.dart';
import '../../../core/widgets/tracking_map_view.dart';
import '../../../data/mock/mock_salesmen_data.dart';
import '../../../data/models/salesman_gps_location.dart';
import '../../../data/models/salesman_model.dart';
import '../../../data/services/location_tracking_service.dart';
import '../../../routing/app_router.dart';
import '../viewmodels/live_tracking_viewmodel.dart';
import '../viewmodels/route_history_viewmodel.dart';

class LiveTrackingView extends StatelessWidget {
  final LocationTrackingService? locationService;
  final Widget? tileLayerOverride;

  const LiveTrackingView({
    super.key,
    this.locationService,
    this.tileLayerOverride,
  });

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => LiveTrackingViewModel(service: locationService),
    child: _LiveTrackingContent(tileLayerOverride: tileLayerOverride),
  );
}

class _LiveTrackingContent extends StatefulWidget {
  final Widget? tileLayerOverride;

  const _LiveTrackingContent({this.tileLayerOverride});

  @override
  State<_LiveTrackingContent> createState() => _LiveTrackingContentState();
}

class _LiveTrackingContentState extends State<_LiveTrackingContent> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveTrackingViewModel>();
    final desktop = ResponsiveLayout.isDesktop(context);
    final selected = model.selectedSalesman;
    final center = selected == null
        ? const LatLng(23.8103, 90.4125)
        : LatLng(selected.latitude, selected.longitude);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(child: AppSidebar(activeRoute: AppRouter.liveTracking)),
      body: Row(
        children: [
          if (desktop) const AppSidebar(activeRoute: AppRouter.liveTracking),
          Expanded(
            child: Column(
              children: [
                const AppTopbar(
                  title: 'Live Tracking',
                  subtitle: 'Monitor your field team locations in real time',
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
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 900;
                            final map = _mapPanel(model, center);
                            final list = _salesmanPanel(
                              context,
                              model,
                              compact,
                            );
                            return SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _statusSummary(model),
                                  const SizedBox(height: 18),
                                  if (!compact)
                                    SizedBox(
                                      height: 610,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(flex: 7, child: map),
                                          const SizedBox(width: 18),
                                          SizedBox(width: 330, child: list),
                                        ],
                                      ),
                                    )
                                  else ...[
                                    SizedBox(height: 430, child: map),
                                    const SizedBox(height: 16),
                                    SizedBox(height: 430, child: list),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusSummary(LiveTrackingViewModel model) => Wrap(
    spacing: 10,
    runSpacing: 8,
    children: [
      _countChip('Online now', model.onlineCount, AppColors.success),
      _countChip('Offline', model.offlineCount, AppColors.textMuted),
      _countChip('Last sync', '15 sec', AppColors.primary),
    ],
  );

  Widget _countChip(String label, Object count, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label  ',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _mapPanel(LiveTrackingViewModel model, LatLng center) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: TrackingMapView(
          controller: _mapController,
          initialCenter: center,
          tileLayerOverride: widget.tileLayerOverride,
          markers: model.locations.map(_mapMarker).toList(growable: false),
        ),
      ),
      const SizedBox(height: 12),
      _selectedDetails(context, model.selectedSalesman),
    ],
  );

  TrackingMapMarker _mapMarker(SalesmanGpsLocation location) =>
      TrackingMapMarker(
        id: location.salesmanId,
        point: LatLng(location.latitude, location.longitude),
        label: '${location.name} · ${location.isOnline ? 'Online' : 'Offline'}',
        initials: location.initials,
        color: location.isOnline ? AppColors.success : AppColors.textMuted,
        isSelected:
            location.salesmanId ==
            context.read<LiveTrackingViewModel>().selectedSalesmanId,
        onTap: () => _selectLocation(location),
      );

  void _selectLocation(SalesmanGpsLocation location) {
    context.read<LiveTrackingViewModel>().selectSalesman(location.salesmanId);
    _mapController.move(LatLng(location.latitude, location.longitude), 15);
  }

  Widget _selectedDetails(BuildContext context, SalesmanGpsLocation? location) {
    if (location == null) return const SizedBox.shrink();
    final updated = _relativeTime(location.updatedAt);

    final salesmanModel = MockSalesmenData.salesmen.firstWhere(
      (s) => s.id == location.salesmanId || s.name == location.name,
      orElse: () => SalesmanModel(
        id: location.salesmanId,
        name: location.name,
        email: 'salesman@dealer.com',
        phone: '+8801711223344',
        nid: '199226928001',
        totalOrders: 18,
        totalCollected: 142000,
        lastSeen: 'Now',
        isOnline: location.isOnline,
        status: 'Active',
        assignedTerritory: location.territory,
        avatarInitials: location.initials,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: location.isOnline
                    ? AppColors.successBg
                    : AppColors.infoBg,
                child: Text(
                  location.initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${location.territory} · ${salesmanModel.phone}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _statusTag(location.isOnline),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _detailItem(Icons.place_outlined, location.placeName),
              _detailItem(
                Icons.my_location_outlined,
                '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
              ),
              _detailItem(Icons.shopping_bag_outlined, 'Total Orders: ${salesmanModel.totalOrders}'),
              _detailItem(Icons.schedule_rounded, 'Updated $updated'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('WhatsApp'),
                onPressed: () {
                  final phoneClean = salesmanModel.phone.replaceAll(RegExp(r'[^\d+]'), '');
                  final waUrl = 'https://wa.me/${phoneClean.replaceAll('+', '')}?text=${Uri.encodeComponent('Hello ${salesmanModel.name}, regarding your field orders...')}';
                  _openUrl(waUrl);
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.route_rounded, size: 16),
                label: const Text('View Route'),
                onPressed: () {
                  try {
                    context.read<RouteHistoryViewModel>().selectSalesman(salesmanModel.id);
                  } catch (_) {}
                  Navigator.of(context).pushReplacementNamed(AppRouter.routeHistory);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openUrl(String url) {
    try {
      web.window.open(url, '_blank');
    } catch (_) {}
  }

  Widget _salesmanPanel(
    BuildContext context,
    LiveTrackingViewModel model,
    bool compact,
  ) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cardBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Salesmen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${model.locations.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: model.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search salesmen or area',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: model.filteredLocations.isEmpty
              ? const Center(
                  child: Text(
                    'No salesmen match your search.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: model.filteredLocations.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 14, endIndent: 14),
                  itemBuilder: (context, index) {
                    final location = model.filteredLocations[index];
                    final selected =
                        model.selectedSalesmanId == location.salesmanId;
                    return Material(
                      color: selected ? AppColors.infoBg : AppColors.surface,
                      child: InkWell(
                        onTap: () => _selectLocation(location),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: location.isOnline
                                    ? AppColors.successBg
                                    : AppColors.background,
                                child: Text(
                                  location.initials,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            location.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        _statusTag(location.isOnline),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${location.placeName} · ${_relativeTime(location.updatedAt)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );

  Widget _statusTag(bool online) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: online ? AppColors.successBg : AppColors.background,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: online ? AppColors.success : AppColors.textMuted,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          online ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: online ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    ),
  );

  Widget _detailItem(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: AppColors.textSecondary),
      const SizedBox(width: 5),
      Text(
        text,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    ],
  );

  Widget _errorState(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_searching_rounded,
            size: 40,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    ),
  );

  String _relativeTime(DateTime time) {
    final age = DateTime.now().difference(time);
    if (age.inSeconds < 60) return '${age.inSeconds.clamp(0, 59)} sec ago';
    if (age.inMinutes < 60) return '${age.inMinutes} min ago';
    return '${age.inHours} hr ago';
  }
}
