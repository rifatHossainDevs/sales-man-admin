class SalesmanModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String nid;
  final int totalOrders;
  final double totalCollected;
  final String lastSeen;
  final bool isOnline;
  final String status; // 'Active', 'Inactive', 'Pending'
  final String? appliedDate;
  final String assignedTerritory;
  final String avatarInitials;

  const SalesmanModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nid,
    this.totalOrders = 0,
    this.totalCollected = 0.0,
    this.lastSeen = 'Online',
    this.isOnline = true,
    this.status = 'Active',
    this.appliedDate,
    this.assignedTerritory = 'Mirpur, Dhaka',
    required this.avatarInitials,
  });

  bool get isActive => status == 'Active';
  bool get isPending => status == 'Pending';

  SalesmanModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? nid,
    int? totalOrders,
    double? totalCollected,
    String? lastSeen,
    bool? isOnline,
    String? status,
    String? appliedDate,
    String? assignedTerritory,
    String? avatarInitials,
  }) {
    return SalesmanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nid: nid ?? this.nid,
      totalOrders: totalOrders ?? this.totalOrders,
      totalCollected: totalCollected ?? this.totalCollected,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      assignedTerritory: assignedTerritory ?? this.assignedTerritory,
      avatarInitials: avatarInitials ?? this.avatarInitials,
    );
  }
}
