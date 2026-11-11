import 'package:flutter/material.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/orders_repository.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrdersRepository _repository;

  OrdersViewModel({OrdersRepository? repository})
      : _repository = repository ?? OrdersRepository() {
    loadOrders();
  }

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedSalesman = 'All salesmen';
  OrderModel? _selectedOrder;

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedSalesman => _selectedSalesman;
  OrderModel? get selectedOrder => _selectedOrder;

  int get totalOrdersCount => _orders.length;
  int get pendingOrdersCount => _orders.where((o) => o.paymentStatus == 'Pending').length;
  int get paidOrdersCount => _orders.where((o) => o.paymentStatus == 'Paid').length;
  int get failedOrdersCount => _orders.where((o) => o.paymentStatus == 'Failed').length;

  List<String> get salesmenOptions {
    final set = _orders.map((o) => o.salesmanName).toSet().toList();
    set.sort();
    return ['All salesmen', ...set];
  }

  List<OrderModel> get filteredOrders {
    return _orders.where((order) {
      final matchesSearch = _searchQuery.isEmpty ||
          order.invoiceNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.retailerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.salesmanName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatus == 'All' ||
          order.paymentStatus.toLowerCase() == _selectedStatus.toLowerCase();

      final matchesSalesman = _selectedSalesman == 'All salesmen' ||
          order.salesmanName == _selectedSalesman;

      return matchesSearch && matchesStatus && matchesSalesman;
    }).toList();
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    _orders = await _repository.getOrders();
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSelectedSalesman(String salesman) {
    _selectedSalesman = salesman;
    notifyListeners();
  }

  void selectOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  Future<void> updateOrderStatus(
    String orderId, {
    String? paymentStatus,
    String? shipmentStatus,
    double? paidAmount,
  }) async {
    await _repository.updateOrderStatus(
      orderId,
      paymentStatus: paymentStatus,
      shipmentStatus: shipmentStatus,
      paidAmount: paidAmount,
    );
    await loadOrders();
    if (_selectedOrder != null && _selectedOrder!.id == orderId) {
      _selectedOrder = await _repository.getOrderById(orderId);
    }
  }
}
