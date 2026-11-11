import 'dart:async';
import 'dart:math' as math;

import '../mock/mock_gps_data.dart';
import '../models/route_history_point.dart';
import '../models/salesman_gps_location.dart';
import '../models/salesman_model.dart';
import '../repositories/salesmen_repository.dart';
import 'location_tracking_service.dart';

class MockLocationTrackingService implements LocationTrackingService {
  final SalesmenRepository _salesmenRepository;
  final Map<String, MockGpsPosition> _positions = Map.of(
    MockGpsData.livePositions,
  );
  bool _disposed = false;
  int _tick = 0;

  MockLocationTrackingService({SalesmenRepository? salesmenRepository})
    : _salesmenRepository = salesmenRepository ?? SalesmenRepository();

  @override
  Stream<List<SalesmanGpsLocation>> watchLiveLocations() async* {
    final salesmen = await _salesmenRepository.getSalesmen();
    if (_disposed) return;
    yield _snapshot(salesmen);
    await for (final _ in Stream<void>.periodic(const Duration(seconds: 15))) {
      if (_disposed) return;
      _simulateMovement(salesmen);
      yield _snapshot(salesmen);
    }
  }

  List<SalesmanGpsLocation> _snapshot(List<SalesmanModel> salesmen) {
    final now = DateTime.now();
    return salesmen
        .where((salesman) => _positions.containsKey(salesman.id))
        .map((salesman) {
          final position = _positions[salesman.id]!;
          final online = salesman.isOnline && salesman.status == 'Active';
          final updatedAt = online
              ? now.subtract(position.age)
              : now.subtract(
                  position.age > const Duration(hours: 1)
                      ? position.age
                      : const Duration(hours: 2),
                );
          return SalesmanGpsLocation(
            salesmanId: salesman.id,
            name: salesman.name,
            initials: salesman.avatarInitials,
            territory: salesman.assignedTerritory,
            latitude: position.latitude,
            longitude: position.longitude,
            placeName: position.placeName,
            updatedAt: updatedAt,
            isOnline: online,
          );
        })
        .toList(growable: false);
  }

  void _simulateMovement(List<SalesmanModel> salesmen) {
    _tick++;
    final direction = _tick.isEven ? 1.0 : -1.0;
    for (final salesman in salesmen) {
      final position = _positions[salesman.id];
      if (position == null ||
          !salesman.isOnline ||
          salesman.status != 'Active') {
        continue;
      }
      final delta =
          0.000025 + (math.sin(_tick + salesman.id.hashCode) + 1) * 0.000008;
      _positions[salesman.id] = MockGpsPosition(
        placeName: position.placeName,
        latitude: position.latitude + delta * direction,
        longitude:
            position.longitude + delta * (salesman.id.hashCode.isEven ? 1 : -1),
        age: Duration(seconds: _tick % 3),
      );
    }
  }

  @override
  Future<List<RouteHistoryPoint>> getRouteHistory({
    required String salesmanId,
    required DateTime date,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (_disposed) return const [];
    return List.unmodifiable(
      MockGpsData.routesForDate(date)[salesmanId] ?? const [],
    );
  }

  @override
  void dispose() => _disposed = true;
}
