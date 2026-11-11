import 'package:flutter/material.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/payments_repository.dart';

class SalesmanCollectionSummary {
  final String name;
  final double amount;
  final double percentageOfMax;

  const SalesmanCollectionSummary({
    required this.name,
    required this.amount,
    required this.percentageOfMax,
  });
}

class PaymentsViewModel extends ChangeNotifier {
  final PaymentsRepository _repository;

  PaymentsViewModel({PaymentsRepository? repository})
    : _repository = repository ?? PaymentsRepository() {
    loadPayments();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<PaymentModel> _allPayments = [];
  String _searchQuery = '';
  String _selectedStatus = 'All status';

  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  final List<String> statusOptions = [
    'All status',
    'Paid',
    'Pending',
    'Failed',
  ];

  Future<void> loadPayments() async {
    _isLoading = true;
    notifyListeners();

    _allPayments = await _repository.getPayments();
    _isLoading = false;
    notifyListeners();
  }

  double get totalCollected => _allPayments
      .where((p) => p.status == 'Paid')
      .fold(0.0, (sum, p) => sum + p.amount);

  double get pendingAmount => _allPayments
      .where((p) => p.status == 'Pending')
      .fold(0.0, (sum, p) => sum + p.amount);

  int get failedCount => _allPayments.where((p) => p.status == 'Failed').length;

  List<SalesmanCollectionSummary> get salesmanCollections {
    final totals = <String, double>{};
    for (final payment in _allPayments.where((p) => p.status == 'Paid')) {
      totals.update(
        payment.salesmanName,
        (value) => value + payment.amount,
        ifAbsent: () => payment.amount,
      );
    }
    final maxAmount = totals.values.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    return totals.entries
        .map(
          (entry) => SalesmanCollectionSummary(
            name: entry.key,
            amount: entry.value,
            percentageOfMax: maxAmount == 0 ? 0 : entry.value / maxAmount,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  List<PaymentModel> get filteredPayments {
    return _allPayments.where((p) {
      if (_selectedStatus != 'All status' && p.status != _selectedStatus) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTrx = p.trxId.toLowerCase().contains(q);
        final matchInv = p.invoiceNo.toLowerCase().contains(q);
        final matchSales = p.salesmanName.toLowerCase().contains(q);
        final matchRet = p.retailerName.toLowerCase().contains(q);
        if (!matchTrx && !matchInv && !matchSales && !matchRet) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  Future<void> addPayment(PaymentModel payment) async {
    await _repository.addPayment(payment);
    _allPayments = await _repository.getPayments();
    notifyListeners();
  }

  Future<void> updatePaymentStatus(String id, String status) async {
    await _repository.updatePaymentStatus(id, status);
    _allPayments = await _repository.getPayments();
    notifyListeners();
  }
}
