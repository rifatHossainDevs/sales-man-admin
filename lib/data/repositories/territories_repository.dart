import '../mock/mock_territories_data.dart';
import '../models/territory_model.dart';

class TerritoriesRepository {
  final List<DistrictModel> _districts = List.from(MockTerritoriesData.getDistricts());
  final List<SubDistrictModel> _subDistricts = List.from(MockTerritoriesData.getSubDistricts());
  final List<AreaModel> _areas = List.from(MockTerritoriesData.getAreas());

  // --- Districts ---
  Future<List<DistrictModel>> getDistricts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_districts);
  }

  Future<DistrictModel> addDistrict(DistrictModel district) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _districts.add(district);
    return district;
  }

  Future<DistrictModel> updateDistrict(DistrictModel district) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _districts.indexWhere((d) => d.id == district.id);
    if (index != -1) {
      _districts[index] = district;
    }
    return district;
  }

  Future<bool> deleteDistrict(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _districts.removeWhere((d) => d.id == id);
    _subDistricts.removeWhere((sd) => sd.districtId == id);
    return true;
  }

  // --- Sub-districts ---
  Future<List<SubDistrictModel>> getSubDistricts(String? districtId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (districtId == null) return List.from(_subDistricts);
    return _subDistricts.where((s) => s.districtId == districtId).toList();
  }

  Future<SubDistrictModel> addSubDistrict(SubDistrictModel subDistrict) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _subDistricts.add(subDistrict);
    return subDistrict;
  }

  Future<SubDistrictModel> updateSubDistrict(SubDistrictModel subDistrict) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _subDistricts.indexWhere((s) => s.id == subDistrict.id);
    if (index != -1) {
      _subDistricts[index] = subDistrict;
    }
    return subDistrict;
  }

  Future<bool> deleteSubDistrict(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _subDistricts.removeWhere((s) => s.id == id);
    _areas.removeWhere((a) => a.subDistrictId == id);
    return true;
  }

  // --- Areas ---
  Future<List<AreaModel>> getAreas(String? subDistrictId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (subDistrictId == null) return List.from(_areas);
    return _areas.where((a) => a.subDistrictId == subDistrictId).toList();
  }

  Future<AreaModel> addArea(AreaModel area) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _areas.add(area);
    return area;
  }

  Future<AreaModel> updateArea(AreaModel area) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _areas.indexWhere((a) => a.id == area.id);
    if (index != -1) {
      _areas[index] = area;
    }
    return area;
  }

  Future<bool> deleteArea(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _areas.removeWhere((a) => a.id == id);
    return true;
  }

  Future<AreaModel?> assignSalesman(String areaId, String salesmanName, String? salesmanId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _areas.indexWhere((a) => a.id == areaId);
    if (index != -1) {
      _areas[index] = _areas[index].copyWith(
        assignedSalesman: salesmanName,
        assignedSalesmanId: salesmanId,
      );
      return _areas[index];
    }
    return null;
  }
}
