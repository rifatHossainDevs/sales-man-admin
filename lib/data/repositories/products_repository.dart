import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../mock/mock_products_data.dart';
import '../models/category_supplier_model.dart';
import '../models/product_model.dart';
import 'auth_repository.dart';
import 'categories_suppliers_repository.dart';

class ProductsRepository {
  final http.Client _client;
  final CategoriesSuppliersRepository _catSupRepo;
  final List<ProductModel> _fallbackProducts = MockProductsData.getInitialProducts();

  // Valid 1x1 transparent PNG bytes used when creating a product via Multipart if no custom file is attached
  static final Uint8List _defaultPngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );

  ProductsRepository({
    http.Client? client,
    CategoriesSuppliersRepository? catSupRepo,
  })  : _client = client ?? http.Client(),
        _catSupRepo = catSupRepo ?? CategoriesSuppliersRepository(client: client);

  Future<List<ProductModel>> getProducts() async {
    try {
      final results = await Future.wait([
        _client.get(Uri.parse(ApiConstants.products)),
        _catSupRepo.getCategories(),
        _catSupRepo.getSuppliers(),
      ]);

      final response = results[0] as http.Response;
      final categories = results[1] as List<CategoryModel>;
      final suppliers = results[2] as List<SupplierModel>;

      final catById = {for (final c in categories) c.id: c.name};
      final supById = {for (final s in suppliers) s.id: s.name};

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((item) => _mapJsonToProduct(item, catById, supById)).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
    } catch (_) {}

    return List.from(_fallbackProducts);
  }

  ProductModel _mapJsonToProduct(
    Map<String, dynamic> item,
    Map<String, String> catById,
    Map<String, String> supById,
  ) {
    final catId = (item['categoryId'] ?? '').toString();
    final supId = (item['supplierID'] ?? '').toString();

    final categoryName = (item['categoryName'] ?? catById[catId] ?? 'General').toString();
    final supplierName = (item['supplierName'] ?? supById[supId] ?? 'General Supplier').toString();

    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
    final rawOffer = (item['offerPrice'] as num?)?.toDouble();
    final offerPrice = (rawOffer != null && rawOffer > 0 && rawOffer < price) ? rawOffer : null;

    String? firstImage;
    final imgField = item['imageUrl'];
    if (imgField is List && imgField.isNotEmpty) {
      firstImage = imgField.first?.toString();
    } else if (imgField is String && imgField.isNotEmpty) {
      firstImage = imgField;
    }

    return ProductModel(
      id: (item['_id'] ?? item['id'] ?? '').toString(),
      name: (item['productName'] ?? item['name'] ?? '').toString(),
      brand: (item['brandName'] ?? item['brand'] ?? '').toString(),
      sku: (item['sku'] ?? '').toString(),
      description: (item['description'] ?? '').toString(),
      category: categoryName,
      supplier: supplierName,
      price: price,
      offerPrice: offerPrice,
      stock: (item['stockQuantity'] as num?)?.toInt() ?? 0,
      unit: (item['unit'] ?? 'pcs').toString(),
      isActive: item['isActive'] ?? true,
      imageUrl: firstImage,
    );
  }

  Future<String> _resolveCategoryId(String categoryName) async {
    final cats = await _catSupRepo.getCategories();
    final match = cats
        .where((c) => c.name.toLowerCase() == categoryName.trim().toLowerCase())
        .firstOrNull;
    if (match != null && !match.id.startsWith('cat_')) {
      return match.id;
    }
    final created = await _catSupRepo.addCategory(
      CategoryModel(
        id: '',
        name: categoryName.trim(),
        description: '${categoryName.trim()} products',
        productCount: 0,
      ),
    );
    return created.id;
  }

  Future<String> _resolveSupplierId(String supplierName) async {
    final sups = await _catSupRepo.getSuppliers();
    final match = sups
        .where((s) => s.name.toLowerCase() == supplierName.trim().toLowerCase())
        .firstOrNull;
    if (match != null && !match.id.startsWith('sup_')) {
      return match.id;
    }
    final created = await _catSupRepo.addSupplier(
      SupplierModel(
        id: '',
        name: supplierName.trim(),
        location: 'Dhaka, Bangladesh',
        phone: '01700000000',
        email: 'info@supplier.com',
        productCount: 0,
      ),
    );
    return created.id;
  }

  Future<void> addProduct(ProductModel product, {Uint8List? imageBytes, String? imageName}) async {
    try {
      final categoryId = await _resolveCategoryId(product.category);
      final supplierID = await _resolveSupplierId(product.supplier);
      final effectiveOffer = product.offerPrice ?? product.price;

      final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.addProduct));
      final authHeaders = AuthRepository.getAuthHeaders();
      if (authHeaders['Authorization'] != null) {
        request.headers['Authorization'] = authHeaders['Authorization']!;
      }

      request.fields['productName'] = product.name;
      request.fields['supplierID'] = supplierID;
      request.fields['brandName'] = product.brand;
      request.fields['description'] = product.description;
      request.fields['price'] = product.price.toStringAsFixed(0);
      request.fields['offerPrice'] = effectiveOffer.toStringAsFixed(0);
      request.fields['stockQuantity'] = product.stock.toString();
      request.fields['categoryId'] = categoryId;
      request.fields['unit'] = product.unit;
      request.fields['sku'] = product.sku;
      request.fields['isActive'] = product.isActive.toString();

      final bytesToUpload = imageBytes ?? _defaultPngBytes;
      final fileNameToUse = imageName ?? 'product_cover.png';
      request.files.add(
        http.MultipartFile.fromBytes(
          'imageUrl',
          bytesToUpload,
          filename: fileNameToUse,
        ),
      );

      final streamedRes = await request.send();
      if (streamedRes.statusCode == 200 || streamedRes.statusCode == 201) {
        return;
      }
    } catch (_) {}

    _fallbackProducts.insert(0, product);
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      final categoryId = await _resolveCategoryId(product.category);
      final supplierID = await _resolveSupplierId(product.supplier);
      final effectiveOffer = product.offerPrice ?? product.price;

      final response = await _client.patch(
        Uri.parse(ApiConstants.updateProduct(product.id)),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'productName': product.name,
          'supplierID': supplierID,
          'brandName': product.brand,
          'description': product.description,
          'price': product.price,
          'offerPrice': effectiveOffer,
          'stockQuantity': product.stock,
          'categoryId': categoryId,
          'unit': product.unit,
          'sku': product.sku,
          'isActive': product.isActive,
        }),
      );
      if (response.statusCode == 200) {
        return;
      }
    } catch (_) {}

    final index = _fallbackProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _fallbackProducts[index] = product;
    }
  }

  Future<bool> toggleProductStatus(ProductModel product) async {
    try {
      final response = await _client.patch(
        Uri.parse(ApiConstants.toggleProductStatus(product.id)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        if (data != null && data['isActive'] is bool) {
          return data['isActive'] as bool;
        }
        return !product.isActive;
      }
    } catch (_) {}

    final updated = product.copyWith(isActive: !product.isActive);
    await updateProduct(updated);
    return updated.isActive;
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.deleteProduct(id)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        _fallbackProducts.removeWhere((p) => p.id == id);
        return;
      }
    } catch (_) {}

    _fallbackProducts.removeWhere((p) => p.id == id);
  }
}
