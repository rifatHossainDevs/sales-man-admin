import 'package:flutter/material.dart';
import '../../../data/mock/mock_phase5_data.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/salesman_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/orders_repository.dart';
import '../../../data/repositories/salesmen_repository.dart';

class SalesmanPerformanceMetric {
  final SalesmanModel salesman;
  final int orders, completedOrders, pendingOrders;
  final double sales, collected, target;
  const SalesmanPerformanceMetric({
    required this.salesman,
    required this.orders,
    required this.completedOrders,
    required this.pendingOrders,
    required this.sales,
    required this.collected,
    required this.target,
  });
  double get achievement => target == 0 ? 0 : sales / target;
}

class MonthlyPerformanceMetric {
  final String month;
  final double sales;
  final double target;
  final int orderCount;
  const MonthlyPerformanceMetric({
    required this.month,
    required this.sales,
    required this.target,
    required this.orderCount,
  });
}

class SalesmanPerformanceViewModel extends ChangeNotifier {
  final OrdersRepository _ordersRepository;
  final SalesmenRepository _salesmenRepository;
  final String? companyId;

  static const double defaultMonthlySalesTarget = 250000.0;

  SalesmanPerformanceViewModel({
    OrdersRepository? ordersRepository,
    SalesmenRepository? salesmenRepository,
    this.companyId,
  })  : _ordersRepository = ordersRepository ?? OrdersRepository(),
        _salesmenRepository = salesmenRepository ?? SalesmenRepository() {
    load();
  }

  bool isLoading = true;
  String? error;
  DateTime? startDate;
  DateTime? endDate;
  String selectedQuickPeriod = 'All Time';
  List<OrderModel> _orders = [];
  List<SalesmanModel> _salesmen = [];

  double _monthlyTargetFor(String salesmanName) {
    return MockPhase5Data.monthlySalesTargets[salesmanName] ??
        defaultMonthlySalesTarget;
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final cid = companyId ?? AuthRepository().loadSavedUserSync()?.companyId;
      final results = await Future.wait([
        _ordersRepository.getOrders(companyId: cid),
        _salesmenRepository.getSalesmen(companyId: cid),
      ]);

      _orders = results[0] as List<OrderModel>;
      final loadedSalesmen = (results[1] as List<SalesmanModel>)
          .where((s) => s.status != 'Pending')
          .toList();

      // Ensure any salesman present in live orders is also represented in the list
      final knownNames = loadedSalesmen
          .map((s) => s.name.trim().toLowerCase())
          .toSet();
      for (final order in _orders) {
        final name = order.salesmanName.trim();
        if (name.isNotEmpty && !knownNames.contains(name.toLowerCase())) {
          knownNames.add(name.toLowerCase());
          final parts = name.split(RegExp(r'\s+'));
          final initials = parts.length > 1
              ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
              : name.substring(0, name.length.clamp(1, 2)).toUpperCase();
          loadedSalesmen.add(
            SalesmanModel(
              id: 'sm_${name.hashCode}',
              name: name,
              email: '',
              phone: order.salesmanPhone,
              nid: '',
              totalOrders: 0,
              totalCollected: 0,
              lastSeen: 'Offline',
              isOnline: false,
              status: 'Active',
              appliedDate: '',
              assignedTerritory: order.retailerAddress,
              avatarInitials: initials,
            ),
          );
        }
      }

      _salesmen = loadedSalesmen;

      final dates = _orders.map(_orderDate).whereType<DateTime>().toList();
      if (dates.isNotEmpty) {
        final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
        final latest = dates.reduce((a, b) => a.isAfter(b) ? a : b);
        startDate ??= DateTime(earliest.year, earliest.month, 1);
        endDate ??= DateTime(latest.year, latest.month + 1, 0);
      } else {
        final now = DateTime.now();
        startDate ??= DateTime(now.year, now.month, 1);
        endDate ??= DateTime(now.year, now.month + 1, 0);
      }
    } catch (e) {
      error = 'Could not load performance records: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<OrderModel> get filteredOrders => _orders.where((order) {
        final date = _orderDate(order);
        return date != null &&
            (startDate == null || !date.isBefore(_day(startDate!))) &&
            (endDate == null || !date.isAfter(_day(endDate!)));
      }).toList();

  List<SalesmanPerformanceMetric> get metrics {
    return _salesmen.map((salesman) {
      final sName = salesman.name.trim().toLowerCase();
      final orders = filteredOrders
          .where((o) => o.salesmanName.trim().toLowerCase() == sName)
          .toList();
      final monthTarget = _monthlyTargetFor(salesman.name);
      final target = _targetForPeriod(monthTarget);
      return SalesmanPerformanceMetric(
        salesman: salesman,
        orders: orders.length,
        completedOrders: orders
            .where((o) =>
                o.shipmentStatus == 'Delivered' || o.paymentStatus == 'Paid')
            .length,
        pendingOrders: orders.where((o) => o.paymentStatus == 'Pending').length,
        sales: orders
            .where((o) => o.paymentStatus != 'Failed')
            .fold(0.0, (a, o) => a + o.totalAmount),
        collected: orders.fold(
          0.0,
          (a, o) =>
              a +
              (o.paymentStatus == 'Paid' && o.paidAmount == 0
                  ? o.totalAmount
                  : o.paidAmount),
        ),
        target: target,
      );
    }).toList()
      ..sort((a, b) => b.sales.compareTo(a.sales));
  }

  double get totalSales => metrics.fold(0, (s, m) => s + m.sales);
  int get totalOrders => metrics.fold(0, (s, m) => s + m.orders);
  int get completedOrders => metrics.fold(0, (s, m) => s + m.completedOrders);
  int get pendingOrders => metrics.fold(0, (s, m) => s + m.pendingOrders);
  double get totalTarget => metrics.fold(0, (s, m) => s + m.target);
  double get targetAchievement =>
      totalTarget == 0 ? 0 : totalSales / totalTarget;
  List<OrderModel> get recentOrders => filteredOrders;

  List<MonthlyPerformanceMetric> get monthlyPerformance {
    final orders = filteredOrders;
    final months = orders
        .map((order) => _orderDate(order)!)
        .map((date) => DateTime(date.year, date.month))
        .toSet()
        .toList()
      ..sort();
    final teamMonthlyTarget = _salesmen.isEmpty
        ? defaultMonthlySalesTarget
        : _salesmen.fold<double>(
            0,
            (sum, s) => sum + _monthlyTargetFor(s.name),
          );
    return months.map((month) {
      final monthOrders = orders.where((order) {
        final date = _orderDate(order)!;
        return date.year == month.year && date.month == month.month;
      }).toList();
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      final rangeStart = startDate != null && startDate!.isAfter(monthStart)
          ? startDate!
          : monthStart;
      final rangeEnd = endDate != null && endDate!.isBefore(monthEnd)
          ? endDate!
          : monthEnd;
      final visibleDays = rangeEnd.difference(rangeStart).inDays + 1;
      final dayCount = monthEnd.day;
      return MonthlyPerformanceMetric(
        month: '${_monthName(month.month)} ${month.year}',
        sales: monthOrders
            .where((o) => o.paymentStatus != 'Failed')
            .fold(0.0, (sum, o) => sum + o.totalAmount),
        target: teamMonthlyTarget * visibleDays / dayCount,
        orderCount: monthOrders.length,
      );
    }).toList();
  }

  void setDateRange(DateTimeRange range) {
    selectedQuickPeriod = 'Custom';
    startDate = _day(range.start);
    endDate = _day(range.end);
    notifyListeners();
  }

  void setQuickPeriod(String period) {
    selectedQuickPeriod = period;
    final now = _day(DateTime.now());
    if (period == 'Today') {
      startDate = now;
      endDate = now;
    } else if (period == '7D') {
      startDate = now.subtract(const Duration(days: 6));
      endDate = now;
    } else if (period == '30D') {
      startDate = now.subtract(const Duration(days: 29));
      endDate = now;
    } else {
      final dates = _orders.map(_orderDate).whereType<DateTime>().toList();
      if (dates.isNotEmpty) {
        final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
        final latest = dates.reduce((a, b) => a.isAfter(b) ? a : b);
        startDate = DateTime(earliest.year, earliest.month, 1);
        endDate = DateTime(latest.year, latest.month + 1, 0);
      } else {
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
      }
    }
    notifyListeners();
  }

  DateTime? _orderDate(OrderModel order) {
    try {
      return DateTime.parse(order.date);
    } catch (_) {
      try {
        final parts = order.date.trim().split(RegExp(r'\s+'));
        const months = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12,
        };
        return DateTime(
          int.parse(parts[2]),
          months[parts[1]]!,
          int.parse(parts[0]),
        );
      } catch (_) {
        return null;
      }
    }
  }

  DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

  double _targetForPeriod(double monthlyTarget) {
    if (startDate == null || endDate == null) return 0;
    var month = DateTime(startDate!.year, startDate!.month);
    var fractionOfMonths = 0.0;
    while (!month.isAfter(DateTime(endDate!.year, endDate!.month))) {
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      final rangeStart = startDate!.isAfter(month) ? startDate! : month;
      final rangeEnd = endDate!.isBefore(monthEnd) ? endDate! : monthEnd;
      if (!rangeEnd.isBefore(rangeStart)) {
        fractionOfMonths +=
            (rangeEnd.difference(rangeStart).inDays + 1) / monthEnd.day;
      }
      month = DateTime(month.year, month.month + 1);
    }
    return monthlyTarget * fractionOfMonths;
  }

  String _monthName(int month) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month - 1];
}
