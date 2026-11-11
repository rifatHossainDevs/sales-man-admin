class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String sku;
  final String description;
  final String category;
  final String supplier;
  final double price;
  final double? offerPrice;
  final int stock;
  final String unit;
  final bool isActive;
  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.sku,
    required this.description,
    required this.category,
    required this.supplier,
    required this.price,
    this.offerPrice,
    required this.stock,
    required this.unit,
    this.isActive = true,
    this.imageUrl,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? sku,
    String? description,
    String? category,
    String? supplier,
    double? price,
    double? offerPrice,
    int? stock,
    String? unit,
    bool? isActive,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      price: price ?? this.price,
      offerPrice: offerPrice ?? this.offerPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
