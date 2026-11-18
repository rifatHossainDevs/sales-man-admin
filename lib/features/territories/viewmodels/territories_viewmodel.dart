import 'package:flutter/material.dart';
import '../../../data/models/territory_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/salesmen_repository.dart';
import '../../../data/repositories/territories_repository.dart';

class TerritoriesViewModel extends ChangeNotifier {
  final TerritoriesRepository _repository;
  final SalesmenRepository _salesmenRepository;

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<DivisionModel> _divisions = [];
  List<DistrictModel> _allDistricts = [];
  List<SubDistrictModel> _allSubDistricts = [];
  List<AreaModel> _allAreas = [];
  List<String> _salesmenNames = [];

  String _selectedDivisionCode = 'all';
  String? _selectedDistrictId;
  String? _selectedSubDistrictId;
  String? _selectedAreaId;

  TerritoriesViewModel({
    TerritoriesRepository? repository,
    SalesmenRepository? salesmenRepository,
  })  : _repository = repository ?? TerritoriesRepository(),
        _salesmenRepository = salesmenRepository ?? SalesmenRepository() {
    loadData();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<DivisionModel> get divisions => _divisions;
  List<String> get salesmenNames => _salesmenNames;
  String get selectedDivisionCode => _selectedDivisionCode;
  String? get selectedDistrictId => _selectedDistrictId;
  String? get selectedSubDistrictId => _selectedSubDistrictId;
  String? get selectedAreaId => _selectedAreaId;

  String get selectedDivisionName {
    if (_selectedDivisionCode == 'all') return 'All Divisions';
    for (final div in _divisions) {
      if (div.code == _selectedDivisionCode || div.id == _selectedDivisionCode) {
        return div.name;
      }
    }
    return 'Dhaka';
  }

  DistrictModel? get selectedDistrict {
    try {
      return _allDistricts.firstWhere((d) => d.id == _selectedDistrictId);
    } catch (_) {
      return districts.isNotEmpty ? districts.first : null;
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

  bool _belongsToDistrict(SubDistrictModel sub, DistrictModel? dist) {
    if (dist == null) return false;
    return sub.districtId == dist.id || sub.districtId == dist.code;
  }

  bool _belongsToSubDistrict(AreaModel area, SubDistrictModel? sub) {
    if (sub == null) return false;
    return area.subDistrictId == sub.id || area.subDistrictId == sub.code;
  }

  List<DistrictModel> get districts {
    var list = _allDistricts;
    if (_selectedDivisionCode != 'all') {
      list = list.where((d) => d.divisionId == _selectedDivisionCode).toList();
    }
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((d) => d.name.toLowerCase().contains(q) || d.code.contains(q)).toList();
  }

  List<SubDistrictModel> get subDistricts {
    final dist = selectedDistrict;
    final list = _allSubDistricts.where((s) => _belongsToDistrict(s, dist)).toList();
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list.where((s) => s.name.toLowerCase().contains(q) || s.code.contains(q)).toList();
  }

  List<AreaModel> get areas {
    final sub = selectedSubDistrict;
    final list = _allAreas.where((a) => _belongsToSubDistrict(a, sub)).toList();
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
      final cid = AuthRepository().loadSavedUserSync()?.companyId;
      final results = await Future.wait([
        _repository.getDivisions(),
        _repository.getDistricts(),
        _repository.getSubDistricts(null),
        _repository.getAreas(null),
        _salesmenRepository.getSalesmen(companyId: cid),
      ]);

      _divisions = results[0] as List<DivisionModel>;
      _allDistricts = results[1] as List<DistrictModel>;
      _allSubDistricts = results[2] as List<SubDistrictModel>;
      _allAreas = results[3] as List<AreaModel>;
      final salesmenList = results[4] as List;
      _salesmenNames = salesmenList
          .where((s) => s.status != 'Pending')
          .map<String>((s) => s.name.toString())
          .toSet()
          .toList();

      _syncSelections();
    } catch (e) {
      _errorMessage = 'Failed to load territories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _syncSelections() {
    final visibleDistricts = districts;
    if (!visibleDistricts.any((d) => d.id == _selectedDistrictId)) {
      _selectedDistrictId = visibleDistricts.isNotEmpty ? visibleDistricts.first.id : null;
    }

    final dist = selectedDistrict;
    final currentSubs = _allSubDistricts.where((s) => _belongsToDistrict(s, dist)).toList();
    if (!currentSubs.any((s) => s.id == _selectedSubDistrictId)) {
      _selectedSubDistrictId = currentSubs.isNotEmpty ? currentSubs.first.id : null;
    }

    final sub = selectedSubDistrict;
    final currentAreas = _allAreas.where((a) => _belongsToSubDistrict(a, sub)).toList();
    if (!currentAreas.any((a) => a.id == _selectedAreaId)) {
      _selectedAreaId = currentAreas.isNotEmpty ? currentAreas.first.id : null;
    }
  }

  void selectDivision(String divisionCode) {
    _selectedDivisionCode = divisionCode;
    _syncSelections();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectDistrict(String districtId) {
    _selectedDistrictId = districtId;
    final dist = selectedDistrict;
    final subs = _allSubDistricts.where((s) => _belongsToDistrict(s, dist)).toList();
    _selectedSubDistrictId = subs.isNotEmpty ? subs.first.id : null;
    if (_selectedSubDistrictId != null) {
      final sub = selectedSubDistrict;
      final ars = _allAreas.where((a) => _belongsToSubDistrict(a, sub)).toList();
      _selectedAreaId = ars.isNotEmpty ? ars.first.id : null;
    } else {
      _selectedAreaId = null;
    }
    notifyListeners();
  }

  void selectSubDistrict(String subDistrictId) {
    _selectedSubDistrictId = subDistrictId;
    final sub = selectedSubDistrict;
    final ars = _allAreas.where((a) => _belongsToSubDistrict(a, sub)).toList();
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
      if (_selectedDivisionCode != 'all' && _selectedDivisionCode != res.divisionId) {
        _selectedDivisionCode = 'all';
      }
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
      final idx = _allDistricts.indexWhere((d) => d.id == district.id || d.id == res.id);
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
      DistrictModel? target;
      for (final d in _allDistricts) {
        if (d.id == id) target = d;
      }
      final success = await _repository.deleteDistrict(id);
      if (success) {
        _allDistricts.removeWhere((d) => d.id == id);
        _allSubDistricts.removeWhere((s) => _belongsToDistrict(s, target));
        _syncSelections();
        notifyListeners();
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
      final dist = selectedDistrict;
      final normalized = dist != null
          ? subDistrict.copyWith(districtId: dist.code)
          : subDistrict;
      final res = await _repository.addSubDistrict(normalized);
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
      final idx = _allSubDistricts.indexWhere((s) => s.id == subDistrict.id || s.id == res.id);
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
      SubDistrictModel? target;
      for (final s in _allSubDistricts) {
        if (s.id == id) target = s;
      }
      final success = await _repository.deleteSubDistrict(id);
      if (success) {
        _allSubDistricts.removeWhere((s) => s.id == id);
        _allAreas.removeWhere((a) => _belongsToSubDistrict(a, target));
        _syncSelections();
        notifyListeners();
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
      final sub = selectedSubDistrict;
      final normalized = sub != null
          ? area.copyWith(subDistrictId: sub.code)
          : area;
      final res = await _repository.addArea(normalized);
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
      final idx = _allAreas.indexWhere((a) => a.id == area.id || a.id == res.id);
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
        _syncSelections();
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
