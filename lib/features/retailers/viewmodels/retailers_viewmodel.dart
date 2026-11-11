import 'package:flutter/material.dart';
import '../../../data/models/retailer_model.dart';
import '../../../data/repositories/retailers_repository.dart';

class RetailersViewModel extends ChangeNotifier {
  final RetailersRepository _repository;

  RetailersViewModel({RetailersRepository? repository})
      : _repository = repository ?? RetailersRepository() {
    loadRetailers();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<RetailerModel> _allRetailers = [];
  String _searchQuery = '';
  String _selectedDivision = 'Dhaka';
  String _selectedDistrict = 'Dhaka';
  String _selectedSubDistrict = 'Mirpur';
  String _selectedArea = 'All areas';
  bool _isMapView = false;

  String get searchQuery => _searchQuery;
  String get selectedDivision => _selectedDivision;
  String get selectedDistrict => _selectedDistrict;
  String get selectedSubDistrict => _selectedSubDistrict;
  String get selectedArea => _selectedArea;
  bool get isMapView => _isMapView;

  final List<String> divisions = ['All divisions', 'Dhaka', 'Chattogram', 'Sylhet'];
  final List<String> districts = ['All districts', 'Dhaka', 'Gazipur', 'Narayanganj'];
  final List<String> subDistricts = ['All sub-districts', 'Mirpur', 'Uttara', 'Dhanmondi', 'Gulshan'];
  final List<String> areas = [
    'All areas',
    'Mirpur-1',
    'Mirpur-2',
    'Mirpur-6',
    'Mirpur-10',
    'Mirpur-11',
    'Mirpur-12',
    'Pallabi',
    'Kafrul',
    'Shewrapara',
  ];

  Future<void> loadRetailers() async {
    _isLoading = true;
    notifyListeners();

    _allRetailers = await _repository.getRetailers();
    _isLoading = false;
    notifyListeners();
  }

  int get totalRetailersCount => _allRetailers.length;

  List<RetailerModel> get filteredRetailers {
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

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedDivision(String div) {
    _selectedDivision = div;
    notifyListeners();
  }

  void setSelectedDistrict(String dist) {
    _selectedDistrict = dist;
    notifyListeners();
  }

  void setSelectedSubDistrict(String subDist) {
    _selectedSubDistrict = subDist;
    notifyListeners();
  }

  void setSelectedArea(String area) {
    _selectedArea = area;
    notifyListeners();
  }

  void setViewMode({required bool isMap}) {
    _isMapView = isMap;
    notifyListeners();
  }

  Future<void> addRetailer(RetailerModel retailer) async {
    await _repository.addRetailer(retailer);
    _allRetailers = await _repository.getRetailers();
    notifyListeners();
  }

  Future<void> updateRetailer(RetailerModel retailer) async {
    await _repository.updateRetailer(retailer);
    _allRetailers = await _repository.getRetailers();
    notifyListeners();
  }

  Future<void> deleteRetailer(String id) async {
    await _repository.deleteRetailer(id);
    _allRetailers = await _repository.getRetailers();
    notifyListeners();
  }
}
