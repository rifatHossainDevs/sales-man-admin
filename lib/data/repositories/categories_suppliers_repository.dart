import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../mock/mock_categories_suppliers_data.dart';
import '../models/category_supplier_model.dart';
import 'auth_repository.dart';

class CategoriesSuppliersRepository {
  final http.Client _client;
  final List<CategoryModel> _fallbackCategories =
      List.from(MockCategoriesSuppliersData.getCategories());
  final List<SupplierModel> _fallbackSuppliers =
      List.from(MockCategoriesSuppliersData.getSuppliers());

  CategoriesSuppliersRepository({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, Map<String, int>>> _fetchProductCounts() async {
    final categoryCounts = <String, int>{};
    final supplierCounts = <String, int>{};
    try {
      final res = await _client.get(Uri.parse(ApiConstants.products));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body)['data'] ?? [];
        for (final item in data) {
          final catId = (item['categoryId'] ?? '').toString();
          final supId = (item['supplierID'] ?? '').toString();
          if (catId.isNotEmpty) {
            categoryCounts[catId] = (categoryCounts[catId] ?? 0) + 1;
          }
          if (supId.isNotEmpty) {
            supplierCounts[supId] = (supplierCounts[supId] ?? 0) + 1;
          }
        }
      }
    } catch (_) {}
    return {'categories': categoryCounts, 'suppliers': supplierCounts};
  }

  // --- Categories CRUD ---
  Future<List<CategoryModel>> getCategories() async {
    try {
      final results = await Future.wait([
        _client.get(Uri.parse(ApiConstants.categories)),
        _fetchProductCounts(),
      ]);
      final response = results[0] as http.Response;
      final counts = (results[1] as Map<String, Map<String, int>>)['categories'] ?? {};

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((item) {
          final id = (item['_id'] ?? item['id'] ?? '').toString();
          final countFromApi = (item['productCount'] as num?)?.toInt();
          return CategoryModel(
            id: id,
            name: (item['categoryName'] ?? item['name'] ?? '').toString(),
            description: (item['description'] ?? '').toString(),
            productCount: countFromApi ?? counts[id] ?? 0,
          );
        }).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
    } catch (_) {}
    return List.from(_fallbackCategories);
  }

  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.addCategory),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'categoryName': category.name,
          'description': category.description,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final item = json.decode(response.body)['data'] ?? {};
        return CategoryModel(
          id: (item['_id'] ?? item['id'] ?? category.id).toString(),
          name: (item['categoryName'] ?? category.name).toString(),
          description: (item['description'] ?? category.description).toString(),
          productCount: (item['productCount'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (_) {}

    _fallbackCategories.add(category);
    return category;
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final response = await _client.patch(
        Uri.parse(ApiConstants.updateCategory(category.id)),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'categoryName': category.name,
          'description': category.description,
        }),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body)['data'] ?? {};
        return CategoryModel(
          id: (item['_id'] ?? item['id'] ?? category.id).toString(),
          name: (item['categoryName'] ?? category.name).toString(),
          description: (item['description'] ?? category.description).toString(),
          productCount: (item['productCount'] as num?)?.toInt() ?? category.productCount,
        );
      }
    } catch (_) {}

    final index = _fallbackCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _fallbackCategories[index] = category;
    }
    return category;
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.deleteCategory(id)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        _fallbackCategories.removeWhere((c) => c.id == id);
        return true;
      }
    } catch (_) {}

    _fallbackCategories.removeWhere((c) => c.id == id);
    return true;
  }

  // --- Suppliers CRUD ---
  Future<List<SupplierModel>> getSuppliers() async {
    try {
      final results = await Future.wait([
        _client.get(Uri.parse(ApiConstants.suppliers)),
        _fetchProductCounts(),
      ]);
      final response = results[0] as http.Response;
      final counts = (results[1] as Map<String, Map<String, int>>)['suppliers'] ?? {};

      if (response.statusCode == 200) {
        final List data = json.decode(response.body)['data'] ?? [];
        return data.map((item) {
          final id = (item['_id'] ?? item['id'] ?? '').toString();
          final countFromApi = (item['productCount'] as num?)?.toInt();
          return SupplierModel(
            id: id,
            name: (item['supplierName'] ?? item['name'] ?? '').toString(),
            location: (item['supplierAddress'] ?? item['location'] ?? '').toString(),
            phone: (item['supplierPhone'] ?? item['phone'] ?? '').toString(),
            email: (item['supplierEmail'] ?? item['email'] ?? '').toString(),
            productCount: countFromApi ?? counts[id] ?? 0,
          );
        }).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
    } catch (_) {}
    return List.from(_fallbackSuppliers);
  }

  Future<SupplierModel> addSupplier(SupplierModel supplier) async {
    // Sanitize phone for legacy Number schema compatibility if backend hasn't redeployed yet
    final numericPhone = supplier.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final phonePayload = numericPhone.isNotEmpty ? numericPhone : supplier.phone;

    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.addSupplier),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'supplierName': supplier.name,
          'supplierAddress': supplier.location,
          'supplierPhone': phonePayload,
          'supplierEmail': supplier.email,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final item = json.decode(response.body)['data'] ?? {};
        return SupplierModel(
          id: (item['_id'] ?? item['id'] ?? supplier.id).toString(),
          name: (item['supplierName'] ?? supplier.name).toString(),
          location: (item['supplierAddress'] ?? supplier.location).toString(),
          phone: (item['supplierPhone'] ?? supplier.phone).toString(),
          email: (item['supplierEmail'] ?? supplier.email).toString(),
          productCount: (item['productCount'] as num?)?.toInt() ?? 0,
        );
      }
    } catch (_) {}

    _fallbackSuppliers.add(supplier);
    return supplier;
  }

  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    final numericPhone = supplier.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final phonePayload = numericPhone.isNotEmpty ? numericPhone : supplier.phone;

    try {
      final response = await _client.patch(
        Uri.parse(ApiConstants.updateSupplier(supplier.id)),
        headers: AuthRepository.getAuthHeaders(),
        body: json.encode({
          'supplierName': supplier.name,
          'supplierAddress': supplier.location,
          'supplierPhone': phonePayload,
          'supplierEmail': supplier.email,
        }),
      );
      if (response.statusCode == 200) {
        final item = json.decode(response.body)['data'] ?? {};
        return SupplierModel(
          id: (item['_id'] ?? item['id'] ?? supplier.id).toString(),
          name: (item['supplierName'] ?? supplier.name).toString(),
          location: (item['supplierAddress'] ?? supplier.location).toString(),
          phone: (item['supplierPhone'] ?? supplier.phone).toString(),
          email: (item['supplierEmail'] ?? supplier.email).toString(),
          productCount: (item['productCount'] as num?)?.toInt() ?? supplier.productCount,
        );
      }
    } catch (_) {}

    final index = _fallbackSuppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      _fallbackSuppliers[index] = supplier;
    }
    return supplier;
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.deleteSupplier(id)),
        headers: AuthRepository.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        _fallbackSuppliers.removeWhere((s) => s.id == id);
        return true;
      }
    } catch (_) {}

    _fallbackSuppliers.removeWhere((s) => s.id == id);
    return true;
  }
}
