import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/mock/mock_gps_data.dart';
import '../../../data/models/route_history_point.dart';
import '../../../data/models/salesman_model.dart';
import '../../../data/repositories/salesmen_repository.dart';
import '../../../data/services/location_tracking_service.dart';
import '../../../data/services/mock_location_tracking_service.dart';

class RouteHistoryViewModel extends ChangeNotifier {
  final LocationTrackingService _locationService;
  final SalesmenRepository _salesmenRepository;

  RouteHistoryViewModel({
    LocationTrackingService? locationService,
    SalesmenRepository? salesmenRepository,
  }) : _locationService = locationService ?? MockLocationTrackingService(),
       _salesmenRepository = salesmenRepository ?? SalesmenRepository() {
    load();
  }

  List<SalesmanModel> _salesmen = const [];
  List<RouteHistoryPoint> _points = const [];
  String? _selectedSalesmanId;
  DateTime _selectedDate = MockGpsData.sampleRouteDate;
  bool _isLoading = true;
  String? _errorMessage;
  int _requestId = 0;

  List<SalesmanModel> get salesmen => List.unmodifiable(_salesmen);
  List<RouteHistoryPoint> get points => List.unmodifiable(_points);
  String? get selectedSalesmanId => _selectedSalesmanId;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SalesmanModel? get selectedSalesman => _salesmen
      .where((salesman) => salesman.id == _selectedSalesmanId)
      .firstOrNull;
  bool get hasRoute => _points.isNotEmpty;

  double? get distanceKm {
    if (_points.length < 2) return null;
    const distance = Distance();
    var meters = 0.0;
    for (var index = 1; index < _points.length; index++) {
      meters += distance(
        LatLng(_points[index - 1].latitude, _points[index - 1].longitude),
        LatLng(_points[index].latitude, _points[index].longitude),
      );
    }
    return meters / 1000;
  }

  Duration? get routeDuration {
    if (_points.length < 2) return null;
    return _points.last.recordedAt.difference(_points.first.recordedAt);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _salesmen = await _salesmenRepository.getSalesmen();
      if (_selectedSalesmanId == null && _salesmen.isNotEmpty) {
        _selectedSalesmanId = _salesmen.first.id;
      }
      await _loadRoute();
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Route history could not be loaded.';
      notifyListeners();
    }
  }

  Future<void> selectSalesman(String? salesmanId) async {
    if (salesmanId == null ||
        !_salesmen.any((salesman) => salesman.id == salesmanId)) {
      return;
    }
    _selectedSalesmanId = salesmanId;
    await _loadRoute();
  }

  Future<void> selectDate(DateTime date) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    await _loadRoute();
  }

  Future<void> _loadRoute() async {
    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final id = _selectedSalesmanId;
      final points = id == null
          ? const <RouteHistoryPoint>[]
          : await _locationService.getRouteHistory(
              salesmanId: id,
              date: _selectedDate,
            );
      if (requestId != _requestId) return;
      _points = points;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      if (requestId != _requestId) return;
      _isLoading = false;
      _errorMessage = 'Route history could not be loaded.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
