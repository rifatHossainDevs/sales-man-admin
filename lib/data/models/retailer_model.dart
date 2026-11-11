class RetailerOrderSummary {
  final String invoiceNo;
  final String date;
  final double amount;
  final String status;

  const RetailerOrderSummary({
    required this.invoiceNo,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class RetailerModel {
  final String id;
  final String storeName;
  final String ownerName;
  final String phone;
  final String division;
  final String district;
  final String subDistrict;
  final String area;
  final String address;
  final String registeredBy;
  final String registeredDate;
  final int ordersCount;
  final double dueAmount;
  final bool isGpsMapped;
  final double lat;
  final double lng;
  final List<RetailerOrderSummary> orderHistory;

  const RetailerModel({
    required this.id,
    required this.storeName,
    required this.ownerName,
    required this.phone,
    this.division = 'Dhaka',
    this.district = 'Dhaka',
    required this.subDistrict,
    required this.area,
    required this.address,
    required this.registeredBy,
    required this.registeredDate,
    this.ordersCount = 0,
    this.dueAmount = 0.0,
    this.isGpsMapped = true,
    this.lat = 23.8069,
    this.lng = 90.3687,
    this.orderHistory = const [],
  });

  RetailerModel copyWith({
    String? id,
    String? storeName,
    String? ownerName,
    String? phone,
    String? division,
    String? district,
    String? subDistrict,
    String? area,
    String? address,
    String? registeredBy,
    String? registeredDate,
    int? ordersCount,
    double? dueAmount,
    bool? isGpsMapped,
    double? lat,
    double? lng,
    List<RetailerOrderSummary>? orderHistory,
  }) {
    return RetailerModel(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      division: division ?? this.division,
      district: district ?? this.district,
      subDistrict: subDistrict ?? this.subDistrict,
      area: area ?? this.area,
      address: address ?? this.address,
      registeredBy: registeredBy ?? this.registeredBy,
      registeredDate: registeredDate ?? this.registeredDate,
      ordersCount: ordersCount ?? this.ordersCount,
      dueAmount: dueAmount ?? this.dueAmount,
      isGpsMapped: isGpsMapped ?? this.isGpsMapped,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      orderHistory: orderHistory ?? this.orderHistory,
    );
  }
}
