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
  });

  SalesmanGpsLocation copyWith({
    double? latitude,
    double? longitude,
    String? placeName,
    DateTime? updatedAt,
    bool? isOnline,
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
  );
}
