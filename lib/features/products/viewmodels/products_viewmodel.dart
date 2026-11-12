import 'package:flutter/material.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/products_repository.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductsRepository _repository;

  ProductsViewModel({ProductsRepository? repository})
      : _repository = repository ?? ProductsRepository() {
    loadProducts();
  }

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All categories';
  String _selectedSupplier = 'All suppliers';
  String _selectedStatus = 'All status';

  // Specific product row loading states for toggle
  final Set<String> _updatingProductIds = {};

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedSupplier => _selectedSupplier;
  String get selectedStatus => _selectedStatus;

  bool isProductUpdating(String id) => _updatingProductIds.contains(id);

  int get totalProducts => _products.length;
  int get activeProducts => _products.where((p) => p.isActive).length;
  int get lowStockProducts => _products.where((p) => p.stock > 0 && p.stock <= 15).length;
  int get outOfStockProducts => _products.where((p) => p.stock == 0).length;

  List<String> get categories {
    final list = _products.map((p) => p.category).toSet().toList();
    list.sort();
    return ['All categories', ...list];
  }

  List<String> get suppliers {
    final list = _products.map((p) => p.supplier).toSet().toList();
    list.sort();
    return ['All suppliers', ...list];
  }

  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.sku.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All categories' ||
          product.category == _selectedCategory;

      final matchesSupplier = _selectedSupplier == 'All suppliers' ||
          product.supplier == _selectedSupplier;

      final matchesStatus = _selectedStatus == 'All status' ||
          (_selectedStatus == 'Active' && product.isActive) ||
          (_selectedStatus == 'Inactive' && !product.isActive);

      return matchesSearch && matchesCategory && matchesSupplier && matchesStatus;
    }).toList();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    _products = await _repository.getProducts();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedSupplier(String supplier) {
    _selectedSupplier = supplier;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product) async {
    await _repository.addProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _repository.updateProduct(product);
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _repository.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // 5. Localized Product Status Toggle without full-page reloading
  Future<void> toggleProductStatus(ProductModel product) async {
    _updatingProductIds.add(product.id);
    notifyListeners();

    try {
      final updated = product.copyWith(isActive: !product.isActive);
      await _repository.updateProduct(updated);

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updated;
      }
    } catch (e) {
      debugPrint('Failed to toggle product status: $e');
    } finally {
      _updatingProductIds.remove(product.id);
      notifyListeners();
    }
  }
}
