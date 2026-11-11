class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String dealershipName;
  final String avatarInitials;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.dealershipName,
    required this.avatarInitials,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      dealershipName: json['dealershipName'] as String,
      avatarInitials: json['avatarInitials'] as String,
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
    };
  }
}
