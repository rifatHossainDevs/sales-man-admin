class SalesmanDutyModel {
  final String id;
  final String name;
  final String initials;
  final String location;
  final String lastSeenTime;
  final int ordersCount;
  final bool isOnline;

  SalesmanDutyModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.location,
    this.lastSeenTime = '',
    required this.ordersCount,
    this.isOnline = true,
  });
}
