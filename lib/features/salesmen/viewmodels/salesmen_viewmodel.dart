import 'package:flutter/material.dart';
import '../../../data/models/salesman_model.dart';
import '../../../data/repositories/salesmen_repository.dart';

class SalesmenViewModel extends ChangeNotifier {
  final SalesmenRepository _repository;

  SalesmenViewModel({SalesmenRepository? repository})
      : _repository = repository ?? SalesmenRepository() {
    loadSalesmen();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<SalesmanModel> _allSalesmen = [];
  String _searchQuery = '';
  String _selectedStatus = 'All status';

  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;

  final List<String> statusOptions = [
    'All status',
    'Active',
    'Inactive',
    'Pending',
  ];

  Future<void> loadSalesmen() async {
    _isLoading = true;
    notifyListeners();

    _allSalesmen = await _repository.getSalesmen();
    _isLoading = false;
    notifyListeners();
  }

  // Dynamic KPI Counts
  int get totalCount => _allSalesmen.length;
  int get activeCount => _allSalesmen.where((s) => s.status == 'Active').length;
  int get pendingCount => _allSalesmen.where((s) => s.status == 'Pending').length;
  int get inactiveCount => _allSalesmen.where((s) => s.status == 'Inactive').length;

  List<SalesmanModel> get pendingSalesmen =>
      _allSalesmen.where((s) => s.status == 'Pending').toList();

  List<SalesmanModel> get filteredSalesmen {
    return _allSalesmen.where((s) {
      // Filter by Status
      if (_selectedStatus != 'All status') {
        if (s.status.toLowerCase() != _selectedStatus.toLowerCase()) {
          return false;
        }
      } else {
        // Exclude pending from table when 'All status' is selected since they are in the banner
        if (s.status == 'Pending') return false;
      }

      // Filter by Search Query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchName = s.name.toLowerCase().contains(q);
        final matchPhone = s.phone.toLowerCase().contains(q);
        final matchEmail = s.email.toLowerCase().contains(q);
        final matchNid = s.nid.toLowerCase().contains(q);
        if (!matchName && !matchPhone && !matchEmail && !matchNid) {
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

  Future<void> toggleStatus(String id) async {
    await _repository.toggleSalesmanStatus(id);
    _allSalesmen = await _repository.getSalesmen();
    notifyListeners();
  }

  Future<void> approveSalesman(String id) async {
    await _repository.approveSalesman(id);
    _allSalesmen = await _repository.getSalesmen();
    notifyListeners();
  }

  Future<void> rejectSalesman(String id) async {
    await _repository.rejectSalesman(id);
    _allSalesmen = await _repository.getSalesmen();
    notifyListeners();
  }

  Future<void> addSalesman(SalesmanModel salesman) async {
    await _repository.addSalesman(salesman);
    _allSalesmen = await _repository.getSalesmen();
    notifyListeners();
  }

  Future<void> updateSalesman(SalesmanModel salesman) async {
    await _repository.updateSalesman(salesman);
    _allSalesmen = await _repository.getSalesmen();
    notifyListeners();
  }

  Future<void> deleteSalesman(String id) async {
    await _repository.deleteSalesman(id);
    _allSalesmen = await _repository.getSalesmen();
    notifyListeners();
  }
}
