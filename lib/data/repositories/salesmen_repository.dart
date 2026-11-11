import '../mock/mock_salesmen_data.dart';
import '../models/salesman_model.dart';

class SalesmenRepository {
  final List<SalesmanModel> _salesmen = List.from(MockSalesmenData.salesmen);

  Future<List<SalesmanModel>> getSalesmen() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_salesmen);
  }

  Future<void> addSalesman(SalesmanModel salesman) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _salesmen.insert(0, salesman);
  }

  Future<void> updateSalesman(SalesmanModel salesman) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _salesmen.indexWhere((s) => s.id == salesman.id);
    if (index != -1) {
      _salesmen[index] = salesman;
    }
  }

  Future<void> toggleSalesmanStatus(String salesmanId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _salesmen.indexWhere((s) => s.id == salesmanId);
    if (index != -1) {
      final current = _salesmen[index];
      final newStatus = current.status == 'Active' ? 'Inactive' : 'Active';
      _salesmen[index] = current.copyWith(status: newStatus);
    }
  }

  Future<void> approveSalesman(String salesmanId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _salesmen.indexWhere((s) => s.id == salesmanId);
    if (index != -1) {
      _salesmen[index] = _salesmen[index].copyWith(status: 'Active');
    }
  }

  Future<void> rejectSalesman(String salesmanId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Reject button removes the pending registration from the local list
    _salesmen.removeWhere((s) => s.id == salesmanId);
  }

  Future<void> deleteSalesman(String salesmanId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _salesmen.removeWhere((salesman) => salesman.id == salesmanId);
  }
}
