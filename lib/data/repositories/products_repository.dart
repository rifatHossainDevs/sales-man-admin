import '../models/product_model.dart';
import '../mock/mock_products_data.dart';

class ProductsRepository {
  final List<ProductModel> _products = MockProductsData.getInitialProducts();

  Future<List<ProductModel>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_products);
  }

  Future<void> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _products.insert(0, product);
  }

  Future<void> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }

  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _products.removeWhere((p) => p.id == id);
  }
}
