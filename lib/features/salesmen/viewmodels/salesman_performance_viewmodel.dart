import 'package:flutter/material.dart';
import '../../../data/mock/mock_phase5_data.dart';
import '../../../data/mock/mock_orders_data.dart';
import '../../../data/mock/mock_salesmen_data.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/salesman_model.dart';

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
  SalesmanPerformanceViewModel() {
    load();
  }
  bool isLoading = true;
  String? error;
  DateTime? startDate;
  DateTime? endDate;
  List<OrderModel> _orders = [];
  List<SalesmanModel> _salesmen = [];

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      _orders = MockOrdersData.getInitialOrders();
      _salesmen = MockSalesmenData.salesmen
          .where((s) => s.status != 'Pending')
          .toList();
      final dates = _orders.map(_orderDate).whereType<DateTime>().toList();
      if (dates.isNotEmpty) {
        startDate ??= dates.reduce((a, b) => a.isBefore(b) ? a : b);
        endDate ??= dates.reduce((a, b) => a.isAfter(b) ? a : b);
      }
    } catch (_) {
      error = 'Could not load performance records.';
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
      final orders = filteredOrders
          .where((o) => o.salesmanName == salesman.name)
          .toList();
      final monthTarget =
          MockPhase5Data.monthlySalesTargets[salesman.name] ?? 0;
      final target = _targetForPeriod(monthTarget);
      return SalesmanPerformanceMetric(
        salesman: salesman,
        orders: orders.length,
        completedOrders: orders
            .where((o) => o.shipmentStatus == 'Delivered')
            .length,
        pendingOrders: orders.where((o) => o.paymentStatus == 'Pending').length,
        sales: orders
            .where((o) => o.paymentStatus != 'Failed')
            .fold(0.0, (a, o) => a + o.totalAmount),
        collected: orders.fold(0.0, (a, o) => a + o.paidAmount),
        target: target,
      );
    }).toList()..sort((a, b) => b.sales.compareTo(a.sales));
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
    final months =
        orders
            .map((order) => _orderDate(order)!)
            .map((date) => DateTime(date.year, date.month))
            .toSet()
            .toList()
          ..sort();
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
      final monthlyTarget = MockPhase5Data.monthlySalesTargets.values
          .fold<double>(0, (sum, value) => sum + value);
      return MonthlyPerformanceMetric(
        month: '${_monthName(month.month)} ${month.year}',
        sales: monthOrders
            .where((o) => o.paymentStatus != 'Failed')
            .fold(0.0, (sum, o) => sum + o.totalAmount),
        target: monthlyTarget * visibleDays / dayCount,
        orderCount: monthOrders.length,
      );
    }).toList();
  }

  void setDateRange(DateTimeRange range) {
    startDate = _day(range.start);
    endDate = _day(range.end);
    notifyListeners();
  }

  DateTime? _orderDate(OrderModel order) {
    try {
      return DateTime.parse(order.date);
    } catch (_) {
      try {
        final parts = order.date.split(' ');
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
