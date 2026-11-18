import '../models/route_history_point.dart';
import '../models/salesman_gps_location.dart';

abstract interface class LocationTrackingService {
  Stream<List<SalesmanGpsLocation>> watchLiveLocations({String? companyId});

  Future<List<RouteHistoryPoint>> getRouteHistory({
    required String salesmanId,
    required DateTime date,
  });

  void dispose();
}
