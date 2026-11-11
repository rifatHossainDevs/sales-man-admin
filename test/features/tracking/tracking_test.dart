import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sales_man_admin/core/widgets/tracking_map_view.dart';
import 'package:sales_man_admin/data/mock/mock_gps_data.dart';
import 'package:sales_man_admin/data/mock/mock_salesmen_data.dart';
import 'package:sales_man_admin/data/models/route_history_point.dart';
import 'package:sales_man_admin/data/models/salesman_gps_location.dart';
import 'package:sales_man_admin/data/models/salesman_model.dart';
import 'package:sales_man_admin/data/repositories/salesmen_repository.dart';
import 'package:sales_man_admin/data/services/location_tracking_service.dart';
import 'package:sales_man_admin/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:sales_man_admin/features/tracking/viewmodels/live_tracking_viewmodel.dart';
import 'package:sales_man_admin/features/tracking/viewmodels/route_history_viewmodel.dart';
import 'package:sales_man_admin/features/tracking/views/live_tracking_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('map renders markers, route polyline, attribution and controls', (
    tester,
  ) async {
    final controller = MapController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 600,
          height: 400,
          child: TrackingMapView(
            controller: controller,
            initialCenter: const LatLng(23.81, 90.37),
            tileLayerOverride: const ColoredBox(color: Color(0xFFE8EDF1)),
            markers: const [
              TrackingMapMarker(
                id: 'start',
                point: LatLng(23.81, 90.37),
                label: 'Start',
                initials: 'S',
                color: Colors.green,
              ),
              TrackingMapMarker(
                id: 'end',
                point: LatLng(23.82, 90.38),
                label: 'End',
                initials: 'E',
                color: Colors.red,
              ),
            ],
            routePoints: const [LatLng(23.81, 90.37), LatLng(23.82, 90.38)],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(PolylineLayer), findsOneWidget);
    expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
    expect(find.text('S'), findsOneWidget);
    expect(find.text('E'), findsOneWidget);
    expect(find.byTooltip('Zoom in'), findsOneWidget);
    expect(find.byTooltip('Fit all markers'), findsOneWidget);
  });

  test('live view model selects salesman and filters search results', () async {
    final service = _FakeLocationService(_locations);
    final model = LiveTrackingViewModel(service: service);
    addTearDown(model.dispose);
    await Future<void>.delayed(Duration.zero);

    expect(model.selectedSalesman?.salesmanId, 'sm_001');
    model.selectSalesman('sm_002');
    expect(model.selectedSalesman?.name, 'Sohel Rana');
    model.setSearchQuery('pallabi');
    expect(model.filteredLocations.map((location) => location.salesmanId), [
      'sm_002',
    ]);
  });

  test(
    'route history date selection filters locations and calculates distance',
    () async {
      final model = RouteHistoryViewModel(
        locationService: _FakeLocationService(_locations),
        salesmenRepository: _FakeSalesmenRepository(),
      );
      addTearDown(model.dispose);
      await _untilLoaded(model);

      expect(model.points, isNotEmpty);
      expect(model.distanceKm, greaterThan(0));
      await model.selectDate(DateTime.now().subtract(const Duration(days: 3)));
      expect(model.points, isEmpty);
      expect(model.distanceKm, isNull);
    },
  );

  testWidgets(
    'live tracking supports desktop and narrow layouts and salesman selection',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(),
          child: MaterialApp(
            home: LiveTrackingView(
              locationService: _FakeLocationService(_locations),
              tileLayerOverride: const ColoredBox(color: Color(0xFFE8EDF1)),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));

      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.byTooltip('Fit all markers'), findsOneWidget);
      expect(find.text('Rakib Hasan'), findsOneWidget);

      tester.view.physicalSize = const Size(390, 844);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.byTooltip('Fit all markers'), findsOneWidget);
      await tester.ensureVisible(find.text('Sohel Rana'));
      await tester.tap(find.text('Sohel Rana'));
      await tester.pump();
      expect(find.text('Pallabi'), findsWidgets);
    },
  );
}

Future<void> _untilLoaded(RouteHistoryViewModel model) async {
  for (var attempt = 0; attempt < 20 && model.isLoading; attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

final List<SalesmanGpsLocation> _locations = [
  SalesmanGpsLocation(
    salesmanId: 'sm_001',
    name: 'Rakib Hasan',
    initials: 'RH',
    territory: 'Mirpur',
    latitude: 23.8067,
    longitude: 90.3686,
    placeName: 'Mirpur 10',
    updatedAt: DateTime.now(),
    isOnline: true,
  ),
  SalesmanGpsLocation(
    salesmanId: 'sm_002',
    name: 'Sohel Rana',
    initials: 'SR',
    territory: 'Pallabi',
    latitude: 23.8240,
    longitude: 90.3652,
    placeName: 'Pallabi',
    updatedAt: DateTime.now(),
    isOnline: true,
  ),
];

class _FakeLocationService implements LocationTrackingService {
  final List<SalesmanGpsLocation> liveLocations;

  _FakeLocationService(this.liveLocations);

  @override
  Stream<List<SalesmanGpsLocation>> watchLiveLocations() =>
      Stream.value(liveLocations);

  @override
  Future<List<RouteHistoryPoint>> getRouteHistory({
    required String salesmanId,
    required DateTime date,
  }) async => MockGpsData.routesForDate(date)[salesmanId] ?? const [];

  @override
  void dispose() {}
}

class _FakeSalesmenRepository extends SalesmenRepository {
  @override
  Future<List<SalesmanModel>> getSalesmen() async => MockSalesmenData.salesmen;
}
