import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../mock/mock_gps_data.dart';
import '../models/route_history_point.dart';
import '../models/salesman_gps_location.dart';
import 'location_tracking_service.dart';

class ApiLocationTrackingService implements LocationTrackingService {
  final http.Client _client;
  Timer? _timer;
  final StreamController<List<SalesmanGpsLocation>> _controller =
      StreamController<List<SalesmanGpsLocation>>.broadcast();

  int lastRouteTotalOrders = 0;
  double lastRouteTotalCollection = 0.0;
  bool lastRouteStatsFromApi = false;

  ApiLocationTrackingService({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Stream<List<SalesmanGpsLocation>> watchLiveLocations({String? companyId}) {
    _timer?.cancel();
    _fetchLiveLocations(companyId);
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchLiveLocations(companyId);
    });
    return _controller.stream;
  }

  Future<void> _fetchLiveLocations(String? companyId) async {
    try {
      Set<String>? companySellerIds;
      final sellerPhones = <String, String>{};
      final sellerOrderCounts = <String, int>{};

      if (companyId != null && companyId.isNotEmpty) {
        try {
          final usersRes = await _client.get(Uri.parse(ApiConstants.allCompanyUsers(companyId)));
          if (usersRes.statusCode == 200) {
            final List users = json.decode(usersRes.body)['data'] ?? [];
            final sellers = users.where((u) => u['userType'] == 'seller').toList();
            companySellerIds = sellers.map((u) => u['_id'].toString()).toSet();
            for (final u in sellers) {
              final id = (u['_id'] ?? '').toString();
              final phone = (u['phone'] ?? '').toString();
              if (id.isNotEmpty && phone.isNotEmpty) {
                sellerPhones[id] = phone;
              }
            }
          }
        } catch (_) {}
      }

      try {
        final ordersRes = await _client.get(Uri.parse('${ApiConstants.orders}?limit=200'));
        if (ordersRes.statusCode == 200) {
          final decoded = json.decode(ordersRes.body);
          final List ordersList = decoded['data'] is Map
              ? (decoded['data']['orders'] ?? [])
              : (decoded['data'] is List ? decoded['data'] : []);
          for (final o in ordersList) {
            final sm = o['salesmanId'];
            final smId = (sm is Map ? sm['_id'] : sm)?.toString() ?? '';
            final smName = (sm is Map ? sm['fullName'] : '')?.toString().trim().toLowerCase() ?? '';
            if (smId.isNotEmpty) {
              sellerOrderCounts[smId] = (sellerOrderCounts[smId] ?? 0) + 1;
            }
            if (smName.isNotEmpty) {
              sellerOrderCounts[smName] = (sellerOrderCounts[smName] ?? 0) + 1;
            }
          }
        }
      } catch (_) {}

      final response = await _client.get(Uri.parse(ApiConstants.liveLocations(companyId)));
      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        final List data = jsonMap['data'] ?? [];
        List<SalesmanGpsLocation> locations = data.map((item) {
          final id = (item['salesmanId'] ?? item['_id'] ?? '').toString();
          final name = (item['name'] ?? item['fullName'] ?? '').toString();
          final phone = (item['phone'] ?? sellerPhones[id] ?? '').toString();
          final ordersCount = sellerOrderCounts[id] ??
              sellerOrderCounts[name.trim().toLowerCase()] ??
              0;

          return SalesmanGpsLocation(
            salesmanId: id,
            name: name,
            initials: (item['initials'] ?? 'SR').toString(),
            territory: (item['territory'] ?? 'Dhaka').toString(),
            latitude: (item['latitude'] as num).toDouble(),
            longitude: (item['longitude'] as num).toDouble(),
            placeName: (item['placeName'] ?? '').toString(),
            updatedAt: DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
            isOnline: item['isOnline'] ?? false,
            phone: phone,
            totalOrders: ordersCount,
          );
        }).toList();

        // Strict company seller ID filter
        if (companySellerIds != null && companySellerIds.isNotEmpty) {
          final filtered = locations
              .where((loc) => companySellerIds!.contains(loc.salesmanId))
              .toList();
          if (filtered.isNotEmpty) {
            locations = filtered;
          }
        }

        _controller.add(locations);
        return;
      }
    } catch (_) {}

    _controller.add(_getFallbackLocations());
  }

  List<SalesmanGpsLocation> _getFallbackLocations() {
    return const [];
  }

  @override
  Future<List<RouteHistoryPoint>> getRouteHistory({
    required String salesmanId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    lastRouteStatsFromApi = false;
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.routeHistory(salesmanId, dateStr)),
      );
      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body);
        final dataObj = jsonMap['data'] ?? {};
        final List pointsData = dataObj['points'] ?? [];
        lastRouteTotalOrders = (dataObj['totalOrders'] as num?)?.toInt() ?? 0;
        lastRouteTotalCollection = (dataObj['totalCollection'] as num?)?.toDouble() ?? 0.0;
        lastRouteStatsFromApi = true;

        return pointsData.map((pt) {
          return RouteHistoryPoint(
            latitude: (pt['latitude'] as num).toDouble(),
            longitude: (pt['longitude'] as num).toDouble(),
            recordedAt: (DateTime.tryParse(pt['recordedAt'] ?? '') ?? DateTime.now()).toLocal(),
            placeName: pt['placeName'] ?? '',
          );
        }).toList();
      }
    } catch (_) {}

    final routes = MockGpsData.routesForDate(date);
    return routes[salesmanId] ??
        routes.values.firstOrNull ??
        [
          RouteHistoryPoint(
            latitude: 23.8067,
            longitude: 90.3686,
            recordedAt: date.add(const Duration(hours: 9)),
            placeName: 'Mirpur 10 · Start',
          ),
          RouteHistoryPoint(
            latitude: 23.8168,
            longitude: 90.3682,
            recordedAt: date.add(const Duration(hours: 10, minutes: 30)),
            placeName: 'Mirpur 11 · Market Visit',
          ),
          RouteHistoryPoint(
            latitude: 23.8240,
            longitude: 90.3652,
            recordedAt: date.add(const Duration(hours: 12, minutes: 15)),
            placeName: 'Pallabi · End',
          ),
        ];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
