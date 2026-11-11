import '../models/route_history_point.dart';
import '../models/salesman_gps_location.dart';

/// Data-source boundary for salesman GPS. A Firebase Realtime Database
/// implementation can be added after the Android app's actual schema is known.
abstract interface class LocationTrackingService {
  Stream<List<SalesmanGpsLocation>> watchLiveLocations();

  Future<List<RouteHistoryPoint>> getRouteHistory({
    required String salesmanId,
    required DateTime date,
  });

  void dispose();
}
