class DistrictModel {
  final String id;
  final String divisionId;
  final String name;
  final String code;
  final int retailersCount;

  const DistrictModel({
    required this.id,
    this.divisionId = 'div_dhaka',
    required this.name,
    required this.code,
    required this.retailersCount,
  });

  DistrictModel copyWith({
    String? id,
    String? divisionId,
    String? name,
    String? code,
    int? retailersCount,
  }) {
    return DistrictModel(
      id: id ?? this.id,
      divisionId: divisionId ?? this.divisionId,
      name: name ?? this.name,
      code: code ?? this.code,
      retailersCount: retailersCount ?? this.retailersCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'divisionId': divisionId,
      'name': name,
      'code': code,
      'retailersCount': retailersCount,
    };
  }

  factory DistrictModel.fromMap(Map<String, dynamic> map) {
    return DistrictModel(
      id: map['id'] ?? '',
      divisionId: map['divisionId'] ?? 'div_dhaka',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      retailersCount: map['retailersCount'] ?? 0,
    );
  }
}

class SubDistrictModel {
  final String id;
  final String districtId;
  final String name;
  final String code;
  final int retailersCount;

  const SubDistrictModel({
    required this.id,
    required this.districtId,
    required this.name,
    required this.code,
    required this.retailersCount,
  });

  SubDistrictModel copyWith({
    String? id,
    String? districtId,
    String? name,
    String? code,
    int? retailersCount,
  }) {
    return SubDistrictModel(
      id: id ?? this.id,
      districtId: districtId ?? this.districtId,
      name: name ?? this.name,
      code: code ?? this.code,
      retailersCount: retailersCount ?? this.retailersCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'districtId': districtId,
      'name': name,
      'code': code,
      'retailersCount': retailersCount,
    };
  }

  factory SubDistrictModel.fromMap(Map<String, dynamic> map) {
    return SubDistrictModel(
      id: map['id'] ?? '',
      districtId: map['districtId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      retailersCount: map['retailersCount'] ?? 0,
    );
  }
}

class AreaModel {
  final String id;
  final String subDistrictId;
  final String name;
  final String code;
  final int retailersCount;
  final String? assignedSalesman;
  final String? assignedSalesmanId;

  const AreaModel({
    required this.id,
    required this.subDistrictId,
    required this.name,
    required this.code,
    required this.retailersCount,
    this.assignedSalesman,
    this.assignedSalesmanId,
  });

  AreaModel copyWith({
    String? id,
    String? subDistrictId,
    String? name,
    String? code,
    int? retailersCount,
    String? assignedSalesman,
    String? assignedSalesmanId,
  }) {
    return AreaModel(
      id: id ?? this.id,
      subDistrictId: subDistrictId ?? this.subDistrictId,
      name: name ?? this.name,
      code: code ?? this.code,
      retailersCount: retailersCount ?? this.retailersCount,
      assignedSalesman: assignedSalesman ?? this.assignedSalesman,
      assignedSalesmanId: assignedSalesmanId ?? this.assignedSalesmanId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subDistrictId': subDistrictId,
      'name': name,
      'code': code,
      'retailersCount': retailersCount,
      'assignedSalesman': assignedSalesman,
      'assignedSalesmanId': assignedSalesmanId,
    };
  }

  factory AreaModel.fromMap(Map<String, dynamic> map) {
    return AreaModel(
      id: map['id'] ?? '',
      subDistrictId: map['subDistrictId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      retailersCount: map['retailersCount'] ?? 0,
      assignedSalesman: map['assignedSalesman'],
      assignedSalesmanId: map['assignedSalesmanId'],
    );
  }
}
