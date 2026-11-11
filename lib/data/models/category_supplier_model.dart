class CategoryModel {
  final String id;
  final String name;
  final String description;
  final int productCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.productCount,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? productCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productCount: productCount ?? this.productCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'productCount': productCount,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      productCount: map['productCount'] ?? 0,
    );
  }
}

class SupplierModel {
  final String id;
  final String name;
  final String location;
  final String phone;
  final String email;
  final int productCount;

  const SupplierModel({
    required this.id,
    required this.name,
    required this.location,
    required this.phone,
    required this.email,
    required this.productCount,
  });

  SupplierModel copyWith({
    String? id,
    String? name,
    String? location,
    String? phone,
    String? email,
    int? productCount,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      productCount: productCount ?? this.productCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'phone': phone,
      'email': email,
      'productCount': productCount,
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      productCount: map['productCount'] ?? 0,
    );
  }
}
