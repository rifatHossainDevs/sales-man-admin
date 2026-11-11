import 'package:flutter/material.dart';
import '../../../data/models/category_supplier_model.dart';
import '../../../data/repositories/categories_suppliers_repository.dart';

class CategoriesSuppliersViewModel extends ChangeNotifier {
  final CategoriesSuppliersRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<CategoryModel> _categories = [];
  List<SupplierModel> _suppliers = [];

  CategoriesSuppliersViewModel({CategoriesSuppliersRepository? repository})
      : _repository = repository ?? CategoriesSuppliersRepository() {
    loadData();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<CategoryModel> get categories {
    if (_searchQuery.isEmpty) return _categories;
    final query = _searchQuery.toLowerCase();
    return _categories.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query);
    }).toList();
  }

  List<SupplierModel> get suppliers {
    if (_searchQuery.isEmpty) return _suppliers;
    final query = _searchQuery.toLowerCase();
    return _suppliers.where((s) {
      return s.name.toLowerCase().contains(query) ||
          s.location.toLowerCase().contains(query) ||
          s.phone.toLowerCase().contains(query) ||
          s.email.toLowerCase().contains(query);
    }).toList();
  }

  int get totalCategoriesCount => _categories.length;
  int get totalSuppliersCount => _suppliers.length;

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cats = await _repository.getCategories();
      final sups = await _repository.getSuppliers();
      _categories = cats;
      _suppliers = sups;
    } catch (e) {
      _errorMessage = 'Failed to load categories and suppliers: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // --- Category Actions ---
  Future<bool> addCategory(CategoryModel category) async {
    try {
      final newCat = await _repository.addCategory(category);
      _categories.add(newCat);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(CategoryModel category) async {
    try {
      final updated = await _repository.updateCategory(category);
      final idx = _categories.indexWhere((c) => c.id == updated.id);
      if (idx != -1) {
        _categories[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update category: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      final success = await _repository.deleteCategory(id);
      if (success) {
        _categories.removeWhere((c) => c.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete category: $e';
      notifyListeners();
      return false;
    }
  }

  // --- Supplier Actions ---
  Future<bool> addSupplier(SupplierModel supplier) async {
    try {
      final newSup = await _repository.addSupplier(supplier);
      _suppliers.add(newSup);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add supplier: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSupplier(SupplierModel supplier) async {
    try {
      final updated = await _repository.updateSupplier(supplier);
      final idx = _suppliers.indexWhere((s) => s.id == updated.id);
      if (idx != -1) {
        _suppliers[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update supplier: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSupplier(String id) async {
    try {
      final success = await _repository.deleteSupplier(id);
      if (success) {
        _suppliers.removeWhere((s) => s.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete supplier: $e';
      notifyListeners();
      return false;
    }
  }
}
