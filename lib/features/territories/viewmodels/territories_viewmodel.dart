import 'package:flutter/material.dart';
import '../../../data/models/territory_model.dart';
import '../../../data/repositories/territories_repository.dart';

class TerritoriesViewModel extends ChangeNotifier {
  final TerritoriesRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<DistrictModel> _allDistricts = [];
  List<SubDistrictModel> _allSubDistricts = [];
  List<AreaModel> _allAreas = [];

  String? _selectedDistrictId = 'dist_dhaka';
  String? _selectedSubDistrictId = 'sub_mirpur';
  String? _selectedAreaId = 'area_3';

  TerritoriesViewModel({TerritoriesRepository? repository})
      : _repository = repository ?? TerritoriesRepository() {
    loadData();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  String? get selectedDistrictId => _selectedDistrictId;
  String? get selectedSubDistrictId => _selectedSubDistrictId;
  String? get selectedAreaId => _selectedAreaId;

  DistrictModel? get selectedDistrict {
    try {
      return _allDistricts.firstWhere((d) => d.id == _selectedDistrictId);
    } catch (_) {
      return _allDistricts.isNotEmpty ? _allDistricts.first : null;
    }
  }

  SubDistrictModel? get selectedSubDistrict {
    try {
      return _allSubDistricts.firstWhere((s) => s.id == _selectedSubDistrictId);
    } catch (_) {
      return null;
    }
  }

  AreaModel? get selectedArea {
    try {
      return _allAreas.firstWhere((a) => a.id == _selectedAreaId);
    } catch (_) {
      return null;
    }
  }

  List<DistrictModel> get districts {
    if (_searchQuery.isEmpty) return _allDistricts;
    final q = _searchQuery.toLowerCase();
    return _allDistricts.where((d) => d.name.toLowerCase().contains(q) || d.code.contains(q)).toList();
  }

  List<SubDistrictModel> get subDistricts {
    final list = _allSubDistricts.where((s) => s.districtId == _selectedDistrictId).toList();
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((s) => s.name.toLowerCase().contains(q) || s.code.contains(q)).toList();
  }

  List<AreaModel> get areas {
    final list = _allAreas.where((a) => a.subDistrictId == _selectedSubDistrictId).toList();
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((a) {
      return a.name.toLowerCase().contains(q) ||
          a.code.contains(q) ||
          (a.assignedSalesman?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allDistricts = await _repository.getDistricts();
      _allSubDistricts = await _repository.getSubDistricts(null);
      _allAreas = await _repository.getAreas(null);

      // Verify selections
      if (!_allDistricts.any((d) => d.id == _selectedDistrictId) && _allDistricts.isNotEmpty) {
        _selectedDistrictId = _allDistricts.first.id;
      }
      final currentSubs = _allSubDistricts.where((s) => s.districtId == _selectedDistrictId).toList();
      if (!currentSubs.any((s) => s.id == _selectedSubDistrictId)) {
        _selectedSubDistrictId = currentSubs.isNotEmpty ? currentSubs.first.id : null;
      }
      final currentAreas = _allAreas.where((a) => a.subDistrictId == _selectedSubDistrictId).toList();
      if (!currentAreas.any((a) => a.id == _selectedAreaId)) {
        _selectedAreaId = currentAreas.isNotEmpty ? currentAreas.first.id : null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load territories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectDistrict(String districtId) {
    _selectedDistrictId = districtId;
    final subs = _allSubDistricts.where((s) => s.districtId == districtId).toList();
    _selectedSubDistrictId = subs.isNotEmpty ? subs.first.id : null;
    if (_selectedSubDistrictId != null) {
      final ars = _allAreas.where((a) => a.subDistrictId == _selectedSubDistrictId).toList();
      _selectedAreaId = ars.isNotEmpty ? ars.first.id : null;
    } else {
      _selectedAreaId = null;
    }
    notifyListeners();
  }

  void selectSubDistrict(String subDistrictId) {
    _selectedSubDistrictId = subDistrictId;
    final ars = _allAreas.where((a) => a.subDistrictId == subDistrictId).toList();
    _selectedAreaId = ars.isNotEmpty ? ars.first.id : null;
    notifyListeners();
  }

  void selectArea(String areaId) {
    _selectedAreaId = areaId;
    notifyListeners();
  }

  // --- District CRUD ---
  Future<bool> addDistrict(DistrictModel district) async {
    try {
      final res = await _repository.addDistrict(district);
      _allDistricts.add(res);
      selectDistrict(res.id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add district: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDistrict(DistrictModel district) async {
    try {
      final res = await _repository.updateDistrict(district);
      final idx = _allDistricts.indexWhere((d) => d.id == res.id);
      if (idx != -1) {
        _allDistricts[idx] = res;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update district: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDistrict(String id) async {
    try {
      final success = await _repository.deleteDistrict(id);
      if (success) {
        _allDistricts.removeWhere((d) => d.id == id);
        _allSubDistricts.removeWhere((s) => s.districtId == id);
        if (_selectedDistrictId == id) {
          _selectedDistrictId = _allDistricts.isNotEmpty ? _allDistricts.first.id : null;
          selectDistrict(_selectedDistrictId ?? '');
        } else {
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete district: $e';
      notifyListeners();
      return false;
    }
  }

  // --- SubDistrict CRUD ---
  Future<bool> addSubDistrict(SubDistrictModel subDistrict) async {
    try {
      final res = await _repository.addSubDistrict(subDistrict);
      _allSubDistricts.add(res);
      selectSubDistrict(res.id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add sub-district: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSubDistrict(SubDistrictModel subDistrict) async {
    try {
      final res = await _repository.updateSubDistrict(subDistrict);
      final idx = _allSubDistricts.indexWhere((s) => s.id == res.id);
      if (idx != -1) {
        _allSubDistricts[idx] = res;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update sub-district: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSubDistrict(String id) async {
    try {
      final success = await _repository.deleteSubDistrict(id);
      if (success) {
        _allSubDistricts.removeWhere((s) => s.id == id);
        _allAreas.removeWhere((a) => a.subDistrictId == id);
        if (_selectedSubDistrictId == id) {
          final remaining = _allSubDistricts.where((s) => s.districtId == _selectedDistrictId).toList();
          _selectedSubDistrictId = remaining.isNotEmpty ? remaining.first.id : null;
          if (_selectedSubDistrictId != null) {
            selectSubDistrict(_selectedSubDistrictId!);
          } else {
            _selectedAreaId = null;
            notifyListeners();
          }
        } else {
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete sub-district: $e';
      notifyListeners();
      return false;
    }
  }

  // --- Area CRUD ---
  Future<bool> addArea(AreaModel area) async {
    try {
      final res = await _repository.addArea(area);
      _allAreas.add(res);
      selectArea(res.id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add area: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateArea(AreaModel area) async {
    try {
      final res = await _repository.updateArea(area);
      final idx = _allAreas.indexWhere((a) => a.id == res.id);
      if (idx != -1) {
        _allAreas[idx] = res;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update area: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteArea(String id) async {
    try {
      final success = await _repository.deleteArea(id);
      if (success) {
        _allAreas.removeWhere((a) => a.id == id);
        if (_selectedAreaId == id) {
          final remaining = _allAreas.where((a) => a.subDistrictId == _selectedSubDistrictId).toList();
          _selectedAreaId = remaining.isNotEmpty ? remaining.first.id : null;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete area: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignSalesman(String areaId, String salesmanName, String? salesmanId) async {
    try {
      final res = await _repository.assignSalesman(areaId, salesmanName, salesmanId);
      if (res != null) {
        final idx = _allAreas.indexWhere((a) => a.id == areaId);
        if (idx != -1) {
          _allAreas[idx] = res;
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to assign salesman: $e';
      notifyListeners();
      return false;
    }
  }
}
