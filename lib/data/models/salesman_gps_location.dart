class SalesmanGpsLocation {
  final String salesmanId;
  final String name;
  final String initials;
  final String territory;
  final double latitude;
  final double longitude;
  final String placeName;
  final DateTime updatedAt;
  final bool isOnline;
  final String phone;
  final int totalOrders;

  const SalesmanGpsLocation({
    required this.salesmanId,
    required this.name,
    required this.initials,
    required this.territory,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    required this.updatedAt,
    required this.isOnline,
    this.phone = '',
    this.totalOrders = 0,
  });

  SalesmanGpsLocation copyWith({
    double? latitude,
    double? longitude,
    String? placeName,
    DateTime? updatedAt,
    bool? isOnline,
    String? phone,
    int? totalOrders,
  }) => SalesmanGpsLocation(
    salesmanId: salesmanId,
    name: name,
    initials: initials,
    territory: territory,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    placeName: placeName ?? this.placeName,
    updatedAt: updatedAt ?? this.updatedAt,
    isOnline: isOnline ?? this.isOnline,
    phone: phone ?? this.phone,
    totalOrders: totalOrders ?? this.totalOrders,
  );
}
