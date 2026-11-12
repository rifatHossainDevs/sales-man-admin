import 'package:web/web.dart' as web;
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
  DateTime? _selectedDate;
  OrderModel? _selectedOrder;

  // Pagination (10 per page)
  int _currentPage = 1;
  final int _pageSize = 10;

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedStatus => _selectedStatus;
  String get selectedSalesman => _selectedSalesman;
  DateTime? get selectedDate => _selectedDate;
  OrderModel? get selectedOrder => _selectedOrder;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  int get totalOrdersCount => _orders.length;
  int get pendingOrdersCount => _orders.where((o) => o.paymentStatus == 'Pending').length;
  int get paidOrdersCount => _orders.where((o) => o.paymentStatus == 'Paid').length;
  int get failedOrdersCount => _orders.where((o) => o.paymentStatus == 'Failed').length;

  List<String> get salesmenOptions {
    final set = _orders.map((o) => o.salesmanName).toSet().toList();
    set.sort();
    return ['All salesmen', ...set];
  }

  List<OrderModel> get allFilteredOrders {
    return _orders.where((order) {
      final matchesSearch = _searchQuery.isEmpty ||
          order.invoiceNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.retailerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.salesmanName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatus == 'All' ||
          order.paymentStatus.toLowerCase() == _selectedStatus.toLowerCase();

      final matchesSalesman = _selectedSalesman == 'All salesmen' ||
          order.salesmanName == _selectedSalesman;

      final matchesDate = _selectedDate == null || _matchOrderDate(order.date, _selectedDate!);

      return matchesSearch && matchesStatus && matchesSalesman && matchesDate;
    }).toList();
  }

  int get totalPages {
    final count = allFilteredOrders.length;
    if (count == 0) return 1;
    return (count / _pageSize).ceil();
  }

  List<OrderModel> get filteredOrders {
    final list = allFilteredOrders;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= list.length) {
      return list.skip(0).take(_pageSize).toList();
    }
    return list.skip(startIndex).take(_pageSize).toList();
  }

  bool _matchOrderDate(String dateStr, DateTime targetDate) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final targetMonth = months[targetDate.month - 1];
    return dateStr.contains(targetMonth) || dateStr.contains('${targetDate.day}');
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
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedSalesman(String salesman) {
    _selectedSalesman = salesman;
    _currentPage = 1;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    _currentPage = 1;
    notifyListeners();
  }

  void setCurrentPage(int page) {
    if (page < 1 || page > totalPages) return;
    _currentPage = page;
    notifyListeners();
  }

  void selectOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void exportOrdersCsv() {
    final list = allFilteredOrders;
    final StringBuffer csv = StringBuffer();
    csv.writeln('Invoice No,Retailer,Salesman,Date,Total Amount,Paid Amount,Due Amount,Payment Status,Shipment Status');
    for (final o in list) {
      csv.writeln('"${o.invoiceNo}","${o.retailerName}","${o.salesmanName}","${o.date}",${o.totalAmount},${o.paidAmount},${o.dueAmount},"${o.paymentStatus}","${o.shipmentStatus}"');
    }

    try {
      final bytes = Uri.encodeComponent(csv.toString());
      final url = 'data:text/csv;charset=utf-8,$bytes';
      web.window.open(url, '_blank');
    } catch (_) {}
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
