import 'package:flutter/material.dart';
import '../../../data/models/retailer_model.dart';
import '../../../data/models/territory_model.dart';
import '../../../data/repositories/retailers_repository.dart';
import '../../../data/repositories/territories_repository.dart';

class RetailersViewModel extends ChangeNotifier {
  final RetailersRepository _repository;
  final TerritoriesRepository _territoriesRepository;
  final String? companyId;

  RetailersViewModel({
    RetailersRepository? repository,
    TerritoriesRepository? territoriesRepository,
    this.companyId,
  })  : _repository = repository ?? RetailersRepository(),
        _territoriesRepository = territoriesRepository ?? TerritoriesRepository() {
    loadRetailers();
    loadLocationsFromBackend();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<RetailerModel> _allRetailers = [];
  List<DivisionModel> _dbDivisions = [];
  List<DistrictModel> _dbDistricts = [];
  List<SubDistrictModel> _dbSubDistricts = [];
  List<AreaModel> _dbAreas = [];

  String _searchQuery = '';
  String _selectedDivision = 'All divisions';
  String _selectedDistrict = 'All districts';
  String _selectedSubDistrict = 'All sub-districts';
  String _selectedArea = 'All areas';
  bool _isMapView = false;

  // Pagination (10 per page)
  int _currentPage = 1;
  final int _pageSize = 10;

  String get searchQuery => _searchQuery;
  String get selectedDivision => _selectedDivision;
  String get selectedDistrict => _selectedDistrict;
  String get selectedSubDistrict => _selectedSubDistrict;
  String get selectedArea => _selectedArea;
  bool get isMapView => _isMapView;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  Future<void> loadLocationsFromBackend() async {
    try {
      final divs = await _territoriesRepository.getDivisions();
      final dists = await _territoriesRepository.getDistricts();
      final subDists = await _territoriesRepository.getSubDistricts(null);
      final ars = await _territoriesRepository.getAreas(null);

      _dbDivisions = divs;
      _dbDistricts = dists;
      _dbSubDistricts = subDists;
      _dbAreas = ars;
      notifyListeners();
    } catch (_) {}
  }

  // Dynamic Relational Cascading Dropdown Getters
  List<String> get divisions {
    final fromDb = _dbDivisions.map((d) => d.name).where((n) => n.isNotEmpty);
    final fromStores = _allRetailers.map((r) => r.division).where((d) => d.isNotEmpty);
    final set = {...fromDb, ...fromStores}.toList()..sort();
    return ['All divisions', ...set];
  }

  List<String> get districts {
    if (_selectedDivision != 'All divisions') {
      final divObj = _dbDivisions.where((d) => d.name == _selectedDivision).firstOrNull;
      if (divObj != null) {
        final filteredDists = _dbDistricts.where((d) => d.divisionId == divObj.code).map((d) => d.name).toList()..sort();
        return ['All districts', ...filteredDists];
      }
    }
    final set = _dbDistricts.map((d) => d.name).where((n) => n.isNotEmpty).toSet().toList()..sort();
    return ['All districts', ...set];
  }

  List<String> get subDistricts {
    if (_selectedDistrict != 'All districts') {
      final distObj = _dbDistricts.where((d) => d.name == _selectedDistrict).firstOrNull;
      if (distObj != null) {
        final filteredSubDists = _dbSubDistricts.where((sd) => sd.districtId == distObj.code).map((sd) => sd.name).toList()..sort();
        return ['All sub-districts', ...filteredSubDists];
      }
    }
    final set = _dbSubDistricts.map((sd) => sd.name).where((n) => n.isNotEmpty).toSet().toList()..sort();
    return ['All sub-districts', ...set];
  }

  List<String> get areas {
    if (_selectedSubDistrict != 'All sub-districts') {
      final subDistObj = _dbSubDistricts.where((sd) => sd.name == _selectedSubDistrict).firstOrNull;
      if (subDistObj != null) {
        final filteredAreas = _dbAreas.where((a) => a.subDistrictId == subDistObj.code).map((a) => a.name).toList()..sort();
        return ['All areas', ...filteredAreas];
      }
    }
    final set = _dbAreas.map((a) => a.name).where((n) => n.isNotEmpty).toSet().toList()..sort();
    return ['All areas', ...set];
  }

  Future<void> loadRetailers() async {
    _isLoading = true;
    notifyListeners();

    _allRetailers = await _repository.getRetailers(companyId: companyId);
    _isLoading = false;
    notifyListeners();
  }

  int get totalRetailersCount => _allRetailers.length;

  List<RetailerModel> get allFilteredRetailers {
    return _allRetailers.where((r) {
      if (_selectedDivision != 'All divisions' && r.division != _selectedDivision) {
        return false;
      }
      if (_selectedDistrict != 'All districts' && r.district != _selectedDistrict) {
        return false;
      }
      if (_selectedSubDistrict != 'All sub-districts' && r.subDistrict != _selectedSubDistrict) {
        return false;
      }
      if (_selectedArea != 'All areas' && r.area != _selectedArea) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchStore = r.storeName.toLowerCase().contains(q);
        final matchOwner = r.ownerName.toLowerCase().contains(q);
        final matchPhone = r.phone.toLowerCase().contains(q);
        final matchArea = r.area.toLowerCase().contains(q);
        if (!matchStore && !matchOwner && !matchPhone && !matchArea) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  int get totalPages {
    final count = allFilteredRetailers.length;
    if (count == 0) return 1;
    return (count / _pageSize).ceil();
  }

  List<RetailerModel> get filteredRetailers {
    final list = allFilteredRetailers;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= list.length) {
      return list.skip(0).take(_pageSize).toList();
    }
    return list.skip(startIndex).take(_pageSize).toList();
  }

  void setCurrentPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedDivision(String div) {
    _selectedDivision = div;
    _selectedDistrict = 'All districts';
    _selectedSubDistrict = 'All sub-districts';
    _selectedArea = 'All areas';
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedDistrict(String dist) {
    _selectedDistrict = dist;
    _selectedSubDistrict = 'All sub-districts';
    _selectedArea = 'All areas';
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedSubDistrict(String subDist) {
    _selectedSubDistrict = subDist;
    _selectedArea = 'All areas';
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedArea(String area) {
    _selectedArea = area;
    _currentPage = 1;
    notifyListeners();
  }

  void setViewMode({required bool isMap}) {
    _isMapView = isMap;
    notifyListeners();
  }

  Future<void> addRetailer(RetailerModel retailer) async {
    await _repository.addRetailer(retailer, companyId: companyId);
    _allRetailers = await _repository.getRetailers(companyId: companyId);
    notifyListeners();
  }

  Future<void> updateRetailer(RetailerModel retailer) async {
    await _repository.updateRetailer(retailer);
    _allRetailers = await _repository.getRetailers(companyId: companyId);
    notifyListeners();
  }

  Future<void> deleteRetailer(String id) async {
    await _repository.deleteRetailer(id);
    _allRetailers = await _repository.getRetailers(companyId: companyId);
    notifyListeners();
  }
}
