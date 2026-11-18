import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/salesman_gps_location.dart';
import '../../../data/services/api_location_tracking_service.dart';
import '../../../data/services/location_tracking_service.dart';

class LiveTrackingViewModel extends ChangeNotifier {
  final LocationTrackingService _service;
  late final StreamSubscription<List<SalesmanGpsLocation>> _subscription;

  LiveTrackingViewModel({LocationTrackingService? service, String? companyId})
    : _service = service ?? ApiLocationTrackingService() {
    _subscription = _service.watchLiveLocations(companyId: companyId).listen(
      (locations) {
        _locations = locations;
        _isLoading = false;
        _errorMessage = null;
        if (_selectedSalesmanId == null ||
            !_locations.any(
              (location) => location.salesmanId == _selectedSalesmanId,
            )) {
          _selectedSalesmanId =
              _locations
                  .where((location) => location.isOnline)
                  .firstOrNull
                  ?.salesmanId ??
              _locations.firstOrNull?.salesmanId;
        }
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _errorMessage = 'Salesman locations could not be loaded.';
        notifyListeners();
      },
    );
  }

  List<SalesmanGpsLocation> _locations = const [];
  String _searchQuery = '';
  String _statusFilter = 'All';
  String? _selectedSalesmanId;
  String? _errorMessage;
  bool _isLoading = true;

  List<SalesmanGpsLocation> get locations => List.unmodifiable(_locations);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  String? get selectedSalesmanId => _selectedSalesmanId;
  SalesmanGpsLocation? get selectedSalesman => _locations
      .where((location) => location.salesmanId == _selectedSalesmanId)
      .firstOrNull;
  int get onlineCount =>
      _locations.where((location) => location.isOnline).length;
  int get offlineCount => _locations.length - onlineCount;

  List<SalesmanGpsLocation> get filteredLocations {
    final query = _searchQuery.trim().toLowerCase();
    return _locations
        .where((location) {
          if (_statusFilter == 'Online' && !location.isOnline) return false;
          if (_statusFilter == 'Offline' && location.isOnline) return false;
          if (query.isEmpty) return true;
          return location.name.toLowerCase().contains(query) ||
              location.territory.toLowerCase().contains(query) ||
              location.placeName.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  void selectSalesman(String salesmanId) {
    if (!_locations.any((location) => location.salesmanId == salesmanId)) {
      return;
    }
    _selectedSalesmanId = salesmanId;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _service.dispose();
    super.dispose();
  }
}
