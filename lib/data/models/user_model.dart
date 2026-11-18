class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String dealershipName;
  final String avatarInitials;
  final String companyId;
  final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.dealershipName,
    required this.avatarInitials,
    required this.companyId,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? json['userType'] as String? ?? '',
      dealershipName: json['dealershipName'] as String? ?? '',
      avatarInitials: json['avatarInitials'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      token: json['token'] as String? ?? json['accessToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'dealershipName': dealershipName,
      'avatarInitials': avatarInitials,
      'companyId': companyId,
      'token': token,
    };
  }
}
