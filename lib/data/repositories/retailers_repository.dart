import '../mock/mock_retailers_data.dart';
import '../models/retailer_model.dart';

class RetailersRepository {
  final List<RetailerModel> _retailers = List.from(MockRetailersData.retailers);

  Future<List<RetailerModel>> getRetailers() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_retailers);
  }

  Future<void> addRetailer(RetailerModel retailer) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _retailers.insert(0, retailer);
  }

  Future<void> updateRetailer(RetailerModel retailer) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _retailers.indexWhere((r) => r.id == retailer.id);
    if (index != -1) {
      _retailers[index] = retailer;
    }
  }

  Future<void> deleteRetailer(String retailerId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _retailers.removeWhere((r) => r.id == retailerId);
  }
}
