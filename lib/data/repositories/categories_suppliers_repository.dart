import '../mock/mock_categories_suppliers_data.dart';
import '../models/category_supplier_model.dart';

class CategoriesSuppliersRepository {
  final List<CategoryModel> _categories = List.from(MockCategoriesSuppliersData.getCategories());
  final List<SupplierModel> _suppliers = List.from(MockCategoriesSuppliersData.getSuppliers());

  // --- Categories CRUD ---
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_categories);
  }

  Future<CategoryModel> addCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _categories.add(category);
    return category;
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
    return category;
  }

  Future<bool> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _categories.removeWhere((c) => c.id == id);
    return true;
  }

  // --- Suppliers CRUD ---
  Future<List<SupplierModel>> getSuppliers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_suppliers);
  }

  Future<SupplierModel> addSupplier(SupplierModel supplier) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _suppliers.add(supplier);
    return supplier;
  }

  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (index != -1) {
      _suppliers[index] = supplier;
    }
    return supplier;
  }

  Future<bool> deleteSupplier(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _suppliers.removeWhere((s) => s.id == id);
    return true;
  }
}
