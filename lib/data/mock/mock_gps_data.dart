import '../models/route_history_point.dart';

class MockGpsPosition {
  final String placeName;
  final double latitude;
  final double longitude;
  final Duration age;

  const MockGpsPosition({
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.age,
  });
}

/// Centralized Dhaka GPS fixtures. Replace this source with the real Android
/// application's confirmed schema when Firebase integration is approved.
class MockGpsData {
  MockGpsData._();

  static final DateTime sampleRouteDate = DateTime.now().subtract(
    const Duration(days: 1),
  );

  static const Map<String, MockGpsPosition> livePositions = {
    'sm_001': MockGpsPosition(
      placeName: 'Mirpur 10',
      latitude: 23.8067,
      longitude: 90.3686,
      age: Duration(seconds: 12),
    ),
    'sm_002': MockGpsPosition(
      placeName: 'Pallabi',
      latitude: 23.8240,
      longitude: 90.3652,
      age: Duration(seconds: 25),
    ),
    'sm_003': MockGpsPosition(
      placeName: 'Mirpur 12',
      latitude: 23.8275,
      longitude: 90.3655,
      age: Duration(seconds: 8),
    ),
    'sm_004': MockGpsPosition(
      placeName: 'Dhanmondi 27',
      latitude: 23.7461,
      longitude: 90.3742,
      age: Duration(seconds: 42),
    ),
    'sm_005': MockGpsPosition(
      placeName: 'Uttara Sector 7',
      latitude: 23.8712,
      longitude: 90.3978,
      age: Duration(seconds: 18),
    ),
    'sm_006': MockGpsPosition(
      placeName: 'Gulshan 2',
      latitude: 23.7937,
      longitude: 90.4140,
      age: Duration(hours: 2, minutes: 10),
    ),
    'sm_007': MockGpsPosition(
      placeName: 'Mirpur 11',
      latitude: 23.8172,
      longitude: 90.3658,
      age: Duration(seconds: 31),
    ),
    'sm_008': MockGpsPosition(
      placeName: 'Kafrul',
      latitude: 23.8069,
      longitude: 90.3791,
      age: Duration(hours: 4, minutes: 5),
    ),
  };

  static Map<String, List<RouteHistoryPoint>> routesForDate(DateTime date) {
    if (!_sameDate(date, sampleRouteDate)) return const {};
    final base = DateTime(date.year, date.month, date.day);
    return {
      'sm_001': [
        _point(23.8067, 90.3686, base, 9, 5, 'Mirpur 10 · Start'),
        _point(23.8091, 90.3712, base, 9, 28, 'Mirpur 10 bus stand'),
        _point(23.8168, 90.3682, base, 10, 2, 'Mirpur 11'),
        _point(23.8240, 90.3652, base, 10, 41, 'Pallabi market'),
        _point(23.8275, 90.3655, base, 11, 16, 'Mirpur 12'),
        _point(23.8172, 90.3658, base, 11, 52, 'Mirpur 11'),
        _point(23.8067, 90.3686, base, 12, 24, 'Mirpur 10 · End'),
      ],
      'sm_003': [
        _point(23.8275, 90.3655, base, 9, 12, 'Mirpur 12 · Start'),
        _point(23.8240, 90.3652, base, 9, 47, 'Pallabi'),
        _point(23.8172, 90.3658, base, 10, 15, 'Mirpur 11'),
        _point(23.8067, 90.3686, base, 10, 54, 'Mirpur 10'),
        _point(23.8003, 90.3675, base, 11, 31, 'Mirpur 1'),
        _point(23.8275, 90.3655, base, 12, 8, 'Mirpur 12 · End'),
      ],
    };
  }

  static RouteHistoryPoint _point(
    double lat,
    double lng,
    DateTime base,
    int hour,
    int minute,
    String place,
  ) => RouteHistoryPoint(
    latitude: lat,
    longitude: lng,
    recordedAt: DateTime(base.year, base.month, base.day, hour, minute),
    placeName: place,
  );

  static bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
