import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/utils/web_platform.dart';
import '../models/territory_model.dart';
import '../mock/mock_territories_data.dart';
import 'auth_repository.dart';

class TerritoriesRepository {
  final http.Client _client;
  static const String _assignmentsStorageKey = 'territory_area_salesman_assignments';

  final List<DistrictModel> _districts = List.from(MockTerritoriesData.getDistricts());
  final List<SubDistrictModel> _subDistricts = List.from(MockTerritoriesData.getSubDistricts());
  final List<AreaModel> _areas = List.from(MockTerritoriesData.getAreas());

  TerritoriesRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _loadSavedAssignments() {
    try {
      final raw = WebPlatform.getLocalStorageItem(_assignmentsStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(raw);
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    return {};
  }

  void _saveAssignment(String key, String? salesmanName) {
    try {
      final map = _loadSavedAssignments();
      if (salesmanName == null || salesmanName.trim().isEmpty || salesmanName == 'Unassigned') {
        map.remove(key);
      } else {
        map[key] = salesmanName.trim();
      }
      WebPlatform.setLocalStorageItem(_assignmentsStorageKey, json.encode(map));
    } catch (_) {}
  }

  Future<Map<String, Map<String, int>>> _fetchRetailerCounts() async {
    final Map<String, int> byAreaCode = {};
    final Map<String, int> bySubDisCode = {};
    try {
      final user = AuthRepository().loadSavedUserSync();
      final cid = user?.companyId;
      final response = await _client.get(
        Uri.parse('${ApiConstants.stores}?limit=500'),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List stores = decoded['data'] is Map
            ? (decoded['data']['stores'] ?? [])
            : (decoded['data'] is List ? decoded['data'] : []);
        for (final st in stores) {
          if (cid != null && cid.isNotEmpty && !cid.startsWith('cmp_')) {
            final storeCid = (st['underCompanyId'] ?? '').toString();
            if (storeCid.isNotEmpty && storeCid != cid) continue;
          }
          final areaCode = (st['areaNo'] ?? '').toString();
          final subCode = (st['subDisNo'] ?? '').toString();
          if (areaCode.isNotEmpty) {
            byAreaCode[areaCode] = (byAreaCode[areaCode] ?? 0) + 1;
          }
          if (subCode.isNotEmpty) {
            bySubDisCode[subCode] = (bySubDisCode[subCode] ?? 0) + 1;
          }
        }
      }
    } catch (_) {}
    return {'area': byAreaCode, 'subDis': bySubDisCode};
  }

  // --- Divisions ---
  Future<List<DivisionModel>> getDivisions() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.divisions),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          return data.map((item) {
            return DivisionModel(
              id: (item['_id'] ?? '').toString(),
              name: (item['divName'] ?? '').toString(),
              code: (item['divNo'] ?? '1').toString(),
            );
          }).toList();
        }
      }
    } catch (_) {}

    return const [
      DivisionModel(id: '1', name: 'Dhaka', code: '1'),
      DivisionModel(id: '2', name: 'Chattogram', code: '2'),
      DivisionModel(id: '3', name: 'Rajshahi', code: '3'),
      DivisionModel(id: '4', name: 'Khulna', code: '4'),
      DivisionModel(id: '5', name: 'Barishal', code: '5'),
      DivisionModel(id: '6', name: 'Sylhet', code: '6'),
      DivisionModel(id: '7', name: 'Rangpur', code: '7'),
      DivisionModel(id: '8', name: 'Mymensingh', code: '8'),
    ];
  }

  // --- Districts ---
  Future<List<DistrictModel>> getDistricts() async {
    try {
      final counts = await _fetchRetailerCounts();
      final response = await _client.get(
        Uri.parse(ApiConstants.districts),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          final loaded = data.map((item) {
            final code = (item['disNo'] ?? '1').toString();
            // Sum retailers for sub-districts belonging to this district prefix or loaded later
            int retailCount = 0;
            counts['subDis']?.forEach((subCode, cnt) {
              if (subCode.startsWith(code)) retailCount += cnt;
            });
            return DistrictModel(
              id: (item['_id'] ?? '').toString(),
              divisionId: (item['divNo'] ?? '1').toString(),
              name: (item['disName'] ?? '').toString(),
              code: code,
              retailersCount: retailCount,
            );
          }).toList();
          loaded.sort((a, b) => (int.tryParse(a.code) ?? 0).compareTo(int.tryParse(b.code) ?? 0));
          _districts
            ..clear()
            ..addAll(loaded);
          return List.from(_districts);
        }
      }
    } catch (_) {}

    return List.from(_districts);
  }

  Future<DistrictModel> addDistrict(DistrictModel district) async {
    final disNo = int.tryParse(district.code.trim()) ??
        (_districts.fold<int>(0, (m, d) => (int.tryParse(d.code) ?? 0) > m ? int.parse(d.code) : m) + 1);
    final divNo = int.tryParse(district.divisionId.trim()) ?? 1;

    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.addDistrict),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'disName': district.name.trim(),
          'disNo': disNo,
          'divNo': divNo,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final item = json.decode(response.body)['data'] ?? {};
        final created = DistrictModel(
          id: (item['_id'] ?? district.id).toString(),
          divisionId: (item['divNo'] ?? divNo).toString(),
          name: (item['disName'] ?? district.name).toString(),
          code: (item['disNo'] ?? disNo).toString(),
          retailersCount: district.retailersCount,
        );
        _districts.add(created);
        return created;
      }
    } catch (_) {}

    final fallback = district.copyWith(code: disNo.toString(), divisionId: divNo.toString());
    _districts.add(fallback);
    return fallback;
  }

  Future<DistrictModel> updateDistrict(DistrictModel district) async {
    final disNo = int.tryParse(district.code.trim()) ?? 1;
    final divNo = int.tryParse(district.divisionId.trim()) ?? 1;

    try {
      final response = await _client.patch(
        Uri.parse(ApiConstants.updateDistrict(district.id)),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'disName': district.name.trim(),
          'disNo': disNo,
          'divNo': divNo,
        }),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body)['data'] ?? {};
        final updated = district.copyWith(
          id: (item['_id'] ?? district.id).toString(),
          divisionId: (item['divNo'] ?? divNo).toString(),
          name: (item['disName'] ?? district.name).toString(),
          code: (item['disNo'] ?? disNo).toString(),
        );
        final index = _districts.indexWhere((d) => d.id == district.id);
        if (index != -1) _districts[index] = updated;
        return updated;
      }
    } catch (_) {}

    final index = _districts.indexWhere((d) => d.id == district.id);
    if (index != -1) {
      _districts[index] = district;
    }
    return district;
  }

  Future<bool> deleteDistrict(String id) async {
    DistrictModel? target;
    for (final d in _districts) {
      if (d.id == id) target = d;
    }
    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.deleteDistrict(id)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        _districts.removeWhere((d) => d.id == id);
        _subDistricts.removeWhere((sd) => sd.districtId == id || (target != null && sd.districtId == target.code));
        return true;
      }
    } catch (_) {}

    _districts.removeWhere((d) => d.id == id);
    _subDistricts.removeWhere((sd) => sd.districtId == id || (target != null && sd.districtId == target.code));
    return true;
  }

  int _resolveDisNo(String districtIdOrCode) {
    final direct = int.tryParse(districtIdOrCode.trim());
    if (direct != null) return direct;
    for (final d in _districts) {
      if (d.id == districtIdOrCode) {
        return int.tryParse(d.code) ?? 1;
      }
    }
    return 1;
  }

  // --- Sub-districts ---
  Future<List<SubDistrictModel>> getSubDistricts(String? districtId) async {
    try {
      final counts = await _fetchRetailerCounts();
      final url = (districtId != null && districtId.isNotEmpty)
          ? ApiConstants.subDistrictsByDis(_resolveDisNo(districtId).toString())
          : ApiConstants.subDistricts;
      final response = await _client.get(Uri.parse(url), headers: AuthRepository.getAuthHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          final loaded = data.map((item) {
            final code = (item['subDisNo'] ?? '101').toString();
            final disCode = (item['disNo'] ?? districtId ?? '1').toString();
            final retailCount = counts['subDis']?[code] ?? 0;
            return SubDistrictModel(
              id: (item['_id'] ?? '').toString(),
              districtId: disCode,
              name: (item['subDisName'] ?? '').toString(),
              code: code,
              retailersCount: retailCount,
            );
          }).toList();
          loaded.sort((a, b) => (int.tryParse(a.code) ?? 0).compareTo(int.tryParse(b.code) ?? 0));
          if (districtId == null) {
            _subDistricts
              ..clear()
              ..addAll(loaded);
          }
          return loaded;
        }
      }
    } catch (_) {}

    if (districtId == null) return List.from(_subDistricts);
    final disCode = _resolveDisNo(districtId).toString();
    return _subDistricts.where((s) => s.districtId == districtId || s.districtId == disCode).toList();
  }

  Future<SubDistrictModel> addSubDistrict(SubDistrictModel subDistrict) async {
    final disNo = _resolveDisNo(subDistrict.districtId);
    final subDisNo = int.tryParse(subDistrict.code.trim()) ??
        (_subDistricts.fold<int>(100, (m, s) => (int.tryParse(s.code) ?? 0) > m ? int.parse(s.code) : m) + 1);

    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.addSubDistrict),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'subDisName': subDistrict.name.trim(),
          'subDisNo': subDisNo,
          'disNo': disNo,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final item = json.decode(response.body)['data'] ?? {};
        final created = SubDistrictModel(
          id: (item['_id'] ?? subDistrict.id).toString(),
          districtId: (item['disNo'] ?? disNo).toString(),
          name: (item['subDisName'] ?? subDistrict.name).toString(),
          code: (item['subDisNo'] ?? subDisNo).toString(),
          retailersCount: subDistrict.retailersCount,
        );
        _subDistricts.add(created);
        return created;
      }
    } catch (_) {}

    final fallback = subDistrict.copyWith(
      districtId: disNo.toString(),
      code: subDisNo.toString(),
    );
    _subDistricts.add(fallback);
    return fallback;
  }

  Future<SubDistrictModel> updateSubDistrict(SubDistrictModel subDistrict) async {
    final disNo = _resolveDisNo(subDistrict.districtId);
    final subDisNo = int.tryParse(subDistrict.code.trim()) ?? 101;

    try {
      final response = await _client.patch(
        Uri.parse(ApiConstants.updateSubDistrict(subDistrict.id)),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'subDisName': subDistrict.name.trim(),
          'subDisNo': subDisNo,
          'disNo': disNo,
        }),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body)['data'] ?? {};
        final updated = subDistrict.copyWith(
          id: (item['_id'] ?? subDistrict.id).toString(),
          districtId: (item['disNo'] ?? disNo).toString(),
          name: (item['subDisName'] ?? subDistrict.name).toString(),
          code: (item['subDisNo'] ?? subDisNo).toString(),
        );
        final index = _subDistricts.indexWhere((s) => s.id == subDistrict.id);
        if (index != -1) _subDistricts[index] = updated;
        return updated;
      }
    } catch (_) {}

    final index = _subDistricts.indexWhere((s) => s.id == subDistrict.id);
    if (index != -1) {
      _subDistricts[index] = subDistrict;
    }
    return subDistrict;
  }

  Future<bool> deleteSubDistrict(String id) async {
    SubDistrictModel? target;
    for (final s in _subDistricts) {
      if (s.id == id) target = s;
    }
    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.deleteSubDistrict(id)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        _subDistricts.removeWhere((s) => s.id == id);
        _areas.removeWhere((a) => a.subDistrictId == id || (target != null && a.subDistrictId == target.code));
        return true;
      }
    } catch (_) {}

    _subDistricts.removeWhere((s) => s.id == id);
    _areas.removeWhere((a) => a.subDistrictId == id || (target != null && a.subDistrictId == target.code));
    return true;
  }

  int _resolveSubDisNo(String subDistrictIdOrCode) {
    final direct = int.tryParse(subDistrictIdOrCode.trim());
    if (direct != null) return direct;
    for (final s in _subDistricts) {
      if (s.id == subDistrictIdOrCode) {
        return int.tryParse(s.code) ?? 101;
      }
    }
    return 101;
  }

  // --- Areas ---
  Future<List<AreaModel>> getAreas(String? subDistrictId) async {
    try {
      final counts = await _fetchRetailerCounts();
      final savedAssignments = _loadSavedAssignments();
      final url = (subDistrictId != null && subDistrictId.isNotEmpty)
          ? ApiConstants.areasBySubDis(_resolveSubDisNo(subDistrictId).toString())
          : ApiConstants.areas;
      final response = await _client.get(Uri.parse(url), headers: AuthRepository.getAuthHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        if (data.isNotEmpty) {
          final loaded = data.map((item) {
            final id = (item['_id'] ?? '').toString();
            final code = (item['areaNo'] ?? '1001').toString();
            final subCode = (item['subdisNo'] ?? item['subDisNo'] ?? subDistrictId ?? '101').toString();
            final retailCount = counts['area']?[code] ?? 0;
            final assigned = savedAssignments[id] ??
                savedAssignments[code] ??
                item['salesmanName']?.toString();
            return AreaModel(
              id: id,
              subDistrictId: subCode,
              name: (item['areaName'] ?? '').toString(),
              code: code,
              retailersCount: retailCount,
              assignedSalesman: assigned,
            );
          }).toList();
          loaded.sort((a, b) => (int.tryParse(a.code) ?? 0).compareTo(int.tryParse(b.code) ?? 0));
          if (subDistrictId == null) {
            _areas
              ..clear()
              ..addAll(loaded);
          }
          return loaded;
        }
      }
    } catch (_) {}

    if (subDistrictId == null) return List.from(_areas);
    final subCode = _resolveSubDisNo(subDistrictId).toString();
    return _areas.where((a) => a.subDistrictId == subDistrictId || a.subDistrictId == subCode).toList();
  }

  Future<AreaModel> addArea(AreaModel area) async {
    final subdisNo = _resolveSubDisNo(area.subDistrictId);
    final areaNo = int.tryParse(area.code.trim()) ??
        (_areas.fold<int>(1000, (m, a) => (int.tryParse(a.code) ?? 0) > m ? int.parse(a.code) : m) + 1);

    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.addArea),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'areaName': area.name.trim(),
          'areaNo': areaNo,
          'subdisNo': subdisNo,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final item = json.decode(response.body)['data'] ?? {};
        final id = (item['_id'] ?? area.id).toString();
        final code = (item['areaNo'] ?? areaNo).toString();
        if (area.assignedSalesman != null && area.assignedSalesman!.isNotEmpty) {
          _saveAssignment(id, area.assignedSalesman);
          _saveAssignment(code, area.assignedSalesman);
        }
        final created = AreaModel(
          id: id,
          subDistrictId: (item['subdisNo'] ?? subdisNo).toString(),
          name: (item['areaName'] ?? area.name).toString(),
          code: code,
          retailersCount: area.retailersCount,
          assignedSalesman: area.assignedSalesman,
        );
        _areas.add(created);
        return created;
      }
    } catch (_) {}

    final fallback = area.copyWith(
      subDistrictId: subdisNo.toString(),
      code: areaNo.toString(),
    );
    if (fallback.assignedSalesman != null) {
      _saveAssignment(fallback.id, fallback.assignedSalesman);
      _saveAssignment(fallback.code, fallback.assignedSalesman);
    }
    _areas.add(fallback);
    return fallback;
  }

  Future<AreaModel> updateArea(AreaModel area) async {
    final subdisNo = _resolveSubDisNo(area.subDistrictId);
    final areaNo = int.tryParse(area.code.trim()) ?? 1001;

    _saveAssignment(area.id, area.assignedSalesman);
    _saveAssignment(areaNo.toString(), area.assignedSalesman);

    try {
      final response = await _client.patch(
        Uri.parse(ApiConstants.updateArea(area.id)),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'areaName': area.name.trim(),
          'areaNo': areaNo,
          'subdisNo': subdisNo,
        }),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body)['data'] ?? {};
        final updated = area.copyWith(
          id: (item['_id'] ?? area.id).toString(),
          subDistrictId: (item['subdisNo'] ?? subdisNo).toString(),
          name: (item['areaName'] ?? area.name).toString(),
          code: (item['areaNo'] ?? areaNo).toString(),
        );
        final index = _areas.indexWhere((a) => a.id == area.id);
        if (index != -1) _areas[index] = updated;
        return updated;
      }
    } catch (_) {}

    final index = _areas.indexWhere((a) => a.id == area.id);
    if (index != -1) {
      _areas[index] = area;
    }
    return area;
  }

  Future<bool> deleteArea(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.deleteArea(id)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        _areas.removeWhere((a) => a.id == id);
        _saveAssignment(id, null);
        return true;
      }
    } catch (_) {}

    _areas.removeWhere((a) => a.id == id);
    _saveAssignment(id, null);
    return true;
  }

  Future<AreaModel?> assignSalesman(String areaId, String salesmanName, String? salesmanId) async {
    final normalized = salesmanName.trim().isEmpty ? null : salesmanName.trim();
    _saveAssignment(areaId, normalized);

    final index = _areas.indexWhere((a) => a.id == areaId);
    if (index != -1) {
      _saveAssignment(_areas[index].code, normalized);
      _areas[index] = AreaModel(
        id: _areas[index].id,
        subDistrictId: _areas[index].subDistrictId,
        name: _areas[index].name,
        code: _areas[index].code,
        retailersCount: _areas[index].retailersCount,
        assignedSalesman: normalized,
        assignedSalesmanId: salesmanId,
      );
      return _areas[index];
    }
    return null;
  }
}
