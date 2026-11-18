import 'package:flutter/material.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/models/salesman_collection_model.dart';
import '../../../data/repositories/payments_repository.dart';

class PaymentsViewModel extends ChangeNotifier {
  final PaymentsRepository _repository;
  final String? companyId;

  PaymentsViewModel({PaymentsRepository? repository, this.companyId})
    : _repository = repository ?? PaymentsRepository() {
    loadPayments();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<PaymentModel> _allPayments = [];
  List<SalesmanCollectionModel> _salesmanCollections = [];
  Map<String, dynamic> _kpiSummary = {};

  String _searchQuery = '';
  String _selectedStatus = 'All status';

  // Pagination (10 per page)
  int _currentPage = 1;
  final int _pageSize = 10;

  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  final List<String> statusOptions = [
    'All status',
    'Paid',
    'Pending',
    'Failed',
  ];

  Future<void> loadPayments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchKpiSummary(companyId: companyId),
        _repository.fetchCollectionsBySalesman(companyId: companyId),
        _repository.getPayments(companyId: companyId, page: 1, limit: 200),
      ]);

      _kpiSummary = results[0] as Map<String, dynamic>;
      _salesmanCollections = results[1] as List<SalesmanCollectionModel>;
      _allPayments = results[2] as List<PaymentModel>;
    } catch (_) {
      _allPayments = await _repository.getPayments(companyId: companyId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dynamic KPI Cards
  String get monthName => _kpiSummary['monthName'] ?? 'November';
  double get collectedMonthValue => (_kpiSummary['collectedMonthValue'] as num?)?.toDouble() ?? 482500.0;
  String get growthTrendText => _kpiSummary['growthTrendText'] ?? 'Initial deployment month';

  double get totalCollected {
    if (_allPayments.isNotEmpty) {
      return _allPayments
          .where((p) => p.status == 'Paid')
          .fold<double>(0.0, (sum, p) => sum + p.amount);
    }
    return (_kpiSummary['cashCollected'] as num?)?.toDouble() ?? 0.0;
  }
  double get pendingAmount => (_kpiSummary['cashPending'] as num?)?.toDouble() ?? 35400.0;
  double get failedAmount => (_kpiSummary['failedAmount'] as num?)?.toDouble() ?? 12500.0;
  int get failedCount => (_kpiSummary['failedCount'] as num?)?.toInt() ?? 2;

  List<SalesmanCollectionModel> get salesmanCollections => _salesmanCollections;

  List<PaymentModel> get allFilteredPayments {
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

  int get totalPages {
    final count = allFilteredPayments.length;
    if (count == 0) return 1;
    return (count / _pageSize).ceil();
  }

  List<PaymentModel> get filteredPayments {
    final list = allFilteredPayments;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= list.length) {
      return list.skip(0).take(_pageSize).toList();
    }
    return list.skip(startIndex).take(_pageSize).toList();
  }

  void setCurrentPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    _currentPage = 1;
    notifyListeners();
  }

  Future<void> addPayment(PaymentModel payment) async {
    await _repository.addPayment(payment);
    await loadPayments();
  }

  Future<void> updatePaymentStatus(String id, String status) async {
    await _repository.updatePaymentStatus(id, status);
    await loadPayments();
  }
}
